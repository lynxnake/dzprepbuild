unit u_IniVersionInfo;

interface

uses
  SysUtils,
  IniFiles,
  u_VersionInfo;

type
  {: Tries to read a <projectname>.ini file, succeeds, if it exists
     @param Project is the project name (*.dpr file without extension)
     @param VersionInfo is a TVersionInfoRec record which will be filled with the version info }
  TIniVersionInfo = class(TInterfacedObject)
  protected
    FIniFile: TMemIniFile;
    FInfoSection: string;
    FInfoKeysSection: string;
    function ReadInteger(const _Section, _Ident: string; _Default: integer): integer; virtual;
    procedure WriteInteger(const _Section, _Ident: string; _Value: integer); virtual;
    function ReadString(const _Section, _Ident: string; _Default: string): string; virtual;
    procedure WriteString(const _Section, _Ident: string; _Value: string); virtual;
    function ReadBool(const _Section, _Ident: string; _Default: boolean): boolean; virtual;
    procedure WriteBool(const _Section, _Ident: string; _Value: boolean); virtual;
  private
    FIniFilename: string;
  protected // implement IVersionInfoAccess
    function VerInfoFilename: string;
    procedure ReadFromFile(_VerInfo: TVersionInfo);
    procedure WriteToFile(_VerInfo: TVersionInfo);
  public
    {: Creates a TIniVersionInfo instance.
       @param FullFilename is the full filename including path and extension of
                           file to use
       @param InfoSection is the name of the section that contains the general
                          version info like Major/Minor version, Release etc.
                          In a Delphi .dof file this section is called [Version Info]
       @param InfoKeySection is the name of the section that contains the additional
                             strings of the version information
                             In a Delphi .dof file this section is called [Version Info Keys] }
    constructor Create(const _FullFilename: string; const _InfoSection: string;
      const _InfoKeysSection: string);
    destructor Destroy; override;
  end;

implementation

uses
  u_dzTranslator,
  i_VersionInfoAccess;

{ TIniVersionInfo }

constructor TIniVersionInfo.Create(const _FullFilename: string; const _InfoSection: string;
  const _InfoKeysSection: string);
begin
  inherited Create;
  FIniFilename := _FullFilename;
  if not FileExists(_FullFilename) then
    raise ENoVersionInfo.CreateFmt(_('File %s does not exist.'), [_FullFilename]);
  FInfoSection := _InfoSection;
  FInfoKeysSection := _InfoKeysSection;
  FIniFile := TMemIniFile.Create(_FullFilename);
end;

destructor TIniVersionInfo.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

function TIniVersionInfo.ReadBool(const _Section, _Ident: string; _Default: boolean): boolean;
begin
  Result := 0 <> ReadInteger(_Section, _Ident, Ord(_Default));
end;

function TIniVersionInfo.ReadInteger(const _Section, _Ident: string; _Default: integer): integer;
var
  s: string;
begin
  s := ReadString(_Section, _Ident, IntToStr(_Default));
  if not TryStrToInt(s, Result) then
    Result := _Default;
end;

function TIniVersionInfo.ReadString(const _Section, _Ident: string; _Default: string): string;
begin
  Result := FIniFile.ReadString(_Section, _Ident, _Default);
end;

function TIniVersionInfo.VerInfoFilename: string;
begin
  Result := FIniFilename;
end;

procedure TIniVersionInfo.WriteBool(const _Section, _Ident: string; _Value: boolean);
begin
  WriteInteger(_Section, _Ident, Ord(_Value));
end;

procedure TIniVersionInfo.WriteInteger(const _Section, _Ident: string; _Value: integer);
begin
  WriteString(_Section, _Ident, IntToStr(_Value));
end;

procedure TIniVersionInfo.WriteString(const _Section, _Ident: string; _Value: string);
begin
  FIniFile.WriteString(_Section, _Ident, _Value);
end;

procedure TIniVersionInfo.ReadFromFile(_VerInfo: TVersionInfo);
begin
  _VerInfo.Source := VerInfoFilename;

  _VerInfo.AutoIncBuild := ReadBool(FInfoSection, 'AutoIncBuild', False);

  _VerInfo.Build := ReadInteger(FInfoSection, 'Build', 0);
  _VerInfo.MajorVer := ReadInteger(FInfoSection, 'MajorVer', 0);
  _VerInfo.MinorVer := ReadInteger(FInfoSection, 'MinorVer', 0);
  _VerInfo.Release := ReadInteger(FInfoSection, 'Release', 0);

  _VerInfo.Comments := ReadString(FInfoKeysSection, 'Comments', '');
  _VerInfo.CompanyName := ReadString(FInfoKeysSection, 'CompanyName', '');
  _VerInfo.FileDescription := ReadString(FInfoKeysSection, 'FileDescription', '');
  _VerInfo.FileVersion := ReadString(FInfoKeysSection, 'FileVersion', '');
  _VerInfo.InternalName := ReadString(FInfoKeysSection, 'InternalName', '');
  _VerInfo.LegalCopyright := ReadString(FInfoKeysSection, 'LegalCopyright', '');
  _VerInfo.LegalTrademarks := ReadString(FInfoKeysSection, 'LegalTrademarks', '');
  _VerInfo.OriginalFilename := ReadString(FInfoKeysSection, 'OriginalFilename', '');
  _VerInfo.ProductName := ReadString(FInfoKeysSection, 'ProductName', '');
  _VerInfo.ProductVersion := ReadString(FInfoKeysSection, 'ProductVersion', '');
end;

procedure TIniVersionInfo.WriteToFile(_VerInfo: TVersionInfo);
begin
  WriteBool(FInfoSection, 'AutoIncBuild', _VerInfo.AutoIncBuild);
  WriteInteger(FInfoSection, 'Build', _VerInfo.Build);
  WriteString(FInfoKeysSection, 'Comments', _VerInfo.Comments);
  WriteString(FInfoKeysSection, 'CompanyName', _VerInfo.CompanyName);
  WriteString(FInfoKeysSection, 'FileDescription', _VerInfo.FileDescription);
  WriteString(FInfoKeysSection, 'FileVersion', _VerInfo.FileVersion);
  WriteString(FInfoKeysSection, 'InternalName', _VerInfo.InternalName);
  WriteString(FInfoKeysSection, 'LegalCopyright', _VerInfo.LegalCopyright);
  WriteString(FInfoKeysSection, 'LegalTrademarks', _VerInfo.LegalTrademarks);
  WriteInteger(FInfoSection, 'MajorVer', _VerInfo.MajorVer);
  WriteInteger(FInfoSection, 'MinorVer', _VerInfo.MinorVer);
  WriteString(FInfoKeysSection, 'OriginalFilename', _VerInfo.OriginalFilename);
  WriteString(FInfoKeysSection, 'ProductName', _VerInfo.ProductName);
  WriteString(FInfoKeysSection, 'ProductVersion', _VerInfo.ProductVersion);
  WriteInteger(FInfoSection, 'Release', _VerInfo.Release);
  FIniFile.UpdateFile;
end;

end.

