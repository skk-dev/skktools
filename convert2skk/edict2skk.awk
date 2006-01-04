# edict2skk.awk -- convert EDICT dictionary to SKK-JISYO format.
#
# Copyright (C) 1998, 1999, 2000 NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
#
# Author: NAKAJIMA Mikio <minakaji@osaka.email.ne.jp>
# Created: Dec. 5, 1998
# Last Modified: $Date: 2006/01/04 10:35:06 $
# Version: $Id: edict2skk.awk,v 1.5 2006/01/04 10:35:06 skk-cvs Exp $

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
# This file encoding should be Ja/EUC.
#
# このスクリプトは、James William Breen による EDICT を SKK-JISYO フォー
# マットに変換するものです。できあがった辞書は、SKK 10.x に付いている
# skk-look.el を使うと有効利用できるのではないかと考えています。
#
# EDICT は、
#   ftp://ftp.u-aizu.ac.jp:/pub/SciEng/nihongo/ftp.cc.monash.edu.au/
# から get できます。
#
# この edict を edict2skk.awk と SKK jisyo-tools のコマンドを使って加
# 工します。
#
#   % jgawk -f edict2skk.awk edict | skkdic-sort > SKK-JISYO.E2J
#
# SKK-JISYO.E2J の使い方は色々考えられますが、
#   % skkdic-expr SKK-JISYO.E2J + /usr/local/share/skk/SKK-JISYO.L | skkdic-sort > SKK-JISYO.L
# などとして SKK Large 辞書とマージして使うのが簡単です。
#
# EDICT 及びそのサブセット (本スクリプトにより EDICT を抜粋したものは
# サブセットに当たるでしょう) は、GPL とは異なる配布条件が付いているの
# で、詳細は、EDICT ファイルの冒頭部分もしくは、EDICT 添付の edict.doc
# を参照して下さい。
#
# Code
BEGIN{
  print ";; okuri-ari entry";
  # all entries are `okuri-nasi'.
  print ";; okuri-nasi entry";
}
$1 !~ /^？/ {
    alt_yomi = 0; # initialize
    # plural words that contain spaces cannot be yomi.
    if (match($0, /\/[^ ][^ ]*\/$/) != 0) {
	entries = substr($0, RSTART + 1, RLENGTH - 2);
	num = split(entries, yomi, "/");
	for (i = 1; i <= num; i++) {
	    gsub(/\"/, "", yomi[i]);
	    if (match(yomi[i], /\(-*[a-z]*[a-z]*-*\)/) != 0) {
		head = substr(yomi[i], 1, RSTART - 1);
		middle = substr(yomi[i], RSTART + 1 , RLENGTH - 2);
		tail = substr(yomi[i], RSTART + RLENGTH);
		yomi[i] = head tail;
		gsub(/-/, "", middle);
		if (((middle != "") ||
                     # 過去形
                     (middle != "d") ||
		     # 複数形
		     (middle != "s") ||
		     # 複数形
		     (middle != "es") ||
		     # 進行形
		     (middle != "ing") ||
		     # 放送禁止用語
		     #(middle != "X") ||
		     # 過去形
		     (match(middle, /.ed/) == 0) ) &&
		    (yomi[i] != head middle tail) ) {
		    alt_yomi = head middle tail;
		    gsub(/\"/, "", alt_yomi);
		} else {
		    alt_yomi = 0;
		}
		printf("%s /%s/\n", yomi[i], $1);
		if (alt_yomi) {
		    printf("%s /%s/\n", alt_yomi, $1);
		}
	    } else {
		printf("%s /%s/\n", yomi[i], $1);
	    }
	}
    }
}
# end of edict2skk.awk
