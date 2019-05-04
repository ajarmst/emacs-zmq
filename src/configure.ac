AC_PREREQ([2.69])

AC_INIT([emacs-zmq], [0.1], [nathanielnicandro@gmail.com])
AC_CONFIG_SRCDIR([core.c])
AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([-Wall -Wno-override foreign])

AC_PROG_CC
AM_PROG_AR
AC_CANONICAL_HOST
AM_CONDITIONAL(WINDOWS, [test "$host_os" = mingw32])
AM_CONDITIONAL(DARWIN, [test "$host_vendor" = apple])

LT_INIT([win32-dll shared disable-static])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
