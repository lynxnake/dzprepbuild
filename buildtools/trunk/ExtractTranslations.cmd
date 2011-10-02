@echo off
@rem this file must be copied to the main project directory since it does not work inside the buildtools subdir

rem set the following if you don't need French, English or German translations:
rem set SKIPDE=1
rem set SKIPFR=1
rem set SKIPEN=1

if not exist buildtools\doextracttranslations.cmd goto error
call buildtools\doextracttranslations.cmd
goto ende

:error
echo this file must be copied to the main project directory since it does not work inside the buildtools subdir

:ende
pause
start "buildtools\gorm.exe" locale\de\lc_messages\default.po
