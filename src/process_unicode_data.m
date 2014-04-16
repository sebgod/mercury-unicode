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

:- type facts == list(fact_def).

:- type prop_processor == pred(int, props, facts, facts).
:- inst prop_processor_pred == (pred(in, in, in, out) is det).

:- pred process_name `with_type` prop_processor `with_inst` prop_processor_pred.

process_name(Char, Props, Facts0, [Fact | Facts0]) :-
    Fact = s(format("%x - %s\n", [i(Char), s(Props^char_name)])).

process_unicode_data(Artifact, !IO) :-
    ucd_file_parser.file(Artifact^input, parse_char_properties, CharProps, !IO),
    SubGen = (pred(ModuleName::in, Proc::in(prop_processor_pred),
            Import::out, IO0::di, IO1::uo) is det :-
        map.foldl(Proc, CharProps, [], Facts),
        SubModule = Artifact `sub_module` ModuleName,
        code_gen.file(SubModule, []-[], [], Facts, IO0, IO1),
        Import = include(SubModule^module_name)
    ),
    SubGen("name", process_name, NameImport, !IO),
    IfaceIncludes = [NameImport],
    code_gen.file(Artifact, IfaceIncludes-[], [], [], !IO).

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%
