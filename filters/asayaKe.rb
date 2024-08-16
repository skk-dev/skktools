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
## Based on registdic.cgi and skkform.rb by Mikio NAKAJIMA.
##
### Instruction:
## This script converts okuri-nasi pairs with okuri into okuri-ari:
## 「あさやけ /朝焼け/」 → 「あさやk /朝焼/」
##
## '-e' simply extracts such pairs.
## '-E' outputs both in original and converted forms.
##
## '-o' given, the okuri is appended as an annotation:
## 「あさやk /朝焼;‖-け/」
##
## '-O' given, the result will be in skk-henkan-okuri-strictly format:
## 「あさやk /朝焼/[け/朝焼]/」
##
## '-u' eliminates all the annotations.
##
## '-p' eliminates pairs with "※" or "?" annotations that are suspected
## as 'wrong' words.
##
## NOTE: skkdictools.rb should be in one of the ruby loadpaths.
##
#require 'jcode'
#require 'kconv'
STDOUT.set_encoding(Encoding.default_external, "utf-8")

require 'skkdictools'
require 'optparse'
opt = OptionParser.new

mode = "convert"
unannotate = false
okuri_mode = "none"
#stem = 0
purge = false
#filter = false


opt.on('-e', 'extract okuri-nasi-with-okuri pairs') { mode = "extract" }
opt.on('-E', 'extract and then convert okuri-nasi-with-okuri pairs') { mode = "both" }
#opt.on('-f', 'output original pairs if conversion failed') { filter = true }
opt.on('-o', 'append original "okurigana" as annotation') { okuri_mode = "annotation" }
opt.on('-O', 'append original "okurigana" in skk-henkan-okuri-strictly format') { okuri_mode = "bracket" }
opt.on('-p', 'purge candidates marked with "※" or "?"') { purge = true }
opt.on('-u', 'eliminate annotations') { unannotate = true }
#opt.on('-s VAL', 'stem candidates equal or shorter than VAL letters') { |v| stem = v.to_i * 2 }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption
  print "'#{$0} -h' for help.\n"
  exit 1
end


while gets
  $_ = $_.encode("utf-8", Encoding.default_external)
  next if $_ =~ /^;/
  tmp = $_.chop.split(" /", 2)
  midasi = tmp.shift
  tokens = tmp[0].split("/")

  tokens.each do |token|
    candidate, annotation = token.split(";", 2)
    #next if tmp[0].length <= stem
    next if purge && annotation =~ /※/
    next if purge && annotation =~ /\?$/

    key, prefix, postfix = okuri_nasi_to_ari(midasi, candidate)
    if !key.nil?
      if mode == "extract" || mode == "both"
	print "#{midasi} /#{candidate}"
	if !unannotate && !annotation.nil?
	  print ";#{annotation}"
	end
	print "/\n"
      end

      if mode == "convert" || mode == "both"
	print "#{key} /#{prefix}"

	case okuri_mode
	when "annotation"
	  if !unannotate && !annotation.nil?
	    print ";#{annotation}‖-#{postfix}"
	  else
	    print ";‖-#{postfix}"
	  end
	when "bracket"
	  if !unannotate && !annotation.nil?
	    print ";#{annotation}/[#{postfix[0,2]}/#{prefix};#{annotation}]"
	  else
	    print "/[#{postfix[0,2]}/#{prefix}]"
	  end
	else
	  if !unannotate && !annotation.nil?
	    print ";#{annotation}"
	  end
	end
	print "/\n"
      end
    end
  end
end
