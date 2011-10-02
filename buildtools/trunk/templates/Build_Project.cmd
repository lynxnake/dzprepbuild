@echo off
REM - nimmt an, dass das uebergeordnete Verzeichnis gleichzeitig der Name des Projekts ist,
REM - extrahiert ihn und ruft dann msbuild mit %projekt%.dproj auf.

setlocal
if not "%project%"=="" goto projgiven
call :GetLastDir %0
set project=%result%
pushd %directory%

:projgiven

echo building project %project%.dproj

call buildtools\InitForDelphi2007.cmd

pushd src
msbuild %project%.dproj
popd
popd
endlocal

if errorlevel 1 goto error
if "%BatchBuild%"=="1" goto nopause
pause
:nopause
goto :eof

:error
echo ************************************
echo ***** Error building %project% *****
echo ************************************
pause
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
