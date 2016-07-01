include ../Makefile.inc
UPSTREAM=https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: build/libmemcached/libmemcached.la

build/libmemcached/libmemcached.la: build/Makefile
	$(MAKE) -C build install-libLTLIBRARIES install-pkgconfigDATA install-nobase_includeHEADERS

libmemcached_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--with-mysql=no --disable-sasl \
	--enable-shared=no

build/Makefile: build/configure
	(cd build; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(libmemcached_CONF_OPTS);)

dl/$(TARBALL):
	mkdir -p dl
	../scripts/fetch.sh ${UPSTREAM} dl/$(TARBALL)

build/configure: | dl/$(TARBALL)
	mkdir -p build
	(cd build && tar -zx --strip-components 1 -f ../dl/$(TARBALL))

.PHONY: clean
clean:
	-$(MAKE) -C build clean

.PHONY: distclean
distclean: clean
	rm -rf build

