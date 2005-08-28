#!/usr/local/bin/ruby -Ke
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: chasen2skk.rb,v 1.1 2005/08/28 17:51:47 skk-cvs Exp $
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
## This script tries to extract SKK pairs from the output of ChaSen.
##
## skkdictools.rb required.
##
# ¡û
require 'jcode'
require 'kconv'
require 'skkdictools'

#require 'cgi'
#require 'socket'
#require 'timeout'

require 'optparse'
opt = OptionParser.new

katakana_words = false
katakana_majiri = false
#append_goohits = false
keyword = ""
#fetch_from_goo = false
append_notes = false

# -g might be a bad idea; better eliminate pairs already in SKK-JISYO.L first
#opt.on('-g', 'append goo hit numbers') { append_goohits = true }
opt.on('-n', 'append notes') { append_notes = true }
opt.on('-k', 'extract katakana words (if WORD not given)') { katakana_words = true }
#opt.on('-K', 'extract words containing katakana') { katakana_majiri = true }
opt.on('-w WORD', 'extract pairs containing WORD') { |v| keyword = v }
#opt.on('-W WORD', 'query goo and extract pairs containing WORD') { |v| keyword = v; fetch_from_goo = true }

begin
  opt.parse!(ARGV)
  #rulesets = default_rulesets if rulesets.empty?
rescue OptionParser::InvalidOption => e
  print "'#{$0} -h' for help.\n"
  exit 1
end

#keyword_pat = Regexp.compile("[°¡-ô¦]*#{keyword}[°¡-ô¦]*")

count = 0
#key = word = last_key = last_word = last_part = ""
key = word = last_part = ""
poisoned = terminate = false

while gets
  midasi, yomi, root, part, conj = $_.split("	", 5)
  if midasi !~ /^[°¡-ô¦¥¡-¥ó¥ô¡¼]+$/ || terminate
    next if count < 1
    if midasi =~ /^[^°¡-ô¦¥¡-¥ó¥ô¡¼]+$/ && !terminate
      # nothing
    else
      if part =~ /ÀÜÂ³»ì|ÀÜÆ¬»ì|Éû»ì[^²Ä]/
	# nothing - decline some parts
      elsif midasi =~ /ÊÂ¤Ó|µÚ¤Ó/
	# nothing - (HACK) decline conjonctions that ChaSen overlooks
      elsif midasi =~ /^[¤¡-¤ó]+[°¡-ô¦¥¡-¥ó¥ô¡¼]+/
	# nothing - this applies to quasi-words such as:
	# ¤Ë´Ø¤¹¤ë        ¥Ë¥«¥ó¥¹¥ë      ¤Ë´Ø¤¹¤ë        ½õ»ì-³Ê½õ»ì-Ï¢¸ì
      else
	key += yomi.to_hiragana
	word += midasi
	last_part = part
	# asayaKify here?
      end
    end

    if !katakana_words && word =~ /^[¥¡-¥ó¥ô¡¼]+$/
      # nothing
    elsif !keyword.empty? && !word.include?(keyword)
      # nothing
    elsif word.size < 3 || poisoned # || word.size >= 20
      # nothing
    else
      print_pair(key, word, nil, append_notes ? "<autogen>,#{last_part.chomp}" : nil)
    end

    key = word = last_part = ""
    poisoned = terminate = false
    count = 0

  else
    if count > 0 && part =~ /ÀÜÂ³»ì|ÀÜÆ¬»ì|Éû»ì[^²Ä]/
      terminate = true
      redo
    end
    count += 1
    key += yomi.to_hiragana
    word += midasi
    last_part = part
    poisoned = true if part =~ /Ì¤ÃÎ¸ì/
  end
end
