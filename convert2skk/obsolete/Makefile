PERL = /afs/cs/project/cmt/bin/perl

FILES = Makefile README \
	codeconv.pl roma2kana.pl kana2roma.pl \
	convprog.t \
	skk2list.t pubdic2list.t list2skk.t \
	adddummy.t removedummy.t \
	skkconv.t sub.t
LIBS = codeconv.pl roma2kana.pl kana2roma.pl
SKKPROGS = skk2list pubdic2list list2skk adddummy removedummy sub skkconv
CONVPROGS = sjis2jis jis2sjis ujis2jis jis2ujis roma2kana kana2roma
PROGS = $(SKKPROGS) $(CONVPROGS)
CONVPROG = convprog

all: $(PROGS)
	chmod +x $(PROGS)
	/bin/rm -f $(CONVPROG)
$(SKKPROGS):
	sed -e 's#PERLPATH#$(PERL)#' < $@.t > $@
$(CONVPROGS): $(CONVPROG)
	ln $(CONVPROG) $@
$(CONVPROG):
	sed -e 's#PERLPATH#$(PERL)#' < $@.t > $@

clean:
	/bin/rm -f $(PROGS)

DIST = skktools.tar
tar:
	tar cvf $(DIST) $(FILES)
