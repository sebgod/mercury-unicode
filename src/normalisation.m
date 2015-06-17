%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: normalisation.m
% Main author: Sebastian Godelet <sebastian.godelet@outlook.com>
% Created on: Sun Apr 13 11:27:17 CEST 2014
%
%----------------------------------------------------------------------------%

:- module ucd.normalisation.

:- interface.

:- import_module string.

%----------------------------------------------------------------------------%

:- type form
    ---> nfd
    ;    nfc
    ;    nfkd
    ;    nfkc.

:- func normalise(string, form) = string.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

%----------------------------------------------------------------------------%

:- func canonical_decompose(string) = string.

canonical_decompose(String) = String.

:- func canonical_compose(string) = string.

canonical_compose(String) = String.

:- func compatibility_decompose(string) = string.

compatibility_decompose(String) = String.

normalise(String, Form) = Norm :-
    (
        Form = nfd,
        Norm = canonical_decompose(String)
    ;
        Form = nfc,
        Norm = canonical_compose(canonical_decompose(String))
    ;
        Form = nfkd,
        Norm = compatibility_decompose(String)
    ;
        Form = nfkc,
        Norm = canonical_compose(compatibility_decompose(String))
    ).

%----------------------------------------------------------------------------%
% -*- Mode: Mercury; column: 80; indent-tabs-mode: nil; tabs-width: 4 -*-
%----------------------------------------------------------------------------%
