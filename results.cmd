@setlocal enabledelayedexpansion enableextensions
@set TARGET=runtests
@if /i "%~1" EQU "-v" set TARGET=runtests-verbose
@if /i "%~1" EQU "--verbose" set TARGET=runtests-verbose

@call build %TARGET%
@if exist "%~dp0tests\Makefile" @set TESTS_SUBDIR=%~dp0tests

@if defined TESTS_SUBDIR @pushd "%TESTS_SUBDIR%"
@for %%E in (res test_err) do @(
    @for %%F in (*.%%E) do @(
        echo @@ %%F
        call "%~dp0tools\convert_utf8to16" <%%F
    )
)

@if defined TESTS_SUBDIR @popd
