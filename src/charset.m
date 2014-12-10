%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: charset.m
% Copyright © 2014 Sebastian Godelet
% Main author: Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Thu Mar 20 17:17:48 CET 2014
%
%----------------------------------------------------------------------------%

:- module charset.

:- interface.

:- import_module char.
:- import_module list.
:- import_module pair.

:- type charset.
:- type codepoint_range == pair(int).

:- func charset_from_sorted_list(list(char)) = charset.
:- func charset_from_range(codepoint_range) = charset.

:- func init = charset.
:- func union(charset, charset) = charset.
%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module list.
:- import_module sparse_bitset.

:- type charset == sparse_bitset(char).

%----------------------------------------------------------------------------%

:- func codepoint_range_to_list(codepoint_range) = list(int).

codepoint_range_to_list(Start-End) = Start `..` End.

%----------------------------------------------------------------------------%

charset_from_sorted_list(CharList) =
    sparse_bitset.sorted_list_to_set(CharList).

charset_from_range(Range) =
    charset_from_sorted_list(
        list.map(char.det_from_int,
        codepoint_range_to_list(Range))
    ).

init = sparse_bitset.init.

union(A, B) = sparse_bitset.union(A, B).

%----------------------------------------------------------------------------%
% -*- Mode: Mercury; column: 80; indent-tabs-mode: nil; tabs-width: 4 -*-
%----------------------------------------------------------------------------%
