@setlocal enabledelayedexpansion enableextensions

@rem ember that for the C# compiler, we MUST NOT use the UTF-8 codepage
@set newCP=850
@for /F "usebackq tokens=2 delims=:" %%A in (`chcp`) do @(
    set oldCP=%%A
    set oldCP=!oldCP: =!
    set oldCP=!oldCP:.=!
)
@if %oldCP% NEQ %newCP% chcp %newCP% 1>nul

@if defined MERCURY_HOME (
   call :SET_HOME MERCURY_COMPILER
) else (
   call :FIND_IN_PATH mercury.bat MERCURY_COMPILER MERCURY_HOME
)

@if not exist "Makefile" (
    if exist "%cd%\src\Makefile" (
        set SRC_SUBDIR=%cd%\src
    ) else (
        if exist "%~dp0src\Makefile" set SRC_SUBDIR=%~dp0src
    )
)

@if defined MERCURY_COMPILER goto :MAKE
@echo Cannot find Mercury compiler executable, MERCURY_HOME=%MERCURY_HOME%
@rem ember the previous codepage (very important for Windows XP)
@if %oldCP% NEQ %newCP% chcp %oldCP% 1>nul
@exit /b 1

:MAKE
    @if defined SRC_SUBDIR @pushd "%SRC_SUBDIR%"
        @set MERCURY_CONFIG_DIR="%MERCURY_HOME%\lib\mercury"
        @call gmake MMC="%MERCURY_COMPILER:\=/%" MERCURY_HOME="%MERCURY_HOME:\=/%" %*
        @set MAKE_RESULT=%ERRORLEVEL%
    @if defined SRC_SUBDIR @popd
    @rem ember the previous codepage (very important for Windows XP)
    @if %oldCP% NEQ %newCP% chcp %oldCP% 1>nul
    @exit /b %MAKE_RESULT%

:SET_HOME
    @setlocal enabledelayedexpansion
    @endlocal && (set %1="%MERCURY_HOME%\bin\mercury_compile") && exit /b 0

:FIND_IN_PATH
    @setlocal enabledelayedexpansion enableextensions
    @set RESULT=%~dp$PATH:1
    @set STRIP=%RESULT%~~~
    @set HOME=%STRIP:bin~~~=%
    @set HOME=%HOME:bin\~~~=%
    @endlocal && (set %2=%RESULT%mercury_compile) && (set %3=%HOME%) && exit /b 0
