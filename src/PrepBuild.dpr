program PrepBuild;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Forms,
  d_XmlVersionInfo in 'd_XmlVersionInfo.pas' {dm_XmlVersionInfo: TDataModule},
  d_DprojVersionInfo in 'd_DprojVersionInfo.pas' {dm_DprojVersionInfo: TDataModule},
  d_BdsProjVersionInfo in 'd_BdsProjVersionInfo.pas' {dm_BdsProjVersionInfo: TDataModule},
  i_VersionInfoAccess in 'i_VersionInfoAccess.pas',
  u_DofVersionInfo in 'u_DofVersionInfo.pas',
  u_IniVersionInfo in 'u_IniVersionInfo.pas',
  u_CentralIniVersionInfo in 'u_CentralIniVersionInfo.pas',
  u_PrepBuildMain in 'u_PrepBuildMain.pas',
  u_VersionInfo in 'u_VersionInfo.pas',
  u_dzDefaultMain in '..\libs\dzCmdLineParser\src\u_dzDefaultMain.pas',
  w_dzDialog in '..\libs\dzlib\forms\w_dzDialog.pas' {f_dzDialog};

{$R *_icon.res}
{$R *_version.res}

begin
  Application.Initialize;
  Application.Title := 'PrepBuild';
  MainClass := TPrepBuildMain;
  System.ExitCode := Main;
end.

