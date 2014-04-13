.PHONY: all clean

UNICODE_HOST:=www.unicode.org

all: tr15 tr38

tr%:
	wget -nv -N -k --page-requisites -np http://$(UNICODE_HOST)/reports/$@/

clean:
	rm -fR $(UNICODE_HOST)
	
