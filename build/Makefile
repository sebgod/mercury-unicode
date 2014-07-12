include ../Make.options
include ../Project.options

UCD_COMPILER_DEPS := $(wildcard ../src/ucd_*.m) ucd_types.m
UCD_PROCESSORS := $(wildcard ../src/process_*.m)
UCD_GEN_MODULES := ucd_types.m ucd.scripts.m ucd.blocks.m ucd.unicode_data.m
MODULES := $(wildcard ../src/*.m)

.PRECIOUS: %.txt

.PHONY: $(PROJ_LIBNAME)
$(PROJ_LIBNAME): $(UCD_GEN_MODULES)
	$(MMC) -f $(MODULES) $(wildcard *.m)
	$(MMC) $(MCFLAGS) --make $@

Mercury.modules: $(MODULES)
	$(MMC) -f $^

ucd_type_compiler: Mercury.modules
	$(MMC) $(MCFLAGS) -m $@

ucd_compiler: Mercury.modules $(UCD_COMPILER_DEPS) $(UCD_PROCESSORS)
	$(MMC) $(MCFLAGS) -m $@

%.txt:
	./download_ucd.sh $@

ucd_types.m: property_value_aliases.txt ucd_type_compiler
	./ucd_type_compiler $< $@

ucd.%.m: %.txt ucd_compiler
	./ucd_compiler $< $@

.PHONY: update
update:
	./download_ucd.sh $(wildcard *.txt)

.PHONY: all
all: update $(PROJ_LIBNAME)

.PHONY: install
install: $(PROJ_LIBNAME)
	$(SUDO) $(MMC) $(MCFLAGS) -m $(PROJ_LIBNAME).install

.PHONY: clean
clean:
	rm -f ucd_compiler
	rm -f ucd_type_compiler
	rm -f *.err
	rm -f *.mh
	rm -f *.init
	$(SUDO) rm -fR Mercury/
	rm -f ucd.*.m
	rm -f ucd_types.m
	rm -f ucd_types.*.m
	rm -f *.jar
	rm -f *.dll
	rm -f *.so
	rm -f *.a
	rm -f *.dylib

.PHONY: realclean
realclean: clean
	rm -f *.txt
