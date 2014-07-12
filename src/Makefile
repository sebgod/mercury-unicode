include ../Make.options
include ../Project.options

BUILD_MAKE:=cd ../build && $(MAKE)
DOCS_MAKE:=cd ../doc && $(MAKE)

.PHONY: default
default: copy
	$(BUILD_MAKE) $(PROJ_LIBNAME)

.PHONY: copy
copy:
	cp -u -f -l *.m ../build

.PHONY: update
update:
	$(BUILD_MAKE) update

.PHONY: all
all: copy update $(PROJ_LIBNAME) doc

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
	
