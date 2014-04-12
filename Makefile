ifeq ($(OS),Windows_NT)
    MMC=mercury_compile
else
    MMC=mmc
endif
MCFLAGS=--use-grade-subdirs
# --debug --stack-segments

SUBMAKE :=cd build && make MMC="$(MMC)" MCFLAGS="$(MCFLAGS)"
.PHONY: all clean update install sinstall libucd realclean copy

libucd: copy
	$(SUBMAKE) libucd

copy:
	cp -u src/*.m build

update:
	$(SUBMAKE) update

all: copy update libucd

install: libucd
	$(SUBMAKE) install

sinstall: libucd
	$(SUBMAKE) sinstall

clean:
	$(SUBMAKE) clean

realclean:
	$(SUBMAKE) realclean
