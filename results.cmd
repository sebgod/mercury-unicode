@setlocal enabledelayedexpansion enableextensions

@if exist "%~dp0src\Makefile" @set SRC_SUBDIR=%~dp0src

@if defined SRC_SUBDIR @pushd "%SRC_SUBDIR%"
@for %%R in (*.res) do @(
    echo @@ %%R
    call convert_utf8to16 <%%R
)

@if defined SRC_SUBDIR @popd
