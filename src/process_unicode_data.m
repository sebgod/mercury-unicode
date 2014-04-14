%------------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 et
%------------------------------------------------------------------------------%
% File: process_unicode_data.m
% Main author:  Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Mon Mar 10 13:54:02 CET 2014
%
%------------------------------------------------------------------------------%

:- module process_unicode_data.

:- interface.

:- import_module ucd_processor.

:- pred process_unicode_data `with_type` ucd_processor.
:- mode process_unicode_data `with_inst` ucd_processor_pred.

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
:- import_module ucd_types, ucd_types.gc.
:- import_module map_of_set.

%------------------------------------------------------------------------------%

:- type props --->
    props(
        char_name::string,
        category::gc
         ).

:- pred parse_char_properties `with_type` parser(int, props).
:- mode parse_char_properties `with_inst` parser2_pred.

parse_char_properties(!Map) -->
    hex_number(Char),
    separator,
    until_separator(Name),
    separator,
    value_name_no_ws(GCName),
    %ws, ['#'],
    junk,
    {
        gc_alias(GC, GCName),
        !:Map = !.Map^elem(Char) := props(Name, GC)
    }.

:- func switch_line(string, pair(string)) = fact_def.

switch_line(Fun, Script - Result) =
    s(Fun ++ "(" ++ Script ++ ") = " ++ Result).

process_unicode_data(Artifact, !IO) :-
    ucd_file_parser.file(Artifact^input, parse_char_properties, Scripts, !IO),
    RangeType = "charset_range",
    RangePred = RangeType ++ "_pred",
    ScriptRangeFun = "script_range",
    map.foldl3( (pred(Char::in, Props::in, Includes0::in, Includes1::out,
        RangeSwitch0::in, RangeSwitch1::out, IO0::di, IO::uo) is det :-
            Includes1 = Includes0,
            RangeSwitch1 = RangeSwitch0,
            IO = IO0
            %ScriptName = atom_to_string(Script),
            %PredName = ScriptName ++ "_range",
            %RangeDecl = typed_pred(PredName, RangeType, RangePred),
            %SubArtifact = Artifact `sub_module` ScriptName,
            %Includes1 = [include(SubArtifact^module_name),
            %    import(SubArtifact^module_name) | Includes0],
            %RangeSwitch1 = [pair(ScriptName, PredName) | RangeSwitch0],
            %Facts = list.map((func(range(Start, End)) =
            %    s(format("%s(%d, %d)", [s(PredName), i(Start), i(End)]))
            %    ), to_sorted_list(Ranges)),
            %code_gen.file(SubArtifact, [], [RangeDecl], Facts, IO0, IO)
        ), Scripts, [], SubIncludes, [], RangeSwitch, !IO),
    ScriptDecls = [
        decl("func " ++ ScriptRangeFun ++ "(sc) = " ++ RangeType,
            [fun_mode(ScriptRangeFun, (semidet),
                ["in"], "out(" ++ RangePred ++ ")")])
    ],
    ScriptIncludes = [import("require") | SubIncludes],
    ScriptFacts = list.map(switch_line(ScriptRangeFun), RangeSwitch),
    code_gen.file(Artifact, ScriptIncludes-[], ScriptDecls, ScriptFacts, !IO).

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%
