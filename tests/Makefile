include ../Make.options

MODULES:=$(wildcard *.m) $(wildcard ../src/*.m)

.PHONY: runtests
runtests: test_ucd

Mercury.modules: $(MODULES)
	$(MMC) -f $^

tags: $(MODULES)
	$(MTAGS) $^

test_ucd: Mercury.modules
	$(MMC) $(MCFLAGS) --make $@ $(MLLIBS) $(MLCLASSPATH)

.PHONY: clean
clean:
	$(MMC) --make test_ucd.clean

.PHONY: realclean
realclean:
	$(MMC) --make test_ucd.realclean
	rm -rf Mercury
	rm -f $(wildcard *.err) $(wildcard *.mh)
	rm -f Mercury.modules
	rm -f tags
