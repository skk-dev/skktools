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
### Instruction:
##
## This script tries to convert PRIME dictionary files into skk ones.
##
##    % prime2skk.rb prime-dict | skkdic-expr2 > SKK-JISYO.prime
##
##    % prime2skk.rb -Ag prime-dict | conjugation.rb -opUC | skkdic-expr2 > SKK-JISYO.prime.conjugation
##
## -g and -A given, this script can append grammatical annotations useful in
## combination with conjugation.rb.
## 
## NOTE: skkdictools.rb should be in one of the ruby loadpaths.
##

require_relative 'skkdictools'
require 'optparse'
opt = OptionParser.new

skip_identical = true
skip_hira2kana = true
grammar = false
asayake_mode = "none"
unannotate = false
encoding = "euc-jis-2004"

opt.on('-a', "convert Asayake into AsayaKe") { asayake_mode = "convert" }
opt.on('-A', "both Asayake and AsayaKe are output") { asayake_mode = "both" }
opt.on('-g', "append grammatical annotations") { grammar = true }
opt.on('-k', "generate hiragana-to-katakana pairs (「ねこ /ネコ/」)") { skip_hira2kana = false }
opt.on('-K', "generate identical pairs (「ねこ /ねこ/」)") { skip_identical = false }
opt.on('-u', "don't add original comments as annotation") { unannotate = true }
opt.on('-8', "read and write in utf8") { encoding = "utf-8" }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption
  print "'#{$0} -h' for help.\n"
  exit 1
end
Encoding.default_external = encoding
STDOUT.set_encoding(encoding, "utf-8")

while gets
  $_.encode!("utf-8")

  #line = $_.toeuc
  key, hinsi, candidate, _score, notes = $_.split("	", 5)
  # じょうたい	名詞	状態	377	comment=state	usage=ものごとの様子。「状態変化」
  next if skip_identical && key == candidate
  next if skip_hira2kana && key.to_katakana == candidate

  comment = nil
  if grammar
    comment = hinsi
    comment += "[φ>]" if hinsi =~ /接頭語/
    comment += "[φ#]" if hinsi =~ /助数詞/
    comment += "[φ<]" if hinsi =~ /接尾語/
  end

  print_orig = true
  okuri = ""
  comment_extra = ""
  notes.chop!.gsub!(/	/, ",") if !notes.nil?

  if asayake_mode != "none"
    new_key, new_candidate, postfix = okuri_nasi_to_ari(key, candidate)
    if !new_key.nil?
      if grammar
        comment_extra += "(-#{postfix})"

        if (hinsi =~ /名詞/ ||
            hinsi =~ /副詞/ ||
            hinsi =~ /連体詞/ ||
            hinsi =~ /体言/ )
          print_orig = true
        else
          print_orig = false
        end
      end
      print_pair(new_key, new_candidate, unannotate ? nil : notes,
                 comment.delete("φ") + comment_extra)
      print_orig = false if asayake_mode != "both"
    elsif grammar
      # XXX XXX Unfortunately, prime-dict doesn't have data of exact
      # conjugation types for adjective verbs; this should yield a lot of
      # unwanted okuri-ari pairs, such as 「どうどうn /堂々/」(タリ活用).
      comment += "[φdn(st)]" if hinsi =~ /形容動詞/
      comment += "[φs]" if hinsi =~ /サ行\(する\)/

      if hinsi =~ /([ア-ン])行五段/
        okuri = GyakuhikiOkurigana.assoc($1.to_hiragana)[1]
      end

      if hinsi =~ /形容詞/
        comment += "[iks(gm)]" 
        okuri = "i"
      elsif hinsi =~ /ワ行五段/
        comment += "[wiueot(c)]"
        okuri = "u"
      elsif hinsi =~ /ガ行五段/
        comment += "[gi]"
      elsif hinsi =~ /カ行五段/
        #if candidate =~ /行$/
        if key =~ /い$/
          comment += "[ktc]"
        elsif key =~ /ゆ$/
          comment += "[k]"
        else
          comment += "[ki]"
        end
      elsif hinsi =~ /マ行五段/
        comment += "[mn]"
      elsif hinsi =~ /ラ行五段/
        comment += "[rt(cn)]"
      elsif hinsi =~ /来\(く\)/
        comment += "[*]"
        okuri = "r"
      elsif hinsi =~ /一段/
        # this can be of problem
        comment += "[a-z]"
        okuri = "r"
      end
    end
  end
  print_pair(key + okuri, candidate, unannotate ? nil : notes, grammar ? comment : nil) if print_orig
end
