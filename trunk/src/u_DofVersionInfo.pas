unit u_DofVersionInfo;

interface

uses
  SysUtils,
  IniFiles,
  i_VersionInfoAccess,
  u_VersionInfo,
  u_IniVersionInfo;

type
  {: This is a specialized version of TIniVersionInfo which reads a
     <projectname>.dof file, that was used by Delphi up to version 7. }
  TDofVersionInfo = class(TIniVersionInfo, IVersionInfoAccess)
  private
    FProjectName: string;
  public
    {: Creates a TDofVersionInfo instance. Succeeds, if the file exists
       and IncludeVerInfo is <> 0
       @param _Projectname is the project name (*.dpr file without extension)
       @raises ENoVersionInfo if the file does not exist or
                              the value of [Version Info] IncludeVerInfo is not 1 }
    constructor Create(const _ProjectName: string);
    class function FilenameFor(const _ProjectName: string): string;
  end;

implementation

uses
  u_dzTranslator;

const
  VERSION_INFO_SECTION = 'Version Info';
  VERSION_INFO_KEYS_SECTION = 'Version Info Keys';

{ TDofVersionInfo }

constructor TDofVersionInfo.Create(const _ProjectName: string);
begin
  FProjectName := _ProjectName;
  inherited Create(VerInfoFilename, VERSION_INFO_SECTION, VERSION_INFO_KEYS_SECTION);
  if FIniFile.ReadInteger(VERSION_INFO_SECTION, 'IncludeVerInfo', 0) <> 1 then
    raise ENoVersionInfo.Create(_('.dof file does not contain version info'));
end;

class function TDofVersionInfo.FilenameFor(const _ProjectName: string): string;
begin
  Result := ChangeFileExt(_ProjectName, '.dof');
end;

end.

