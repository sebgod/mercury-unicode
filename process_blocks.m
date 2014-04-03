%------------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 et
%------------------------------------------------------------------------------%
% File: process_blocks.m
% Main author:  Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Mon Mar 10 13:54:02 CET 2014
%
%------------------------------------------------------------------------------%

:- module process_blocks.

:- interface.

:- import_module ucd_processor.

:- pred process_blocks `with_type` ucd_processor.
:- mode process_blocks `with_inst` ucd_processor_pred.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

:- implementation.

:- import_module io.
:- import_module pair, list, set, map.
:- import_module char.
:- import_module require.
:- import_module exception.
:- import_module code_gen.
:- import_module string.
:- import_module int.
:- import_module line_parser.
:- import_module ucd_file_parser.
:- import_module ucd_types, ucd_types.blk.
:- import_module map_of_set.

%------------------------------------------------------------------------------%

:- type range ---> range(int, int).
:- type ps == range.

:- func normalize_block_name(string) = string.

normalize_block_name(Name) = Norm :-
    Parts = string.words_separator(
        (pred(Char::in) is semidet :- member(Char, [' ', '-', '_'])),
        Name),
    Norm = string.join_list("_", list.map(string.capitalize_first, Parts)).

:- pred parse_block_range `with_type` parser(blk, ps).
:- mode parse_block_range `with_inst` parser2_pred.

parse_block_range(!Map) -->
    (   ['#'] -> junk
    ;   ws    -> { true }
    ;   char_range(Start, End),
        separator,
        not_eol_or_comment(BlockName),
        junk,
        {
            NormalizedBlockName = normalize_block_name(BlockName),
            blk_alias(Block, NormalizedBlockName),
            !:Map = !.Map^elem(Block) := range(Start, End)
        }
    ).

process_blocks(Artifact, !IO) :-
    ucd_file_parser.file(Artifact^input, parse_block_range, Blocks, !IO),
    BlockRange = "block_range",
    map.foldr( (pred(Block::in, Range::in, RangeSwitch0::in, RangeSwitch1::out)
        is det :-
            BlockName = atom_to_string(Block),
            Range = range(Start, End),
            RangeSwitch1 = [s(format("%s(%s, %d, %d)", [
                s(BlockRange), s(BlockName), i(Start), i(End)]))
                | RangeSwitch0]
        ), Blocks, [], RangeSwitch),
    RangeDecl = decl(format("pred %s(blk, int, int)", [s(BlockRange)]),
        [pred_mode(BlockRange, (det), ["in", "out", "out"])]),
    code_gen.file(Artifact, [], [RangeDecl], RangeSwitch, !IO).

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%
