/* SKK JISYO TOOLS (SKK dictionary handling tools)
Copyright (C) 2002 Kentaro Fukuchi

Author: Kentaro Fukuchi
Maintainer: Kentaro Fukuchi <fukuchi@users.sourceforge.net>
Version: $Id: skkdic-expr2.c,v 1.4 2003/07/25 08:20:19 fukuchi Exp $
Keywords: japanese
Last Modified: $Date: 2003/07/25 08:20:19 $

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
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
*/

/* skkdic-expr2.c
   このプログラムは SKK の辞書のマージや削除を行います。
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include <errno.h>

#define ANNOTATION_DELIMITER ","

typedef struct {
	gchar *candidate;
	gchar *annotation;
	gboolean flag;
} Candidate;

typedef struct {
	GSList *entries;
} Entry;

#ifndef errno
extern int errno;
#endif

/* 1994 年版の SKK 辞書では最長の行でも 656 文字ですが安全のために
   以下の値としています。*/

#ifdef MAXLINE
#define BLEN MAXLINE
#else
#define BLEN 4096
#endif

/* 辞書ツリー */
GTree *okuriAri;
GTree *okuriNashi;

static gint strCmp(gconstpointer, gconstpointer, gpointer);
static gint strCmpR(gconstpointer, gconstpointer, gpointer);
static void entryFree(Entry *);
static int isOkuriAri(gchar *);

static void treeKeyDestroy(gpointer key)
{
	g_free(key);
}

static void treeValueDestroy(gpointer value)
{
	entryFree((Entry *)value);
}

static void initTrees()
{
	okuriAri = g_tree_new_full(strCmpR, NULL, treeKeyDestroy, treeValueDestroy);
	okuriNashi = g_tree_new_full(strCmp, NULL, treeKeyDestroy, treeValueDestroy);
}

static Candidate *candidateNew(gchar *candidate, gchar *annotation)
{
	Candidate *c;

	c = g_new(Candidate, 1);
	c->candidate = g_strdup(candidate);
	c->annotation = g_strdup(annotation);
	c->flag = FALSE;

	return c;
}

static void candidateFree(Candidate *c)
{
	g_free(c->candidate);
	g_free(c->annotation);
	g_free(c);
}

static Entry *entryNew()
{
	Entry *e;

	e = g_new(Entry, 1);
	e->entries = NULL;

	return e;
}

static void entryFree(Entry *e)
{
	g_slist_free(e->entries);
	g_free(e);
}

static void joinAnnotation(Candidate *c, gchar *str)
{
	gchar *tmp;

	if(str != NULL) {
		if(c->annotation == NULL) {
			c->annotation = g_strdup(str);
		} else {
			tmp = g_strjoin(ANNOTATION_DELIMITER, c->annotation, str, NULL);
			g_free(c->annotation);
			c->annotation = tmp;
		}
	}
}

static void addCandidate(GTree *tree, gchar *midashi, gchar *candidate, gchar *annotation)
{
	Entry *e;
	Candidate *c;
	GSList *list;

	e = g_tree_lookup(tree, midashi);
	if(e == NULL) {
		e = entryNew();
		g_tree_insert(tree, g_strdup(midashi), e);
		c = candidateNew(candidate, annotation);
		e->entries = g_slist_append(e->entries, c);
	} else {
		list = e->entries;
		while(list != NULL) {
			c = (Candidate *)list->data;
			if(strCmp(c->candidate, candidate, NULL) == 0) {
				joinAnnotation(c, annotation);
				break;
			}
			list = g_slist_next(list);
		}
		if(list == NULL) {
			c = candidateNew(candidate, annotation);
			e->entries = g_slist_append(e->entries, c);
		}
	}
}

static void removeCandidate(GTree *tree, gchar *midashi, gchar *candidate)
{
	Entry *e;
	Candidate *c;
	GSList *list;

	e = g_tree_lookup(tree, midashi);
	if(e != NULL) {
		list = e->entries;
		while(list != NULL) {
			c = (Candidate *)list->data;
			if(strCmp(c->candidate, candidate, NULL) == 0) {
				e->entries = g_slist_remove(e->entries, c);
				candidateFree(c);
				break;
			}
			list = g_slist_next(list);
		}
		if(e->entries == NULL) {
			g_tree_remove(tree, midashi);
		}
	}
}

static void andCandidate(GTree *tree, gchar *midashi, gchar *candidate)
{
	Entry *e;
	Candidate *c;
	GSList *list;

	e = g_tree_lookup(tree, midashi);
	if(e != NULL) {
		list = e->entries;
		while(list != NULL) {
			c = (Candidate *)list->data;
			if(strCmp(c->candidate, candidate, NULL) == 0) {
				c->flag = TRUE;
				break;
			}
			list = g_slist_next(list);
		}
	}
}

static GSList *blackList = NULL;
static gboolean cleanFunc(gpointer key, gpointer value, gpointer data)
{
	Entry *e = (Entry *)value;
	Candidate *c;
	GSList *list, *next;

	list = e->entries;
	while(list != NULL) {
		c = (Candidate *)list->data;
		next = g_slist_next(list);
		if(!c->flag) {
			e->entries = g_slist_delete_link(e->entries, list);
			candidateFree(c);
		} else {
			c->flag = FALSE;
		}
		list = next;
	}
	if(e->entries == NULL) {
		blackList = g_slist_prepend(blackList, key);
	}

	return FALSE;
}

static void cleanTree(GTree *tree)
{
	GSList *list;

	g_tree_foreach(tree, cleanFunc, NULL);
	list = blackList;
	while(list != NULL) {
		g_tree_remove(tree, list->data);
		list = g_slist_next(list);
	}

	g_slist_free(blackList);
	blackList = NULL;
}

static GSList *splitCandidates(gchar *str)
{
	unsigned char *p, *q;
	GSList *list = NULL;

	p = str;
	while(*p >= 0x20) {
		if(*p == '/') {
			q = ++p;
			if(*q < 0x20) break;
			if(*q == '[') {
				while(*q != ']') {
					q++;
				}
				p = q;
				continue;
			}
			while(*q != '/') {
				if(*q == '\0') break;
				q++;
			}
			list = g_slist_append(list, g_strndup(p, (int)q - (int)p));
			p = q;
		} else {
			p++;
		}
	}

	return list;
}

static gchar *findValue(gchar *p)
{
	while(*p != '\0') {
		if(*p == ' ') break;
		p++;
	}

	if(*p == ' ') {
		*p = '\0';
		return p + 1;
	}

	return NULL;
}

static int processMode = 0;

static void processCandidate(GTree *tree, gchar *midashi, gchar *candidate)
{
	gchar *p, *q;

	p = candidate;
	q = NULL;
	while(*p != '\0') {
		if(*p == ';') {
			q = p + 1;
			*p = '\0';
			break;
		}
		p++;
	}

	switch(processMode) {
	case 2:
		andCandidate(tree, midashi, candidate);
		break;
	case 1:
		removeCandidate(tree, midashi, candidate);
		break;
	case 0:
	default:
		addCandidate(tree, midashi, candidate, q);
		break;
	}
}

static void processFile(const char *filename)
{
	FILE *fp;
	static gchar buffer[BLEN];
	gchar *cands;
	GSList *clist, *list;

	if((fp = fopen(filename, "r")) == NULL) {
		perror(filename);
		return;
	}

	while(fgets(buffer, BLEN, fp) != NULL) {
		if(buffer[0] == ';' || buffer[0] == '\0') continue;
		cands = findValue(buffer);
		if(cands != NULL) {
			clist = splitCandidates(cands);
			list = clist;
			if(isOkuriAri(buffer)) {
				while(list != NULL) {
					processCandidate(okuriAri, buffer, (gchar *)list->data);
					g_free(list->data);
					list = g_slist_next(list);
				}
			} else {
				while(list != NULL) {
					processCandidate(okuriNashi, buffer, (gchar *)list->data);
					g_free(list->data);
					list = g_slist_next(list);
				}
			}
			g_slist_free(clist);
		}
	}
	fclose(fp);
}

static void addFile(const char *filename)
{
	processMode = 0;
	processFile(filename);
}

static void subFile(const char *filename)
{
	processMode = 1;
	processFile(filename);
}

static void andFile(const char *filename)
{
	processMode = 2;
	processFile(filename);
	cleanTree(okuriAri);
	cleanTree(okuriNashi);
}

static FILE *output;

static gboolean outputFunc(gpointer key, gpointer value, gpointer data)
{
	Entry *e = (Entry *)value;
	Candidate *c;
	GSList *list;

	fprintf(output, "%s /", (char *)key);

	list = e->entries;
	while(list != NULL) {
		c = (Candidate *)list->data;
		if(c->annotation) {
			fprintf(output, "%s;%s/", c->candidate, c->annotation);
		} else {
			fprintf(output, "%s/", c->candidate);
		}
		list = g_slist_next(list);
	}
	fputs("\n", output);

	return FALSE;
}

static void outputTrees()
{
	fputs(";; okuri-ari entries.\n", output);
	g_tree_foreach(okuriAri, outputFunc, NULL);
	fputs(";; okuri-nasi entries.\n", output);
	g_tree_foreach(okuriNashi, outputFunc, NULL);
}

static void print_usage(char *title)
{
	fprintf(stderr,
		"Usage: %s [-o output] jisyo1 [[+-^] jisyo2]...\n", title);
}

int main(int argc, char **argv)
{
	int negate, i;

	output = stdout;

	for(i=1; i<argc; i++) {
		if(argv[i][0] == '-') {
			if(argv[i][1] == 'o') {/* -o 出力ファイル */
				i++;
				if((output = fopen(argv[i], "w")) == NULL) {
					perror(argv[i]);
					exit(1);
				}
			} else {
				print_usage(argv[0]);
				exit(1);
			}
		} else {
			break;
		}
	}

	if(i >= argc) { /* 辞書が指定されていない */
		print_usage(argv[0]);
		exit(1);
	}

	initTrees();
	negate = 0;
	for(; i<argc; i++) {
		if(argv[i][0] == '+') {
			negate = 0;
			if(strlen(argv[i]) > 1) {
				addFile(argv[i]+1);
			}
		} else if(argv[i][0] == '-') {
			negate = 1;
			if(strlen(argv[i]) > 1) {
				subFile(argv[i]+1);
				negate = 0;
			}
		} else if(argv[i][0] == '^') {
			negate = 2;
			if(strlen(argv[i]) > 1) {
				andFile(argv[i]+1);
				negate = 0;
			}
		} else {
			switch(negate) {
			case 2:
				andFile(argv[i]);
				break;
			case 1:
				subFile(argv[i]);
				break;
			case 0:
			default:
				addFile(argv[i]);
				break;
			}
		}
	}

	outputTrees();

	return 0;
}

static int isOkuriAri(gchar *p)
{
	if ((*p & 0x80) == 0)
		return 0;
	while(*p != '\0') {
		if ((*p >= 'a') && (*p <= 'z'))
			return 1;
		p++;
	}
	return 0;
}

static gint strCmp(gconstpointer a, gconstpointer b, gpointer data)
{
	return strcmp(a, b);
}

static gint strCmpR(gconstpointer a, gconstpointer b, gpointer data)
{
	return strcmp(b, a);
}
