.PHONY: all clean

UNICODE_HOST:=www.unicode.org

all: tr15 tr24 tr38 tr44

tr%:
	wget -nv -N --page-requisites -e robots=off -np http://$(UNICODE_HOST)/reports/$@/

clean:
	rm -fR $(UNICODE_HOST)
	
