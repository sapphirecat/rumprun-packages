include ../Makefile.inc

UPSTREAM=http://de1.php.net/get/php-7.0.7.tar.bz2/from/this/mirror
TARBALL=php.tar.bz2
LIBS=$(RUMPRUN_PKGS_DIR)/lib/libssl.a $(RUMPRUN_PKGS_DIR)/lib/libcurl.a $(RUMPRUN_PKGS_DIR)/lib/libxml2.a

# Mega build: all currently available features.
all: CONFIGURE_OPTS := --enable-cli \
	--enable-zip --enable-mbstring --enable-sockets \
	--with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --without-pdo-sqlite \
	--enable-bcmath --enable-calendar --enable-ctype --enable-exif \
	--enable-ftp --enable-soap \
	--with-curl=$(RUMPRUN_PKGS_DIR) --with-libxml-dir=$(RUMPRUN_PKGS_DIR)

all: bin/php-cgi bin/php images $(LIBS)

include ../Makefile.deps

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libcurl.a
$(RUMPRUN_PKGS_DIR)/lib/libcurl.a:
	$(MAKE) -C ../libcurl

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libxml2.a
$(RUMPRUN_PKGS_DIR)/lib/libxml2.a:
	$(MAKE) -C ../libxml2

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
# opcache: can't detect SHM flavors when cross-compiling
#
# Other than that, we try to leave all defaults enabled (or disabled for
# external libs) and enable whatever is non-default but supportable in the
# unikernel.

build/Makefile: $(LIBS) build/configure
	(cd build && ./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) \
	    --disable-pcntl --without-sqlite3 --without-iconv \
	    --disable-fileinfo --disable-opcache \
	    --disable-shared $(CONFIGURE_OPTS))

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -xj --strip-components 1 -f ../dl/$(TARBALL))

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
