#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: complete-numerative.rb,v 1.4 2013/05/26 09:47:48 skk-cvs Exp $
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
## This script is aimed to supplement missing numerative pairs by
## generating, for example, 「#まい /#3枚/#1枚/#0枚/#2枚/」 from
## 「#まい /#0枚/」.
##
##     % complete-numerative.rb SKK-JISYO.L > SKK-JISYO.num
##     % skkdic-expr2 SKK-JISYO.L + SKK-JISYO.num > SKK-JISYO.L.new
## 
## You might wish to reorder existing numerative pairs; if you always
## prefer /#0/#3/#1/#2/ , try this:
##
##     % complete-numerative.rb -o 0312 SKK-JISYO.L > SKK-JISYO.num
##     % skkdic-expr2 SKK-JISYO.L - SKK-JISYO.num + SKK-JISYO.num > SKK-JISYO.L.new
##
## If you simply want #0 pairs to appear at first, do this:
##
##     % complete-numerative.rb -o 0 SKK-JISYO.L > SKK-JISYO.num0
##     % skkdic-expr2 SKK-JISYO.num0 + SKK-JISYO.L > SKK-JISYO.L.new
##
##
## NOTE: skkdictools.rb should be in one of the ruby loadpaths.
##
##
## TODO: output /#3foo/#3bar/#1foo/#1bar/ instead of /#3foo/#1foo/#3bar/#1bar/
##
Encoding.default_internal = "utf-8"
Encoding.default_external = "euc-jis-2004"
STDOUT.set_encoding("euc-jis-2004", "utf-8")

#require 'jcode'
#require 'kconv'
require 'skkdictools'
require 'optparse'
opt = OptionParser.new

purge = false
order = "3102"
annotation_mode = "all"
mode = "convert"

opt.on('-o ORDER', 'specify order of results, eg. "3102" => "/#3/#1/#0/#2/"') { |v| order = v } # TODO - check sanity
#opt.on('-u', "don't add annotations for derived pairs") { annotation_mode = "self" }
opt.on('-U', 'eliminate all the annotations') { annotation_mode = "none" }
opt.on('-p', 'skip candidates marked with "※" or "?"') { purge = true }
opt.on('-e', 'only extract numerative entries') { mode = "extract" }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption
  print "'#{$0} -h' for help.\n"
  exit 1
end

while gets
  $_ = $_.encode("utf-8", "euc-jis-2004")
  next if $_ =~ /^;/ || $_ =~ /^$/ || $_ !~ /^[^ ]*#/
  if mode == "extract"
    # XXX This is lazy -- there's a slim chance of extracting
    # non-numerative pairs such as 「# /＃/」
    # Anyway it's equivalent to doing grep '^[^ ;]*#'
    print $_
    next
  end
  midasi, tokens = $_.parse_skk_entry

  tokens.each do |token|
    word, annotation, comment = token.skk_split_tokens
    next if word !~ /#[0-3]/
    next if purge && annotation =~ /※/
    next if purge && annotation =~ /\?$/
    order.each_byte do |num|
      if annotation_mode == "none"
	print_pair(midasi, word.gsub(/#[0-3]/, "##{num.chr}"), nil, nil)
      else
	print_pair(midasi, word.gsub(/#[0-3]/, "##{num.chr}"),
		annotation, comment)
      end
    end
  end
end
