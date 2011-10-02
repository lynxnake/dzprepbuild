@rem add jcldebug information from the .map file
@rem copy this file to the projects root directory if
@rem you want it automatically called by postbuild.cmd
echo * %0 running in
cd

%~dp0\makejcldbg -e %1.map
@echo * %0 exiting
