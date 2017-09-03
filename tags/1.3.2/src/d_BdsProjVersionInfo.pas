unit d_BdsProjVersionInfo;

interface

uses
  Windows,
  SysUtils,
  Classes,
  d_XmlVersionInfo,
  xmldom,
  XMLIntf,
  msxmldom,
  XMLDoc;

type
  Tdm_BdsProjVersionInfo = class(Tdm_XmlVersionInfo)
  protected
    procedure InitVersionNodes; override;
  public
    constructor Create(const _Project: string);
  end;

implementation

{$R *.dfm}

{ Tdm_BdsProjVersionInfo }

constructor Tdm_BdsProjVersionInfo.Create(const _Project: string);
begin
  inherited Create(ChangeFileExt(_Project, '.bdsproj'));
end;

procedure Tdm_BdsProjVersionInfo.InitVersionNodes;
var
  BorlandProject: IXMLNode;
  DelphiPersonality: IXMLNode;
begin
  BorlandProject := ProjDoc.DocumentElement;
  DelphiPersonality := BorlandProject.childNodes['Delphi.Personality'];
  FVersionInfo := DelphiPersonality.childNodes['VersionInfo'];
  FVersionInfoKeys := DelphiPersonality.childNodes['VersionInfoKeys'];
end;

end.

