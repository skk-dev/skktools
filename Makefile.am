## Makefile for the toplevel directory of SKK JISYO TOOLS
## (SKK dictionary handling tools).
## Copyright (C) 2002 SKK Development Team <skk@ring.gr.jp>
##
## Author: SKK Development Team <skk@ring.gr.jp>
## Maintainer: SKK Development Team <skk@ring.gr.jp>
## Version: $Id: Makefile.am,v 1.1 2002/09/20 12:18:47 iida Exp $
## Keywords: japanese
## Last Modified: $Date: 2002/09/20 12:18:47 $
##
## This file is part of Daredevil SKK.
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to
## the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
## Boston, MA 02111-1307, USA.

## Process this file with automake to produce Makefile.in

AUTOMAKE_OPTIONS = foreign
bin_PROGRAMS  = skkdic-expr \
		skkdic-sort \
		skkdic-count \
		@SKKDIC_EXPR2@
CLEANFILES    = core
EXTRA_DIST    = READMEs \
		VERSION \
		convert2skk \
		dbm \
		skk-xml.el \
		unannotation.awk
EXTRA_PROGRAMS = skkdic-expr2
skkdic_expr2_CFLAGS = $(GLIB2_CFLAGS)
skkdic_expr2_LDADD = $(GLIB2_LIBS)
SNAPBASE      = $(PACKAGE)-$(THEDATE)
SNAPSHOTDIR   = $(srcdir)/..
TARDIR	      = $(srcdir)/..
THEDATE	      = `$(DATE) '+%Y%m%d'`

dist-hook:
	rm -rf `find $(distdir) -name CVS`

snapshot:
	ss=$(SNAPSHOTDIR); pv=$(PACKAGE)-$(VERSION); tg=$$pv.tar.gz; \
	sb=$(SNAPBASE); st=$$sb.tar; sg=$$st.gz; s2=$$st.bz2; \
	test -f $tg || $(MAKE) $(AM_MAKEFLAGS) dist; \
	case "$$ss" in \
	'') ss=`pwd`;; \
	*) test -d "$$ss" || $(mkinstalldirs) "$$ss";; \
	esac; \
	$(GZIP) -d <$$tg | $(TAR) xf -; \
	rm -rf "$$sb"; \
	mv $$pv "$$sb"; \
	$(TAR) cvpf $$st "$$sb"; \
	$(BZIP2) -cf <$$st >$$s2; $(GZIP) -cf <$$st >$$sg; \
	rm -rf $$st "$$sb"; \
	$(MD5) $$s2 >$$s2.md5; $(MD5) $$sg >$$sg.md5; \
	case "$$ss" in \
	''|.) ;; \
	*) mv $$s2 $$s2.md5 $$sg $$sg.md5 "$$ss";; \
	esac

tar:
	td=$(TARDIR); tf=$(PACKAGE)-$(VERSION).tar; tg=$$tf.gz; tb=$$tf.bz2; \
	test -f $tg || $(MAKE) $(AM_MAKEFLAGS) dist; \
	case "$$td" in \
	'') td=`pwd`;; \
	.) ;; \
	*) test -d "$$ss" || $(mkinstalldirs) "$$td"; cp $$tg "$$td";; \
	esac; \
	cd "$$td"; \
	$(MD5) $$tg >$$tg.md5; \
	$(GZIP) -d <$$tg | $(BZIP2) -cf >$$tb; \
	$(MD5) $$tb >$$tb.md5

## Makefile.am ends here
