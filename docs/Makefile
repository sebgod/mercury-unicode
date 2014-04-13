.PHONY: all clean

UNICODE_HOST:=www.unicode.org

all: tr15 tr38

tr%:
	wget -nv -r -N -l 1 -k --no-remove-listing http://$(UNICODE_HOST)/reports/$@/

clean:
	rm -fR $(UNICODE_HOST)
	
