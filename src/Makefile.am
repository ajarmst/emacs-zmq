ZMQ_GIT_REPO ?= https://github.com/zeromq/libzmq

ACLOCAL_AMFLAGS = -I m4
# The version of ZMQ to build
ZMQ_VERSION ?= 4.3.1

lib_LTLIBRARIES = emacs-zmq.la
emacs_zmq_la_LDFLAGS = -module -avoid-version
emacs_zmq_la_SOURCES = socket.c context.c msg.c constants.c util.c core.c poll.c emacs-zmq.c
emacs_zmq_la_CFLAGS = -O3 -DZMQ_BUILD_DRAFT_API=1 -I$(CURDIR)/libzmq-build/include
emacs_zmq_la_DEPENDENCIES = libzmq-build/lib/libzmq.la

if WINDOWS
libzmq_CXXFLAGS = -static -static-libgcc -static-libstdc++
emacs_zmq_la_LDFLAGS += -no-undefined -Wl,libzmq-build/lib/libzmq.a
emacs_zmq_la_LDFLAGS += -Wl,-l:libgcc.a -Wl,-l:libstdc++.a -Wl,-lws2_32 -Wl,-liphlpapi
else
emacs_zmq_la_LDFLAGS += -Wl,-Llibzmq-build/lib,-lzmq
if !DARWIN
# TODO: Verify gcc compiler
# PIC is needed since it isn't the default with GCC
#
# For tweetnacl which is a C library and comes packaged with libzmq
libzmq_CFLAGS = -fPIC
libzmq_CXXFLAGS = -fPIC -static-libgcc -static-libstdc++
emacs_zmq_la_LDFLAGS += -Wl,-l:libgcc.a -Wl,-l:libstdc++.a
else
endif
endif

libzmq/.git:
	git clone --quiet $(ZMQ_GIT_REPO) libzmq

# Don't rely on .git directory as a dependency since its timestamp is updated
# on every checkout.
libzmq/v-$(ZMQ_VERSION):
	@if ! test -d libzmq/.git; then $(MAKE) libzmq/.git; fi
	cd libzmq && \
		$(RM) v-* && \
		git checkout master && \
		git pull --quiet origin && \
		git checkout v$(ZMQ_VERSION) && \
		touch v-$(ZMQ_VERSION)

libzmq/configure: libzmq/v-$(ZMQ_VERSION)
	cd libzmq && ./autogen.sh

libzmq/vh-$(ZMQ_VERSION)-$(host): libzmq/configure
	cd libzmq && \
		$(RM) vh-* && \
		./configure CFLAGS="$(libzmq_CFLAGS)" CXXFLAGS="$(libzmq_CXXFLAGS)" \
		--host=$(host_alias) \
		--prefix=$(CURDIR)/libzmq-build \
		--libdir=$(CURDIR)/libzmq-build/lib \
		--quiet --without-docs --enable-drafts=yes --enable-libunwind=no \
		--enable-static=yes --enable-shared=no \
		--disable-curve-keygen --disable-perf --disable-eventfd && \
		touch vh-$(ZMQ_VERSION)-$(host)

libzmq-build/lib/libzmq.la: libzmq/vh-$(ZMQ_VERSION)-$(host)
	$(MAKE) -C libzmq install

.PHONY: build-libzmq
build-libzmq: libzmq-build/lib/libzmq.la

.PHONY: clean-libzmq
clean-libzmq:
	$(MAKE) -C libzmq clean
	$(RM) libzmq/v-* libzmq/vh-*
