%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: process_blocks.m
% Main author:  Sebastian Godelet <sebastian.godelet@outlook.com>
% Created on: Mon Mar 10 13:54:02 CET 2014
%
%----------------------------------------------------------------------------%

:- module process_blocks.

:- interface.

:- import_module ucd_processor.

%----------------------------------------------------------------------------%

:- pred process_blocks : ucd_processor_pred.
:- mode process_blocks `with_inst` ucd_processor_pred.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module code_gen.
:- import_module char.
:- import_module exception.
:- import_module int.
:- import_module io.
:- import_module line_parser.
:- import_module list.
:- import_module map.
:- import_module map_of_set.
:- import_module pair.
:- import_module require.
:- import_module set.
:- import_module string.
:- import_module ucd_file_parser.
:- import_module ucd_types.
:- import_module ucd_types.blk.

%----------------------------------------------------------------------------%

:- func normalize_block_name(string) = string.

normalize_block_name(Name) = Norm :-
    Parts = string.words_separator(
        (pred(Char::in) is semidet :- member(Char, [' ', '-', '_'])),
        Name
    ),
    Norm = string.join_list("_", list.map(string.capitalize_first, Parts)).

:- pred parse_block_range : parser_pred(blk, pair(int)).
:- mode parse_block_range `with_inst` parser2_pred.

parse_block_range(!Map) -->
    ( if
        ['#']
    then
        junk
    else if
        ws
    then
        { true }
    else
        char_range(Start, End),
        separator,
        not_eol_or_comment(BlockName),
        junk,
        {
            blk_alias(Block, normalize_block_name(BlockName)),
            !:Map = !.Map ^ elem(Block) := Start-End
        }
    ).

process_blocks(Artifact, !IO) :-
    ucd_file_parser.file(Artifact ^ a_input, parse_block_range, Blocks, !IO),
    BlockRange = "block_range",
    map.foldr(
        (pred(Block::in, Range::in,
            !.RangeSwitch::in, !:RangeSwitch::out) is det :-
                BlockName = atom_to_string(Block),
                Range = Start-End,
                !:RangeSwitch = [
                    s(format("%s(%s, %d, 0x%x, 0x%x)",
                        [s(BlockRange),
                         s(BlockName),
                         i(Start >> 16),
                         i(Start), i(End)
                        ])
                    )
                    | !.RangeSwitch
                ]
        ),
        Blocks,
        [],
        RangeSwitch),
    RangeDecl = decl(format("pred %s(blk, int, int, int)", [s(BlockRange)]),
        [pred_mode(BlockRange, (semidet), ["in",  "out", "out", "out"]),
         pred_mode(BlockRange, (semidet), ["in",  "in",  "out", "out"]),
         pred_mode(BlockRange, (semidet), ["out", "in",  "in",  "in" ]),
         pred_mode(BlockRange, (semidet), ["out", "in",  "in",  "out"]),
         pred_mode(BlockRange, (semidet), ["out", "in",  "out", "in" ]),
         pred_mode(BlockRange, (nondet),  ["out", "in",  "out", "out"]),
         pred_mode(BlockRange, (multi),   ["out", "out", "out", "out"])
        ]),
    code_gen.file(Artifact, []-[], [RangeDecl], RangeSwitch, !IO).

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%
