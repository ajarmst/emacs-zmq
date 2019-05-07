ROOT = .
SHELL = bash
EMACS ?= emacs
EFILES := zmq.el
# CPPFLAGS = -DEZMQ_DEBUG=0
ELCFILES = $(EFILES:.el=.elc)

# The version of ZMQ to build
export ZMQ_VERSION ?= 4.3.1
# Set ZMQ_BUILD_HOST to a host triple to enable cross compiling
export ZMQ_BUILD_HOST ?=
# Directory in which the emacs-zmq module will be written
EZMQ_LIBDIR ?= $(CURDIR)/$(ZMQ_BUILD_HOST)

# Get the module extension for this build
ifeq ($(ZMQ_BUILD_HOST),)
ifneq (,$(or $(findstring MSYS, $(MSYSTEM))), \
			 $(findstring MINGW, $(MSYSTEM)))
SHARED_EXT := .dll
else
SHARED_EXT := .so
endif
else
ifneq (,$(or $(findstring mingw, $(ZMQ_BUILD_HOST)), \
			 $(findstring cygwin, $(ZMQ_BUILD_HOST)), \
			 $(findstring msys, $(ZMQ_BUILD_HOST))))
SHARED_EXT := .dll
else
SHARED_EXT := .so
endif
endif

SHARED := emacs-zmq$(SHARED_EXT)

.PHONY: all
all: $(EZMQ_LIBDIR)/$(SHARED) compile

$(EZMQ_LIBDIR)/$(SHARED): src/Makefile
	$(MAKE) -C src build-libzmq
	$(MAKE) CPPFLAGS=$(CPPFLAGS) -C src install

src/Makefile: src/Makefile.am src/configure
	cd src && ./configure --host=$(ZMQ_BUILD_HOST) --libdir=$(EZMQ_LIBDIR)

src/configure: src/configure.ac
	cd src && autoreconf -i

.PHONY: test
test:
	$(EMACS) -nw -Q -batch -L . -l ert -l zmq-tests.el \
		--eval "(ert-run-tests-batch-and-exit)"

.PHONY: clean
clean:
	$(MAKE) -C src clean
	$(RM) emacs-zmq.* $(ELCFILES)

.PHONY: clean-zmq-build
clean-zmq-build:
	$(RM) -r src/libzmq-build
	$(MAKE) -C src clean-libzmq

.PHONY: compile
compile: $(ELCFILES)

$(ELCFILES): %.elc: %.el
	$(EMACS) --batch -Q -L . -f batch-byte-compile $<

ifeq ($(ZMQ_BUILD_HOST),)
PRODUCT := emacs-zmq-$(shell $(CC) -dumpmachine)
else
PRODUCT := emacs-zmq-$(ZMQ_BUILD_HOST)
endif

.PHONY: products
products: products/$(PRODUCT).tar.gz.sha256

products/$(PRODUCT).tar.gz: $(EZMQ_LIBDIR)/$(SHARED)
	mkdir -p products/$(PRODUCT)
	cp $(EZMQ_LIBDIR)/*$(SHARED_EXT) products/$(PRODUCT)
	cd products && \
		tar -czf $(CURDIR)/products/$(PRODUCT).tar.gz $(PRODUCT)

ifneq ($(shell command -v shasum),)
# OS X
SHA256SUM := shasum -a 256
else
# GNU Coreutils
SHA256SUM := sha256sum
endif

products/$(PRODUCT).tar.gz.sha256: products/$(PRODUCT).tar.gz
	cd products && \
		$(SHA256SUM) $(PRODUCT).tar.gz > $(PRODUCT).tar.gz.sha256
