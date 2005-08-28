#!/usr/local/bin/ruby -Ke
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: aozora2skk.rb,v 1.1 2005/08/28 17:51:47 skk-cvs Exp $
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
##
### Instruction:
##
## This script extracts SKK dictionary pairs from texts with 'ruby' added,
## esp. those of Aozora-bunko.
##
## % aozora2skk.rb file-from-aozora-bunko.html > result.txt
##
# ¡û
require 'jcode'
#require 'kconv'
#require 'skkdictools'
require 'optparse'
opt = OptionParser.new

results = []
note =false

opt.on('-a', 'append annotation <autogen - aozora>') { note = true }
begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  print "'#{$0} -h' for help.\n"
  exit 1
end


while gets
  $_.gsub!(/<[^>]*>/, '')
  results = results + $_.scan(/([°¡-ô¦]{2,})[ ¡¡]*[\[(¡Ê¡Î¡Ì¡Ú]([¤¡-¤ó]*)[\])¡Ë¡Í¡Ï¡Û]/)
end

results.uniq!
results.each {|word,yomi|
  print "#{yomi} /#{word}#{note ? ';¡Â<autogen - aozora>' : ''}/\n"
}
