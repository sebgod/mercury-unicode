%----------------------------------------------------------------------------%
% vim: ft=mercury ff=unix ts=4 sw=4 tw=78 et
%----------------------------------------------------------------------------%
% File: ucd_file_parser_predm
% Main author: Sebastian Godelet <sebastian.godelet+github@gmail.com>
% Created on: Tue Mar 18 15:25:31 CET 2014
%
%----------------------------------------------------------------------------%

:- module ucd_file_parser.

:- interface.

:- import_module io.
:- import_module map.
:- import_module line_parser.

%----------------------------------------------------------------------------%

:- pred value_name_no_ws(string) : parser_pred.
:- mode value_name_no_ws(out)    `with_inst` parser_pred.

:- pred until_separator(string) : parser_pred.
:- mode until_separator(out)    `with_inst` parser_pred.

:- pred not_eol_or_comment(string) : parser_pred.
:- mode not_eol_or_comment(out)    `with_inst` parser_pred.

:- pred separator : parser_pred `with_inst` parser_pred.

:- pred char_range(int, int) : parser_pred.
:- mode char_range(out, out) `with_inst` parser_pred.

:- pred file(string, parser_pred(K, V), map(K, V), io, io).
:- mode file(in, in(parser2_pred), out, di, uo) is det.

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%

:- implementation.

:- import_module list.
:- import_module require.

%----------------------------------------------------------------------------%

value_name_no_ws(ValueName) -->
    until([';', ' ', '\t', '\r', '\n'], ValueName).

until_separator(ValueName)  --> until([';'], ValueName).

not_eol_or_comment(ValueName) --> until(['\r', '\n', '#'], ValueName).

separator --> ws_opt, [';'], ws_opt.

char_range(Start, End) -->
    hex_number(Start),
    (   ['.', '.']  ->  hex_number(End)
    ;   { End = Start }
    ).

file(InputFile, Parser, Parsed, !IO) :-
    see(InputFile, Result, !IO),
    (
        Result = error(Error) ->
        unexpected($file, $pred, io.error_message(Error))
    ;
        lines(Parser, init, Parsed, !IO),
        seen(!IO)
    ).

%----------------------------------------------------------------------------%
%----------------------------------------------------------------------------%
