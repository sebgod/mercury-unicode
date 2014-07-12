@setlocal enabledelayedexpansion enableextensions
@call build runtests
@if exist "%~dp0tests\Makefile" @set TESTS_SUBDIR=%~dp0tests

@if defined TESTS_SUBDIR @pushd "%TESTS_SUBDIR%"
@for %%R in (*.res) do @(
    echo @@ %%R
    call "%~dp0tools\convert_utf8to16" <%%R
)

@if defined TESTS_SUBDIR @popd
