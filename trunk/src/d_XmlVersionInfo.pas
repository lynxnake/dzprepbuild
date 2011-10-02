unit d_XmlVersionInfo;

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
  Tdm_XmlVersionInfo = class(TDataModule, IVersionInfoAccess)
    ProjDoc: TXMLDocument;
  private
    FProjectFilename: string;
    function GetChildNodeContent(_Parent: IXMLNode; const _NodeName, _AttrName: string): string;
    function GetVersionInfo(const _Name: string): string;
    function GetVersionInfoKey(const _Name: string): string;
    procedure SetChildNodeContent(_Parent: IXMLNode; const _NodeName, _AttrName, _Value: string);
    procedure SetVersionInfo(const _Name, _Value: string);
    procedure SetVersionInfoKey(const _Name, _Value: string);
  protected // IInterface
    FRefCount: integer;
    function QueryInterface(const IID: TGUID; out Obj): HResult; override; stdcall;
    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;
  protected // implementation of IVersionInfo
    function VerInfoFilename: string;
    procedure ReadFromFile(_VerInfo: TVersionInfo);
    procedure WriteToFile(_VerInfo: TVersionInfo);
  protected
    FXmlFilename: string;
    FVersionInfo: IXMLNode;
    FVersionInfoKeys: IXMLNode;
    procedure InitVersionNodes; virtual; abstract;
  public
    constructor Create(const _FullFilename: string); reintroduce;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses
  StrUtils,
  u_dzTranslator;

{ Tdm_XmlVersionInfo }

function Tdm_XmlVersionInfo.GetChildNodeContent(_Parent: IXMLNode; const _NodeName, _AttrName: string): string;
var
  Node: IXMLNode;
begin
  // <VersionInfo Name="IncludeVerInfo">True</VersionInfo>
  Node := _Parent.ChildNodes.First;
  while Assigned(Node) do begin
    if Node.nodeName = _NodeName then begin
      if SameText(Node.Attributes['Name'], _AttrName) then begin
        Result := Node.Text;
        exit;
      end;
    end;
    Node := Node.nextSibling;
  end;
end;

function Tdm_XmlVersionInfo.GetVersionInfo(const _Name: string): string;
begin
  Result := GetChildNodeContent(FVersionInfo, 'VersionInfo', _Name);
end;

function Tdm_XmlVersionInfo.GetVersionInfoKey(const _Name: string): string;
begin
  Result := GetChildNodeContent(FVersionInfoKeys, 'VersionInfoKeys', _Name);
end;

procedure Tdm_XmlVersionInfo.SetChildNodeContent(_Parent: IXMLNode; const _NodeName, _AttrName, _Value: string);
var
  Node: IXMLNode;
begin
  // <*NodeName* Name="*AttrName*">*Value*</VersionInfo>
  Node := _Parent.ChildNodes.First;
  while Assigned(Node) do begin
    if Node.nodeName = _NodeName then begin
      if SameText(Node.Attributes['Name'], _AttrName) then begin
        Node.Text := _Value;
        exit;
      end;
    end;
    Node := Node.nextSibling;
  end;
end;

constructor Tdm_XmlVersionInfo.Create(const _FullFilename: string);
begin
  inherited Create(nil);
  FProjectFilename := _FullFilename;
  FXmlFilename := VerInfoFilename;
  ProjDoc.FileName := FXmlFilename;
  ProjDoc.Active := True;

  InitVersionNodes;

  if not SameText(GetChildNodeContent(FVersionInfo, 'VersionInfo', 'IncludeVerInfo'), 'True') then
    raise ENoVersionInfo.Create(_('.dproj file does not contain version information'));
end;

destructor Tdm_XmlVersionInfo.Destroy;
begin
  FVersionInfo := nil;
  inherited;
end;

procedure Tdm_XmlVersionInfo.ReadFromFile(_VerInfo: TVersionInfo);
begin
  _VerInfo.Source := VerInfoFilename;

  _VerInfo.AutoIncBuild := SameText(GetVersionInfo('AutoIncBuild'), 'True');

  _VerInfo.MajorVer := StrToIntDef(GetVersionInfo('MajorVer'), 0);
  _VerInfo.MinorVer := StrToIntDef(GetVersionInfo('MinorVer'), 0);
  _VerInfo.Release := StrToIntDef(GetVersionInfo('Release'), 0);
  _VerInfo.Build := StrToIntDef(GetVersionInfo('Build'), 0);

  _VerInfo.Comments := GetVersionInfoKey('Comments');
  _VerInfo.CompanyName := GetVersionInfoKey('CompanyName');
  _VerInfo.FileDescription := GetVersionInfoKey('FileDescription');
  _VerInfo.FileVersion := GetVersionInfoKey('FileVersion');
  _VerInfo.InternalName := GetVersionInfoKey('InternalName');
  _VerInfo.LegalCopyright := GetVersionInfoKey('LegalCopyright');
  _VerInfo.LegalTrademarks := GetVersionInfoKey('LegalTrademarks');
  _VerInfo.OriginalFilename := GetVersionInfoKey('OriginalFilename');
  _VerInfo.ProductName := GetVersionInfoKey('ProductName');
  _VerInfo.ProductVersion := GetVersionInfoKey('ProductVersion');
end;

procedure Tdm_XmlVersionInfo.WriteToFile(_VerInfo: TVersionInfo);
begin
  SetVersionInfo('AutoIncBuild', IfThen(_VerInfo.AutoIncBuild, 'True', 'False'));
  SetVersionInfo('Build', IntToStr(_VerInfo.Build));
  SetVersionInfoKey('Comments', _VerInfo.Comments);
  SetVersionInfoKey('CompanyName', _VerInfo.CompanyName);
  SetVersionInfoKey('FileDescription', _VerInfo.FileDescription);
  SetVersionInfoKey('FileVersion', _VerInfo.FileVersion);
  SetVersionInfoKey('InternalName', _VerInfo.InternalName);
  SetVersionInfoKey('LegalCopyright', _VerInfo.LegalCopyright);
  SetVersionInfoKey('LegalTrademarks', _VerInfo.LegalTrademarks);
  SetVersionInfo('MajorVer', IntToStr(_VerInfo.MajorVer));
  SetVersionInfo('MinorVer', IntToStr(_VerInfo.MinorVer));
  SetVersionInfoKey('OriginalFilename', _VerInfo.OriginalFilename);
  SetVersionInfoKey('ProductName', _VerInfo.ProductName);
  SetVersionInfoKey('ProductVersion', _VerInfo.ProductVersion);
  SetVersionInfo('Release', IntToStr(_VerInfo.Release));
  ProjDoc.SaveToFile(FXmlFilename);
end;

procedure Tdm_XmlVersionInfo.SetVersionInfo(const _Name, _Value: string);
begin
  SetChildNodeContent(FVersionInfo, 'VersionInfo', _Name, _Value);
end;

procedure Tdm_XmlVersionInfo.SetVersionInfoKey(const _Name, _Value: string);
begin
  SetChildNodeContent(FVersionInfoKeys, 'VersionInfoKeys', _Name, _Value);
end;

function Tdm_XmlVersionInfo.VerInfoFilename: string;
begin
  Result := FProjectFilename;
end;

// standard TInterfacedObject implementation of IInterface

function Tdm_XmlVersionInfo.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE
end;

function Tdm_XmlVersionInfo._AddRef: integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function Tdm_XmlVersionInfo._Release: integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

end.

