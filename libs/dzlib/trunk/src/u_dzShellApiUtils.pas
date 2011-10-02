{.GXFormatter.config=twm}
///<summary> implements an object with utility functions regarding the ShellAPI </summary>
unit u_dzShellApiUtils;

{$I jedi.inc}

interface

uses
  Windows,
  Sysutils,
  ShlObj,
  ShellApi,
  ActiveX,
  Forms;

const
  // constants missing from ShlObj
  CSIDL_WINDOWS = $24;
  CSIDL_PROGRAM_FILES = $26;
  CSIDL_MYPICTURES = $27;
  CSIDL_PROGRAM_FILES_COMMON = $2B;

type
  TSHGetFolderPathA = function(hwnd: HWND; csidl: Integer; hToken: THandle; dwFlags: DWORD; pszPath: PAnsiChar): HResult; Stdcall;
  TSHGetFolderPathW = function(hwnd: HWND; csidl: Integer; hToken: THandle; dwFlags: DWORD; pszPath: PWideChar): HResult; Stdcall;
{$IFDEF SUPPORTS_UNICODE_STRING}
  TSHGetFolderPath = TSHGetFolderPathW;
{$ELSE}
  TSHGetFolderPath = TSHGetFolderPathA;
{$ENDIF}
const
{$IFDEF SUPPORTS_UNICODE_STRING}
  SHGetFolderPathEntryPoint = 'SHGetFolderPathW';
{$ELSE}
  SHGetFolderPathEntryPoint = 'SHGetFolderPathA';
{$ENDIF}

type
  ///<summary> TWindowsShell is a wrapper object for several ShellApi functions.
  ///          For most SHGetFolderPath functions there are two methods. One is called GetXxxxx
  ///          and is a regular method of TWindowsShell (so you must instantiate the
  ///          object to use it). The other is called GetXxxxxDir a class
  ///          method that internally instantiates and frees an object instance
  ///          (so you don't have to do that explicitly). </summary>
  TWindowsShell = class
  private
    function LoadSHFolder(var _SHGetFolderPath: TSHGetFolderPath): Integer;
  protected
    FAppHandle: THandle;
    function GetSpecialFolder(_CSIDL: integer): string;
  public
    ///<summary> Creates a TWindowsShell object,
    ///   @param ApplicationHandle is the application's handle (Application.Handle) </summary>
    constructor Create(_ApplicationHandle: THandle = 0);
    destructor Destroy; override;
    ///<summary> returns the path to the 'My Documents' folder </summary>
    function GetMyDocuments: string;
    class function GetMyDocumentsDir(_ApplicationHandle: THandle = 0): string;
    ///<summary> returns the path of the 'My Pictures' folder </summary>
    function GetMyPictures: string;
    class function GetMyPicturesDir(_ApplicationHandle: THandle = 0): string;
    ///<summary> returns the 'common files' folder </summary>
    function GetCommonFiles: string;
    class function GetCommonFilesDir(_ApplicationHandle: THandle = 0): string;
    ///<summary> returns the 'program files' folder </summary>
    function GetProgramFiles: string;
    class function GetProgramFilesDir(_ApplicationHandle: THandle = 0): string;
    ///<summary> @returns the 'common files\Application Data' folder </summary>
    function GetCommonAppData: string;
    class function GetCommonAppDataDir(_ApplicationHandle: THandle = 0): string;

    ///<summary> @returns the '<home>\Local Settings\Application Data' folder,
    ///          or '' for oder Windows versions </summary>
    function GetLocalAppData: string;
    class function GetLocalAppDataDir(_ApplicationHandle: THandle = 0): string;

    ///<summary> @returns the '<home>\Application Data' folder </summary>
    function GetAppData: string;
    class function GetAppDataDir(_ApplicationHandle: THandle = 0): string;

    function GetSystem32: string;
    class function GetSystem32Dir: string;

    class function GetWindowsDir: string;

    class function GetSystemWindowsDir: string;

    // Warning: These functions will display System dialogs if there is a problem!
    class function CopyDir(const fromDir, toDir: string): boolean;
    class function DelDir(dir: string): boolean;
    class function MoveDir(const fromDir, toDir: string): boolean;
  end;

implementation

uses
  u_dzMiscUtils;

const
  SHGFP_TYPE_CURRENT = 0;

function TWindowsShell.LoadSHFolder(var _SHGetFolderPath: TSHGetFolderPath): Integer;
var
  Hdl: Hwnd;
begin
  Result := 0;
  Hdl := LoadLibrary('SHFOLDER.DLL');
  if Hdl <> 0 then begin
    @_SHGetFolderPath := GetProcAddress(Hdl, SHGetFolderPathEntryPoint);
    if @_SHGetFolderPath <> nil then
      Result := Hdl;
  end;
end;

function TWindowsShell.GetSpecialFolder(_CSIDL: Integer): string;
var
  Path: array[0..MAX_PATH] of Char;
  Pidl: PItemIDList;
  Hdl: Hwnd;
  SHGetFolderPath: TSHGetFolderPath;
begin
  ZeroMemory(@Path, SizeOf(Path));
  Hdl := LoadSHFolder(SHGetFolderPath);
  if Hdl <> 0 then begin
    if Succeeded(SHGetFolderPath(Application.Handle, _CSIDL, 0, SHGFP_TYPE_CURRENT, Path)) then
      Result := Path;
    FreeLibrary(Hdl);
  end else begin
    if Succeeded(SHGetspecialfolderLocation(Application.Handle, _CSIDL, PIdl)) then
      SHGetPathFromIDList(Pidl, Path);
    Result := Path;
  end;
end;

{ TWindowsShell }

constructor TWindowsShell.Create(_ApplicationHandle: THandle = 0);
begin
  inherited Create;
  if _ApplicationHandle = 0 then
    FAppHandle := Application.Handle
  else
    FAppHandle := _ApplicationHandle;
end;

destructor TWindowsShell.Destroy;
begin
  inherited;
end;

//function TWindowsShell.GetSpecialFolder(_CSIDL: integer): string;
//var
//  PMalloc: IMalloc;
//  PIdL: PItemIdList;
//  Path: array[0..MAX_PATH] of char;
//begin
//  SHGetMalloc(PMalloc);
//  try
//    SHGetSpecialFolderLocation(fAppHandle, _CSIDL, PIdL);
//    SHGetPathFromIDList(PIdL, Path);
//    Result := Path;
//  finally
//    PMalloc := nil;
//  end;
//end;

function TWindowsShell.GetMyDocuments: string;
begin
  Result := GetSpecialFolder(CSIDL_PERSONAL);
end;

class function TWindowsShell.GetMyDocumentsDir(_ApplicationHandle: THandle = 0): string;
begin
  with TWindowsShell.Create(_ApplicationHandle) do
    try
      Result := GetMyDocuments;
    finally
      Free;
    end;
end;

function TWindowsShell.GetMyPictures: string;
begin
  Result := GetSpecialFolder(CSIDL_MYPICTURES);
end;

function TWindowsShell.GetAppData: string;
begin
  Result := GetSpecialFolder(CSIDL_APPDATA);
end;

class function TWindowsShell.GetAppDataDir(_ApplicationHandle: THandle): string;
begin
  with TWindowsShell.Create(_ApplicationHandle) do
    try
      Result := GetAppData;
    finally
      Free;
    end;
end;

function TWindowsShell.GetCommonAppData: string;
begin
  Result := GetSpecialFolder(CSIDL_COMMON_APPDATA);
end;

class function TWindowsShell.GetCommonAppDataDir(_ApplicationHandle: THandle): string;
begin
  with TWindowsShell.Create(_ApplicationHandle) do
    try
      Result := GetCommonAppData;
    finally
      Free;
    end;
end;

function TWindowsShell.GetCommonFiles: string;
begin
  Result := GetSpecialFolder(CSIDL_PROGRAM_FILES_COMMON);
end;

class function TWindowsShell.GetCommonFilesDir(_ApplicationHandle: THandle = 0): string;
begin
  with TWindowsShell.Create(_ApplicationHandle) do
    try
      Result := GetCommonFiles;
    finally
      Free;
    end;
end;

function TWindowsShell.GetLocalAppData: string;
begin
  Result := GetSpecialFolder(CSIDL_LOCAL_APPDATA);
end;

class function TWindowsShell.GetLocalAppDataDir(_ApplicationHandle: THandle): string;
begin
  with TWindowsShell.Create(_ApplicationHandle) do
    try
      Result := GetLocalAppData;
    finally
      Free;
    end;
end;

function TWindowsShell.GetProgramFiles: string;
begin
  Result := GetSpecialFolder(CSIDL_PROGRAM_FILES);
end;

function TWindowsShell.GetSystem32: string;
begin
  Result := GetSystem32Dir;
end;

class function TWindowsShell.GetSystem32Dir: string;
begin
  SetLength(Result, MAX_PATH);
  if 0 = windows.GetSystemDirectory(PChar(Result), Length(Result)) then
{$IFDEF Delphi5}
    RaiseLastWin32Error;
{$ELSE}
    RaiseLastOSError;
{$ENDIF}
  Result := PChar(Result);
end;

class function TWindowsShell.GetProgramFilesDir(_ApplicationHandle: THandle = 0): string;
begin
  with TWindowsShell.Create(_ApplicationHandle) do
    try
      Result := GetProgramFiles;
    finally
      Free;
    end;
end;

class function TWindowsShell.GetMyPicturesDir(_ApplicationHandle: THandle = 0): string;
begin
  with TWindowsShell.Create(_ApplicationHandle) do
    try
      Result := GetMyPictures;
    finally
      Free;
    end;
end;

// This handles the case that the GetSystemWindowsDirectoryA entry point
// is not available, probably Windows NT and older

class function TWindowsShell.GetSystemWindowsDir: string;

  function GetSysWindowsDir: string;
  begin
    Result := GetSystem32Dir;
    Result := ExcludeTrailingPathDelimiter(ExtractFilePath(Result));
  end;

type
  TGetSystemWindowsDirectoryA = function(lpBuffer: PChar; uSize: UINT): UINT; stdcall;
var
  HModule: THandle;
  GetSystemWindowsDirectoryA: TGetSystemWindowsDirectoryA;
begin
  HModule := LoadLibrary(kernel32);
  if HModule = 0 then begin
    Result := GetSysWindowsDir;
    exit;
  end;
  try
    GetSystemWindowsDirectoryA := GetProcAddress(HModule, 'GetSystemWindowsDirectoryA');
    if not Assigned(GetSystemWindowsDirectoryA) then begin
      Result := GetSysWindowsDir;
      exit;
    end;
    SetLength(Result, MAX_PATH);
    GetSystemWindowsDirectoryA(PChar(Result), Length(Result));
    Result := PChar(Result);
  finally
    FreeLibrary(HModule);
  end;
end;

class function TWindowsShell.GetWindowsDir: string;
begin
  SetLength(Result, MAX_PATH);
  windows.GetWindowsDirectory(PChar(Result), Length(Result));
  Result := PChar(Result);
end;

class function TWindowsShell.CopyDir(const fromDir, toDir: string): boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  fos.wFunc := FO_COPY;
  fos.fFlags := FOF_FILESONLY;
  fos.pFrom := PChar(fromDir + #0);
  fos.pTo := PChar(toDir);
  Result := (0 = ShFileOperation(fos));
end;

class function TWindowsShell.DelDir(dir: string): boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  fos.wFunc := FO_DELETE;
  fos.fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
  fos.pFrom := PChar(dir + #0);
  Result := (0 = ShFileOperation(fos));
end;

class function TWindowsShell.MoveDir(const fromDir, toDir: string): boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  fos.wFunc := FO_MOVE;
  fos.fFlags := FOF_FILESONLY;
  fos.pFrom := PChar(fromDir + #0);
  fos.pTo := PChar(toDir);
  Result := (0 = ShFileOperation(fos));
end;

end.

