#!/bin/sh
## Copyright (C) 2005 MITA Yuusuke <clefs@mail.goo.ne.jp>
##
## Author: MITA Yuusuke <clefs@mail.goo.ne.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: doc2skk.sh,v 1.3 2005/09/22 16:16:53 skk-cvs Exp $
## Keywords: japanese, dictionary
## Last Modified: $Date: 2005/09/22 16:16:53 $
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
## Sample script of chasen2skk.rb and skk-wordpicker.rb.
##
### Requirements:
##
## - At least one of ChaSen(-c), MeCab(-m) or KAKASI(-k) save -a
## - chasen2skk.rb and/or skk-wordpicker.rb in the current directory
## (or change $converterpath respectedly)
## - skkdictools.rb in the ruby loadpath
## - nkf or qkc (see $charsetfilter)
## - w3m (or alternative HTTP client - see $browser)
## - skkdic-expr2
##
## Don't be discouraged! It's a mere shell script.
##
### Instruction:
##
## This script tries to generate SKK dictionary pairs from various resources,
## ie. plain texts, websites and search engines.
##
##
## % doc2skk.sh some.txt > result.txt
##
## analyse 'some.txt' with ChaSen, picking up keywords and converting them
## into SKK format.
##
## % doc2skk.sh -m -w 音楽 > result.txt
##
## query goo on the keyword '音楽' and analyse the result page with MeCab(-m).
## If '-W' is used instead of '-w', the result is limited to the words containing
## the specified keyword itself (eg.「アジア音楽」「音楽活動」)
##
## % doc2skk.sh -k -e k -u 'http://www.bookshelf.jp/texi/elisp-manual-20-2.5-jp/elisp_toc.html' > SKK-JISYO.elisp
##
## directly fetch a webpage and analyse it with KAKASI(-k).
## '-e k' means '-k' option should be given to skk-wordpicker.rb.
## 
## % doc2skk.sh -a -u 'http://www.aozora.gr.jp/cards/000148/files/776_14941.html' > kusamakura.txt
##
## Aozora-bunko texts have reader-friendly 'rubies' (furigana);
## -a option makes use of them to determine keys.
##
##
## Since this script uses morphological analysis engines to determine 'key',
## the results will contain *MUCH* incorrectness.  You might wish to
## examine and rectify them before making any use of them.
##
## Still, those engines seem to do nice jobs on relatively big compound words.
## 
##
ldic=/usr/local/share/skk/SKK-JISYO.L
converterpath=./
charsetfilter="qkc"
#charsetfilter="nkf -e"
chasencom="chasen -j"
mecabcom="mecab -Ochasen"
analyser=$chasencom
converter="chasen2skk.rb"
browser="w3m -cols 512 -dump"
tmpfile=./goo-fetcher.tmp.$$
tmpfile2=./goo-fetcher.tmp2.$$
extraopts=
extraopts2=
sourceurl=
keyword=
sourcefile=
help=false
purge=true

args=`getopt ackme:hPu:w:W: $*`
if [ $? != 0 ]; then
  help=true
fi

set -- $args
for i
do
  case "$i"
    in
    -a)
    analyser="cat"
    converter="aozora2skk.rb"
    shift;;
    -c)
    analyser=$chasencom
    converter="chasen2skk.rb"
    shift;;
    -m)
    analyser=$mecabcom
    converter="chasen2skk.rb"
    shift;;
    -k)
    analyser="cat" #dummy
    converter="skk-wordpicker.rb"
    shift;;
    -e)
    extraopts="-$2"; shift;
    shift;;
    -h)
    help=true;
    shift;;
    -P)
    purge=false;
    shift;;
    -u)
    # this actually works with filename also (if using w3m)
    sourceurl="$2"; shift;
    shift;;
    -w)
    keyword="$2"; shift;
    shift;;
    -W)
    keyword="$2";
    extraopts2="-w $2";
    shift; shift;;
    --)
    shift; break;;
  esac
done


# kludge: detect url
# XXX cannot handle multiple arguments
if [ "`echo "$1" | grep 'http://'`" ]; then
  sourceurl="$1"
  shift
#elif [ -f "$1" ]; then
#  sourcefile="$1"
fi

# let's read from stdin
#if [ -z "$keyword" -a -z "$sourceurl" -a -z "$sourcefile" ]; then
#  echo "Please specify at least one valid source."
#  help=true
#fi 1>&2

if [ $help = true ]; then
  echo 'Usage: doc2skk.sh [filename]'
  echo 'Options:'
  echo ' -a            use aozora2skk.rb'
  echo ' -c            use ChaSen (default)'
  echo ' -e <options>  options for $converter (eg. -e k)'
  echo ' -h            show this help message'
  echo ' -k            use KAKASI'
  echo ' -m            use MeCab'
  echo ' -P            not eliminate duplications with SKK-JISYO.L'
  echo ' -u <URL>      fetch the webpage specified'
  echo ' -w <keyword>  query goo'
  echo ' -W <keyword>  query goo and/or extract words containing it'
  exit 2
fi 1>&2

if [ "$sourceurl" ]; then
  $browser "$sourceurl" > $tmpfile
  sourcefile=$tmpfile
elif [ "$sourcefile" ]; then
  #nothing
elif [ "$keyword" ]; then
  $browser "http://search.goo.ne.jp/web.jsp?MT=\"$keyword\"&DC=100&CK=1" > $tmpfile
  sourcefile=$tmpfile
fi

$charsetfilter $sourcefile "$@" | $analyser | ruby -Ke $converterpath$converter $extraopts $extraopts2 > $tmpfile2

if [ $purge = true ]; then
  skkdic-expr2 $tmpfile2 - $ldic
else
  cat $tmpfile2
fi

rm -f $tmpfile $tmpfile2
