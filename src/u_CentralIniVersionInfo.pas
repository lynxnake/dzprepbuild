unit u_CentralIniVersionInfo;

interface

uses
  i_VersionInfoAccess,
  u_IniVersionInfo;

type
  {: This is a specialized descendant of TIniVersionInfo which
     allows any entry of the file to redirect to a different file.
     This can be done for single entries or for a whole section.
     For redirecting a single entry, the value must contain a string
     REDIRECT:<filename>,<section><entry>
     For redirecting a section it must contain only one entry
     redirect=<filename>,<section>
     These redirections will be used for reading and writing, that is it can be
     used to maintain/increment a central build number for several branches of
     a project where the files have different version numbers but the build
     number should be increased for a build of any of these versions. }
  TCentralIniVersionInfo = class(TIniVersionInfo, IVersionInfoAccess)
  private
    FProjectName: string;
    procedure GetRedirIdentInfo(const _RedirString: string; out _Filename, _Section, _Ident: string);
    procedure GetRedirSectionInfo(_Redir: string; out _Filename, _Section: string);
    procedure AdjustFilename(var _Filename: string);
  protected
    function ReadString(const _Section, _Ident: string; _Default: string): string; override;
    procedure WriteString(const _Section, _Ident: string; _Value: string); override;
  public
    {: Creates a TCentralVersionInfo instance
       @param ProjectName is the name of the project (.dpr file without extension)
                          The constructor appends "_Version.ini" to this
                          name and tries to open the file }
    constructor Create(const _ProjectName: string);
  end;

implementation

uses
  SysUtils,
  IniFiles,
  u_dzStringUtils;

const
  VERSION_INFO_SECTION = 'Version Info';
  VERSION_INFO_KEYS_SECTION = 'Version Info Keys';

{ TCentralVersionInfo }

constructor TCentralIniVersionInfo.Create(const _ProjectName: string);
begin
  inherited Create(ChangeFileExt(_ProjectName, '_Version.ini'), VERSION_INFO_SECTION, VERSION_INFO_KEYS_SECTION);
end;

procedure TCentralIniVersionInfo.AdjustFilename(var _Filename: string);
var
  Path: string;
begin
  Path := ExtractFilePath(_Filename);
  if (Path = '') or ((Path[1] <> '\') and (Copy(Path, 2, 1) <> ':')) then begin
      // Path is relative, so make it relative to the main .ini file
    _Filename := ExtractFilePath(FProjectName) + _Filename;
  end;
end;

procedure TCentralIniVersionInfo.GetRedirSectionInfo(_Redir: string; out _Filename, _Section: string);
begin
  _Filename := ExtractStr(_Redir, ',');
  _Section := _Redir;
  AdjustFilename(_Filename);
end;

procedure TCentralIniVersionInfo.GetRedirIdentInfo(const _RedirString: string;
  out _Filename, _Section, _Ident: string);
var
  Redir: string;
begin
  Redir := Copy(_RedirString, Length('redirect:') + 1);
  _Filename := ExtractStr(Redir, ',');
  _Section := ExtractStr(Redir, ',');
  _Ident := Redir;
  AdjustFilename(_Filename);
end;

function TCentralIniVersionInfo.ReadString(const _Section, _Ident: string; _Default: string): string;
var
  Redir: string;
  IniFile: TMemIniFile;
  Filename: string;
  Section: string;
  Ident: string;
begin
  Redir := FIniFile.ReadString(_Section, 'redirect', '');
  if Redir = '' then begin
    Result := FIniFile.ReadString(_Section, _Ident, _Default);
    if UStartsWith('redirect:', Result) then begin
      GetRedirIdentInfo(Result, Filename, Section, Ident);
      IniFile := TMemIniFile.Create(Filename);
      try
        Result := IniFile.ReadString(Section, Ident, _Default);
      finally
        IniFile.Free;
      end;
    end;
  end else begin
    GetRedirSectionInfo(Redir, Filename, Section);
    IniFile := TMemIniFile.Create(Filename);
    try
      Result := IniFile.ReadString(Section, _Ident, _Default);
    finally
      IniFile.Free;
    end;
  end;
end;

procedure TCentralIniVersionInfo.WriteString(const _Section, _Ident: string; _Value: string);
var
  Redir: string;
  IniFile: TMemIniFile;
  Filename: string;
  Section: string;
  Ident: string;
begin
  Redir := FIniFile.ReadString(_Section, 'redirect', '');
  if Redir = '' then begin
    Redir := FIniFile.ReadString(_Section, _Ident, '');
    if UStartsWith('redirect:', Redir) then begin
      GetRedirIdentInfo(Redir, Filename, Section, Ident);
      IniFile := TMemIniFile.Create(Filename);
      try
        IniFile.WriteString(Section, Ident, _Value);
        IniFile.UpdateFile;
      finally
        IniFile.Free;
      end;
    end else
      FIniFile.WriteString(_Section, _Ident, _Value);
  end else begin
    GetRedirSectionInfo(Redir, Filename, Section);
    IniFile := TMemIniFile.Create(Filename);
    try
      IniFile.WriteString(Section, _Ident, _Value);
      IniFile.UpdateFile;
    finally
      IniFile.Free;
    end;
  end;
end;

end.

