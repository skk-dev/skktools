#!/usr/local/bin/ruby -Ke
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: abbrev-convert.rb,v 1.4 2005/10/23 17:28:33 skk-cvs Exp $
## Keywords: japanese, dictionary
## Last Modified: $Date: 2005/10/23 17:28:33 $
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
## This script reads SKK-formatted dictionary from a file or stdin,
## extracts the pairs with alphabetic key and 'katakana' candidate (eg.
## "player /¥×¥ì¥¤¥ä¡¼/"), and then convert them into the other styles.
##
##    % abbrev-convert.rb SKK-JISYO.L | skkdic-expr2 > SKK-JISYO.waei
##
## Default action is to produce reversed pairs that can be used to
## convert katakana-words into original spellings,
## eg. "¤×¤ì¤¤¤ä¡¼ /player/".
##
##    % abbrev-convert.rb -k SKK-JISYO.L | skkdic-expr2 > SKK-JISYO.hira-kata
##
## If '-k' or '-K' option is given, the result is hiragana-katakana
## pairs such as "¤×¤ì¤¤¤ä¡¼ /¥×¥ì¥¤¥ä¡¼/". With '-K', the original
## key is appended as an annotation ("¤×¤ì¤¤¤ä¡¼ /¥×¥ì¥¤¥ä¡¼;player/").
##
##    % cat .skk-jisyo .skkinput-jisyo | abbrev-convert.rb -e SKK-JISYO.L | skkdic-expr2 > .skk-jisyo-abbrev
##
## '-e' given, it merely extracts alphabet-katakana (abbrev) pairs;
## you may wish to send the result to the dev-team to help the
## dictionary grow :-)
##
##
## '-s <num>' option suppresses words less than <num> letters (in Zenkaku).
## This can reduce flooding of homonyms caused by adding short words.
## 
## '-u' eliminates all the annotations.
##
## '-p' eliminates pairs with "¢¨" or "?" annotations that are suspected as 'wrong' words.
##
require 'jcode'
#require 'kconv'
require 'optparse'
opt = OptionParser.new

mode = "waei"
unannotate = false
stem = 0
purge = false

opt.on('-e', 'extract alphabet-katakana pairs') { mode = "extract" }
opt.on('-w', 'output hiragana-alphabet pairs') { mode = "waei" }
opt.on('-k', 'output hiragana-katakana pairs') { mode = "hira-kata" }
opt.on('-K', 'same as -k, with original MIDASI as annotation') { mode = "hira-kata-with-spell" }
opt.on('-p', 'purge candidates marked with "¢¨" or "?"') { purge = true }
opt.on('-u', 'eliminate annotations') { unannotate = true }
opt.on('-s VAL', 'stem candidates equal or shorter than VAL letters') { |v| stem = v.to_i * 2 }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  print "'#{$0} -h' for help.\n"
  exit 1
end

while gets
  next if $_ =~ /^[^a-zA-Z0-9]/
  tmp = $_.chop.split(" /", 2)
  midasi = tmp.shift
  tokens = tmp[0].sub(/\/\[.*/, "").split("/")
  candidates = Array.new

  tokens.each do |token|
    tmp = token.split(";")
    next if tmp[0] =~ /[^¥¡-¥ô¡¼¡¦=¡á¡¾]/
    next if tmp[0].length <= stem
    next if tmp[0] !~ /[¥¡-¥ô]/ # at least 1 valid letter
    next if purge && tmp[1] =~ /¢¨/
    next if purge && tmp[1] =~ /\?$/
    candidates.push tmp
  end

  next if candidates.nitems < 1

  case mode
  when "extract"
    print "#{midasi} /"
    candidates.each do |word,annotation|
      if !unannotate && !annotation.nil?
	print "#{word};#{annotation}/"
      else
	print "#{word}/"
      end
    end
    print "\n"
  when "waei"
    candidates.each do |word,annotation|
      word = word.tr('¥¡-¥ó', '¤¡-¤ó').gsub(/¥ô/, '¤¦¡«').gsub(/[¡¦=¡á¡¾]/, '')
      if !unannotate && !annotation.nil?
	print "#{word} /#{midasi};#{annotation}/\n"
      else
	print "#{word} /#{midasi}/\n"
      end
    end
  when "hira-kata"
    candidates.each do |word,annotation|
      word_hira = word.tr('¥¡-¥ó', '¤¡-¤ó').gsub(/¥ô/, '¤¦¡«').gsub(/[¡¦=¡á¡¾]/, '')
      if !unannotate && !annotation.nil?
	print "#{word_hira} /#{word};#{annotation}/"
      else
	print "#{word_hira} /#{word}/"
      end
      print "\n"
    end
  when "hira-kata-with-spell"
    candidates.each do |word,annotation|
      word_hira = word.tr('¥¡-¥ó', '¤¡-¤ó').gsub(/¥ô/, '¤¦¡«').gsub(/[¡¦=¡á¡¾]/, '')
      if !unannotate && !annotation.nil?
	print "#{word_hira} /#{word};#{midasi}¡¨#{annotation}/"
      else
	print "#{word_hira} /#{word};#{midasi}/"
      end
      print "\n"
    end
  end
end
