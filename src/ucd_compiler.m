%------------------------------------------------------------------------------%
% ucd_compiler.m
% Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Fri Feb 28 23:30:58 CET 2014
% vim: ft=mercury ff=unix ts=4 sw=4 et
%
%------------------------------------------------------------------------------%

:- module ucd_compiler.

:- interface.

:- import_module io.

%------------------------------------------------------------------------------%

:- pred main(io::di, io::uo) is det.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

:- implementation.

:- import_module char.
:- import_module string.
:- import_module list.
:- import_module require.
:- import_module ucd_processor.
:- import_module process_scripts.
:- import_module process_blocks.

%------------------------------------------------------------------------------%

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    Artifact = parse_artifact(Args),
    compile_ucd_file(Artifact, !IO).

:- pred ucd_parsers(string, ucd_processor).
:- mode ucd_parsers(in, out(ucd_processor_pred)) is semidet.

ucd_parsers("ucd.blocks", process_blocks).
ucd_parsers("ucd.scripts", process_scripts).

:- pred compile_ucd_file(artifact::in, io::di, io::uo) is det.

compile_ucd_file(Artifact, !IO) :-
    ( if ucd_parsers(Artifact ^ module_name, Parser) then
        Parser(Artifact, !IO)
      else
        unexpected($file, $pred,
            "Cannot find a parser for " ++ Artifact^module_name)
    ).
%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%
