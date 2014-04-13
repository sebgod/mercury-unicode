%------------------------------------------------------------------------------%
% File: ucd.m
% Main author: Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Thu Mar 20 17:44:45 CET 2014
% vim: ft=mercury ff=unix ts=4 sw=4 et
%
%------------------------------------------------------------------------------%

:- module ucd.

:- interface.

:- import_module char, ucd_types, charset.

:- include_module ucd.scripts.
:- include_module ucd.normalisation.

% ucd.script_charset(Script) = Charset:
%   Charset unifies with the codensed set of all valid chars from the given
%   Unicode script.
%
%   Throws an exception iff the script contains no characters (not all scripts
%   have Unicode characters assigned).
:- func script_charset(sc) = charset is det.

% ucd.char_block(Char) = Block:
%   Block unifies with the Unicode character block containing the Char.
:- func char_block(char) = blk is det.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

:- implementation.

:- import_module ucd.scripts.
:- import_module string.
:- import_module sparse_bitset, list.
:- import_module ucd_types.sc.
:- import_module require.
:- import_module solutions.

script_charset(Script) = Charset :-
    ( if ScriptRange = script_range(Script) then
        solutions((pred(RangeSet::out) is multi :-
            ScriptRange(Start, End),
            CharList = map(char.det_from_int, Start `..` End),
            RangeSet = sorted_list_to_set(CharList)
        ), RangeSets),
        Charset = union_list(RangeSets)
      else
        sc_alias(Script, ScriptName),
        unexpected($file, $pred, "No chars for script " ++
            ScriptName ++ " specified!")
    ).

char_block(Char) = Block :-
    (
        unexpected($file, $pred, format("%c is not in any Unicode block!",
            [c(Char)]))
    ).

%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
% -*- Mode: Mercury; column: 80; indent-tabs-mode: nil; tabs-width: 4 -*-
%------------------------------------------------------------------------------%
