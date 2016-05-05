#!/usr/bin/env ruby -E euc-jis-2004:utf-8
# -*- coding: utf-8 -*-
# canna2skk.rb -- convert Canna dictionary to SKK-JISYO format.
#
# Copyright (C) 2003 NAKAJIMA Mikio <minakaji@namazu.org>
#
# Author: NAKAJIMA Mikio <minakaji@namazu.org>
# Created: March 23, 2003
# Last Modified: $Date: 2013/05/26 09:47:48 $
# Version: $Id: canna2skk.rb,v 1.3 2013/05/26 09:47:48 skk-cvs Exp $

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
# As to Canna dictionary, See
#   http://cannadic.oucrc.org/
#
# $ canna2skk.rb gcanna.t gcannaf.t > tmp.jisyo
# $ skkdic-expr2 tmp.jisyo > SKK-JISYO.canna
#
# かん #JS*8 巻 #CNSUC2*2 間 #JS 缶 貫 #JSSUC 間

file = ARGV.shift
open(file).each{|line|
  if !(line =~ /([^ ]+) (.+) *$/)
    next
  else
    key = $1
    words = $2
    words.split(' ').each{|word|
      if (word =~ /[#*a-zA-Z0-9]+/ || key == word)
          next
      else
        print key, " /", word, "/\n"
      end
    }
  end
}
# end of canna2skk.rb
