/* SKK JISYO TOOLS (SKK dictionary handling tools)
Copyright (C) 1994, 1996, 1999, 2000
      Hironobu Takahashi, Masahiko Sato, Kiyotaka Sakai, Kenji Yabuuchi

Author: Hironobu Takahashi, Masahiko Sato, Kiyotaka Sakai, Kenji Yabuuchi
Maintainer: Mikio Nakajima <minakaji@osaka.email.ne.jp>
Keywords: japanese

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
the Free Software Foundation,  Inc., 51 Franklin Street, Fifth Floor,
Boston, MA 02110-1301, USA. */

/* skkdic-expr.c
   このプログラムは SKK の辞書のマージや削除を行います。
 */

#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef HAVE_MKDTEMP
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif /* HAVE_UNISTD_H */
#endif /* HAVE_MKDTEMP */

#ifdef HAVE_DB_H
#include <db.h>
#else /* not HAVE_LIBDB */
#ifdef HAVE_GDBM_NDBM_H
#include <gdbm/ndbm.h>
#else /* not HAVE_GDBM_NDBM_H */
#ifdef HAVE_NDBM_H
#include <ndbm.h>
#else /* not HAVE_NDBM_H */
#ifdef HAVE_DB1_NDBM_H
#include <db1/ndbm.h>
#endif /* HAVE_DB1_NDBM_H */
#endif /* HAVE_NDBM_H */
#endif /* HAVE_GDBM_NDBM_H */
#endif /* HAVE_LIBDB */

#include <errno.h>
#include <signal.h>

#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif

#ifndef errno
extern int errno;
#endif

/* 次の一時ファイルの場所に十分な空きがなければ、変更した方がいいでしょう */
/* 例 #define TMPDIR "." */

#ifndef TMPDIR
#define TMPDIR "/tmp"
#endif

/* 1994 年版の SKK 辞書では最長の行でも 656 文字ですが安全のために
   以下の値としています。*/

#ifdef MAXLINE
#define BLEN MAXLINE
#else
#define BLEN 65536
#endif

/* 作業用ファイル名 */
char file_name[256];
char okuri_tail_name[256];
char okuri_head_name[256];
char tmpsubdir[256];

/* 作業用データベース */
DB *db;
DB *okuriheaddb;
DB *okuritaildb;
FILE *dbcontent;

/* snprintf() がない環境のための定義 */
#ifndef HAVE_SNPRINTF
/* #include <stdio.h> */
#include <stdarg.h>
int snprintf(char *s, size_t maxlen, const char *format, ...)
{
    va_list ap;
    int n;

    va_start(ap, format);
    n = vsprintf(s, format, ap);
    va_end(ap);
    return n;
}
#endif

/* 送りがながついたエントリを含めて処理を行わせるかどうか */
int	okurigana_flag;

static int add_content_line(unsigned char *, unsigned char *, DBT *);
static void subtract_content_line(unsigned char *, unsigned char *, DBT *);

/* Part1: 辞書データベース基本操作プログラム */

/* ファイル削除
   そのファイルがなくてもかまわない。それ以外の問題があればプログラムを停止 */
static void db_remove_file(fname)
     char *fname;
{
    if (unlink(fname) == -1)
	if (errno != ENOENT) {
	    perror(fname);
	    exit(1);
	}
}

/* 作業用データベースファイルを削除
   file_name には content が格納される */
static void db_remove_files()
{
    char pag_name[256];
    char dir_name[256];

    db_remove_file(file_name);
    snprintf(pag_name, sizeof(pag_name), "%s.pag", file_name);
    db_remove_file(pag_name);
    snprintf(dir_name, sizeof(dir_name), "%s.dir", file_name);
    db_remove_file(dir_name);
    snprintf(dir_name, sizeof(dir_name), "%s.db", file_name);
    db_remove_file(dir_name);

    if (okurigana_flag) {
	db_remove_file(okuri_head_name);
	snprintf(pag_name, sizeof(pag_name), "%s.pag", okuri_head_name);
	db_remove_file(pag_name);
	snprintf(dir_name, sizeof(dir_name), "%s.dir", okuri_head_name);
	db_remove_file(dir_name);
	snprintf(dir_name, sizeof(dir_name), "%s.db", okuri_head_name);
	db_remove_file(dir_name);

	db_remove_file(okuri_tail_name);
	snprintf(pag_name, sizeof(pag_name), "%s.pag", okuri_tail_name);
	db_remove_file(pag_name);
	snprintf(dir_name, sizeof(dir_name), "%s.dir", okuri_tail_name);
	db_remove_file(dir_name);
	snprintf(dir_name, sizeof(dir_name), "%s.db", okuri_tail_name);
	db_remove_file(dir_name);
    }
}

/* データベースファイルを作成 */
static void db_make_files()
{
    db_remove_files();
    if (db->open(db, NULL, file_name, NULL, DB_BTREE, DB_CREATE, 0600) != 0){
	perror(file_name);
	exit(1);
    }
    if ((dbcontent = fopen(file_name, "w+")) == NULL){
	perror(file_name);
	exit(1);
    }
    if (okurigana_flag) {
        if (okuriheaddb->open(okuriheaddb, NULL, okuri_head_name, NULL, DB_BTREE, DB_CREATE, 0600) != 0){
	    perror(okuri_head_name);
	    exit(1);
	}
    if (okuritaildb->open(okuritaildb, NULL, okuri_tail_name, NULL, DB_BTREE, DB_CREATE, 0600) != 0){
	    perror(okuri_tail_name);
	    exit(1);
	}
    }
}

/* データベースファイルに新規に追加する */
static void db_append(DBT key, unsigned char *new, DB *dbm)
{
    long pos;
    DBT content;

    fseek(dbcontent, 0L, 2);
    pos = ftell(dbcontent);
    fwrite(new, strlen(new)+1, 1, dbcontent);
    content.data = &pos;
    content.size = sizeof pos;
    dbm->put(dbm, NULL, &key, &content, 0);
}

/* データベース中のポジションを計算する (alignment の問題) */
static long getpos(ptr)
     unsigned char *ptr;
{
    long i;
    union long_dat {
	long pos;
	unsigned char c[sizeof i];
    } dat;
    for (i = 0; i < (sizeof i); ++ i)
	dat.c[i] = ptr[i];
    return dat.pos;
}

/* データベースファイルの内容を前より小さいもので置換する */
static void db_replace(ptr, new)
     unsigned char *ptr;
     unsigned char *new;
{
    fseek(dbcontent, getpos(ptr), 0);
    fwrite(new, strlen(new)+1, 1, dbcontent);
}

/* データベースファイルから文字列を取る */
static void db_gets(ptr, len, fp)
     unsigned char *ptr;
     int len;
     FILE *fp;
{
    while((*(ptr++) = getc(fp)) != '\0');
}

/* Part2: 割り込み操作 */

RETSIGTYPE
signal_handler (signo)
     int signo;
{
    db_remove_files();
    rmdir(tmpsubdir);
    signal(signo, SIG_DFL);
    kill(getpid(), signo);
}

RETSIGTYPE
set_signal_handler()
{
#ifdef SIGQUIT
    if (signal(SIGQUIT, SIG_IGN) != SIG_IGN)
	signal(SIGQUIT, signal_handler);
#endif
    if (signal(SIGINT, SIG_IGN) != SIG_IGN)
	signal(SIGINT, signal_handler);
#ifdef SIGALRM
    if (signal(SIGALRM, SIG_IGN) != SIG_IGN)
	signal(SIGALRM, signal_handler);
#endif
#ifdef SIGHUP
    if (signal(SIGHUP, SIG_IGN) != SIG_IGN)
	signal(SIGHUP, signal_handler);
#endif
    if (signal(SIGSEGV, SIG_IGN) != SIG_IGN)
	signal(SIGSEGV, signal_handler);
#ifdef SIGBUS
    if (signal(SIGBUS, SIG_IGN) != SIG_IGN)
	signal(SIGBUS, signal_handler);
#endif
}

/* Part3: 辞書ファイルの作成 */

/* base の文字列に *s と *e に狭まれた文字列があるかどうか調べる
   0- なし  1- あり */
static int match_item(base, s, e)
     unsigned char *base;
     unsigned char *s;
     unsigned char *e;
{
    unsigned char *p, *q1, *q2;

    for (p = base; *p != '\0'; ++ p) {
	if (*p == *s) {
	    for(q1 = p+1, q2 = s+1; q2 <= e; ++ q1, ++ q2)
		if (*q1 != *q2) goto next;
	    return 1; /* matched */
	}
      next:;
    }
    return 0;
}

/* base の文字列に *s と *e に狭まれた文字列を追加 */
static void append_item(base, s, e)
     unsigned char *base;
     unsigned char *s;
     unsigned char *e;
{
    unsigned char *p, *q;

    for (p = base; *p >= 0x20; ++ p);
    for (q = s+1; q <= e; ++ q, ++ p)
	*p = *q;
    *p = '\0';
}

/* 各送りがなエントリは、"わりこmみ"のようなキーを持ち、
 * その値は、"/割り込/割込/"となる
 */
void add_okuri_item(key, s)
     DBT 		*key;
     unsigned char 	*s;
{
    unsigned char	*p, *headtop;
    unsigned char	keybuf[BLEN];
    unsigned char	content[BLEN];
    unsigned char	new[BLEN];

    int			len;
    DBT		otails, oheads;
    DBT		tkey, hkey;

    /* 見出しをコピー */
    strncpy(keybuf, key->data, key->size);
    tkey.data = (char *)keybuf;
    headtop = keybuf + key->size;	/* 語尾をどこにコピーするか */

    /* 語尾をtkeyにコピー */
    for (p = headtop; *s != '/'; s++, p++) {
	if (*s < 0x20) return;
	*p = *s;
    }
    tkey.size = p - keybuf;

    /* 語幹部分をcontentにコピーする */
    p = content; 
    for( ; *s != ']'; s++, p++) {
	if (*s < 0x20) return;
	*p = *s;
    }
    *p = '\0';
    if (*++s != '/') 
	return ;		/* フォーマットエラー */

    /* 古いものと比べて必要ならappend */
    if (okuriheaddb->get(okuriheaddb, NULL, &tkey, &otails, 0) != 0)  {
	db_append(tkey, content, okuriheaddb);
    } else {
	fseek(dbcontent, getpos(otails.data), 0);
	db_gets(new, BLEN, dbcontent);
	if (add_content_line(new, content, NULL))
	    db_append(tkey, new, okuriheaddb);
    }
}

/* tailsで指している文字列にlineの内容から語尾を選んで追加
 * このとき文字列は"/[あああ/[いいい/"のような形式となっている
 */
static int add_okuri_tail_line(tails, line)
     unsigned char 	*tails, *line;
{
    unsigned char     	*s, *e;
    int n_add;

    n_add = 0;
    for(s = line; (0x20 <= *s); ++ s) {
	if (*s == '/') {
	    if (s[1] == '[') {
		for(e = s+2; (0x20 <= *e); ++e) {
		    if (*e == '/') {
			if (!match_item(tails, s, e)) {
			    append_item(tails, s, e);
			    n_add ++;
			}
			s = e-1;
			goto next;
		    }
		}
		return n_add;
	    }
	}
      next:;
    }
    return n_add;
}

/* base が差している文字列に new の内容で重複しないものを加える
   何も加えなければ 0 を、それ以外は加えた熟語数を返す */
static int add_content_line(unsigned char *base, unsigned char *new, DBT *key)
{
    unsigned char *s, *e;
    int n_add;

    n_add = 0;
    for(s = new; (0x20 <= *s); ++ s) {
	if (*s == '/') {
	    if (s[1] == '[') {
		if (okurigana_flag) 
		    add_okuri_item(key, s + 2);
		for(s++ ; *s != ']'; ++s)
		    if (*s < 0x20) return n_add;
		goto next;
	    }
	    for(e = s+1; (0x20 <= *e); ++ e) {
		if (*e == '/') {
		    if (!match_item(base, s, e)) {
			append_item(base, s, e);
			n_add ++;
		    }
		    s = e-1;
		    goto next;
		}
	    }
	    return n_add;
	}
      next:;
    }
    return n_add;
}

/* いくつの「書き方」があるか数える */
static int item_number(p)
     unsigned char *p;
{
    int n = 0;
    for (p++ ; *p >= 0x20; ++ p)
	if (*p == '/') ++ n;
    return n;
}

static int line_process(unsigned char *buffer, DBT *key, unsigned char *kanji, unsigned char *tails)
{
    int key_len;

    if ((buffer[0] == ';') || (buffer[0] == '\0')) return 0;
    for (key_len = 1;
	(buffer[key_len] != ' ') || (buffer[key_len+1] != '/');
	++ key_len)
	if (buffer[key_len] == '\0') return 0;
    key->data = buffer;
    key->size = key_len;

    kanji[0] = tails[0] = '/';
    kanji[1] = tails[1] = '\0';
    add_content_line(kanji, buffer+key_len+1, key);
    if (okurigana_flag) 
	add_okuri_tail_line(tails, buffer+key_len+1);
    return item_number(kanji);
}

/* 指定された名前のファイルの内容を加える */
static void add_file(srcname)
     char *srcname;
{
    static unsigned char buffer[BLEN], kanji[BLEN], new[BLEN];
    static unsigned char tails[BLEN], tkeybuf[BLEN];
    DBT key, old, tkey;
    FILE *fp;

    if ((fp = fopen(srcname, "r")) == NULL) {
	perror(srcname);
	return;
    }
    while(fgets(buffer, BLEN, fp) != NULL) {
	if (line_process(buffer, &key, kanji, tails) > 0) {
	    if (okurigana_flag) {
		/* 語尾を登録 */
                if (tails[1] != '\0') {
		    if (okuritaildb->get(okuritaildb, NULL, &key, &old, 0) != 0) {
			db_append(key, tails, okuritaildb);
		    } else {
			fseek(dbcontent, getpos(old.data), 0);
			db_gets(new, BLEN, dbcontent);
			if (add_okuri_tail_line(new, tails))
			    db_append(key, new, okuritaildb);
		    }
		}
	    }

	    if (db->get(db, NULL, &key, &old, 0) != 0) {
		db_append(key, kanji, db);
	    } else {
		fseek(dbcontent, getpos(old.data), 0);
		db_gets(new, BLEN, dbcontent);
		if (add_content_line(new, kanji, NULL))
		    db_append(key, new, db);
	    }
	}
    }
    fclose(fp);
}

static void
delete_item(base, s, e)
     unsigned char *base;
     unsigned char *s;
     unsigned char *e;
/* base の文字列中に *s と *e に狭まれた文字列があれば削除 */
{
    unsigned char *p, *q1, *q2;

    for (p = base; *p != '\0'; ++ p) {
	if (*p == *s) {
	    for(q1 = p+1, q2 = s+1; q2 <= e; ++ q1, ++ q2)
		if (*q1 != *q2) goto next;
	    /* matched */
	    for(q2 = p+1; *q1 != '\0'; ++ q1, ++ q2)
		*q2 = *q1;
	    *q2 = '\0';
	    return;
	}
      next:;
    }
}

/* 各送りがなエントリは、"わりこmみ"のようなキーを持つことになる
 * その値は、"/割り込/割込/"となる
 */
void subtract_okuri_item(DBT *key, unsigned char *s)
{
    unsigned char	*p, *headtop;
    unsigned char	keybuf[BLEN];
    unsigned char	content[BLEN];
    unsigned char	new[BLEN];

    int			len;
    DBT		otails, oheads;
    DBT		tkey, hkey;

    /* 見出しをコピー */
    strncpy(keybuf, key->data, key->size);
    tkey.data = keybuf;
    headtop = keybuf + key->size;	/* 語尾をどこにコピーするか */

    /* 語尾をtkeyにコピー */ 
    for (p = headtop; *s != '/'; s++, p++) {
	if (*s < 0x20) return;
	*p = *s;
    }
    tkey.size = p - keybuf;

    /* 語幹部分をcontentにコピーする */
    p = content; 
    for( ; *s != ']'; s++, p++) {
	if (*s < 0x20) return;
	*p = *s;
    }
    *p = '\0';
    if (*++s != '/') 
	return ;		/* フォーマットエラー */

    /* 古いものと比べて必要ならreplace/delete */
    if (okuriheaddb->get(okuriheaddb, NULL, &tkey, &otails, 0) == 0)  {
	fseek(dbcontent, getpos(otails.data), 0);
	db_gets(new, BLEN, dbcontent);
	subtract_content_line(new, content, NULL);
	if (strlen(new) >= 3)
	    db_replace(otails.data, new);
        else
            okuriheaddb->del(okuriheaddb, NULL, &tkey, 0);
    }
}

/* tailで指している文字列からlineに含まれる語尾を削除
 */
void subtract_okuri_tail_line(tails, line)
     unsigned char 	*tails, *line;
{
    unsigned char     	*s, *e;

    for(s = line; (0x20 <= *s); ++ s) {
	if (*s == '/') {
	    if (s[1] == '[') {
		for(e = s+2; (0x20 <= *e); ++e) {
		    if (*e == '/') {
			delete_item(tails, s, e);
			s = e-1;
			goto next;
		    }
		}
		return;
	    }
	}
      next:;
    }
    return;
}

/* base の文字列中から new 中の文字列を削除 */
static void
subtract_content_line(unsigned char *base, unsigned char *new, DBT *key)
{
    unsigned char *s, *e;

    for(s = new; (0x20 <= *s); ++ s) {
	if (*s == '/') {
	    if (s[1] == '[') {
		if (okurigana_flag)
		    subtract_okuri_item(key, s + 2);
		for(s++; *s != ']'; ++s)
		    if (*s < 0x20) return;
		goto next;
	    }
	    for(e = s+1; (0x20 <= *e); ++ e) {
		if (*e == '/') {
		    delete_item(base, s, e);
		    s = e-1;
		    goto next;
		}
	    }
	    return;
	}
      next:;
    }
}

/* 与えた名前の辞書の内容を現在の辞書から削除する */
static void subtract_file(srcname)
     char *srcname;
{
    static unsigned char buffer[BLEN], kanji[BLEN], new[BLEN];
    static unsigned char tails[BLEN], tkeybuf[BLEN];
    DBT key, old, tkey;
    FILE *fp;

    if ((fp = fopen(srcname, "r")) == NULL) {
	perror(srcname);
	return;
    }
    while(fgets(buffer, BLEN, fp) != NULL) {
	/* 行から「読み(key)」と「書き方(content)」を取り出す。
	   もしもコメント行等であれば飛ばす */
	if (line_process(buffer, &key, kanji, tails) > 0) {
	    /* 辞書にすでにあればそれから削除する。なければ何もしない */

	    if (okurigana_flag) {
		if (tails[1] != '\0') {
		    if (okuritaildb->get(okuritaildb, NULL, &key, &old, 0) == 0) {
			fseek(dbcontent, getpos(old.data), 0);
			db_gets(new, BLEN, dbcontent);
			subtract_okuri_tail_line(new, tails);
			if (strlen(new) >= 3)
			    db_replace(old.data, new);
                        else
                            okuritaildb->del(okuritaildb, NULL, &key, 0);
		    }
		}
	    }

	    if (db->get(db, NULL, &key, &old, 0) == 0) {
		fseek(dbcontent, getpos(old.data), 0L);
		db_gets(new, BLEN, dbcontent);
		subtract_content_line(new, kanji, &key);
		if (strlen(new) >= 3)
		    db_replace(old.data, new);
                else
                    db->del(db, NULL, &key, 0);
	    }
	}
    }
    fclose(fp);
}

void okuri_type_out(DBT *key, FILE *output)
{
    unsigned char	*s, *e, *headtop;
    unsigned char	keybuf[BLEN];
    unsigned char	tail_content[BLEN];
    unsigned char	head_content[BLEN];

    DBT	tails, tkey;
    DBT	one;

    /* 見出しをコピー */
    strncpy(keybuf, key->data, key->size);
    tkey.data = keybuf;
    tkey.size = key->size;
    headtop = keybuf + tkey.size;	/* 語尾をどこにコピーするか */

    if (okuritaildb->get(okuritaildb, NULL, &tkey, &tails, 0) != 0)  {
	return;
    } else {
	fseek(dbcontent, getpos(tails.data), 0);
	db_gets(tail_content, BLEN, dbcontent);

	s = tail_content + 2; 		/* '/'と'['をとばす */
	for(e = s; e[1] != '\0'; s = e + 2) {
	    for (e = s; *e != '/'; e++)
		if (*e < 0x20) 
		    return;

	    strncpy(headtop, s, e - s);
            tkey.size = (headtop - keybuf) + (e - s);

	    if (okuriheaddb->get(okuriheaddb, NULL, &tkey, &one, 0) != 0) {
		continue;
	    } else {
		fseek(dbcontent, getpos(one.data), 0);
		db_gets(head_content, BLEN, dbcontent);

		putc('[', output);
		while (s != e)
		    putc(*s++, output);		    
		fputs(head_content, output);
		fputs("]/", output);
	    }
	}
    }
}

/* 結果を出力
   順序はまったくのでたらめになるので、最終的な結果を得るには
   skkdic-sort を用いる
   */
static void type_out(output)
     FILE *output;
{
    DBT key, content;
    int i;
    unsigned char kanji[BLEN];

    DBC *cursor;
    db->cursor(db, NULL, &cursor, 0);

    while (cursor->get(cursor, &key, &content, DB_NEXT) == 0) {
	for(i = 0; i < key.size; ++ i)
	    putc(((char *)key.data)[i], output);
	putc(' ', output);
	fseek(dbcontent, getpos(content.data), 0);
	db_gets(kanji, BLEN, dbcontent);
	fputs(kanji, output);
	if (okurigana_flag)
	    okuri_type_out(&key, output);
	putc('\n', output);
    }

    if (okurigana_flag) {
        DBT entry;
        DBC *cursor;
        okuritaildb->cursor(okuritaildb, NULL, &cursor, 0);
        while (cursor->get(cursor, &key, &entry, DB_NEXT) == 0) {
	    for(i = 0; i < key.size; ++ i)
		putc(((char *)key.data)[i], output);
	    putc(' ', output);
	    putc('/', output);
	    okuri_type_out(&key, output);
	    putc('\n', output);
	}
    }
}

/* 使用法を表示 */
static void print_usage(argc, argv)
     int argc;
     char **argv;
{
    fprintf(stderr,
	    "Usage: %s [-d workdir] [-o output] [-O] jisyo1 [[+-] jisyo2]...\n",
	    argv[0]);
}

/* メインプログラム  引数を処理する */
int main(argc, argv)
     int argc;
     char **argv;
{
    int negate, i;
    FILE *output;
    char *tmpdir;

    output = stdout;

    tmpdir = getenv("TMPDIR");
    if (tmpdir == NULL) {
      tmpdir = TMPDIR;
    }

    /* 引数の処理 */
    for (i = 1; i < argc; ++ i) {
	if (argv[i][0] == '-') {
	    if (argv[i][1] == 'd') { /* -d 作業ディレクトリ */
		tmpdir=argv[i+1];
		i ++;
	    } else if (argv[i][1] == 'o') { /* -o 出力ファイル */
		if ((output = fopen(argv[i+1], "w")) == NULL) {
		    perror(argv[i+1]);
		    exit(1);
		}
		i ++;
	    } else if (argv[i][1] == 'O') { /* 送りがなの処理の指定  */
		okurigana_flag++;
	    } else {
		print_usage(argc, argv);
		exit(1);
	    }
	} else {
	    break;
	}
    }

    if (i >= argc) { /* 辞書が指定されていない */
	print_usage(argc, argv);
	exit(1);
    }

#ifdef HAVE_MKDTEMP
    snprintf(tmpsubdir, sizeof(tmpsubdir), "%s/skkdicXXXXXX", tmpdir);
    if (mkdtemp(tmpsubdir) == NULL) {
#else /* not HAVE_MKDTEMP */
    snprintf(tmpsubdir, sizeof(tmpsubdir), "%s/skkdic%d", tmpdir, getpid());
    if (mkdir(tmpsubdir, 0700)) {
#endif /* not HAVE_MKDTEMP */
	perror(tmpsubdir);
	exit(1);
    }
    tmpdir = tmpsubdir;
    snprintf(file_name, sizeof(file_name), "%s/skkdic%d", tmpdir, getpid());
    if (okurigana_flag) {
	snprintf(okuri_head_name, sizeof(okuri_head_name), "%s/skkhead%d", tmpdir, getpid());
	snprintf(okuri_tail_name, sizeof(okuri_tail_name), "%s/skktail%d", tmpdir, getpid());
    }
    set_signal_handler();
    db_make_files();

    negate = 0;
    for (; i < argc; ++ i) {
	if (argv[i][0] == '+') {
	    negate = 0;
	    if (strlen(argv[i]) > 1)
		add_file(argv[i]+1);
	} else if (argv[i][0] == '-') {
	    negate = 1;
	    if (strlen(argv[i]) > 1) {
		subtract_file(argv[i]+1);
		negate = 0;
	    }
	} else {
	    if (negate == 0)
		add_file(argv[i]);
	    else
		subtract_file(argv[i]);
	}
    }
    type_out(output);
    db_remove_files();
    rmdir(tmpsubdir);
    return 0;
}

/* end of skkdic-expr.c */
