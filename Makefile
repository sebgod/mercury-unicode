.PHONY: all
all:
	cd src && $(MAKE) copy
	cd build && $(MAKE) all

.PHONY: clean
clean:
	cd src && $(MAKE) clean
