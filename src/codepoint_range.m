%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 et
%----------------------------------------------------------------------------%
% File: codepoint_range.m
% Copyright © 2016 Sebastian Godelet
% Main author: Sebastian Godelet <sebastian.godelet@outlook.com>
% Created on: 05 Oct 2016 12:16:29
% Stability: low
%----------------------------------------------------------------------------%
% TODO: module documentation
%----------------------------------------------------------------------------%

:- module codepoint_range.

:- interface.

:- import_module list.
:- import_module pair.
:- import_module set.

%----------------------------------------------------------------------------%

    % An inclusive range of codepoints.
    %
:- type codepoint_range.

    % Compacts a set of ranges.
    %
    % e.g. { 1-2, 3-4, 7-10 } -> [1-4, 7-10]
    %
:- func codepoint_range_from_set(set(pair(int))) = codepoint_range.

    % Compacts a sorted list of ranges.
    %
    % e.g. [1-2, 3-4, 7-10] -> [1-4, 7-10]
    %
:- func codepoint_range_from_sorted_list(list(pair(int))) = codepoint_range.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module int. % for -/2

%----------------------------------------------------------------------------%

:- type codepoint_range == list(pair(int)).

%----------------------------------------------------------------------------%

codepoint_range_from_set(SetOfRanges) =
    codepoint_range_from_sorted_list(to_sorted_list(SetOfRanges)).

codepoint_range_from_sorted_list(Ranges) =
    list.foldl(
        (func(Range, Compacted0) =
            ( if
                Compacted0 = [PrevStart-PrevEnd | CompactedR],
                Range = Start-End,
                PrevEnd = Start - 1
            then
                [PrevStart-End | CompactedR]
            else
                [Range | Compacted0]
            )
        ),
        Ranges,
        []
    ).

%----------------------------------------------------------------------------%
:- end_module codepoint_range.
%----------------------------------------------------------------------------%
