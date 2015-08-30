%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: line_parser.m
% Main author: Sebastian Godelet <sebastian.godelet@outlook.com>
% Created on: Mon Mar 10 15:18:45 CET 2014
%
%----------------------------------------------------------------------------%

:- module line_parser.

:- interface.

:- import_module list.
:- import_module map.
:- import_module io.
:- import_module char.

:- type chars == list(char).

:- type parser_pred == pred(chars, chars).

:- type parser_pred(T) == pred(list(T), list(T), chars, chars).

:- type parser_pred(K, V) == pred(map(K, V), map(K, V), chars, chars).

:- inst det_parser_pred  == (pred(in, out) is det).

:- inst det_parser2_pred == (pred(in, out, in, out) is det).

:- inst parser_pred  == (pred(in, out) is semidet).

:- inst parser2_pred == (pred(in, out, in, out) is semidet).

:- pred lines(parser_pred(K, T), map(K, T), map(K, T), io, io).
:- mode lines(in(parser2_pred), in, out, di, uo) is det.
:- mode lines(in(det_parser2_pred), in, out, di, uo) is det.

:- pred junk : parser_pred `with_inst` parser_pred.

:- pred any(string) : parser_pred.
:- mode any(in)     `with_inst` parser_pred.
:- mode any(out)    `with_inst` parser_pred.

:- pred until(chars, string) : parser_pred.
:- mode until(in, out)       `with_inst` parser_pred.

:- pred ws : parser_pred `with_inst` parser_pred.

:- pred ws_char : parser_pred `with_inst` parser_pred.

:- pred ws_opt : parser_pred.
:- mode ws_opt(in, out) is det.

:- pred char(char) : parser_pred.
:- mode char(in)   `with_inst` parser_pred.
:- mode char(out)  `with_inst` parser_pred.

:- pred digit(int) : parser_pred.
:- mode digit(in)  `with_inst` parser_pred.
:- mode digit(out) `with_inst` parser_pred.

:- pred hex_number(int) : parser_pred.
:- mode hex_number(in)  `with_inst` parser_pred.
:- mode hex_number(out) `with_inst` parser_pred.

:- pred hex_digit(int)  : parser_pred.
:- mode hex_digit(in)   `with_inst` parser_pred.
:- mode hex_digit(out)  `with_inst` parser_pred.

:- pred identifier(string) : parser_pred.
:- mode identifier(in)     `with_inst` parser_pred.
:- mode identifier(out)    `with_inst` parser_pred.

:- pred word(string) : parser_pred.
:- mode word(in)     `with_inst` parser_pred.
:- mode word(out)    `with_inst` parser_pred.

:- type filter_pred == pred(char).
:- inst filter_pred == (pred(in) is semidet).
:- type filter_pred(T) == pred(filter_pred, T, chars, chars).
:- inst filter_pred_in  == (pred(in(filter_pred), in, in, out) is semidet).
:- inst filter_pred_out == (pred(in(filter_pred), out, in, out) is semidet).

:- pred filter : filter_pred(string).
:- mode filter `with_inst` filter_pred_in.
:- mode filter `with_inst` filter_pred_out.

:- pred filter_chars : filter_pred(chars).
:- mode filter_chars `with_inst` filter_pred_in.
:- mode filter_chars `with_inst` filter_pred_out.

:- pred filter_char : filter_pred(char).
:- mode filter_char `with_inst` filter_pred_in.
:- mode filter_char `with_inst` filter_pred_out.

:- pred parse_error(string, string, string, chars, io, io).
:- mode parse_error(in, in, in, in, di, uo) is erroneous.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module int.       % for digit parsing
:- import_module require.
:- import_module std_util.  % for isnt
:- import_module string.    % for format et.al.

%----------------------------------------------------------------------------%

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
            ( if  Rest = [] then
                true
            else
                parse_error($file, $pred,
                    "still unparsed: " ++ from_char_list(Rest), Line, !IO)
            )
        ;   parse_error($file, $pred, "`LineParser' lambda failed", Line, !IO)
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
    ( if
        filter_char(Filter, C)
    then
        { Word = [C | Rest] },
        filter_chars(Filter, Rest)
    else
        { Word = [] }
    ).

filter_char(Filter, Char) --> [Char], { Filter(Char) }.

any(Any) --> filter(isnt(char.is_noncharacter), Any).

junk --> any(_).

until(Sep, Match) --> filter(isnt(contains(Sep)), Match).

ws_char --> filter_char(char.is_whitespace, _).

ws_opt --> ( if ws_char then ws_opt else { true } ).

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

:- pred hex_number2(int, int) : parser_pred.
:- mode hex_number2(in, out)  `with_inst` parser_pred.

hex_number2(!Hex) -->
    ( if hex_digit(Digit) then
        { !:Hex = !.Hex << 4 + Digit },
        hex_number2(!Hex)
    else
        { true }
    ).

hex_number(Hex) --> hex_digit(Digit), hex_number2(Digit, Hex).

identifier(Identifier) --> filter(char.is_alnum_or_underscore, Identifier).

word(Word) --> filter(isnt(char.is_whitespace), Word).

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%
