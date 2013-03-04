@echo off
REM - assumes that the parent directory is also the project name, extracts it
REM - and calls msbuild with %project%.dproj

setlocal
set project=%1
if not "%project%"=="" goto projgiven
call :GetLastDir %0
set project=%result%

:projgiven

echo building project %project%.dproj using Delphi XE2

call buildtools\delphiversions.cmd

if not exist "%DelphiXE2Dir%\bin\rsvars.bat" goto nodelphi
call "%DelphiXE2Dir%\bin\rsvars.bat"

pushd src
msbuild %project%.dproj | ..\buildtools\msbuildfilter ..\errors.txt
popd

if errorlevel 1 goto error
endlocal
if "%BatchBuild%"=="1" goto nopause
pause
:nopause
goto :eof

:nodelphi
echo ************************************
echo ****** Error building %project%
echo ****** Delphi installation missing
echo ************************************
if "%MAILSend%"=="" goto nomail
%MAILSend% -sub "Error building %project%" -M "Delphi installation missing"
popd
endlocal
goto :eof

:nomail
popd
endlocal
pause
goto :eof

:error
echo ************************************
echo ****** Error building %project%
echo ************************************
if "%MAILSend%"=="" goto nomail
%MAILSend% -sub "Error building %project%" -M "Build Error" -attach errors.txt,text/plain,a
endlocal
goto :eof

:nomail
endlocal
pause
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
