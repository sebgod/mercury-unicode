%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: charset.m
% Copyright © 2016 Sebastian Godelet
% Main author: Sebastian Godelet <sebastian.godelet@outlook.com>
% Created on: Thu Mar 20 17:17:48 CET 2014
% Stability: low
%----------------------------------------------------------------------------%
%
%----------------------------------------------------------------------------%

:- module charset.

:- interface.

:- import_module char.
:- import_module codepoint_range.
:- import_module list.

%----------------------------------------------------------------------------%

    % A charset is a compacted set of `char's.
    %
:- type charset.

    % An empty charset.
    %
:- func init = charset.

    % Union of two charsets.
    %
:- func union(charset, charset) = charset.

    % Succeeds iff char is a member of charset.
    %
:- pred is_in_charset(char::in, charset::in) is semidet.

    % Constructs a charset from a sorted list of chars.
    %
:- func charset_from_sorted_char_list(list(char)) = charset.

    % Construct a charset from a codepoint range.
    %
:- func charset_from_range(codepoint_range) = charset.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module pair.
:- import_module sparse_bitset.

:- type charset == sparse_bitset(char).

%----------------------------------------------------------------------------%

init = sparse_bitset.init.

union(A, B) = sparse_bitset.union(A, B).

is_in_charset(Char, Charset) :- member(Char, Charset).

charset_from_sorted_char_list(CharList) =
    sparse_bitset.sorted_list_to_set(CharList).

charset_from_range(Range) =
    list.foldl(
        charset.union,
        list.map(
            func(Start-End) =
                charset_from_sorted_char_list(
                    list.map(char.det_from_int, Start `..` End)
            ),
            Range
        ),
        charset.init
    ).

%----------------------------------------------------------------------------%
% -*- Mode: Mercury; column: 80; indent-tabs-mode: nil; tabs-width: 4 -*-
%----------------------------------------------------------------------------%
