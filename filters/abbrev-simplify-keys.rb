#!/usr/local/bin/ruby -Ke
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: abbrev-simplify-keys.rb,v 1.3 2005/06/19 17:03:21 skk-cvs Exp $
## Keywords: japanese, dictionary
## Last Modified: $Date: 2005/06/19 17:03:21 $
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

opt.on('-s VAL', 'stem keys(MIDASI) equal or shorter than VAL letters') { |v| stem = v.to_i }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  print "'#{$0} -h' for help.\n"
  exit 1
end

while gets
  next if $_ =~ /^[^a-zA-Z0-9]/
  tmp = $_.chop.split(" /", 2)
  midasi = tmp.shift.downcase.delete('^a-z0-9')
  next if midasi.length <= stem
  print "#{midasi} /#{tmp[0]}\n"
end
