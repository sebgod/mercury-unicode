include ../Make.options

COMMON_DEPS := $(wildcard map_*.m) code_gen.m line_parser.m ucd_file_parser.m ucd_processor.m
UCD_COMPILER_DEPS := $(wildcard ucd_*.m) ucd_types.m
UCD_PROCESSORS := $(wildcard process_*.m)
UCD_TYPE_COMPILER_DEPS := $(COMMON_DEPS) ucd_type_compiler.m

.PRECIOUS: %.txt

.PHONY: libucd
libucd: ucd_types.m ucd.m ucd.scripts.m ucd.blocks.m ucd.unicode_data.m normalisation.m
	$(MMC) $(MCFLAGS) -m $@

ucd_type_compiler: $(UCD_TYPE_COMPILER_DEPS)
	$(MMC) $(MCFLAGS) -m $@ --ml mercury_misc

ucd_compiler: $(UCD_COMPILER_DEPS) $(UCD_PROCESSORS)
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
all: update libucd

.PHONY: install
install: libucd
	$(MMC) $(MCFLAGS) -m libucd.install

.PHONY: clean
clean:
	rm -f ucd_compiler
	rm -f ucd_type_compiler
	rm -f *.exe
	rm -f *.err
	rm -f *.mh
	rm -f *.init
	rm -fR Mercury/
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
