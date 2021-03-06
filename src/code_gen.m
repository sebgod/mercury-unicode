%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: code_gen.m
% Copyright © 2016 Sebastian Godelet
% Main author: Sebastian Godelet <sebastian.godelet@outlook.com>
% Created on: Sat Mar  8 11:46:34 CET 2014
%
%----------------------------------------------------------------------------%

:- module code_gen.

:- interface.

:- import_module io.
:- import_module pair.
:- import_module string.
:- import_module univ.
:- import_module list.
:- import_module ucd_processor.

:- type import
    --->    include(string)
    ;       import(string).

:- type decl
    ---> decl(
            decl_main    :: string,
            decl_modes   :: list(string)
    ).

:- type fact_def
    --->    s(string)
    ;       t(univ).

:- type pragma_def(T) ---> pragma_def(string, T).

:- type determ ---> (det) ; (semidet) ; (multi) ; (nondet).

:- func pred_mode(string, determ, list(string)) = string.
:- func fun_mode(string, determ, list(string), string) = string.

    % typed_pred(Name, WithType, WithInst) = Decl:
    %
    % Decl = pred Name : WithType `with_inst` WithInst.
:- func typed_pred(string, string, string) = decl.

:- pred file(artifact, pair(list(import)), list(decl), list(fact_def),
    io, io).
:- mode file(in, in, in, in, di, uo) is det.

:- type print(T) == pred(T, io, io).
:- inst print_pred == (pred(in, di, uo) is det).

:- func make_fact(T) = fact_def.

:- func atom_to_string(T) = string.

    % quote_atom_name(Prefix, AtomName) = Quoted:
    %
    % e.g.: Quoted = (+)
:- func quote_atom_name(string, string) = string.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module exception.
:- import_module term.              % for `const'/0
:- import_module term_conversion.   % for `term_to_type'/2
:- import_module term_io.
:- import_module require.
:- import_module char.

:- func det_term_to_const(T) = const.

det_term_to_const(Type) = Const :-
    Term = type_to_term(Type),
    (
        generic_term(Term),
        functor(Functor, _, _) = Term -> Const = Functor
    ;
        unexpected($file, $pred, "Term must be a functor/3")
    ).

pred_mode(Pred, Determ, ArgInsts) =
    format("mode %s(%s) is %s", [s(Pred), s(join_list(", ", ArgInsts)),
        s(atom_to_string(Determ))]).

fun_mode(Fun, Determ, ArgInsts, ResultInst) =
    format("mode %s(%s) = %s is %s", [s(Fun), s(join_list(", ", ArgInsts)),
        s(ResultInst), s(atom_to_string(Determ))]).

:- pred decl : print(string) `with_inst` print_pred.

decl(Decl, !IO) :-
    io.format(":- %s.\n", [s(Decl)], !IO).

:- pred decl_with_modes : print(decl) `with_inst` print_pred.

decl_with_modes(Decl, !IO) :-
    decl(Decl ^ decl_main, !IO),
    list.foldl(decl, Decl ^ decl_modes, !IO).

:- pred separator(io::di, io::uo) is det.

typed_pred(PredName, PredType, PredInst) =
    decl(string.format("pred %s : %s `with_inst` %s",
        [s(PredName), s(PredType), s(PredInst)]), []).

separator(!IO) :-
    io.print("%---------------------------------------", !IO),
    io.print("-------------------------------------%\n", !IO).

:- pred comment_line : print(string) `with_inst` print_pred.

comment_line(Comment, !IO) :-
    io.print("% ", !IO), io.print(Comment, !IO), blank(!IO).

:- pred blank(io::di, io::uo) is det.

blank(!IO) :-
    io.print("\n", !IO).

:- pred fact : print(fact_def) `with_inst` print_pred.

fact(Fact, !IO) :-
    (
        Fact = s(Str),
        io.format("%s.\n", [s(Str)], !IO)
    ;
        Fact = t(Term),
        io.print(Term, !IO),
        io.write_string(".\n", !IO)
    ).

:- pred import : print(import) `with_inst` print_pred.

import(Import, !IO) :-
    (
        Import = import(M),
        Directive = "import_module",
        Module = M
    ;
        Import = include(M),
        Directive = "include_module",
        Module = M
    ),
    decl(Directive ++ " " ++ Module, !IO).

:- pred imports : print(list(import)) `with_inst` print_pred.

imports(Imports, !IO) :-
    list.foldl(import, Imports, !IO).

:- pred add_blank(print(T)) : print(T).
:- mode add_blank(in(print_pred)) `with_inst` print_pred.

add_blank(Printer, Arg, !IO) :-
    Printer(Arg, !IO),
    blank(!IO).

:- pred decl_pragma : print(pragma_def(T)) `with_inst` print_pred.

decl_pragma(pragma_def(Name, Argument), !IO) :-
    io.format(":- pragma %s(", [s(Name)], !IO),
    io.write(Argument, !IO),
    io.print(").\n", !IO).

file(Artifact, IfaceImports-ImplImports, Decls, Facts, !IO) :-
    DeclWithBlank = add_blank(decl),
    tell(Artifact ^ a_path, Result, !IO),
    (
        Result = ok,
        separator(!IO),
        comment_line("vim" ++ ": ft=mercury ts=4 sw=4 et", !IO),
        separator(!IO),
        comment_line("File: " ++ Artifact ^ a_output, !IO),
        comment_line("NOTE: This file is automatically generated", !IO),
        comment_line("Source: " ++ Artifact ^ a_input, !IO),
        separator(!IO),
        DeclWithBlank("module " ++ Artifact ^ a_module_name, !IO),
        DeclWithBlank("interface", !IO) ,
        add_blank(imports, IfaceImports, !IO),
        separator(!IO), blank(!IO),
        list.foldl(add_blank(decl_with_modes), Decls, !IO),
        separator(!IO), blank(!IO),
        decl("implementation", !IO),
        add_blank(imports, ImplImports, !IO),
        list.foldl(fact, Facts, !IO), blank(!IO),
        separator(!IO),
        decl("end_module " ++ Artifact ^ a_module_name, !IO),
        separator(!IO),
        told(!IO)
    ;
        Result = error(IOError), throw(IOError)
    ).

make_fact(Type) = t(Univ) :-
    type_to_univ(Type, Univ).

atom_to_string(Atom) = format_constant(det_term_to_const(Atom)).

quote_atom_name(Prefix, AtomName) =
    ( if AtomName = "is" then
        "(is)"
    else if char.is_digit(AtomName^elem(0)) then
        ( if Prefix = "" then
            unexpected($file, $pred, "Prefix must not be empty")
        else
            quote_atom_name("", Prefix ++ AtomName)
        )
    else
        quoted_atom(AtomName)
    ).

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%
