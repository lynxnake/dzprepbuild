@rem This batch will
@rem * call dxgettext to extract all strings to translate
@rem * compile all .po files and copy them to locale\...
@rem * do the same for the sigunits, dzlib and delphi2007 files in libs

@echo off
echo * %0 running in
cd

set MASKS=*.pas *.dfm *.inc *.tpl
set POFILES=
set OUTDIR=.

set BASE=.
%~dp0\dxgettext %MASKS% -r --no-wrap -b %BASE%\src -o %BASE%

if not exist %BASE%\ignore.po goto noIgnore
%~dp0\msgremove --no-wrap %BASE%\default.po -i %BASE%\ignore.po -o %BASE%\filtered.po
move %BASE%\filtered.po %BASE%\default.po
:noIgnore

set POFILES=%POFILES% %BASE%\default.po
%~dp0\msgcat --no-wrap -o default.po %POFILES%

if "%SKIPDE%"=="1" goto skipde
@rem German:
set LNG=de
call :HandLng
:skipde

if "%SKIPFR%"=="1" goto skipfr
@rem French:
set LNG=fr
call :HandLng
:skipfr

if "%SKIPEN%"=="1" goto skipen
@rem English:
set LNG=en
call :HandLng
:skipen

echo * %0 exiting
goto :eof

@rem subroutine for handling a language
:HandLng
@echo ** handling language %LNG% **

@rem merge translations
%~dp0\msgmerge --no-wrap --update locale\%LNG%\lc_messages\default.po default.po

@rem compile
%~dp0\msgfmt locale\%LNG%\lc_messages\default.po --output-file=%OUTDIR%\locale\%LNG%\lc_messages\default.mo

@rem add Delphi translations
if not exist libs\dxgettext\translations\%LNG%\delphi2007.po goto noDelphi
%~dp0\msgfmt libs\dxgettext\translations\%LNG%\delphi2007.po --output-file=%OUTDIR%\locale\%LNG%\lc_messages\delphi2007.mo
:noDelphi

@rem add sigunits translations
if not exist libs\sigunits\translations\%LNG%\sigunits.po goto noSigUnits
%~dp0\msgfmt libs\sigunits\translations\%LNG%\sigunits.po --output-file=%OUTDIR%\locale\%LNG%\lc_messages\sigunits.mo
:noSigUnits

@rem add sigunits and dzlib translations
if not exist libs\dzlib\translations\%LNG%\dzlib.po goto noDzLib
%~dp0\msgfmt libs\dzlib\translations\%LNG%\dzlib.po --output-file=%OUTDIR%\locale\%LNG%\lc_messages\dzlib.mo
:noDzLib
goto :eof
