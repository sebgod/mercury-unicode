ifeq ($(OS),Windows_NT)
    MMC=mercury_compile
else
    MMC=mmc
endif
MCFLAGS=--use-grade-subdirs
# --debug --stack-segments

COMMON_DEPS := $(wildcard map_*.m) code_gen.m line_parser.m ucd_file_parser.m ucd_processor.m
UCD_COMPILER_DEPS := $(wildcard ucd_*.m) ucd_types.m
UCD_PROCESSORS := $(wildcard process_*.m)
UCD_TYPE_COMPILER_DEPS := $(COMMON_DEPS) ucd_type_compiler.m charset.m

.PHONY: all clean update install sinstall libucd realclean
.PRECIOUS: %.txt

libucd: ucd_types.m ucd.m ucd.scripts.m ucd.blocks.m normalisation.m
	$(MMC) $(MCFLAGS) -m $@

ucd_type_compiler: $(UCD_TYPE_COMPILER_DEPS)
	$(MMC) $(MCFLAGS) -m $@

ucd_compiler: $(UCD_COMPILER_DEPS) $(UCD_PROCESSORS)
	$(MMC) $(MCFLAGS) -m $@

%.txt:
	./download_ucd.sh $@

ucd_types.m: property_value_aliases.txt ucd_type_compiler
	./ucd_type_compiler $< $@

ucd.%.m: %.txt ucd_compiler
	./ucd_compiler $< $@

update:
	./download_ucd.sh $(wildcard *.txt)

all: update libucd

install: libucd
	$(MMC) $(MCFLAGS) -m libucd.install

sinstall: libucd
	sudo $(MMC) $(MCFLAGS) -m libucd.install

clean:
	rm -f ucd_compiler
	rm -f ucd_type_compiler
	rm -f *.err
	rm -f *.mh
	rm -fR Mercury/
	rm -f ucd.*.m
	rm -f ucd_types.m
	rm -f ucd_types.*.m

realclean: clean
	rm -f *.txt
