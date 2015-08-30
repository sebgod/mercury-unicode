%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: ucd.m
% Copyright © 2014 Sebastian Godelet
% Main author: Sebastian Godelet <sebastian.godelet@outlook.com>
% Created on: Thu Mar 20 17:44:45 CET 2014
%
%----------------------------------------------------------------------------%

:- module ucd.

:- interface.

:- import_module char.
:- import_module charset.
:- import_module ucd_types.

:- include_module ucd.blocks.
:- include_module ucd.scripts.
:- include_module ucd.normalisation.
% :- include_module ucd.unicode_data. XXX:Causes a kernel panic

%----------------------------------------------------------------------------%

    % ucd.script_charset(Script) = Charset:
    %   Charset unifies with the condensed set of all valid chars from the
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

:- import_module int.  % for block range comparison
:- import_module list.
:- import_module pair.
:- import_module require.
:- import_module solutions.
:- import_module string.

:- import_module ucd.blocks.
:- import_module ucd.scripts.
:- import_module ucd_types.sc.

%----------------------------------------------------------------------------%

script_charset(Script) = Charset :-
    ( if ScriptRange = script_range(Script) then
        Charset = list.foldl(
            (func(Range, Charset0) =
                union(Charset0, charset_from_range(Range))),
            ScriptRange,
            charset.init)
    else
        sc_alias(Script, ScriptName),
        unexpected($file, $pred,
            format("No chars for script `%s' specified", [s(ScriptName)]))
    ).

    % TODO: This implementation is crossly-inefficient (but correct).
    % There should be some kind of table for quick selection.
    % Looking at the most significant bit
    % of the char and use that index to refer to a bucket of matching ranges
    % should be the most efficient. This table could be pre-generated.
char_block(Char) = CharBlock :-
    CharVal = to_int(Char),
    solutions(
        (pred(Block::out) is nondet :-
            block_range(Block, Start, End),
            CharVal >= Start,
            CharVal =< End
        ),
        Blocks),
    CharBlock = ( if Blocks = [SingleBlock] then SingleBlock else nb ).


%----------------------------------------------------------------------------%
% -*- Mode: Mercury; column: 80; indent-tabs-mode: nil; tabs-width: 4 -*-
%----------------------------------------------------------------------------%
