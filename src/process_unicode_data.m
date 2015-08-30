%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: process_unicode_data.m
% Main author:  Sebastian Godelet <sebastian.godelet@outlook.com>
% Created on: Mon Mar 10 13:54:02 CET 2014
%
%----------------------------------------------------------------------------%

:- module process_unicode_data.

:- interface.

:- import_module ucd_processor.

%----------------------------------------------------------------------------%

:- pred process_unicode_data : ucd_processor_pred.
:- mode process_unicode_data `with_inst` ucd_processor_pred.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module io.
:- import_module pair.
:- import_module list.
:- import_module set.
:- import_module map.
:- import_module char.
:- import_module charset.
:- import_module require.
:- import_module exception.
:- import_module code_gen.
:- import_module string.
:- import_module int.
:- import_module line_parser.
:- import_module ucd_file_parser.
:- import_module ucd_types.
:- import_module ucd_types.gc.
:- import_module map_of_set.

%----------------------------------------------------------------------------%

:- type props
    --->    props(
                prop_char_name  :: string,
                prop_category   :: gc
            ).

:- pred parse_char_properties : parser_pred(int, props).
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

:- type prop_processor_pred == pred(int, props, facts, facts).
:- inst prop_processor_pred == (pred(in, in, in, out) is det).

:- func to_string_const(string, int) = string.

to_string_const(Input, Max) = "\"" ++ Left ++ Right ++ "\"" :-
    ( if
        length(Input) >= Max
    then
        split_by_codepoint(Input, Max - 5, Left, Right0),
        Right = "\" ++\n\t\"" ++ Right0
    else
        Left = Input,
        Right = ""
    ).

:- pred process_name : prop_processor_pred `with_inst` prop_processor_pred.

process_name(Char, Props, Facts0, [Fact | Facts0]) :-
    CharName = Props ^ prop_char_name,
    Fact = s(format("char_prop(0x%x) = %s",
        [i(Char), s(to_string_const(CharName, 55))])).

:- pred process_gc : prop_processor_pred `with_inst` prop_processor_pred.

process_gc(Char, Props, Facts0, [Fact | Facts0]) :-
    GCName = quote_atom_name("", atom_to_string(Props ^ prop_category)),
    Fact = s(format("char_prop(0x%x) = %s", [i(Char), s(GCName)])).

process_unicode_data(Artifact, !IO) :-
    ucd_file_parser.file(Artifact ^ a_input, parse_char_properties, CharProps,
        !IO),
    SubGen = (pred(ModuleName::in, Type::in, Proc::in(prop_processor_pred),
                   IncImps::out, IO0::di, IO1::uo) is det :-
        map.foldr(Proc, CharProps, [], Facts),
        SubModule = Artifact `sub_module` ModuleName,
        code_gen.file(SubModule, []-[],
            [decl("func char_prop(int) = " ++ Type ++ " is semidet" , [])],
            Facts, IO0, IO1),
        FQN = SubModule ^ a_module_name,
        IncImps = [include(FQN)] % , import(FQN)]
    ),
    SubGen("name", "string", process_name, NameIncImps, !IO),
    SubGen("gc",   "gc",     process_gc,   GCIncImps,   !IO),
    IfaceIncImps = NameIncImps ++ GCIncImps,
    code_gen.file(Artifact, IfaceIncImps-[], [], [], !IO).

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%
