%------------------------------------------------------------------------------%
% File: normalisation.m
% Main author: Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Sun Apr 13 11:27:17 CEST 2014
% vim: ft=mercury ff=unix ts=4 sw=4 et
%
%------------------------------------------------------------------------------%

:- module ucd.normalisation.

:- interface.

:- import_module string.

:- type form
    ---> nfd
    ;    nfc
    ;    nfkd
    ;    nfkc.

:- func normalise(string, form) = string.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

:- implementation.

%------------------------------------------------------------------------------%

normalise(String, _Form) = String.

%------------------------------------------------------------------------------%
% -*- Mode: Mercury; column: 80; indent-tabs-mode: nil; tabs-width: 4 -*-
%------------------------------------------------------------------------------%
