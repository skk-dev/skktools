/* SKK JISYO TOOLS (SKK dictionary handling tools)
Copyright (C) 1994, 1996, 1999, 2000
      Hironobu Takahashi, Masahiko Sato, Kiyotaka Sakai

Author: Hironobu Takahashi, Masahiko Sato, Kiyotaka Sakai, Kenji Yabuuchi
Maintainer: Mikio Nakajima <minakaji@osaka.email.ne.jp>
Version: $Id: skkdic-sort.c,v 1.3 2000/10/05 17:16:44 czkmt Exp $
Keywords: japanese
Last Modified: $Date: 2000/10/05 17:16:44 $

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

/* skkdic-sort.c
   このプログラムは SKK の辞書の整列を行います
 */

#include <config.h>
#include <stdio.h>
#ifdef HAVE_MALLOC_H
#include <malloc.h>
#endif

/* このプログラムでは辞書をすべてメモリの中に読み込みます。
   次の値はあらかじめ用意するメモリと、不足した場合に追加す
   るメモリの量を規定します。あまり小さいと頻繁に realloc()
   が発生します。*/

#define STEP (256*1024)

/* 辞書は次のポインタによって差されたメモリに書き込まれます */
static unsigned char *dict;
static unsigned int dictsize;

/* 辞書のインデクスリストです */
static unsigned int *index;

/* ソートで使用するポインタです */
static unsigned int *list;
static unsigned int n_line;

/* 辞書の読み込みプログラム */
static void
readdict()
{
  unsigned int bufsize, incsize;

  dictsize = 0;

  /* 辞書用のメモリとして STEP バイトを用意します */
  dict = malloc(STEP);
  bufsize = STEP;
  incsize = fread(dict+dictsize, 1, bufsize-dictsize, stdin);
  dictsize += incsize;

  /* もしも一杯ならば STEP バイトずつ増やして読み込みを繰り返します */
  while (dictsize == bufsize) {
    bufsize += STEP;
    dict = realloc(dict, bufsize);
    incsize = fread(dict+dictsize, 1, bufsize-dictsize, stdin);
    dictsize += incsize;
  }
}

/* インデクスを作成 */
static void
make_index()
{
  int i, n;

  n = 0;
  for (i = 0; i < dictsize; ++ i)
    if (dict[i] == '\n')
      ++ n;
  n_line = n;

  index = malloc((sizeof *index)*(n_line+1));
  n = 0;
  index[0] = 0;
  for (i = 0; i < dictsize; ++ i)
    if (dict[i] == '\n')
      index[++n] = i+1;

  list = malloc((sizeof *list)*n_line);
  for(i = 0; i < n_line; ++ i)
    list[i] = i;
}

/* ソートための文字列比較ルーチン
   送りなしのエントリで引数 a が先にくるべき時は -1 を返し、
   それ以外の時は 1 を返す */
static int
hexcomp(a, b)
     unsigned char *a;
     unsigned char *b;
{
  while(*a == *b) {
    ++a; ++ b;
  }
  if (*a > *b) return 1;
  return -1;
}

/* 送りがながあるかどうか判断する  0-なし 1-あり */
static int okuriari(p)
     unsigned char *p;
{
  if ((p[0] & 0x80) == 0) return 0;
  while(*p != ' ')
    if (*p == '\0') return 0; /* 空白がない行は本当は異常として扱うべき */
    else            ++ p;
  if (('a' <= p[-1]) && (p[-1] <= 'z')) return 1;
  return 0;
}

/* ソートための比較ルーチン
   引数 a が先にくるべき時は -1 を返し、それ以外の時は 1 を返す */
int skkcompar(a, b)
     int *a;
     int *b;
{
  unsigned char *ptra, *ptrb;
  ptra = dict+index[*a];
  ptrb = dict+index[*b];

  if (okuriari(ptra)) {
    if (okuriari(ptrb))
      /* いずれも送り仮名があるので、a b を交換して比較する */
      return hexcomp(ptrb, ptra);
    else
      return -1;  /* a が先 */
  } else {
    if (okuriari(ptrb))
      return 1;  /* a が後 */
    else
      /* いずれも送り仮名がないので、a b をそのまま比較した結果を返す */
      return hexcomp(ptra, ptrb);
  }
}

/* 結果を出力 */
static void printout()
{
  int i;
  unsigned char *ptr, *line;
  int okuriflag;

  puts(";; okuri-ari entries.");
  okuriflag = 1;
  for(i = 0; i < n_line; ++ i) {
    line = dict+index[list[i]];
    if (line[0] == ';') continue; /* コメント行は出力しない */
    if (okuriflag) {
      if (!okuriari(line)) {
	puts(";; okuri-nasi entries.");
	okuriflag = 0;
      }
    }
    for (ptr = line; *ptr != '\n'; ++ ptr)
      putchar(*ptr);
    putchar('\n');
  }
}

/* メインプログラム 引数は使用しません */
int main(argc, argv)
     int argc;
     char **argv;
{
  readdict();
  make_index();
  qsort((char *)list, n_line, sizeof *list, skkcompar);
  printout();
  return 0;
}

/* end of skkdic-sort.c */
