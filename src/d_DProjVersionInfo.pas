unit d_DprojVersionInfo;

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
  Tdm_DprojVersionInfo = class(Tdm_XmlVersionInfo)
  private
  protected
    procedure InitVersionNodes; override;
  public
    constructor Create(const _Project: string);
  end;

implementation

{$R *.dfm}

constructor Tdm_DprojVersionInfo.Create(const _Project: string);
begin
  inherited Create(ChangeFileExt(_Project, '.dproj'));
end;

procedure Tdm_DprojVersionInfo.InitVersionNodes;
var
  ProjectExtensions: IXMLNode;
  DelphiPersonality: IXMLNode;
  BorlandProject: IXMLNode;
  Project: IXMLNode;
begin
  Project := ProjDoc.DocumentElement;
  ProjectExtensions := Project.ChildNodes['ProjectExtensions'];
  BorlandProject := ProjectExtensions.ChildNodes['BorlandProject'];
  DelphiPersonality := BorlandProject.ChildNodes['Delphi.Personality'];
  FVersionInfo := DelphiPersonality.ChildNodes['VersionInfo'];
  FVersionInfoKeys := DelphiPersonality.ChildNodes['VersionInfoKeys'];
end;

end.

