MMC=mmc
MCFLAGS=--use-grade-subdirs -O5
# --debug --stack-segments

BUILD_MAKE:=cd ../build && $(MAKE) MMC="$(MMC)" MCFLAGS="$(MCFLAGS)"
DOCS_MAKE:=cd ../docs && $(MAKE) MMC="$(MMC)" MCFLAGS="$(MCFLAGS)"

.PHONY: libucd
libucd: copy
	$(BUILD_MAKE) libucd

.PHONY: copy
copy:
	cp -u *.m ../build

.PHONY: update
update:
	$(BUILD_MAKE) update

.PHONY: all
all: copy update libucd docs

.PHONY: install
install: libucd
	$(BUILD_MAKE) install

.PHONY: clean
clean:
	$(BUILD_MAKE) clean
	$(DOCS_MAKE) clean

.PHONY: realclean
realclean:
	$(BUILD_MAKE) realclean
	$(DOCS_MAKE) clean

.PHONY: docs
docs:
	$(DOCS_MAKE) all
	
