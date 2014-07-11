MMC=mmc
export MCFLAGS=--use-grade-subdirs -O5
# --debug --stack-segments

BUILD_MAKE:=cd ../build && $(MAKE)
DOCS_MAKE:=cd ../doc && $(MAKE)

.PHONY: default
default: copy
	$(BUILD_MAKE) $(PROJ_LIBNAME)

.PHONY: copy
copy:
	cp -u *.m ../build

.PHONY: update
update:
	$(BUILD_MAKE) update

.PHONY: all
all: copy update libucd doc

.PHONY: install
install: $(PROJ_LIBNAME)
	$(BUILD_MAKE) install

.PHONY: clean
clean:
	$(BUILD_MAKE) clean
	$(DOCS_MAKE) clean

.PHONY: realclean
realclean:
	$(BUILD_MAKE) realclean
	$(DOCS_MAKE) clean

.PHONY: doc
doc:
	$(DOCS_MAKE) all
	
