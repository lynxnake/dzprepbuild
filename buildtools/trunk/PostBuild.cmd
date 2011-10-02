@rem postbuild.cmd sollte wie folgt als PostBuild-Event aufgerufen werden:
@rem ..\buildtools\postbuild.cmd $(OUTPUTDIR)$(OUTPUTNAME)
@rem

@echo off
@echo %0 running in
cd

@rem needs one parameter: The basename of the executable file (without .exe)
set EXEFILEBASE=%1
if "%EXEFILEBASE%"=="" goto NeedPara

set OUTPUTDIR=%~dp1

pushd %OUTPUTDIR%

if not exist %~dp0\AppendJclDebug.cmd goto NoDebug
  echo appending JclDebug information
  call %~dp0\AppendJclDebug.cmd %EXEFILEBASE%
  goto afterdebug
:NoDebug
echo no jcldebug information appended
:afterdebug

if not exist %~dp0\AppendTranslations.cmd goto NoTrans
  echo appending translations
  call %~dp0\AppendTranslations.cmd %EXEFILEBASE%
  goto aftertrans
:NoTrans
echo no translations appended
:aftertrans

popd

echo %0 exiting
goto :EOF

:NeedPara
echo needs the base filename of the executable as parameter
