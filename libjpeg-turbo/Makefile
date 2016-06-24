include ../Makefile.inc
UPSTREAM=http://download.sourceforge.net/libjpeg-turbo/libjpeg-turbo-1.5.0.tar.gz
TARBALL=$(notdir $(UPSTREAM))

all: build/.libs/libjpeg.a

build/.libs/libjpeg.a: build/Makefile
	$(MAKE) -C build
	$(MAKE) install -C build

libjpeg_turbo_CONF_OPTS += \
	--prefix=$(RUMPRUN_PKGS_DIR) \
	--without-turbojpeg --without-simd \
	--enable-shared=no
	
build/Makefile: build/configure
	(cd build; \
	./configure --host=$(RUMPRUN_TOOLCHAIN_TUPLE) $(libjpeg_turbo_CONF_OPTS);)

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

