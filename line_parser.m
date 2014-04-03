%------------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 et
%------------------------------------------------------------------------------%
% File: line_parser.m
% Main author: Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Mon Mar 10 15:18:45 CET 2014
%
%------------------------------------------------------------------------------%

:- module line_parser.

:- interface.

:- import_module list.
:- import_module map.
:- import_module io.
:- import_module char.

:- type chars == list(char).

:- type parser       == pred(chars, chars).
:- type parser(T)    == pred(list(T), list(T), chars, chars).
:- type parser(K, V) == pred(map(K, V), map(K, V), chars, chars).
:- inst det_parser_pred  == (pred(in, out) is det).
:- inst det_parser2_pred == (pred(in, out, in, out) is det).
:- inst parser_pred  == (pred(in, out) is semidet).
:- inst parser2_pred == (pred(in, out, in, out) is semidet).

:- type filter == pred(char).
:- inst filter_pred == (pred(in) is semidet).

:- pred lines(parser(K, T), map(K, T), map(K, T), io, io).
:- mode lines(in(parser2_pred), in, out, di, uo) is det.
:- mode lines(in(det_parser2_pred), in, out, di, uo) is det.

:- pred junk `with_type` parser `with_inst` parser_pred.

:- pred any(string) `with_type` parser.
:- mode any(in)     `with_inst` parser_pred.
:- mode any(out)    `with_inst` parser_pred.

:- pred until(chars, string) `with_type` parser.
:- mode until(in, out)       `with_inst` parser_pred.

:- pred ws `with_type` parser `with_inst` parser_pred.

:- pred ws_char `with_type` parser `with_inst` parser_pred.

:- pred ws_opt `with_type` parser.
:- mode ws_opt(in, out) is det.

:- pred char(char) `with_type` parser.
:- mode char(in)   `with_inst` parser_pred.
:- mode char(out)  `with_inst` parser_pred.

:- pred digit(int) `with_type` parser.
:- mode digit(in)  `with_inst` parser_pred.
:- mode digit(out) `with_inst` parser_pred.

:- pred hex_number(int) `with_type` parser.
:- mode hex_number(in)  `with_inst` parser_pred.
:- mode hex_number(out) `with_inst` parser_pred.

:- pred hex_digit(int)  `with_type` parser.
:- mode hex_digit(in)   `with_inst` parser_pred.
:- mode hex_digit(out)  `with_inst` parser_pred.

:- pred identifier(string) `with_type` parser.
:- mode identifier(in)     `with_inst` parser_pred.
:- mode identifier(out)    `with_inst` parser_pred.

:- pred word(string) `with_type` parser.
:- mode word(in)     `with_inst` parser_pred.
:- mode word(out)    `with_inst` parser_pred.

:- type filter(T) == pred(filter, T, chars, chars).
:- inst filter_pred_in  == (pred(in(filter_pred), in, in, out) is semidet).
:- inst filter_pred_out == (pred(in(filter_pred), out, in, out) is semidet).

:- pred filter `with_type` filter(string).
:- mode filter `with_inst` filter_pred_in.
:- mode filter `with_inst` filter_pred_out.

:- pred filter_chars `with_type` filter(chars).
:- mode filter_chars `with_inst` filter_pred_in.
:- mode filter_chars `with_inst` filter_pred_out.

:- pred filter_char `with_type` filter(char).
:- mode filter_char `with_inst` filter_pred_in.
:- mode filter_char `with_inst` filter_pred_out.

:- pred filter_not `with_type` filter(string).
:- mode filter_not `with_inst` filter_pred_in.
:- mode filter_not `with_inst` filter_pred_out.

:- pred filter_not_chars `with_type` filter(chars).
:- mode filter_not_chars `with_inst` filter_pred_in.
:- mode filter_not_chars `with_inst` filter_pred_out.

:- pred filter_not_char `with_type` filter(char).
:- mode filter_not_char `with_inst` filter_pred_in.
:- mode filter_not_char `with_inst` filter_pred_out.

:- pred parse_error(string, string, string, chars, io, io).
:- mode parse_error(in, in, in, in, di, uo) is erroneous.

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

:- implementation.

:- import_module require, int, string.

%------------------------------------------------------------------------------%

parse_error(File, Predicate, Msg, Line, !IO) :-
    io.get_line_number(LineNo, !IO),
    unexpected(File, Predicate, format("parse error, %s @%d: %s",
        [s(Msg), i(LineNo), s(from_char_list(Line))])).

lines(LineParser, !Records, !IO) :-
    io.read_line(LineResult, !IO),
    (
        LineResult = ok(Line),
        (
            LineParser(!Records, Line, Rest) ->
            (   Rest = [] -> true
            ;   parse_error($file, $pred,
                    "still unparsed: " ++ from_char_list(Rest), Line, !IO)
            )
        ;   parse_error($file, $pred, "`LineParser` lambda failed", Line, !IO)
        ),
        lines(LineParser, !Records, !IO)
    ;
        LineResult = error(Error),
        unexpected($file, $pred, io.error_message(Error))
    ;
        LineResult = eof
    ).

filter(Filter, string.from_char_list(Chars)) --> filter_chars(Filter, Chars).

filter_chars(Filter, Word) -->
    (   filter_char(Filter, C)
    ->  {   Word = [C | Rest] },
        filter_chars(Filter, Rest)
    ;   {   Word = [] }
    ).

filter_char(Filter, Char) --> [Char], { Filter(Char) }.

filter_not(Filter, string.from_char_list(Chars)) -->
    filter_not_chars(Filter, Chars).

filter_not_chars(Filter, Word) -->
    (   filter_not_char(Filter, C)
    ->  {   Word = [C | Rest] },
        filter_not_chars(Filter, Rest)
    ;   {   Word = [] }
    ).

filter_not_char(Filter, Char) --> [Char], { not Filter(Char) }.

any(Any) --> filter_not(char.is_noncharacter, Any).

junk --> any(_).

until(Sep, Match) --> filter_not(contains(Sep), Match).

ws_char --> filter_char(char.is_whitespace, _).

ws_opt --> ( ws_char -> ws_opt ; { true } ).

ws --> ws_char, ws_opt.

char(Char) --> [Char].

digit(Digit) -->
    filter_char(char.is_digit, Char),
    { Digit = char.to_int(Char) - char.to_int('0') }.

hex_digit(Digit) -->
    (   ['A'] -> { Digit = 10 }
    ;   ['a'] -> { Digit = 10 }
    ;   ['B'] -> { Digit = 11 }
    ;   ['b'] -> { Digit = 11 }
    ;   ['C'] -> { Digit = 12 }
    ;   ['c'] -> { Digit = 12 }
    ;   ['D'] -> { Digit = 13 }
    ;   ['d'] -> { Digit = 13 }
    ;   ['E'] -> { Digit = 14 }
    ;   ['e'] -> { Digit = 14 }
    ;   ['F'] -> { Digit = 15 }
    ;   ['f'] -> { Digit = 15 }
    ;   digit(Digit)
    ).

:- pred hex_number2(int, int) `with_type` parser.
:- mode hex_number2(in, out)  `with_inst` parser_pred.

hex_number2(!Hex) -->
    (   hex_digit(Digit)
    ->  { !:Hex = !.Hex << 4 + Digit },
        hex_number2(!Hex)
    ;   { true }
    ).

hex_number(Hex) --> hex_digit(Digit), hex_number2(Digit, Hex).

identifier(Identifier) --> filter(char.is_alnum_or_underscore, Identifier).

word(Word) --> filter_not(char.is_whitespace, Word).

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%
