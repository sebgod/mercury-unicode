#!/bin/sh
if [ -r src/Makefile ] ; then
    cd src && exec make $*
else
    exec make $*
fi

