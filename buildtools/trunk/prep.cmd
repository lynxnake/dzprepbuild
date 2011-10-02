@echo off
%~dp0\PrepBuild --writerc=%dzProject%.rc --updateini=%dzProject% --MajorVer=%dzVersion.MajorVer% --MinorVer=%dzVersion.MinorVer% --Release=%dzVersion.Release% --Build=%dzVersion.Build% --FileDesc="%dzVersion.FileDesc%" --InternalName="%dzVersion.InternalName%" --OriginalName="%dzVersion.OriginalName%" --Product="%dzVersion.Product%" --ProductVersion="%dzDate%" --Company="%dzVersion.Company%" --Copyright="%dzVersion.Copyright%" --Trademark="%dzVersion.Trademark%" --Comments="%dzVersion.Comments%"
brcc32 %dzProject%_Version.rc
