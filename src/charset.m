%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: charset.m
% Main author: Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Thu Mar 20 17:17:48 CET 2014
%
%----------------------------------------------------------------------------%

:- module charset.

:- interface.

:- import_module char.
:- import_module sparse_bitset.
:- import_module list.
:- import_module pair.

:- type range ---> range(int, int).
:- type charset == sparse_bitset(char).

:- func charset_from_list(list(char)) = charset.
:- func charset_from_range(range) = charset.

:- type charset_range == pred(list(pair(int))).
:- inst charset_range_pred == (pred(out) is det).

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module list.

%----------------------------------------------------------------------------%

charset_from_list(CharList) = sparse_bitset.sorted_list_to_set(CharList).

charset_from_range(range(Start, End)) =
    charset_from_list(list.map(char.det_from_int, Start `..` End)).

%----------------------------------------------------------------------------%
% -*- Mode: Mercury; column: 80; indent-tabs-mode: nil; tabs-width: 4 -*-
%----------------------------------------------------------------------------%
