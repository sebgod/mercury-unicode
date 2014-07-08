@setlocal enabledelayedexpansion enableextensions

:: For the C# compiler, we MUST NOT use the UTF-8 codepage
@set newCP=850
@for /F "usebackq tokens=2 delims=:" %%A in (`chcp`) do @(
    set oldCP=%%A
    set oldCP=!oldCP: =!
    set oldCP=!oldCP:.=!
)
@if %oldCP% NEQ %newCP% chcp %newCP% 1>nul


@if defined MERCURY_HOME (
   call :SET_HOME MMC
) else (
   call :FIND_IN_PATH mercury.bat MMC MERCURY_HOME
)

@if exist "%~dp0src\Makefile" @set SRC_SUBDIR=%~dp0src

@if defined MMC goto :MAKE
@echo Cannot find Mercury compiler executable, MERCURY_HOME=%MERCURY_HOME%
@exit /b 1

:MAKE
    @if defined SRC_SUBDIR @pushd "%SRC_SUBDIR%"
    make MMC=%MMC% MERCURY_HOME=%MERCURY_HOME% %*
    @set MAKE_RESULT=%ERRORLEVEL%
    @rem going back to the current working directory
    @if defined SRC_SUBDIR @popd
    @rem ember the previous codepage (very important for Windows XP)
    @if %oldCP% NEQ %newCP% chcp %oldCP% 1>nul
    @exit /b %MAKE_RESULT%

:SET_HOME
    @setlocal enabledelayedexpansion
    @endlocal && ( set %1="%MERCURY_HOME%\bin\mmc" ) && exit /b 0

:FIND_IN_PATH
    @setlocal enabledelayedexpansion
    @set RESULT=%~dp$PATH:1
    @set STRIP=%RESULT%~~~
    @set HOME=%STRIP:bin~~~=%
    @endlocal && ( set %2=%RESULT%mmc ) && ( set %3=%HOME% ) && exit /b 0
