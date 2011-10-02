@echo off
rem Sourcen aus Repository updaten
rem Build durchfuehren
rem falls Fehler: Anhalten und Fehler anzeigen
rem revert der automatischen Buildnummer-Aenderung

svn update
if errorlevel 1 goto Error

set BatchBuild=1
call build_project.cmd

svn revert src\*_version.ini
if errorlevel 1 goto error

goto :eof

:error
echo ***** ERROR *****
pause

