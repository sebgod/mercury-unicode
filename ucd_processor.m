%------------------------------------------------------------------------------%
% File: ucd_processor.m
% Main author: Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Tue Mar 11 20:15:05 CET 2014
% vim: ft=mercury ff=unix ts=4 sw=4 et
%
%------------------------------------------------------------------------------%

:- module ucd_processor.

:- interface.

:- import_module string.
:- import_module io.
:- import_module list.

:- type artifact
    ---> artifact(
        input  :: string,
        output :: string,
        dir    :: string
    ).

:- type ucd_processor == pred(artifact, io, io).
:- inst ucd_processor_pred == (pred(in, di, uo) is det).

:- type state_processor(K, S, T) == pred(K, S, T, T).
:- inst state_processor_pred  == (pred(in, in, in, out) is det).

:- func artifact ^ module_name = string.

:- func parse_artifact(list(string)) = artifact.

:- func sub_module(artifact, string) = artifact.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

:- implementation.

:- import_module require.

%------------------------------------------------------------------------------%

Artifact ^ module_name = string.det_remove_suffix(Artifact ^ output, ".m").

parse_artifact(Args) = Artifact :-
    ( if Args = [InputFile, OutputFile | _] then
        List = string.split_at_char('/', OutputFile),
        (   \+ list.length(List, 1) ->
            list.det_split_last(List, List1, OutputFile1),
            Dir = string.join_list("/", List1),
            Artifact = artifact(InputFile, OutputFile1, Dir)
        ;   Artifact = artifact(InputFile, OutputFile, "")
        )
    else
        unexpected($file, $pred,
            "Please specify an input file and a target file.")
    ).

sub_module(Artifact, SubModule) = SubArtifact :-
    File = Artifact^module_name ++ "." ++ SubModule ++ ".m",
    SubArtifact = artifact(Artifact^input, File, Artifact^dir).

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%
