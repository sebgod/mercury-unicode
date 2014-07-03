WGET=wget
WGET_OPS=-nv -N --page-requisites -e robots=off -np
UNICODE_HOST=www.unicode.org
SCHEME=http

.PHONY: all
all: tr15 tr24 tr38 tr44

tr%:
	$(WGET) $(WGET_OPS) $(SCHEME)://$(UNICODE_HOST)/reports/$@/

.PHONY: clean
clean:
	rm -fR $(UNICODE_HOST)
	
