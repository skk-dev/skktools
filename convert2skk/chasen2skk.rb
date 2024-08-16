#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Keywords: japanese, dictionary
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
## Free Software Foundation Inc., 51 Franklin St, Fifth Floor, Boston,
## MA 02110-1301, USA.
##
### Commentary:
##
### Instruction:
##
## This script tries to extract SKK pairs from the output of ChaSen.
##
## % chasen | chasen2skk.rb
## or
## % mecab -Ochasen | chasen2skk.rb
##
##
## skkdictools.rb required.
##
## TODO: pick up compound-verbs, eg. 「舞い散る」
## 舞い    マイ    舞う    動詞-自立       五段・ワ行促音便        連用形
## 散る    チル    散る    動詞-自立       五段・ラ行      基本形
##

require_relative 'skkdictools'
require 'optparse'

opt = OptionParser.new

katakana_words = false
#katakana_majiri = false
#append_goohits = false
keyword = ""
#fetch_from_goo = false
append_notes = false
allow_noun_chains = true
#allow_verb_chains = true
handle_prefix = true
min_length = 2 * 2
max_length = 100 * 2
encoding = "euc-jis-2004"

# -g might be a bad idea; better eliminate pairs already in SKK-JISYO.L first
#opt.on('-g', 'append goo hit numbers') { append_goohits = true }
opt.on('-k', '--extract-katakana', 'extract katakana words (if WORD not given)') { katakana_words = true }
#opt.on('-K', 'extract words containing katakana') { katakana_majiri = true }
opt.on('-m VAL', '--min-length=VAL', 'ignore words less than VAL letters') { |v| min_length = v.to_i * 2 }
opt.on('-M VAL', '--max-length=VAL', 'ignore words more than VAL letters') { |v| max_length = v.to_i * 2 }
opt.on('-n', '--append-notes', 'append grammatical notes') { append_notes = true }
opt.on('-N', '--disallow-noun-chains', 'disallow noun chains containing hiragana') { allow_noun_chains = false }
opt.on('-P', '--ignore-prefixes', 'don\'t take prefixes into consideration') { handle_prefix = false }
opt.on('-w WORD', '--extract-word=WORD', 'extract pairs containing WORD') { |v| keyword = v }
#opt.on('-W WORD', 'query goo and extract pairs containing WORD') { |v| keyword = v; fetch_from_goo = true }
opt.on('-8', '--utf8', 'read and write in utf8') { encoding = "utf-8" }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption
  print "'#{$0} -h' for help.\n"
  exit 1
end

#keyword_pat = Regexp.compile("[亜-熙]*#{keyword}[亜-熙]*")

count = 0
#key = word = last_key = last_word = last_part = ""
key = word = last_part = ""
poisoned = terminate = false
Encoding.default_external = encoding
STDOUT.set_encoding(encoding, "utf-8")

while gets
  $_.encode!("utf-8")
  midasi, yomi, _root, part, _conj = $_.split("	", 5)
  #if midasi !~ /^[亜-熙ァ-ンヴー]+$/ || terminate
  if (midasi !~ /^[亜-熙ァ-ンヴー々]+$/ &&
      (!allow_noun_chains || part !~ /名詞/ || part =~ /非自立/ ||
       midasi !~ /^[亜-熙ァ-ンヴー々ぁ-ん]+$/ )) || terminate
    #if (midasi !~ /^[亜-熙ァ-ンヴー]+$/ && conj !~ /連用形/) || terminate
    #next if count < 1
    if count < 1
      next if !handle_prefix
      if part =~ /接頭詞/
        # kludge - keep prefix w/o increasing count (cf.「ご立派」「お味噌」)
        key = yomi.to_hiragana
        word = midasi
        last_part = part
        #elsif part =~ /自立/ && conj =~ /連用形/
        #  hogehoge
      else
        key = word = last_part = ""
      end
      next
    end

    if midasi =~ /^[^亜-熙ァ-ンヴー々]+$/ && !terminate
      # nothing
    else
      if part =~ /接続詞|接頭詞|副詞[^可]/
        # nothing - decline some parts
      elsif midasi =~ /並び|及び/
        # nothing - (HACK) decline conjonctions that ChaSen overlooks
      elsif midasi =~ /^[ぁ-ん]+[亜-熙ァ-ンヴー々]+/
        # nothing - this applies to quasi-words such as:
        # に関する        ニカンスル      に関する        助詞-格助詞-連語
      else
        key += yomi.to_hiragana
        word += midasi
        last_part = part
        # asayaKify here?
      end
    end

    if word =~ /^[ぁ-んー]+$/
      # nothing
    elsif !katakana_words && word =~ /^[ァ-ンヴー]+$/
      # nothing
    elsif !keyword.empty? && !word.include?(keyword)
      # nothing
    elsif poisoned || word.size < min_length || word.size > max_length
      # nothing
    else
      print_pair(key, word, nil, append_notes ? "<autogen>,#{last_part.chomp}" : nil)
    end

    key = word = last_part = ""
    poisoned = terminate = false
    count = 0

  else
    if count > 0 && part =~ /接続詞|接頭詞|副詞[^可]/
      terminate = true
      redo
    elsif count == 0 && part =~ /接尾/
      # avoid generating 「回大会」 from 「第３回大会」
      # 回      カイ    回      名詞-接尾-助数詞
      key = word = last_part = ""
      next
    end
    count += 1
    key += yomi.to_hiragana
    word += midasi
    last_part = part
    poisoned = true if part =~ /未知語/
  end
end
