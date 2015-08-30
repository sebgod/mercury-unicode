%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: ucd_processor.m
% Main author: Sebastian Godelet <sebastian.godelet@outlook.com>
% Created on: Tue Mar 11 20:15:05 CET 2014
%
%----------------------------------------------------------------------------%

:- module ucd_processor.

:- interface.

:- import_module io.
:- import_module list.
:- import_module string.

%----------------------------------------------------------------------------%

:- type artifact
    ---> artifact(
            a_input  :: string,
            a_output :: string,
            a_dir    :: string
    ).

:- type ucd_processor_pred == pred(artifact, io, io).
:- inst ucd_processor_pred == (pred(in, di, uo) is det).

:- type state_processor_pred(K, S, T) == pred(K, S, T, T).
:- inst state_processor_pred  == (pred(in, in, in, out) is det).

:- func artifact ^ a_module_name = string.

:- func artifact ^ a_path = string.

:- func parse_artifact(list(string)) = artifact.

:- func sub_module(artifact, string) = artifact.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module dir.       % for file path calculation
:- import_module int.       % for '<'/2
:- import_module require.

%----------------------------------------------------------------------------%

Artifact ^ a_module_name =
    string.det_remove_suffix(Artifact ^ a_output, ".m").

Artifact ^ a_path =
    ( if Artifact ^ a_dir = "" then
        Artifact ^ a_output
    else
        Artifact ^ a_dir / Artifact ^ a_output
    ).

parse_artifact(Args) = Artifact :-
    ( if Args = [InputFile, OutputFile | _] then
        List = string.split_at_char('/', OutputFile),
        ( if list.length(List) > 1 then
            list.det_split_last(List, List1, OutputFile1),
            Dir = string.join_list("/", List1),
            Artifact = artifact(InputFile, OutputFile1, Dir)
        else
            Artifact = artifact(InputFile, OutputFile, "")
        )
    else
        unexpected($file, $pred,
            "Please specify an input file and a target file.")
    ).

sub_module(Artifact, SubModule) = SubArtifact :-
    File = Artifact ^ a_module_name ++ "." ++ SubModule ++ ".m",
    SubArtifact = artifact(Artifact ^ a_input, File, Artifact ^ a_dir).

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%
