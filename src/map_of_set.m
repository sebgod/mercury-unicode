%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: map_of_set.m
% Main author: Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Sun Mar 16 23:52:23 CET 2014
%
%----------------------------------------------------------------------------%

:- module map_of_set.

:- interface.

:- import_module map, set.

:- type map_of_set(K, V) == map(K, set(V)).

:- pred add_or_update(K, V, map_of_set(K, V), map_of_set(K, V)).
:- mode add_or_update(in, in, in, out) is det.

:- pred is_injection(map_of_set(K, V)::in) is semidet.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module list.

%----------------------------------------------------------------------------%

add_or_update(Key, Value, !Map) :-
    (   Set0 = !.Map^elem(Key)
    ->  !:Map = !.Map^elem(Key) := insert(Set0, Value)
    ;   !:Map = !.Map ^ elem(Key) := make_singleton_set(Value)
    ).

is_injection(Map) :-
    list.all_true(pred(Set::in) is semidet :- set.is_singleton(Set, _),
        Map^values).

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

