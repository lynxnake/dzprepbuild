@rem * compile translations
@rem * bind them to the executable
@rem copy this file to the projects root directory if
@rem you want it automatically called by postbuild.cmd

echo * %0 running in
cd

rem determine the project directory that is the one in which
rem the directory buildtools is located
call :GetDrvAndDir %0
set MyDir=%result%
call :GetDrvAndDir %MyDir%
set ProjectDir=%result%

if exist locale goto locexists
echo subdirectory locale does not exist, no translation added
goto :eof

:locexists

@rem German:
set LNG=de
@call :HandLng

@rem French:
set LNG=fr
@call :HandLng

@rem English:
set LNG=en
@call :HandLng

@echo bind all translations to the executable
%~dp0assemble %1.exe --dxgettext
echo off

echo * %0 exiting
goto :eof

@rem subroutine for handling a language
:HandLng

@echo ** handling language %LNG% **
if exist locale\%LNG%\lc_messages goto lcmsgexists
echo *** subdir locale\%LNG%\lc_messages does not exist skipping language %LNG% ***
goto :eof
:lcmsgexists

if not exist %ProjectDir%\libs\dspack\translations\%LNG%\dspack.po goto nodspack
@echo compile %LNG% dspack.po
%~dp0\msgfmt %ProjectDir%\libs\dspack\translations\%LNG%\dspack.po -o locale\%LNG%\lc_messages\dspack.mo
:nodspack

if not exist %ProjectDir%\libs\dzlib\translations\%LNG%\dzlib.po goto nodzlib
@echo compile %LNG% dzlib.po
%~dp0\msgfmt %ProjectDir%\libs\dzlib\translations\%LNG%\dzlib.po -o locale\%LNG%\lc_messages\dzlib.mo
:nodzlib

if not exist %ProjectDir%\libs\sigunits\translations\%LNG%\sigunits.po goto nosigunits
@echo compile %LNG% sigunits.po
%~dp0\msgfmt %ProjectDir%\libs\sigunits\translations\%LNG%\sigunits.po -o locale\%LNG%\lc_messages\sigunits.mo
:nosigunits

if not exist %ProjectDir%\libs\dxgettext\translations\%LNG%\delphi2007.po goto nodelphi
@echo compile %LNG% delphi2007.po
%~dp0\msgfmt %ProjectDir%\libs\dxgettext\translations\%LNG%\delphi2007.po -o locale\%LNG%\lc_messages\delphi2007.mo
:nodelphi

if not exist %ProjectDir%\libs\comport\locale\%LNG%\LC_MESSAGES\cport.po goto nocomport
@echo compile %LNG% cport.po
%~dp0\msgfmt %ProjectDir%\libs\comport\locale\%LNG%\LC_MESSAGES\cport.po -o locale\%LNG%\lc_messages\cport.mo
:nocomport

@echo compile %LNG% default.po
%~dp0\msgfmt %ProjectDir%\locale\%LNG%\lc_messages\default.po -o locale\%LNG%\lc_messages\default.mo

goto :eof

:GetDrvAndDir
rem extract directory
set directory=%~dp1
rem remove backslash (=last character)
set result=%directory:~0,-1%
goto :eof
