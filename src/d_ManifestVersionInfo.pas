unit d_ManifestVersionInfo;

interface

uses
  Windows,
  SysUtils,
  Classes,
  xmldom,
  XMLIntf,
  msxmldom,
  XMLDoc,
  u_VersionInfo,
  i_VersionInfoAccess;

type
  Tdm_ManifestVersionInfo = class(TDataModule, IVersionInfoAccess)
    ProjDoc: TXMLDocument;
  private
    FInputFilename: string;
    FOutputFilename: string;
  protected // IInterface
    FRefCount: integer;
    function QueryInterface(const IID: TGUID; out Obj): HResult; override; stdcall;
    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;
  protected // IVersionInfoAccess
    function VerInfoFilename: string;
    procedure ReadFromFile(_VerInfo: TVersionInfo);
    procedure WriteToFile(_VerInfo: TVersionInfo);
  protected
    FAssemblyIdentity: IXMLNode;
    procedure InitVersionNodes; virtual;
  public
    constructor Create(const _FullFilename: string); reintroduce;
  end;

implementation

{$R *.dfm}

uses
  StrUtils,
  u_dzFileUtils,
  u_dzStringUtils,
  u_dzVariantUtils,
  u_dzConvertUtils,
  u_dzTranslator;

{ Tdm_ManifestVersionInfo }

constructor Tdm_ManifestVersionInfo.Create(const _FullFilename: string);
begin
  inherited Create(nil);

  FOutputFilename := ChangeFileExt(_FullFilename, '.manifest');
  FInputFilename := FOutputFilename + '.in';
  if not TFileSystem.FileExists(FInputFilename) then
    FInputFilename := FOutputFilename;

  ProjDoc.FileName := FInputFilename;
  ProjDoc.Active := True;

  InitVersionNodes;
end;

//procedure EnumNodes(_Root: IXMLNode; const _Indent: string = '');
//var
//  i: Integer;
//begin
//  WriteLn(_Indent, _Root.NodeName);
//  for i := 0 to _Root.AttributeNodes.Count - 1 do begin
//    WriteLn(_Indent, ':', _Root.AttributeNodes[i].NodeName, '=', _Root.AttributeNodes[i].NodeValue);
//  end;
//  for i := 0 to _Root.ChildNodes.Count - 1 do begin
//    EnumNodes(_Root.ChildNodes.Nodes[i], _Indent + '  ');
//  end;
//end;

procedure Tdm_ManifestVersionInfo.InitVersionNodes;
var
  Assembly: IXMLNode;
begin
  Assembly := ProjDoc.DocumentElement;
  FAssemblyIdentity := Assembly.ChildNodes[0];
end;

function Tdm_ManifestVersionInfo.VerInfoFilename: string;
begin
  Result := FOutputFilename;
end;

procedure Tdm_ManifestVersionInfo.ReadFromFile(_VerInfo: TVersionInfo);
var
  Version: string;
  Major: string;
  Minor: string;
  Release: string;
  Build: string;
begin
  raise Exception.Create(_('Reading version info from Manifest files is not supported.'));

  _VerInfo.Source := VerInfoFilename;
  _VerInfo.FileDescription := Var2Str(FAssemblyIdentity.Attributes['name'], '');
  Version := Var2Str(FAssemblyIdentity.Attributes['version'], '');
  _VerInfo.FileVersion := Version;
  _VerInfo.ProductName := _VerInfo.FileDescription;
  Major := ExtractStr(Version, '.');
  Minor := ExtractStr(Version, '.');
  Release := ExtractStr(Version, '.');
  Build := ExtractStr(Version, '.');
  _VerInfo.MajorVer := StrToIntDef(Major, 0);
  _VerInfo.MinorVer := StrToIntDef(Minor, 0);
  _VerInfo.Release := StrToIntDef(Release, 0);
  _VerInfo.Build := StrToIntDef(Build, 0);
end;

procedure Tdm_ManifestVersionInfo.WriteToFile(_VerInfo: TVersionInfo);
begin
  FAssemblyIdentity.Attributes['name'] := _VerInfo.FileDescription;
  FAssemblyIdentity.Attributes['version'] := _VerInfo.FileVersion;
  ProjDoc.SaveToFile(FOutputFilename);
end;

// standard TInterfacedObject implementation of IInterface

function Tdm_ManifestVersionInfo.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE
end;

function Tdm_ManifestVersionInfo._AddRef: integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function Tdm_ManifestVersionInfo._Release: integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

end.

