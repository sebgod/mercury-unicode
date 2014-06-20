MMC=mmc
MCFLAGS=--use-grade-subdirs
# --debug --stack-segments

BUILD_MAKE:=cd ../build && $(MAKE) MMC="$(MMC)" MCFLAGS="$(MCFLAGS)"
DOCS_MAKE:=cd ../docs && $(MAKE) MMC="$(MMC)" MCFLAGS="$(MCFLAGS)"
.PHONY: all clean update install sinstall libucd realclean copy docs

libucd: copy
	$(BUILD_MAKE) libucd

copy:
	cp -u *.m ../build

update:
	$(BUILD_MAKE) update

all: copy update libucd docs

install: libucd
	$(BUILD_MAKE) install

clean:
	$(BUILD_MAKE) clean
	$(DOCS_MAKE) clean

realclean:
	$(BUILD_MAKE) realclean
	$(DOCS_MAKE) clean

docs:
	$(DOCS_MAKE) all
	
