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
    call :SET_HOME MMC mmc
    if not exist "!MMC!" (
        call :SET_HOME MMC mercury_compile
    )
) else (
    call :FIND_IN_PATH mercury.bat MERCURY_COMPILER MERCURY_HOME mmc
    if not exist "!MMC!" (
        call :FIND_IN_PATH mercury.bat MERCURY_COMPILER MERCURY_HOME mercury_compile
    )
)

@if not defined MMC @set MMC=%MERCURY_COMPILER%

@if not exist "Makefile" (
    if exist "%cd%\src\Makefile" (
        set SRC_SUBDIR=%cd%\src
    ) else (
        if exist "%~dp0src\Makefile" set SRC_SUBDIR=%~dp0src
    )
)

:: Make detection
@set make_is_gnu=0
@if not defined MAKE @set MAKE=make
@for /F "usebackq" %%C in (`%MAKE% -v ^| find /c "GNU" 2^>nul`) do @(
    set make_is_gnu=%%C
)

@if %make_is_gnu% EQU 0 (
    @echo The make %MAKE% is not GNU compatible 2>&1
    @rem ember the previous codepage (very important for Windows XP)
    @if %oldCP% NEQ %newCP% chcp %oldCP% 1>nul
    @exit /b 1
)

:: If we have found mmc, proceed to make
@if defined MMC goto :MAKE
@echo Cannot find Mercury compiler executable, MERCURY_HOME=%MERCURY_HOME%
@rem ember the previous codepage (very important for Windows XP)
@if %oldCP% NEQ %newCP% chcp %oldCP% 1>nul
@exit /b 1

:MAKE
    @if defined SRC_SUBDIR @pushd "%SRC_SUBDIR%"
        @set MERCURY_CONFIG_DIR="%MERCURY_HOME%\lib\mercury"
        @call %MAKE% MMC="%MMC:\=/%" MERCURY_HOME="%MERCURY_HOME:\=/%" %*
        @set MAKE_RESULT=%ERRORLEVEL%
    @if defined SRC_SUBDIR @popd
    @rem ember the previous codepage (very important for Windows XP)
    @if %oldCP% NEQ %newCP% chcp %oldCP% 1>nul
    @exit /b %MAKE_RESULT%

:SET_HOME
    @setlocal enabledelayedexpansion enableextensions
    @set BIN=%~2
    @endlocal && (set %1="%MERCURY_HOME%\bin\%BIN%") && exit /b 0

:FIND_IN_PATH
    @setlocal enabledelayedexpansion enableextensions
    @set RESULT=%~dp$PATH:1
    @set BIN=%~4
    @set STRIP=%RESULT%~~~
    @set HOME=%STRIP:bin~~~=%
    @set HOME=%HOME:bin\~~~=%
    @endlocal && (set %2=%RESULT%%BIN%) && (set %3=%HOME%) && exit /b 0
