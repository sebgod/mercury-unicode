include Make.options
include Project.options

.PHONY: default
default:
	cd src && $(MAKE) default

.PHONY: install
install:
	cd src && $(MAKE) install

.PHONY: runtests
runtests:
	cd tests && $(MAKE) runtests

.PHONY: realclean
realclean:
	cd src && $(MAKE) realclean
	cd tests && $(MAKE) realclean

.PHONY: tags
tags:
	cd src && $(MAKE) tags
	cd tests && $(MAKE) tags

.PHONY: doc
doc:
	cd doc && $(MAKE) doc
