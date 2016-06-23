include ../Makefile.inc
UPSTREAM=http://download.sourceforge.net/libpng/libpng-1.6.23.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: build/.libs/libpng16.a

build/.libs/libpng16.a: build/Makefile
	$(MAKE) -C build
	$(MAKE) install -C build

libpng_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--enable-shared=no
	
build/Makefile: build/configure
	(cd build; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(libpng_CONF_OPTS);)

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

