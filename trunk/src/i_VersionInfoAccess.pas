unit i_VersionInfoAccess;

interface

uses
  SysUtils,
  u_VersionInfo;

type
  ENoVersionInfo = class(Exception);

type
  IVersionInfoAccess = interface ['{57B36255-0A4B-4F62-9007-B4D211C2185D}']
    function VerInfoFilename: string;
    procedure ReadFromFile(_VerInfo: TVersionInfo);
    procedure WriteToFile(_VerInfo: TVersionInfo);
  end;

implementation

end.

