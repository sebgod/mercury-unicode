mercury-unicode
===============

## Introduction

[Unicode character database](http://www.unicode.org) parser and library for the [Mercury language](https://github.com/Mercury-Language/mercury.git).
The implementation uses the latest Unicode release, version 8.0.
As Unicode updates are rather frequent, this code uses a generative approach,
to facilitate the frequent addition of characters, blocks and scripts.

The project can be build using any current Mercury compiler in any legal grade.

A consequence of this approach is that this library can also be used as a 
common ground for portable libraries which must ensure a consistent behaviour
across different execution environments. This means that no native code is
involved, and all facts and data are purely derived from the UCD file.

## Components

 1. [ucd_type_compiler.m](src/ucd_type_compiler.m)
   * Input: [PropertyValueAliases.txt](http://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt)
   * Output: ucd_types.m 
 2. [ucd_compiler.m](src/ucd_compiler.m)
   * The UCD compiler itself is modular, and links together a list of processors:
     - [process_scripts.m](src/process_scripts.m)
     - [process_blocks.m](src/process_blocks.m)
     - [process_unicode_data.m](src/process_unicode_data.m)
 3. [Makefile](src/Makefile)
   * Variables:
     - MMC: the Mercury compiler executable
     - MCFLAGS: the flags for the given Mercury compiler, default: _--use-grade-subdirs_
   * Targets:
     - clean: removes all generated code files and binary output
     - update: forces an update of all downloaded files
     - realclean: invokes _clean_, but also removes downloaded files
     - libucd: A library containing all expored functions and predicates dealing with Unicode, sourcing [ucd.m](src/ucd.m)
