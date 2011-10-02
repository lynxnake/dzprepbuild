@rem prebuild.cmd should be called as pre-build event like this:
@rem ..\buildtools\prebuild.cmd $(OUTPUTDIR)$(OUTPUTNAME)
@echo on
@echo %0 running in
cd

set PROJECTPATH=%1
if "%PROJECTPATH%"=="" goto NeedPara
rem echo PROJECTPATH=%PROJECTPATH%
set PROJECTNAMEONLY=%~dpn1
rem echo PROJECTNAMEONLY=%PROJECTNAMEONLY%
set OUTPUTDIR=%~dp1

subwcrev .. %~dp0\templates\SVN_Version_template.ini SVN_Version.ini

pushd %OUTPUTDIR%

%~dp0\prepbuild.exe --incbuild --readini=%PROJECTPATH% --updateini=%PROJECTPATH% --WriteRc=%PROJECTPATH%
brcc32 %PROJECTNAMEONLY%_Version.rc

popd

echo %0 exiting
goto :EOF

:NeedPara
echo needs the base filename of the executable as parameter
