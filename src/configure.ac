AC_PREREQ([2.69])

AC_INIT([emacs-zmq], [0.10.9], [nathanielnicandro@gmail.com])
AC_CONFIG_SRCDIR([core.c])
AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([-Wall -Wno-override foreign])
AC_PROG_CC
AM_PROG_AR
AC_CANONICAL_HOST
AM_CONDITIONAL(WINDOWS, [test "$host_os" = mingw32])
AM_CONDITIONAL(DARWIN, [test "$host_vendor" = apple])

# Ensure the libzmq/configure script is generated
cd libzmq
if test "`git describe --candidates=0 2>/dev/null || echo x`" != v$ZMQ_VERSION; then
    git checkout --quiet master
    git pull --quiet origin
    git checkout v$ZMQ_VERSION
    rm -f configure
fi
if test ! -e configure; then
    ./autogen.sh
fi
cd ..
AC_CONFIG_SUBDIRS([libzmq])

CXXFLAGS="-static -static-libgcc -static-libstdc++ $CXXFLAGS"
case "${host_os}" in
    *darwin*)
        ;;
    *mingw*|*msys*|*cygwin*)
        LDFLAGS="-Wl,-l:libgcc.a -Wl,-l:libstdc++.a -Wl,-lws2_32 -Wl,-liphlpapi $LDFLAGS"
        ;;
    *)
        # Assume GCC compatible compiler
        # TODO: Actually check for this
        # PIC is needed since it isn't the default with GCC
        #
        # For tweetnacl which is a C library and comes packaged with libzmq
        CFLAGS="-fPIC $CFLAGS"
        CXXFLAGS="-fPIC $CXXFLAGS"
        LDFLAGS="-Wl,-l:libgcc.a -Wl,-l:libstdc++.a $LDFLAGS"
        ;;
esac

LT_INIT([win32-dll shared disable-static])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
