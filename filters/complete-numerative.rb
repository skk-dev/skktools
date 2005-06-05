#!/usr/local/bin/ruby -Ke
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: complete-numerative.rb,v 1.1 2005/06/05 16:49:32 skk-cvs Exp $
## Keywords: japanese, dictionary
## Last Modified: $Date: 2005/06/05 16:49:32 $
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
### Instruction:
##
## This script is aimed to supplement missing numerative pairs by
## generating, for example, ＞#引中 /#3呦/#1呦/#0呦/#2呦/＝ from
## ＞#引中 /#0呦/＝.
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
##
## NOTE: skkdictools.rb should be in one of the ruby loadpaths.
##

#require 'jcode'
#require 'kconv'
require 'skkdictools'
require 'optparse'
opt = OptionParser.new
purge = false
order = "3102"
annotation_mode = "all"

opt.on('-o ORDER', 'specify order of results, eg. "3102" => "/#3/#1/#0/#2"') { purge = true }
#opt.on('-u', "don't add annotations for derived pairs") { annotation_mode = "self" }
opt.on('-U', 'eliminate all the annotations') { annotation_mode = "none" }
opt.on('-p', 'skip candidates marked with "◢" or "?"') { purge = true }

while gets
	next if $_ =~ /^;/ || $_ =~ /^$/ || $_ !~ /^[^ ]*#/
	midasi, tokens = $_.parse_skk_entry

	tokens.each do |token|
		word, annotation, comment = token.skk_split_tokens
		next if word !~ /#[0-3]/
		next if purge && annotation =~ /◢/
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
