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
:- import_module require.
:- import_module exception.
:- import_module code_gen.
:- import_module string.
:- import_module int.
:- import_module line_parser.
:- import_module ucd_file_parser.
:- import_module ucd_types, ucd_types.sc, ucd_types.gc.
:- import_module map_of_set.

%------------------------------------------------------------------------------%

:- type range ---> range(gc, int, int).
:- type ps == set(range).

:- pred parse_script_range `with_type` parser(sc, ps).
:- mode parse_script_range `with_inst` parser2_pred.

parse_script_range(!Map) -->
    (   ['#'] -> junk
    ;   ws    -> { true }
    ;   char_range(Start, End),
        separator,
        value_name(ScriptName),
        ws, ['#'], ws,
        value_name(ClassName),
        junk,
        {
            sc_alias(Script, ScriptName),
            gc_alias(Class, ClassName),
            add_or_update(Script, range(Class, Start, End), !Map)
        }
    ).

:- func switch_line(string, pair(string)) = fact_def.

switch_line(Fun, Script - Result) =
    s(Fun ++ "(" ++ Script ++ ") = " ++ Result).

process_scripts(Artifact, !IO) :-
    ucd_file_parser.file(Artifact^input, parse_script_range, Scripts, !IO),
    RangeType = "char_range",
    RangePred = RangeType ++ "_pred",
    ScriptRangeFun = "script_range",
    map.foldr3( (pred(Script::in, Ranges::in, Includes0::in, Includes1::out,
        RangeSwitch0::in, RangeSwitch1::out, IO0::di, IO::uo) is det :-
            ScriptName = atom_to_string(Script),
            PredName = ScriptName ++ "_range",
            RangeDecl = typed_pred(PredName, RangeType, RangePred),
            SubArtifact = Artifact `sub_module` ScriptName,
            Includes1 = [include(SubArtifact^module_name),
                import(SubArtifact^module_name) | Includes0],
            RangeSwitch1 = [pair(ScriptName, PredName) | RangeSwitch0],
            Facts = list.map((func(range(Class, Start, End)) =
                s(format("%s(%s, %d, %d)",
                    [s(PredName), s(atom_to_string(Class)),
                     i(Start), i(End)]))
                ), to_sorted_list(Ranges)),
            code_gen.file(SubArtifact, [], [RangeDecl], Facts, IO0, IO)
        ), Scripts, [], SubIncludes, [], RangeSwitch, !IO),
    ScriptDecls = [
        decl("func " ++ ScriptRangeFun ++ "(sc) = " ++ RangeType,
            [fun_mode(ScriptRangeFun, (semidet),
                ["in"], "out(" ++ RangePred ++ ")")]),
        decl("type " ++ RangeType ++ " == pred(gc, int, int)", []),
        decl("inst " ++ RangePred ++ " == (pred(out, out, out) is multi)", [])
    ],
    ScriptIncludes = [import("require") | SubIncludes],
    ScriptFacts = list.map(switch_line(ScriptRangeFun), RangeSwitch),
    code_gen.file(Artifact, ScriptIncludes, ScriptDecls, ScriptFacts, !IO).

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%
