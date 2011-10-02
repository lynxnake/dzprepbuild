@rem This batch will
@rem * call dxgettext to extract all strings to translate
@rem * call msgremove remove any strings stored in the ignore.po file
@rem * call msgmerge to merge German and English translations with the new template

set BASE=.

@rem extract from subdirectories src and forms
..\..\buildtools\dxgettext --delphi -r -b %BASE%\src -b %BASE%\forms -o %BASE%

@rem remove strings given in ignore.po
..\..\buildtools\msgremove %BASE%\default.po -i %BASE%\ignore.po -o %BASE%\filtered.po

@rem merge German translations
..\..\buildtools\msgmerge --no-wrap --update %BASE%\translations\de\dzCmdLineParser.po %BASE%\filtered.po

@rem merge English translations
..\..\buildtools\msgmerge --no-wrap --update %BASE%\translations\en\dzCmdLineParser.po %BASE%\filtered.po

@rem merge French translations
..\..\buildtools\msgmerge --no-wrap --update %BASE%\translations\fr\dzCmdLineParser.po %BASE%\filtered.po

pause
