%------------------------------------------------------------------------------%
% File: map_of_map.m
% Main author: Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Sun Mar 16 23:52:23 CET 2014
% vim: ft=mercury ff=unix ts=4 sw=4 et
%
%------------------------------------------------------------------------------%

:- module map_of_map.

:- interface.

:- import_module map.

:- type map_of_map(K1, K2, V) == map(K1, map(K2, V)).

:- pred add_or_update(K1, K2, V,
    map_of_map(K1, K2, V), map_of_map(K1, K2, V)).
:- mode add_or_update(in, in, in, in, out) is det.

:- pred is_injection(map_of_map(K1, K2, V)::in) is semidet.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

:- implementation.

:- import_module list.

%------------------------------------------------------------------------------%

add_or_update(Key1, Key2, Value, !Map) :-
    (   !:Map = !.Map ^ elem(Key1) ^ elem(Key2) := Value -> true
    ;   !:Map = !.Map ^ elem(Key1) := ( init ^ elem(Key2) := Value )
    ).

is_injection(Map) :-
    list.all_true((pred(Value::in) is semidet :- count(Value) = 1), Map^values).

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

