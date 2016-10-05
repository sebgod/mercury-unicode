%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: process_scripts.m
% Main author:  Sebastian Godelet <sebastian.godelet@outlook.com>
% Created on: Mon Mar 10 13:54:02 CET 2014
%
%----------------------------------------------------------------------------%

:- module process_scripts.

:- interface.

:- import_module ucd_processor.

%----------------------------------------------------------------------------%

:- pred process_scripts : ucd_processor_pred.
:- mode process_scripts `with_inst` ucd_processor_pred.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module char.
:- import_module charset.
:- import_module code_gen.
:- import_module exception.
:- import_module io.
:- import_module line_parser.
:- import_module list.
:- import_module int.
:- import_module map.
:- import_module map_of_set.
:- import_module pair.
:- import_module require.
:- import_module set.
:- import_module string.
:- import_module ucd_file_parser.
:- import_module ucd_types.
:- import_module ucd_types.sc.

%----------------------------------------------------------------------------%

:- pred parse_script_range : parser_pred(sc, set(codepoint_range)).
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
            add_or_update(Script, Start-End, !Map)
        }
    ).

:- func to_compact_list(set(codepoint_range)) = list(codepoint_range).

to_compact_list(Ranges) = Compacted :-
    Sorted = to_sorted_list(Ranges),
    Compacted = list.foldl((func(Range, Compacted0) =
        ( if
            Compacted0 = [PrevStart-PrevEnd | CompactedR],
            Range = Start-End,
            PrevEnd = Start - 1
        then
            [PrevStart-End | CompactedR]
        else
            [Range | Compacted0]
        )
    ), Sorted, []).

process_scripts(Artifact, !IO) :-
    ucd_file_parser.file(Artifact ^ a_input, parse_script_range, Scripts,
        !IO),
    RangeSwitch = map.foldr(
        (func(Script, Ranges, RangeSwitch0) = [Fact | RangeSwitch0] :-
            ScriptName = atom_to_string(Script),
            list.foldl2(
                (pred(Range::in, S0::in, S::out, I0::in, I::out) is det :-
                    I = I0 + 1,
                    Range = Start-End,
                    Elem = format("0x%x-0x%x", [i(Start), i(End)]),
                    S =
                        ( if S0 = "" then
                            Elem
                        else if I mod 4 = 0 then
                            Elem ++ ",\n    " ++ S0
                        else
                            Elem ++ ", " ++ S0
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

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%
