%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: ucd_type_compiler.m
% Main author: Sebastian Godelet <sebastian.godelet@outlook.com>
% Created on: Fri Mar 11 21:22:11 CET 2014
%
%----------------------------------------------------------------------------%

:- module ucd_type_compiler.

:- interface.

:- import_module io.

%----------------------------------------------------------------------------%

:- pred main(io::di, io::uo) is det.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module char.
:- import_module code_gen.
:- import_module list.
:- import_module line_parser.
:- import_module map.
:- import_module map_of_map.
:- import_module map_of_set.
:- import_module pair.
:- import_module require.
:- import_module set.
:- import_module string.
:- import_module term_io.
:- import_module ucd_file_parser.
:- import_module ucd_processor.

%----------------------------------------------------------------------------%

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    Artifact = parse_artifact(Args),
    process_ucd_types(Artifact, !IO).

:- pred aliases : parser_pred(string) `with_inst` parser2_pred.

aliases(!Aliases) -->
    ws_opt,
    (   [';']   ->  ws,
        value_name_no_ws(Alias),
        { !:Aliases = [Alias | !.Aliases] },
        aliases(!Aliases)
    ;   ['#'] -> junk
    ;   { true }
    ).

:- type ps == map_of_set(string, string).
:- type decls == list(decl).
:- type alias_decls == map(string, decl).
:- type fact_defs == map(string, list(fact_def)).
:- pred parse_type_with_aliases : parser_pred(string, ps).
:- mode parse_type_with_aliases `with_inst` parser2_pred.

parse_type_with_aliases(!Map) -->
    (   ['#']   -> junk
    ;   ws      -> { true }
    ;   identifier(Kind),
        separator,
        value_name_no_ws(ValueName),
        {
            Aliases0 = [ValueName]
        },
        aliases(Aliases0, Aliases1),
        {
            Key = to_lower(ValueName),
            add_or_update(to_lower(Kind), Key, from_list(Aliases1), !Map)
        }
    ).

:- pred type_decl : state_processor_pred(string, ps, decls).
:- mode type_decl `with_inst` state_processor_pred.

type_decl(TypeName, EnumValues, S0, [decl(Decl, []) | S0]) :-
    Decl = foldl(
        (func(Key, _, EnumType0) = Result ++ quote_atom_name(TypeName, Key) :-
            (
                EnumType0 = ""
            ->  Result = "type " ++ TypeName  ++ "\n    --->   "
            ;   Result = EnumType0 ++ "\n    ;      "
            )
        ), EnumValues, ""
   ).

:- pred type_alias_decl : state_processor_pred(string, ps, alias_decls).
:- mode type_alias_decl `with_inst` state_processor_pred.

type_alias_decl(TypeName, EnumValues, !Decls) :-
    Name = string.format("%s_alias", [s(TypeName)]),
    P = string.format("pred %s(%s, string)", [s(Name), s(TypeName)]),
    M1 = pred_mode(Name, (semidet), ["in", "in"]),
    ( is_injection(EnumValues) ->  InOutDet = (det) ; InOutDet = (multi)),
    M2 = pred_mode(Name, InOutDet,   ["in", "out"]),
    M3 = pred_mode(Name, (semidet), ["out", "in"]),
    !:Decls = !.Decls^elem(TypeName) := decl(P, [M1, M2, M3]).

:- pred type_alias_fact : state_processor_pred(string, ps, fact_defs).
:- mode type_alias_fact `with_inst` state_processor_pred.

type_alias_fact(TypeName, EnumValues, !FactMap) :-
    Facts = map.foldr(
        (func(Key, Aliases,  A0) = A ++ A0 :-
            Prefix = quote_atom_name(TypeName, Key),
            A = to_sorted_list(set.map( (func(Alias) = s(AliasDef) :-
                AliasDef = string.format("%s_alias(%s, %s)",
                    [s(TypeName),
                     s(Prefix),
                     s(quoted_string(Alias))
                    ])
                ), Aliases)
            )
        ), EnumValues, []
    ),
    !:FactMap = !.FactMap^elem(TypeName) := Facts.

:- pred process_ucd_types : ucd_processor_pred.
:- mode process_ucd_types `with_inst` ucd_processor_pred.

process_ucd_types(Artifact, !IO) :-
    ucd_file_parser.file(Artifact ^ a_input, parse_type_with_aliases,
        Types, !IO),
    map.foldr(type_decl,       Types, [], EnumDecls),
    map.foldr(type_alias_decl, Types, init, AliasDecls),
    map.foldr(type_alias_fact, Types, init, AliasFacts),
    map.foldr2(
        (pred(Type::in, Decl::in, Ins0::in, Ins::out, di, uo)
            is det -->
                { SubArtifact = Artifact `sub_module` Type,
                  Ins = [include(SubArtifact ^ a_module_name) | Ins0]
                },
                code_gen.file(SubArtifact, []-[], [Decl],
                    AliasFacts ^ det_elem(Type))
        ), AliasDecls, [], SubIncludes, !IO),
    code_gen.file(Artifact, SubIncludes-[], EnumDecls, [], !IO).

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%
