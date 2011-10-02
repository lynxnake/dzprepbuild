REM - nimmt an, dass das uebergeordnete Verzeichnis gleichzeitig der Name des Projekts ist,
REM - extrahiert ihn und ruft dann bds mit %projekt%.dproj auf.
@echo off

setlocal
call :GetLastDir %0
set project=%result%
start "Delphi XE" "%ProgramFiles%\Embarcadero\RAD Studio\8.0\bin\bds.exe" -pDelphi src\%project%.dproj
endlocal
goto :eof

:GetLastDir
rem Pfad extrahieren
set directory=%~p1%
rem backslash (=letztes Zeichen)  entfernen
set directory=%directory:~0,-1%
rem "Dateienamen" (= letztes Verzeichnis des Pfades) extrahieren
call :LastItem %directory%
goto :eof

:LastItem
set result=%~n1%
goto :eof
