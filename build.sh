#!/bin/sh
if [ -r Makefile ] ; then
    exec make $*
elif [ -r src/Makefile ] ; then
    cd src && exec make $*
else
    echo "Couldn't find a Makefile" 1>&2
    exit 1
fi

