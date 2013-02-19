@echo off
REM - assumes that the parent directory is also the project name, extracts it
REM - and calls msbuild with %project%.dproj

setlocal
if not "%project%"=="" goto projgiven
call :GetLastDir %0
set project=%result%
pushd %directory%

:projgiven

echo building project %project%.dproj using Delphi XE

call buildtools\delphiversions.cmd

call "%DelphiXE2Dir%\bin\rsvars.bat"

pushd src
msbuild %project%.dproj | ..\buildtools\msbuildfilter
popd
popd

if errorlevel 1 goto error
endlocal
if "%BatchBuild%"=="1" goto nopause
pause
:nopause
goto :eof

:error
echo ************************************
echo ***** Error building %project% *****
echo ************************************
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
