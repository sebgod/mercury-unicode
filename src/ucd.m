%------------------------------------------------------------------------------%
% File: ucd.m
% Main author: Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Thu Mar 20 17:44:45 CET 2014
% vim: ft=mercury ff=unix ts=4 sw=4 et
%
%------------------------------------------------------------------------------%

:- module ucd.

:- interface.

:- import_module ucd_types, charset.

:- include_module ucd.scripts.

:- func script_charset(sc) = charset is det.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

:- implementation.

:- import_module ucd.scripts.
:- import_module char, string.
:- import_module sparse_bitset, list.
:- import_module ucd_types.sc.
:- import_module require.
:- import_module solutions.

script_charset(Script) = Charset :-
    ( if ScriptRange = script_range(Script) then
        solutions((pred(RangeSet::out) is multi :-
            ScriptRange(_, Start, End),
            CharList = map(char.det_from_int, Start `..` End),
            RangeSet = sorted_list_to_set(CharList)
        ), RangeSets),
        Charset = union_list(RangeSets)
      else
        sc_alias(Script, ScriptName),
        unexpected($file, $pred, "No chars for script " ++
            ScriptName ++ " specified!")
    ).

%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
% -*- Mode: Mercury; column: 80; indent-tabs-mode: nil; tabs-width: 4 -*-
%------------------------------------------------------------------------------%
