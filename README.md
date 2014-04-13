mercury-unicode
===============

Introduction
------------

[Unicode character database](http://www.unicode.org) parser and library for the [Mercury language](https://github.com/Mercury-Language/mercury.git).
The implementation uses the latest Unicode release, version 6.3.
As Unicode updates are rather requent, this code uses a genertive approach,
to facilitate the frequent addition of characters, blocks and scripts.

Components
----------

 1. [ucd_type_compiler.m](src/ucd_type_compiler.m)
    Input: [PropertyValueAliases.txt](http://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt)
    Output: ucd_types.m 
 2. [ucd_compiler.m](src/ucd_compiler.m)
    The UCD compiler itself is modular, and links together a list of processors:
   1. [process_scripts.m](src/process_scripts.m)
   2. [process_blocks.m](src/process_blocks.m)
 3. [libucd](src/ucd.m)
    libucd is the primary output of the [Makefile](src/Makefile) and can be
    build using any current Mercury compiler in any legal grade.
    A consequence of this approach is that this library can also be used as a 
    common ground for portable libraries which must ensure a consistent behaviour
    across different execution environments. This means that no native code is
    involed, and all facts and data are purely derived from the UCD files.
