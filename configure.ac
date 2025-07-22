dnl -*- mode: autoconf -*-
dnl Process this file with autoconf to produce a configure script.
AC_INIT
AC_CONFIG_SRCDIR([skkdic-count.c])
AM_INIT_AUTOMAKE(skktools, `cat <"${srcdir}"/VERSION`)
AM_CONFIG_HEADER([config.h])

AC_ARG_WITH(gdbm,
  [  --with-gdbm             use gdbm instead of ndbm],
  [WITH_GDBM="$withval"])

AC_ARG_WITH(skkdic-expr2,
  [  --without-skkdic-expr2  skip compiling skkdic-expr2],
  [WITH_SKKDIC_EXPR2="$withval"])

dnl checks for Unix variants
AC_USE_SYSTEM_EXTENSIONS

dnl Checks for programs.
AC_PROG_AWK
AC_PROG_CC
AC_PROG_INSTALL
LT_INIT
dnl AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PATH_PROG(BZIP2, bzip2)
AC_PATH_PROG(DATE, date)
AC_PATH_PROG(GZIP, gzip)
AC_PATH_PROGS(MD5, md5 md5sum)
AC_PATH_PROG(TAR, tar,, /usr/local/bin:$PATH)
dnl Checks for executable suffix.
AC_EXEEXT

dnl Checks for system functions.

AC_CHECK_FUNCS(mkdtemp snprintf)
dnl if test $ac_cv_func_snprintf = no; then
dnl    echo "Error: snprintf() not available." >&2 && exit 1
dnl fi

dnl Checks for libraries.

if test "$WITH_GDBM" = yes; then
   AC_CHECK_LIB(gdbm, dbm_open,, AC_CHECK_LIB(gdbm_compat, dbm_open,,, -lgdbm))

   if test "$ac_cv_lib_gdbm_compat_dbm_open" = yes; then
      AC_CHECK_HEADERS(gdbm/ndbm.h)
      if test "$ac_cv_header_gdbm_ndbm_h" = yes; then
         LIBS="$LIBS  -lgdbm"
         cat >>confdefs.h <<_ACEOF
#define HAVE_LIBGDBM 1
_ACEOF
      else
         LIBS=""
      fi
   fi

fi

if test "x$LIBS" = x; then
   AC_CHECK_FUNC(dbm_open,, AC_CHECK_LIB(ndbm, dbm_open))
   if test "$ac_cv_func_dbm_open" = no; then
      if test "x$LIBS" = x; then
         AC_CHECK_LIB(db, __db_ndbm_open)
      fi
      if test "x$LIBS" = x; then
         AC_CHECK_LIB(gdbm, dbm_open,, AC_CHECK_LIB(gdbm_compat, dbm_open,,, -lgdbm))

         if test "$ac_cv_lib_gdbm_compat_dbm_open" = yes; then
            AC_CHECK_HEADERS(gdbm/ndbm.h)
            if test "$ac_cv_header_gdbm_ndbm_h" = yes; then
               LIBS="$LIBS  -lgdbm"
               cat >>confdefs.h <<_ACEOF
#define HAVE_LIBGDBM 1
_ACEOF
            else
               LIBS=""
            fi
         fi

      fi
   fi
fi

PKG_CHECK_MODULES(GLIB2, glib-2.0 >= 2.0.0, HAVE_GLIB2=yes, HAVE_GLIB2=no)
  case "$HAVE_GLIB2" in
	yes) SKKDIC_EXPR2="skkdic-expr2\${EXEEXT}" ;;
	no)  SKKDIC_EXPR2="" ;;
  esac

if test "${WITH_SKKDIC_EXPR2}" = no; then
  SKKDIC_EXPR2=""
fi
AC_SUBST(GLIB2_LIBS)
AC_SUBST(GLIB2_CFLAGS)
AC_SUBST(SKKDIC_EXPR2)

dnl Checks for header files.
AC_CHECK_HEADERS([fcntl.h glib.h malloc.h])

if test "$ac_cv_func_dbm_open" = yes || test "$ac_cv_lib_ndbm_dbm_open" = yes; then
    AC_CHECK_HEADERS(ndbm.h)
    if test "$ac_cv_header_ndbm_h" = no; then
	AC_CHECK_HEADERS(db1/ndbm.h)
    fi
fi

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST

dnl Checks for library functions.
AC_FUNC_MALLOC
m4_warn([obsolete],[your code may safely assume C89 semantics that RETSIGTYPE is void.
Remove this warning and the `AC_CACHE_CHECK' when you adjust the code.])dnl
AC_CACHE_CHECK([return type of signal handlers],[ac_cv_type_signal],[AC_COMPILE_IFELSE(
[AC_LANG_PROGRAM([#include <sys/types.h>
#include <signal.h>
],
		 [return *(signal (0, 0)) (0) == 1;])],
		   [ac_cv_type_signal=int],
		   [ac_cv_type_signal=void])])
AC_DEFINE_UNQUOTED([RETSIGTYPE],[$ac_cv_type_signal],[Define as the return type of signal handlers
		    (`int' or `void').])


AC_CONFIG_FILES([Makefile])
AC_OUTPUT
