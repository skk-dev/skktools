/* SKK JISYO TOOLS (SKK dictionary handling tools)
Copyright (C) 1994, 1996, 1999, 2000
      Hironobu Takahashi, Masahiko Sato, Kiyotaka Sakai

Author: Hironobu Takahashi, Masahiko Sato, Kiyotaka Sakai, Kenji Yabuuchi
Maintainer: Mikio Nakajima <minakaji@osaka.email.ne.jp>
Version: $Id: skkdic-count.c,v 1.8 2005/03/25 15:59:48 skk-cvs Exp $
Keywords: japanese
Last Modified: $Date: 2005/03/25 15:59:48 $

This file is part of Daredevil SKK.

SKK JISYO TOOLS are free software; you can redistribute them and/or modify
them under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

SKK JISYO TOOLS are distributed in the hope that they will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SKK; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.  */

/* skkdic-count.c
   このプログラムは SKK の辞書に含まれる候補数を数えます。
 */

#include <config.h>
#include <stdio.h>

/* 2005 年版の SKK 辞書では最長の行(「こう」)は 2286 bytes ですが
 * 安全のために以下の値としています。*/

#define BUFSIZE 10240

/* 各ファイルの候補を数えます。 */
static void
count_entry(filename, fp)
     char *filename;
     FILE *fp;
{
  unsigned char buffer[BUFSIZE], *p, *q;
  int count;

  count = 0;
  while(fgets(buffer, BUFSIZE, fp) != NULL) {
    if ((buffer[0] == ';') || (buffer[0] == '\0')) continue;
    for(p = buffer; *p != '\0'; ++ p) {
      if ((p[0] == ' ') && (p[1] == '/')) {
	/* '/['から先は skk-henkan-okuri-strictly 用のデータなので無視 */
	for (q = p+2; (*q != '\0') && (*(q-1) != '/' || *q != '[') ; ++ q) {
	  if (*q == '/') count++;
	}
	break;
      }
    }
  }
  if (count == 1)
    printf("%s: %d candidate\n", filename, count);
  else
    printf("%s: %d candidates\n", filename, count);
}

/* メインプログラムでは引数を判別します。もしもなければ標準入力
   からのデータが得られるものとします。 */

int main(argc, argv)
     int argc;
     char **argv;
{
  int i;
  FILE *fp;

  if (argc <= 1) {
    count_entry("", stdin);
  } else {
    for (i = 1; i < argc; ++ i) {
      if ((fp = fopen(argv[i], "r")) != NULL) {
	count_entry(argv[i], fp);
	fclose(fp);
      } else {
	perror(argv[i]);
      }
    }
  }
  return 0;
}

/* end of skkdic-count.c */
