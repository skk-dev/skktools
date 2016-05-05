#!/usr/bin/env ruby -E euc-jis-2004:utf-8
# -*- coding: utf-8 -*-
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: aozora2skk.rb,v 1.3 2013/05/26 09:47:48 skk-cvs Exp $
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
### Commentary:
##
### Instruction:
##
## This script extracts SKK dictionary pairs from texts with 'ruby' added,
## esp. those of Aozora-bunko.
##
## % aozora2skk.rb file-from-aozora-bunko.html > result.txt
##
# ○

require 'optparse'

opt = OptionParser.new

results = []
note =false

opt.on('-a', 'append annotation <autogen - aozora>') { note = true }
begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption
  print "'#{$0} -h' for help.\n"
  exit 1
end



while gets
  $_.encode!("utf-8")
  $_.gsub!(/<[^>]*>/, '')
  results = results + $_.scan(/([亜-熙]{2,})[ 　]*[\[(（［〔【]([ぁ-ん]*)[\])）〕］】]/)
end

results.uniq!
results.each {|word,yomi|
  print "#{yomi} /#{word}#{note ? ';‖<autogen - aozora>' : ''}/\n"
}
