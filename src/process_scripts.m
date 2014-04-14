%------------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 et
%------------------------------------------------------------------------------%
% File: process_scripts.m
% Main author:  Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Mon Mar 10 13:54:02 CET 2014
%
%------------------------------------------------------------------------------%

:- module process_scripts.

:- interface.

:- import_module ucd_processor.

:- pred process_scripts `with_type` ucd_processor.
:- mode process_scripts `with_inst` ucd_processor_pred.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

:- implementation.

:- import_module io.
:- import_module pair, list, set, map.
:- import_module char.
:- import_module charset.
:- import_module require.
:- import_module exception.
:- import_module code_gen.
:- import_module string.
:- import_module int.
:- import_module line_parser.
:- import_module ucd_file_parser.
:- import_module ucd_types, ucd_types.sc.
:- import_module map_of_set.

%------------------------------------------------------------------------------%

:- type ps == set(range).

:- pred parse_script_range `with_type` parser(sc, ps).
:- mode parse_script_range `with_inst` parser2_pred.

parse_script_range(!Map) -->
    (   ['#'] -> junk
    ;   ws    -> { true }
    ;   char_range(Start, End),
        separator,
        value_name_no_ws(ScriptName),
        ws, ['#'],
        junk,
        {
            sc_alias(Script, ScriptName),
            add_or_update(Script, range(Start, End), !Map)
        }
    ).

:- func to_compact_list(set(range)) = list(range).

to_compact_list(Ranges) = Compacted :-
    Sorted = to_sorted_list(Ranges),
    Compacted = list.foldl((func(Range, Compacted0) = Compacted1 :-
        (
            Compacted0 = [range(PrevStart, PrevEnd) | CompactedR],
            Range = range(Start, End),
            PrevEnd = Start - 1
        ->  Compacted1 = [range(PrevStart, End) | CompactedR]
        ;   Compacted1 = [Range | Compacted0]
        )
    ), Sorted, []).

process_scripts(Artifact, !IO) :-
    ucd_file_parser.file(Artifact^input, parse_script_range, Scripts, !IO),
    RangeSwitch = map.foldr(
        (func(Script, Ranges, RangeSwitch0) = [Fact | RangeSwitch0] :-
            ScriptName = atom_to_string(Script),
            list.foldl2((pred(range(Start, End)::in,
                S0::in, S::out, I0::in, I::out) is det :-
                    I = I0 + 1,
                    Elem = format("0x%x-0x%x", [i(Start), i(End)]),
                    (   S0 = ""      -> S = Elem
                    ;   I mod 4 = 0 -> S = Elem ++ ",\n    " ++ S0
                    ;   S = Elem ++ ", " ++ S0
                    )
                ), to_compact_list(Ranges), "", FactItems, 2, _),
            Fact = s(format("script_range(%s)=[%s]",
                [s(ScriptName), s(FactItems)]))
        ), Scripts, []),
    ScriptDecls = [
        decl("type script_range == list(pair(int))", []),
        decl("func script_range(sc) = script_range",
            [fun_mode("script_range", (semidet), ["in"], "out")])
    ],
    code_gen.file(Artifact, []-[], ScriptDecls, RangeSwitch, !IO).

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%
