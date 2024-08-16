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
## This script parses given SKK dictionary and outputs entries with
## alphabetic keys, decapitalising all the alphabets and removing
## any non-alphabetic letters.
##
##     % abbrev-simplify-keys.rb -s 3 SKK-JISYO.L > tmp.txt
##     % skkdic-expr2 SKK-JISYO.L + tmp.txt
## 
## '-s <num>' option suppresses keys less than <num> letters; this is
## highly recommended, since capitalisation and special letters can have
## considerable distinctive meanings in abbrev entries with short keys.

#require 'jcode'

require 'optparse'
opt = OptionParser.new

stem = 0
encoding = "euc-jis-2004"

opt.on('-s VAL', 'stem keys(MIDASI) equal or shorter than VAL letters') { |v| stem = v.to_i }
opt.on('-8', 'read and write in utf8') { encoding = "utf-8" }

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
  next if $_ =~ /^[^a-zA-Z0-9]/
  tmp = $_.chop.split(" /", 2)
  midasi = tmp.shift.downcase.delete('^a-z0-9')
  next if midasi.length <= stem
  print "#{midasi} /#{tmp[0]}\n"
end
