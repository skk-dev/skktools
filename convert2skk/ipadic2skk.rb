#!/usr/bin/env ruby -E euc-jis-2004:utf-8
# -*- coding: utf-8 -*-

## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: ipadic2skk.rb,v 1.4 2013/05/26 09:47:48 skk-cvs Exp $
## Keywords: japanese, dictionary
## Last Modified: $Date: 2013/05/26 09:47:48 $
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
### Instruction:
##
## This script tries to convert IPADIC dictionary files into skk ones.
##
##     % ipadic2skk.rb ipadic-2.7.0/Noun.name.dic | skkdic-expr2 > SKK-JISYO.ipadic.jinmei
##
## would yield a lot of nifty jinmei additions.
##
##     % ipadic2skk.rb -Ag ipadic-2.7.0/Verb.dic | conjugation.rb -opUC | skkdic-expr2 > SKK-JISYO.ipadic.verb
##
## With -g and -A options, this script can append grammatical annotations
## useful in combination with conjugation.rb.
##
## NOTE: skkdictools.rb should be in the ruby loadpaths to have this work.
##

require_relative 'skkdictools'
require 'optparse'

opt = OptionParser.new
skip_identical = true
skip_hira2kana = true
grammar = false
asayake_mode = "none"

opt.on('-a', "convert Asayake into AsayaKe") { asayake_mode = "convert" }
opt.on('-A', "both Asayake and AsayaKe are output") { asayake_mode = "both" }
opt.on('-g', "append grammatical annotations") { grammar = true }
opt.on('-k', "generate hiragana-to-katakana pairs (「ねこ /ネコ/」)") { skip_hira2kana = false }
opt.on('-K', "generate identical pairs (「ねこ /ねこ/」)") { skip_identical = false }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption
  print "'#{$0} -h' for help.\n"
  exit 1
end

while gets
  $_.encode!("utf-8")

  #line = $_.toeuc
  next if $_ !~ /^\(品詞 \(([^)]*)\)\) \(\(見出し語 \(([^ ]*) [0-9]*\)\) \(読み ([^ ]*)\)/
  # (品詞 (名詞 一般)) ((見出し語 (学課 3999)) (読み ガッカ) (発音 ガッカ) )
  next if skip_hira2kana && $2 == $3
  hinsi = $1
  candidate = $2
  key = $3.tr('ァ-ン', 'ぁ-ん').gsub(/ヴ/, 'う゛')
  next if skip_identical && key == candidate

  conjugation = nil
  if grammar && $_ =~ /\(活用型 ([^)]*)\) \)$/
    # (活用型 五段・ワ行促音便) )
    conjugation = $1.sub(/^(..)・([ア-ン]行)/, '\2\1 ')
  end

  comment = nil
  if grammar
    comment = hinsi
    comment += " " + conjugation if !conjugation.nil?
    if hinsi =~ /接頭詞/
      if hinsi =~ /数接続/
        # generate "#0"; complete-numerative.rb should do the rest
        candidate += "#0"
        key += "#"
      else
        comment += "[φ>]"
      end
    elsif hinsi =~ /接尾/
      if hinsi =~ /助数詞/
        comment += "[φ#]"
      else
        comment += "[φ<]"
      end
    end
  end

  tail = ""
  if key =~ /^\{(.*)\}([ぁ-ん]*)$/
    tail = $2
    # (読み {チネツ/ジネツ})
    keys = $1.split("/")
  else
    keys = [key]
  end

  keys.each do |midasi|
    midasi += tail if !tail.nil?
    next if skip_identical && midasi == candidate
    print_orig = true

    if asayake_mode != "none"
      new_midasi, new_candidate, postfix = okuri_nasi_to_ari(midasi, candidate)
      if !new_midasi.nil?
        comment_extra = ""
        if grammar
          comment_extra += "[iks(gm)]" if postfix == "い" && hinsi =~ /形容詞/

          comment_extra += "[wiueot(c)]" if postfix == "う" && conjugation =~ /ワ行五段/
          comment_extra += "[gi]" if postfix == "ぐ" && conjugation =~ /ガ行五段/
          comment_extra += "[mn]" if postfix == "む" && conjugation =~ /マ行五段/
          comment_extra += "[*]" if postfix == "る" && conjugation =~ /カ変/
          comment_extra += "[rt(cn)]" if postfix == "る" && conjugation =~ /ラ行五段/
          # this can be of problem
          comment_extra += "[a-z]" if postfix == "る" && conjugation =~ /一段/

          #comment_extra += "[ki]" if postfix == "く" && conjugation =~ /カ行五段/
          if postfix == "く" && conjugation =~ /カ行五段/
            #if new_candidate =~ /行$/
            if new_midasi =~ /いk$/
              comment_extra += "[ktc]"
            elsif new_midasi =~ /ゆk$/
              comment_extra += "[k]"
            else
              comment_extra += "[ki]"
            end
          end

          comment_extra += "(-#{postfix})"
          #print_orig = false if !comment_extra.empty?
          print_orig = false if hinsi =~ /動詞|形容詞/
        end
        print_pair(new_midasi, new_candidate, nil, comment.delete("φ") + comment_extra)
        print_orig = false if asayake_mode != "both"
      else
        comment += "[φdn(s)]" if hinsi =~ /形容動詞語幹/
        comment += "[φs]" if hinsi =~ /サ変接続/
      end
    end
    print_pair(midasi, candidate, nil, grammar ? comment : nil) if print_orig
  end
end
