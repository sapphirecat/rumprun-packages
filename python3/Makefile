include ../Makefile.inc

UPSTREAM=https://www.python.org/ftp/python/3.5.1/Python-3.5.1.tar.xz
TARBALL=$(notdir $(UPSTREAM))
ARCH=$(shell $(RUMPRUN_CC) -dumpmachine)

all: $(RUMPRUN_PKGS_DIR)/lib/libsqlite.a images

.NOTPARALLEL: $(RUMPRUN_PKGS_DIR)/lib/libsqlite.a
$(RUMPRUN_PKGS_DIR)/lib/libsqlite.a:
	$(MAKE) -C ../sqlite

build/python: build/Makefile
	$(MAKE) -C build
	$(MAKE) -C build install

PYTHON_CONF_ENV += \
	LDFLAGS="-static -static-libgcc" \
	CPPFLAGS="$(CPPFLAGS) -static" \
	CFLAGS="$(CFLAGS) -static" \
	CC=$(RUMPRUN_CC) \
	PYTHON_FOR_BUILD=$(shell pwd)/build/hostdist/bin/python3 \
	CONFIG_SITE=config.site

PYTHON_CONF_OPTS += \
	--prefix=$(shell pwd)/build/pythondist \
	--disable-shared \
	--host=$(RUMPRUN_TOOLCHAIN_TUPLE) \
	--build $(ARCH) \
	--enable-ipv6 \
        --without-ensurepip

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/hostpython: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -x --strip-components 1 -f ../dl/$(TARBALL))
	(cd build; ./configure --prefix=$(shell pwd)/build/hostdist; make python Parser/pgen && make install)
	mv build/python build/hostpython

build/Parser/hostpgen: build/hostpython
	mv build/Parser/pgen build/Parser/hostpgen

build/Programs/host_freeze_importlib: build/Parser/hostpgen
	mv build/Programs/_freeze_importlib build/Programs/host_freeze_importlib

build/configure: build/Programs/host_freeze_importlib
	(cd build; make distclean)

build/stamp_patch: build/configure patches/*
	cp config.site build/
	(cd build && ../../scripts/apply-patches.sh ./ ../patches/*)
	touch $@

build/Makefile: build/stamp_patch
	(cd build; $(PYTHON_CONF_ENV) ./configure $(PYTHON_CONF_OPTS))

.PHONY: images
images: images/stubetc.iso

images/stubetc.iso: images/python.iso ../stubetc/etc/*
	mkdir -p images
	genisoimage -l -r -o images/stubetc.iso ../stubetc/etc

images/python.iso: build/python
	mkdir -p images
	genisoimage -l -r -o images/python.iso build/pythondist/lib/python3.5

.PHONY: clean
clean:
	-$(MAKE) -C build clean
	rm -f bin/*
	rm -f images/stubetc.iso images/python.iso
	rm -f examples/hw.c examples/hw.bin examples/hw

.PHONY: distclean
distclean: clean
	rm -rf build