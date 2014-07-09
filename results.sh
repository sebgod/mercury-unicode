#!/bin/sh

show_res() {
    echo "@@ $1"
    cat "$1"
}

if [ -r src/Makefile ] ; then
    for r in src/*.res ; do show_res $r ; done
else
    for r in *.res ;     do show_res $r ; done
fi
