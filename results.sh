#!/bin/sh

show_res() {
    echo "@@ $1"
    cat "$1"
}

./build.sh runtests

if [ -r tests/Makefile ] ; then
    for r in tests/*.res ; do show_res $r ; done
elif [ -r Makefile ] ; then
    for r in *.res ; do show_res $r ; done
else
    echo "cannot find any result files" >&1
fi
