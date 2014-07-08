@setlocal enabledelayedexpansion
@set tmpFile=%temp%\%RAND%.%RAND%.%RAND%.utf16.tmp
@copy /y "%~dp0empty_utf16le_bom.txt" "%tmpFile%" 1>nul 2>nul
@iconv -f utf-8 -t utf-16le >>"%tmpFile%"
@type "%tmpFile%"
@del "%tmpFile%"
@exit /b 0
