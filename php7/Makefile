include ../Makefile.inc

PHP_VERSION := 7.0.10
UPSTREAM := http://de1.php.net/get/php-$(PHP_VERSION).tar.bz2/from/this/mirror
TARBALL := php-$(PHP_VERSION).tar.bz2
LIBS := $(RUMPRUN_PKGS_DIR)/lib/libssl.a $(RUMPRUN_PKGS_DIR)/lib/libcurl.a $(RUMPRUN_PKGS_DIR)/lib/libxml2.a \
	$(RUMPRUN_PKGS_DIR)/lib/libmemcached.a \
	$(RUMPRUN_PKGS_DIR)/lib/libpng16.a $(RUMPRUN_PKGS_DIR)/lib/libjpeg.a

# check for a specific build instruction targeted to us, else do the default.
ifdef php7_CONFIGURE_OPTS
CONFIGURE_OPTS := $(php7_CONFIGURE_OPTS)
ifneq ($(php7_LIBS),)
LIBS := $(php7_LIBS)
endif
endif

ifeq ($(CONFIGURE_OPTS),)

# Super hack! we want to use the ALREADY INCLUDED zlib.h, so we have to find
# it (using gcc -M) and, effectively, dirname() it a couple of times.
# But carefully, since '-: .../zlib.h' and 'TAB .../zlib.h' are valid lines.
_awk := '/zlib.h/ { n=split($$0, p, "/"); r=""; for (i=2; i<= n-2; i++) { r=r "/" p[i]; } print r; }'

# Mega build: all currently available features.
CONFIGURE_OPTS := --enable-cli \
	--enable-zip --with-zlib --enable-mbstring --enable-sockets --enable-opcache \
	--with-zlib-dir=$(shell echo "\#include <zlib.h>" | $(RUMPRUN_TOOLCHAIN_TUPLE)-gcc -M -xc - | awk $(_awk) ) \
	--with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-pdo-sqlite=no \
	--enable-bcmath --enable-calendar --enable-ctype --enable-exif \
	--enable-ftp --enable-soap \
	--with-gd --with-jpeg-dir=$(RUMPRUN_PKGS_DIR) --with-png-dir=$(RUMPRUN_PKGS_DIR) \
		--without-webp-dir --without-xpm-dir \
		--without-freetype-dir --enable-gd-native-ttf --enable-gd-jis-conv \
	--enable-memcached --with-libmemcached-dir=$(RUMPRUN_PKGS_DIR) \
		--enable-memcached-json --disable-memcached-sasl \
	--with-curl=$(RUMPRUN_PKGS_DIR) --with-libxml-dir=$(RUMPRUN_PKGS_DIR)
endif


all: bin/php-cgi bin/php images $(LIBS)

include ../Makefile.deps

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libcurl.a
$(RUMPRUN_PKGS_DIR)/lib/libcurl.a:
	$(MAKE) -C ../libcurl

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libjpeg.a
$(RUMPRUN_PKGS_DIR)/lib/libjpeg.a:
	$(MAKE) -C ../libjpeg-turbo

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libpng16.a
$(RUMPRUN_PKGS_DIR)/lib/libpng16.a:
	$(MAKE) -C ../libpng

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libxml2.a
$(RUMPRUN_PKGS_DIR)/lib/libxml2.a:
	$(MAKE) -C ../libxml2

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libmemcached.a
$(RUMPRUN_PKGS_DIR)/lib/libmemcached.a:
	$(MAKE) -C ../libmemcached


bin/php-cgi: build/sapi/cgi/php-cgi
	mkdir -p bin
	cp $< $@

bin/php: build/sapi/cli/php
	mkdir -p bin
	cp $< $@

build/sapi/cgi/php-cgi: build/Makefile
	$(MAKE) -C build sapi/cgi/php-cgi

build/sapi/cli/php: build/Makefile build/sapi/cgi/php-cgi
	$(MAKE) -C build sapi/cli/php

# Disabled due to build issues other than simply "uses external library":
#
# pcntl: there are no processes
# fileinfo: can't run test program while cross-compiling
#
# Other than that, we try to leave all defaults enabled (or disabled for
# external libs) and enable whatever is non-default but supportable in the
# unikernel.

build/Makefile: $(LIBS) build/configure
	(cd build && env CXX="$(RUMPRUN_CXX)" ./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) \
	    --disable-pcntl --without-sqlite3 --without-iconv \
	    --disable-fileinfo \
	    --disable-shared $(CONFIGURE_OPTS))

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)
	[ -d dl/memcached ] || git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git dl/memcached

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -xj --strip-components 1 -f ../dl/$(TARBALL))
	if ! test -e build/ext/memcached ; then \
		(cd build && cp -a ../dl/memcached ext/memcached && \
		../../scripts/apply-patches.sh ./ ../patches/*) \
	fi
	(cd build && ./buildconf --force)

.PHONY: images
images: images/data.iso

images/data.iso: images/data/www/* images/data/www/static/*
	$(RUMPRUN_GENISOIMAGE) -o images/data.iso images/data

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/data.iso

.PHONY: distclean
distclean: clean
	rm -rf build/
