%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: ucd.m
% Main author: Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Thu Mar 20 17:44:45 CET 2014
%
%----------------------------------------------------------------------------%

:- module ucd.

:- interface.

:- import_module char, ucd_types, charset.

:- include_module ucd.scripts.
:- include_module ucd.normalisation.
% :- include_module ucd.unicode_data. XXX:Causes a kernel panic

%----------------------------------------------------------------------------%

    % ucd.script_charset(Script) = Charset:
    %   Charset unifies with the codensed set of all valid chars from the
    %   given Unicode script.
    %
    %   Throws an exception iff the script contains no characters
    %   (not all scripts have Unicode characters assigned).
:- func script_charset(sc) = charset is det.

    % ucd.char_block(Char) = Block:
    %   Block unifies with the Unicode character block containing the Char.
:- func char_block(char) = blk is det.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module list.
:- import_module pair.
:- import_module require.
:- import_module solutions.
:- import_module sparse_bitset.
:- import_module string.
:- import_module ucd.scripts.
:- import_module ucd_types.sc.

%----------------------------------------------------------------------------%

script_charset(Script) = Charset :-
    ( if ScriptRange = script_range(Script) then
        Charset = list.foldl((func(Start-End, Charset0) =
                union(Charset0, RangeSet) :-
            CharList = map(char.det_from_int, Start `..` End),
            RangeSet = sorted_list_to_set(CharList)
        ), ScriptRange, init)
      else
        sc_alias(Script, ScriptName),
        unexpected($file, $pred,
            format("No chars for script `%s' specified", [s(ScriptName)]))
    ).

char_block(Char) = Block :-
    (
        unexpected($file, $pred,
            format("%c is not in any Unicode block!", [c(Char)]))
    ).


%----------------------------------------------------------------------------%
% -*- Mode: Mercury; column: 80; indent-tabs-mode: nil; tabs-width: 4 -*-
%----------------------------------------------------------------------------%
