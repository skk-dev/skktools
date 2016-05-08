#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# ctdicconv.rb -- convert china_taiwan.csv to SKK-JISYO dictionary format.
#
# Copyright (C) 2002 NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
#
# Author: NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
# Created: Aug 2, 2002
# Last Modified: $Date: 2013/05/26 09:47:48 $
# Version: $Id: ctdicconv.rb,v 1.3 2013/05/26 09:47:48 skk-cvs Exp $

# This file is part of Daredevil SKK.

# Daredevil SKK is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either versions 2, or (at your option)
# any later version.
#
# Daredevil SKK is distributed in the hope that it will be useful
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Daredevil SKK, see the file COPYING.  If not, write to the
# Free Software Foundation Inc., 51 Franklin St, Fifth Floor, Boston,
# MA 02110-1301, USA.
#
# Commentary:

Encoding.default_external = "euc-jis-2004"
$ANNOTATION = true
##$ANNOTATION = false

# from 「オブジェクト指向スクリプト言語ruby」p121
def csv_split(source, delimiter = ',')
  csv = []
  data = ""
  source.split(delimiter).each do |d|
    if data.empty?
      data = d
    else
      data += delimiter + d
    end
    if /^"/ =~ data
      if /[^"]"$/ =~ data or '""' == data
        csv << data.sub(/^"(.*)"$/, '\1').gsub(/""/, '"')
        data = ''
      end
    else
      csv << d
      data = ''
    end
  end
  raise "cannot decode CSV\n" unless data.empty?
  csv
end

file = ARGV.shift

if not file
  print "ファイルを指定して下さい\n"
else
  first = true
  File.foreach(file) do |line|
    if first
      first = false
      next
    end
    #中国・台湾,種別,英語見出し,漢字,日本語読み,中国語読み（カタカナ）,英語標記2,漢字別名,漢字別名読み,省都,省都読み,annotation
    _c_t, _d,e_key,kanji,j_key,c_key,_english,kanji_alias,kanji_alias_key,_capital,_capital_key,annotation= csv_split(line.chomp)
    if (e_key && !e_key.empty? && kanji && !kanji.empty?)
      e_key.strip!
      kanji.strip!
      # 英語見出し /漢字/
      if ($ANNOTATION && annotation && !annotation.empty?)
        annotation.strip!
        print e_key, " /", kanji, ";", annotation, "/\n"
      else
        print e_key, " /", kanji, "/\n"
      end

      # 日本語見出し /Capitalized 英語/
      if (j_key && !j_key.empty?)
        j_key.strip!
        if ($ANNOTATION && annotation && !annotation.empty?)
          annotation.strip!
          print j_key, " /", e_key.capitalize, ";", annotation, "/\n"
        else
          print j_key, " /", e_key.capitalize, "/\n"
        end
      end
    end

    if (j_key && !j_key.empty? && kanji && !kanji.empty?)
      # 日本語見出し /漢字/
      if ($ANNOTATION && annotation && !annotation.empty?)
        annotation.strip!
        print j_key, " /", kanji, ";", annotation, "/\n"
      else
        print j_key, " /", kanji, "/\n"
      end
    end

    if (c_key && !c_key.empty? && kanji && !kanji.empty?)
      c_key.strip!
      c_key.tr!("ァ-ン", "ぁ-ん")
      # 中国語見出し /漢字/
      if ($ANNOTATION && annotation && !annotation.empty?)
        print c_key, " /", kanji, ";", annotation, "/\n"
      else
        print c_key, " /", kanji, "/\n"
      end
    end
    # 漢字別名見出し /漢字別名/
    if (kanji_alias && kanji_alias_key &&
        !kanji_alias.empty? && !kanji_alias_key.empty?)
      if ($ANNOTATION && annotation && !annotation.empty?)
        print kanji_alias_key, " /", kanji_alias, ";", annotation, "/\n"
      else
        print kanji_alias_key, " /", kanji_alias, "/\n"
      end
    end
    # 省都見出し /省都/
    #if (capital && capital_key &&
    #    !capital.empty? && !capital_key.empty?)
    #  print capital_key, " /", capital, "/\n"
    #end
  end
end

# end of ctdicconv.rb
