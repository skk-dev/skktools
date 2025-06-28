#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# dic-it2skk.rb -- convert dic-it dictionary to SKK-JISYO format.
#
# Copyright (C) 2003 NAKAJIMA Mikio <minakaji@namazu.org>
#
# Author: NAKAJIMA Mikio <minakaji@namazu.org>
# Created: March 18, 2003

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
# As to dic-it dictionary, See
#   http://member.nifty.ne.jp/palmgiraffe/dic-it/readmeit.htm
#
# $ dic-it2skk.rb dic-it.txt > tmp.jisyo
# $ skkdic-expr2 tmp.jisyo > SKK-JISYO.dic-it
#
encoding = "euc-jis-2004"
file = ARGV.shift
if file == "-8"
  encoding = "utf-8"
  file = ARGV.shift
end
Encoding.default_external = encoding
open(file).each{|line|
  line.encode!("utf-8")
  if !(line =~ /([^ \/]+)\/([^ ]+) *$/)
    next
  else
    key = $1
    words = $2
    print key, " /", words, "/\n"
  end
}
# end of dic-it2skk.rb
