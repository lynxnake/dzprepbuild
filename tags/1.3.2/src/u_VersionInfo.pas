unit u_VersionInfo;

interface

uses
  SysUtils;

type
  TVersionInfo = class
  private
    FMajorVer: Integer;
    FMinorVer: Integer;
    FRelease: Integer;
    FBuild: Integer;

    FFileVersion: string;
    FProductVersion: string;
    FProductName: string;
    FLegalTrademarks: string;
    FLegalCopyright: string;
    FCompanyName: string;
    FAutoIncBuild: Boolean;
    FFileDescription: string;
    FInternalName: string;
    FOriginalFilename: string;
    FComments: string;
    FSource: string;
    FSCMRevision: string;
    FBuildDateTime: string;
    FIsPrivateBuild: Boolean;
    FIsSpecialBuild: Boolean;
    FPrivateBuildComments: string;
    FSpecialBuildComments: string;
    function ResolveVariable(const _s: string): string;
    procedure AdjustFilename(var _Filename: string);
  protected
    function GetAutoIncBuild: Boolean;
    procedure SetAutoIncBuild(_AutoIncBuild: Boolean); virtual;
    //
    procedure Assign(_VersionInfo: TVersionInfo); virtual;
    //
    function GetMajorVer: Integer; virtual;
    function GetMinorVer: Integer; virtual;
    function GetRelease: Integer; virtual;
    function GetBuild: Integer; virtual;
    procedure SetMajorVer(_MajorVer: Integer); virtual;
    procedure SetMinorVer(_MinorVer: Integer); virtual;
    procedure SetRelease(_Release: Integer); virtual;
    procedure SetBuild(_Build: Integer); virtual;
    //
    function GetComments: string; virtual;
    function GetCompanyName: string; virtual;
    function GetFileDescription: string; virtual;
    function GetFileVersion: string; virtual;
    function GetInternalName: string; virtual;
    function GetLegalCopyright: string; virtual;
    function GetLegalTrademarks: string; virtual;
    function GetOriginalFilename: string;
    function GetProductName: string; virtual;
    function GetProductVersion: string; virtual;
    procedure SetComments(const _Comments: string); virtual;
    procedure SetCompanyName(_CompanyName: string); virtual;
    procedure SetFileDescription(_FileDescription: string); virtual;
    procedure SetFileVersion(_FileVersion: string); virtual;
    procedure SetInternalName(_InternalName: string); virtual;
    procedure SetLegalCopyright(_LegalCopyright: string); virtual;
    procedure SetLegalTrademarks(_LegalTrademarks: string); virtual;
    procedure SetOriginalFilename(_OriginalFilename: string); virtual;
    procedure SetProductName(_ProductName: string); virtual;
    procedure SetProductVersion(_ProductVersion: string); virtual;
    function GetSCMRevision: string; virtual;
    function GetBuildDateTime: string; virtual;
    procedure SetSCMRevision(const _SCMRevision: string); virtual;
    procedure SetBuildDateTime(const _BuildDateTime: string); virtual;
    function GetIsPrivateBuild: Boolean; virtual;
    function GetIsSpecialBuild: Boolean; virtual;
    function GetPrivateBuildComments: string; virtual;
    function GetSpecialBuildComments: string; virtual;
    procedure SetIsPrivateBuild(const _IsPrivateBuild: Boolean); virtual;
    procedure SetIsSpecialBuild(const _IsSpecialBuild: Boolean); virtual;
    procedure SetPrivateBuildComments(const _PrivateBuildComments: string); virtual;
    procedure SetSpecialBuildComments(const _SpecialBuildComments: string); virtual;

  public
    procedure UpdateFileVersion;
    function ResolveVariables(const _s: string): string;

    property Source: string read FSource write FSource;
    //
    property AutoIncBuild: Boolean read GetAutoIncBuild write SetAutoIncBuild;
    //
    property MajorVer: Integer read GetMajorVer write SetMajorVer;
    property MinorVer: Integer read GetMinorVer write SetMinorVer;
    property Release: Integer read GetRelease write SetRelease;
    property Build: Integer read GetBuild write SetBuild;
    //
    property Comments: string read GetComments write SetComments;
    property CompanyName: string read GetCompanyName write SetCompanyName;
    property FileDescription: string read GetFileDescription write SetFileDescription;
    property FileVersion: string read GetFileVersion write SetFileVersion;
    property InternalName: string read GetInternalName write SetInternalName;
    property LegalCopyRight: string read GetLegalCopyright write SetLegalCopyright;
    property LegalTrademarks: string read GetLegalTrademarks write SetLegalTrademarks;
    property OriginalFilename: string read GetOriginalFilename write SetOriginalFilename;
    property ProductName: string read GetProductName write SetProductName;
    property ProductVersion: string read GetProductVersion write SetProductVersion;
    property SCMRevision: string read GetSCMRevision write SetSCMRevision;
    property BuildDateTime: string read GetBuildDateTime write SetBuildDateTime;
    property IsPrivateBuild: Boolean read GetIsPrivateBuild write SetIsPrivateBuild;
    property IsSpecialBuild: Boolean read GetIsSpecialBuild write SetIsSpecialBuild;
    property PrivateBuildComments: string read GetPrivateBuildComments write SetPrivateBuildComments;
    property SpecialBuildComments: string read GetSpecialBuildComments write SetSpecialBuildComments;
  end;

implementation

uses
  StrUtils,
  DateUtils,
  IniFiles,
  RegularExpressions,
  u_dzStringUtils,
  u_dzDateUtils;

{ TVersionInfo }

procedure TVersionInfo.Assign(_VersionInfo: TVersionInfo);
begin
  Source := _VersionInfo.Source;

  AutoIncBuild := _VersionInfo.AutoIncBuild;

  MajorVer := _VersionInfo.MajorVer;
  MinorVer := _VersionInfo.MinorVer;
  Release := _VersionInfo.Release;
  Build := _VersionInfo.Build;

  Comments := _VersionInfo.Comments;
  CompanyName := _VersionInfo.CompanyName;
  FileDescription := _VersionInfo.FileDescription;
  FileVersion := _VersionInfo.FileVersion;
  InternalName := _VersionInfo.InternalName;
  LegalCopyRight := _VersionInfo.LegalCopyRight;
  LegalTrademarks := _VersionInfo.LegalTrademarks;
  OriginalFilename := _VersionInfo.OriginalFilename;
  ProductName := _VersionInfo.ProductName;
  ProductVersion := _VersionInfo.ProductVersion;
  SCMRevision := _VersionInfo.SCMRevision;
  BuildDateTime := _VersionInfo.BuildDateTime;
  IsPrivateBuild := _VersionInfo.IsPrivateBuild;
  IsSpecialBuild := _VersionInfo.IsSpecialBuild;
  PrivateBuildComments := _VersionInfo.PrivateBuildComments;
  SpecialBuildComments := _VersionInfo.SpecialBuildComments;
end;

procedure TVersionInfo.AdjustFilename(var _Filename: string);
var
  Path: string;
begin
  Path := ExtractFilePath(_Filename);
  if (Path = '') or ((Path[1] <> '\') and (Copy(Path, 2, 1) <> ':')) then begin
     // Path is relative, so make it relative to the main .ini/project file
    _Filename := ExtractFilePath(FSource) + _Filename;
  end;
end;

function TVersionInfo.ResolveVariable(const _s: string): string;
var
  Redir: string;
  fn: string;
  Section: string;
  Ident: string;
  IniFile: TMemIniFile;
begin
  if UStartsWith('read:', _s) then begin
    Redir := Copy(_s, Length('read:') + 1);
    fn := ExtractStr(Redir, ',');
    Section := ExtractStr(Redir, ',');
    Ident := Redir;
    AdjustFilename(fn);
    IniFile := TMemIniFile.Create(fn);
    try
      Result := IniFile.ReadString(Section, Ident, '');
    finally
      IniFile.Free;
    end;
  end else if SameText('thisyear', _s) then begin
    Result := IntToStr(YearOf(Date));
  end else if SameText('today', _s) then begin
    Result := DateTime2Iso(Date, False);
  end else if SameText('now', _s) then begin
    Result := DateTime2Iso(Date, True);
  end else
    Result := _s;
end;

function TVersionInfo.ResolveVariables(const _s: string): string;
var
  re: TRegEx;
  Match: TMatch;
  s: string;
  Start: Integer;
  Ende: Integer;
begin
  Result := '';
  Start := 1;
  re.Create('\{(.*?)\}');
  Match := re.Match(_s);
  while Match.Success and (Match.Groups.Count > 1) do begin
    Ende := Match.Index;
    Result := Result + Copy(_s, Start, Ende - Start);
    Start := Ende + Match.Length;
    s := Match.Groups[1].Value;
    s := ResolveVariable(s);
    Result := Result + s;
    Match := Match.NextMatch;
  end;
  Result := Result + TailStr(_s, Start);
end;

function TVersionInfo.GetAutoIncBuild: Boolean;
begin
  Result := FAutoIncBuild;
end;

function TVersionInfo.GetBuild: Integer;
begin
  Result := FBuild;
end;

function TVersionInfo.GetBuildDateTime: string;
begin
  Result := FBuildDateTime;
end;

function TVersionInfo.GetComments: string;
begin
  Result := FComments;
end;

function TVersionInfo.GetCompanyName: string;
begin
  Result := FCompanyName;
end;

function TVersionInfo.GetFileDescription: string;
begin
  Result := FFileDescription;
end;

function TVersionInfo.GetFileVersion: string;
begin
  Result := FFileVersion;
end;

function TVersionInfo.GetInternalName: string;
begin
  Result := FInternalName;
end;

function TVersionInfo.GetIsPrivateBuild: Boolean;
begin
  Result := FIsPrivateBuild;
end;

function TVersionInfo.GetIsSpecialBuild: Boolean;
begin
  Result := FIsSpecialBuild;
end;

function TVersionInfo.GetLegalCopyright: string;
begin
  Result := FLegalCopyright;
end;

function TVersionInfo.GetLegalTrademarks: string;
begin
  Result := FLegalTrademarks;
end;

function TVersionInfo.GetMajorVer: Integer;
begin
  Result := FMajorVer;
end;

function TVersionInfo.GetMinorVer: Integer;
begin
  Result := FMinorVer;
end;

function TVersionInfo.GetOriginalFilename: string;
begin
  Result := FOriginalFilename;
end;

function TVersionInfo.GetPrivateBuildComments: string;
begin
  Result := FPrivateBuildComments;
end;

function TVersionInfo.GetProductName: string;
begin
  Result := FProductName;
end;

function TVersionInfo.GetProductVersion: string;
begin
  Result := FProductVersion;
end;

function TVersionInfo.GetRelease: Integer;
begin
  Result := FRelease;
end;

function TVersionInfo.GetSpecialBuildComments: string;
begin
  Result := FSpecialBuildComments;
end;

function TVersionInfo.GetSCMRevision: string;
begin
  Result := FSCMRevision;
end;

procedure TVersionInfo.SetAutoIncBuild(_AutoIncBuild: Boolean);
begin
  FAutoIncBuild := _AutoIncBuild;
end;

procedure TVersionInfo.SetBuild(_Build: Integer);
begin
  FBuild := _Build;
end;

procedure TVersionInfo.SetBuildDateTime(const _BuildDateTime: string);
begin
  FBuildDateTime := _BuildDateTime;
end;

procedure TVersionInfo.SetComments(const _Comments: string);
begin
  FComments := _Comments;
end;

procedure TVersionInfo.SetCompanyName(_CompanyName: string);
begin
  FCompanyName := _CompanyName;
end;

procedure TVersionInfo.SetFileDescription(_FileDescription: string);
begin
  FFileDescription := _FileDescription;
end;

procedure TVersionInfo.SetFileVersion(_FileVersion: string);
begin
  FFileVersion := _FileVersion;
end;

procedure TVersionInfo.SetInternalName(_InternalName: string);
begin
  FInternalName := _InternalName;
end;

procedure TVersionInfo.SetIsPrivateBuild(const _IsPrivateBuild: Boolean);
begin
  FIsPrivateBuild := _IsPrivateBuild;
end;

procedure TVersionInfo.SetIsSpecialBuild(const _IsSpecialBuild: Boolean);
begin
  FIsSpecialBuild := _IsSpecialBuild;
end;

procedure TVersionInfo.SetLegalCopyright(_LegalCopyright: string);
begin
  FLegalCopyright := _LegalCopyright;
end;

procedure TVersionInfo.SetLegalTrademarks(_LegalTrademarks: string);
begin
  FLegalTrademarks := _LegalTrademarks;
end;

procedure TVersionInfo.SetMajorVer(_MajorVer: Integer);
begin
  FMajorVer := _MajorVer;
end;

procedure TVersionInfo.SetMinorVer(_MinorVer: Integer);
begin
  FMinorVer := _MinorVer;
end;

procedure TVersionInfo.SetOriginalFilename(_OriginalFilename: string);
begin
  FOriginalFilename := _OriginalFilename;
end;

procedure TVersionInfo.SetPrivateBuildComments(const _PrivateBuildComments: string);
begin
  FPrivateBuildComments := _PrivateBuildComments;
end;

procedure TVersionInfo.SetProductName(_ProductName: string);
begin
  FProductName := _ProductName;
end;

procedure TVersionInfo.SetProductVersion(_ProductVersion: string);
begin
  FProductVersion := _ProductVersion;
end;

procedure TVersionInfo.SetRelease(_Release: Integer);
begin
  FRelease := _Release;
end;

procedure TVersionInfo.SetSpecialBuildComments(const _SpecialBuildComments: string);
begin
  FSpecialBuildComments := _SpecialBuildComments;
end;

procedure TVersionInfo.SetSCMRevision(const _SCMRevision: string);
begin
  FSCMRevision := _SCMRevision;
end;

procedure TVersionInfo.UpdateFileVersion;
begin
  FileVersion := Format('%d.%d.%d.%d', [MajorVer, MinorVer, Release, Build]);
end;

end.

