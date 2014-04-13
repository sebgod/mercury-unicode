ifeq ($(OS),Windows_NT)
    MMC=mercury_compile
else
    MMC=mmc
endif
MCFLAGS=--use-grade-subdirs
# --debug --stack-segments

BUILD_MAKE:=cd build && make MMC="$(MMC)" MCFLAGS="$(MCFLAGS)"
DOCS_MAKE:=cd docs && make MMC="$(MMC)" MCFLAGS="$(MCFLAGS)"
.PHONY: all clean update install sinstall libucd realclean copy docs

libucd: copy
	$(BUILD_MAKE) libucd

copy:
	cp -u src/*.m build

update:
	$(BUILD_MAKE) update

all: copy update libucd docs

install: libucd
	$(BUILD_MAKE) install

sinstall: libucd
	$(BUILD_MAKE) sinstall

clean:
	$(BUILD_MAKE) clean
	$(DOCS_MAKE) clean

realclean:
	$(BUILD_MAKE) realclean
	$(DOCS_MAKE) clean

docs:
	$(DOCS_MAKE) all
	
