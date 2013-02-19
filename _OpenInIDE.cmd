@echo off
REM - assumes that the parent directory is also the project name, extracts it
REM - and calls msbuild with %project%.dproj

setlocal
call buildtools\delphiversions.cmd
call :GetLastDir %0
set project=%result%
start "Delphi XE2" "%DelphiXE2Dir%\bin\bds.exe" -pDelphi src\%project%.dproj
endlocal
goto :eof

:GetLastDir
rem extract path
set directory=%~p1%
rem remove backslash (=last character)
set directory=%directory:~0,-1%
rem extract "filename" (= last directory of path)
call :LastItem %directory%
goto :eof

:LastItem
set result=%~n1%
goto :eof
