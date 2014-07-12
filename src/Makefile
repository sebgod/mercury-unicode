include ../Make.options
include ../Project.options

BUILD_MAKE:=cd ../build && $(MAKE)
DOCS_MAKE:=cd ../doc && $(MAKE)

.PHONY: default
default:
	$(BUILD_MAKE) $(PROJ_LIBNAME)

.PHONY: update
update:
	$(BUILD_MAKE) update

.PHONY: all
all: copy update default doc

.PHONY: install
install: default
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
	$(DOCS_MAKE) doc
	
