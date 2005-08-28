#!/usr/local/bin/ruby -Ke
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: skkdictools.rb,v 1.4 2005/08/28 17:51:47 skk-cvs Exp $
## Keywords: japanese, dictionary
## Last Modified: $Date: 2005/08/28 17:51:47 $
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program, see the file COPYING.  If not, write to the
## Free Software Foundation Inc., 59 Temple Place - Suite 330, Boston,
## MA 02111-1307, USA.
##
### Commentary:
## Based on registdic.cgi and skkform.rb by Mikio NAKAJIMA.
## (Prolly we'd better integrate skkdictools.rb and skkform.rb into one?)
##
### Instruction:
##
## A library packed with small gadgets useful to handle skk dictionary.
##
## Most of scripts under tools/filters and some under tools/convert2skk
## require this file to be installed in one of the ruby loadpaths.
##

#require 'jcode'
#require 'kconv'

## for Goo::search
#require 'cgi'
#require 'socket'
#require 'timeout'

# exceptions:
#	["ち" , "c"] (eg. 「にいちゃん /兄ちゃん/」→「にいc /兄/」)
#	["っ" , "p"] (eg. 「つっぱる /突っぱる/」→「つp /突/」)
#	["っ" , "c"] (eg. 「さきっちょ /先っちょ/」→「さきc /先/」)
GyakuhikiOkurigana = [
  ["あ" , "a"],
  ["ば" , "b"], ["び" , "b"], ["ぶ" , "b"], ["べ" , "b"], ["ぼ" , "b"],
  ["だ" , "d"], ["ぢ" , "d"], ["づ" , "d"], ["で" , "d"], ["ど" , "d"],
  ["え" , "e"],
  ["が" , "g"], ["ぎ" , "g"], ["ぐ" , "g"], ["げ" , "g"], ["ご" , "g"],
  ["は" , "h"], ["ひ" , "h"], ["ふ" , "h"], ["へ" , "h"], ["ほ" , "h"],
  ["い" , "i"],
  ["じ" , "j"],
  ["か" , "k"], ["き" , "k"], ["く" , "k"], ["け" , "k"], ["こ" , "k"],
  ["ま" , "m"], ["み" , "m"], ["む" , "m"], ["め" , "m"], ["も" , "m"],
  ["な" , "n"], ["に" , "n"], ["ぬ" , "n"], ["ね" , "n"], ["の" , "n"], ["ん" , "n"],
  ["お" , "o"],
  ["ぱ" , "p"], ["ぴ" , "p"], ["ぷ" , "p"], ["ぺ" , "p"], ["ぽ" , "p"],
  ["ら" , "r"], ["り" , "r"], ["る" , "r"], ["れ" , "r"], ["ろ" , "r"],
  ["さ" , "s"], ["し" , "s"], ["す" , "s"], ["せ" , "s"], ["そ" , "s"],
  ["た" , "t"], ["ち" , "t"], ["っ" , "t"], ["つ" , "t"], ["て" , "t"], ["と" , "t"],
  ["う" , "u"],
  ["わ" , "w"], ["を" , "w"],
  ["ぁ" , "x"], ["ぃ" , "x"], ["ぅ" , "x"], ["ぇ" , "x"], ["ぉ" , "x"],
  ["ゃ" , "x"], ["ゅ" , "x"], ["ょ" , "x"], ["ゎ" , "x"], ["ゐ" , "x"], ["ゑ" , "x"],
  ["ゃ" , "y"], ["や" , "y"], ["ゅ" , "y"], ["ゆ" , "y"], ["ょ" , "y"], ["よ" , "y"],
  ["ざ" , "z"], ["じ" , "z"], ["ず" , "z"], ["ぜ" , "z"], ["ぞ" , "z"]
]

# ("あさやけ", "朝焼け") => ("あさやk", "朝焼", "け")
# ("ねこ", "猫") => nil
def okuri_nasi_to_ari(midasi, candidate)
  return nil if (/(.*[^ぁ-んー])([ぁ-ん]+)$/ !~ candidate)
  can_prefix = $1
  can_postfix = $2
  return nil if !(can_prefix && can_postfix && (/(.+)#{can_postfix}$/ =~ midasi))
  key_prefix = $1
  key_kana_postfix = GyakuhikiOkurigana.assoc(can_postfix.split('')[0])
  return nil if key_kana_postfix.empty?

  okuri = key_kana_postfix[1]
  # handle some exceptions
  okuri = "c" if can_postfix =~ /^っち/ || can_postfix =~ /^ち[ゃゅょ]/
  okuri = "p" if can_postfix =~ /^っ[ぱ-ぽ]/
  okuri = "k" if can_postfix =~ /^っ[か-こ]/

  return key_prefix + okuri, can_prefix, can_postfix
end

def print_pair(key, candidate, annotation = nil, comment = nil)
  if !annotation.nil? && !annotation.empty?
    if comment.nil? || comment.empty?
      print "#{key} /#{candidate};#{annotation}/\n"
    else
      print "#{key} /#{candidate};#{annotation}‖#{comment}/\n"
    end
  else
    if comment.nil? || comment.empty?
      print "#{key} /#{candidate}/\n"
    else
      print "#{key} /#{candidate};‖#{comment}/\n"
    end
  end
end

# borrowed from skkform.rb
class String
  def to_katakana
    self.gsub(/う゛/, '\\1ヴ').tr('ぁ-ん', 'ァ-ン')
  end

  def to_hiragana
    self.gsub(/ヴ/, 'う゛').tr('ァ-ン', 'ぁ-ん')
  end

  def cut_off_prefix_postfix
    self.sub(/^[<>\?]([ーぁ-ん]+)$/, '\1').sub(/^([ーぁ-ん]+)[<>\?]$/, '\1')
  end

  # from 「オブジェクト指向スクリプト言語ruby」p121
  def csv_split(delimiter = ',')
    csv = []
    data = ""
    self.split(delimiter).each do |d|
      if data.empty?
	data = d
      else
	data += delimiter + d
      end
      if /^"/ =~ data
	if /[^"]"$/ =~ data or '""' == data
	  csv << data.sub(/^"(.*)"$/, '\1').gsub(/""/, '"')
	  data = ''
	end
      else
	csv << d
	data = ''
      end
    end
    raise "cannot decode CSV\n" unless data.empty?
    csv
  end

  def csv_quote
    self.gsub(/"/, '\\"').sub(/.*,.*/, '"\&"')
  end

  def csv_unquote
    self.sub(/^\"(.+)\"$/, '\1')
  end

  # 09/30/04 => 04/09/30
  def mdy2ymd
    self.sub(/^([0-9]*)\/([0-9]*)\/([0-9]*)/, '\3/\1/\2')
  end

  def parse_skk_entry
    midasi, rest = self.chop.split(" /", 2)
    tokens = rest.sub(/\/\[.*/, "").split("/") if !rest.nil?
    return midasi, tokens
  end

  def skk_split_tokens(delimiter = '‖')
    word, annotation = self.split(";", 2)
    return word, nil, nil if annotation.nil?
    return word, annotation, nil if delimiter.nil?
    annotation, comment = annotation.split(delimiter, 2)
    return word, annotation, comment
  end
end

class Goo
  def search(key)
    hits = tries = 0
    key = Kconv.toeuc(key)
    key = CGI::escape(key)
    timeout(20) {
      begin
	tries += 1
	sock = TCPSocket.open("search.goo.ne.jp", 80)
	sock.printf("GET /web.jsp?DC=1&MT=\"%s\" HTTP/1.0\r\n\r\n", key)
	sock.readlines.each do |line|
	  line = Kconv.toeuc(line)
	  if (/<b>約*([,0-9]+)<\/b>件中/ =~ line)
	    hits = $1.gsub(/,/, '').to_i
	    return hits if hits > 0
	  # 0hits, or system error?
	  elsif (/<br>該当する検索結果が見当たりません。/ =~ line)
	  #elsif (/<br>検索システムから検索結果を正常に取得できなかった可能性があります。/ =~ line) next
	    return 0
	  end
	end
      ensure
	sock.close if sock
      end while tries < 3 && hits < 1
    }
    "unknown"
  end
end

