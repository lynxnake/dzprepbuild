///<summary> This unit contains operating system dependent functions, at least some of them. </summary>
unit u_dzOsUtils;

interface

uses
  Windows,
  SysUtils,
  Classes,
  u_dzTranslator;

type
  EOsFunc = class(Exception);
  EOFNoFileinfo = class(EOsFunc);

///<summary> Determines the computername
///          @returns a string with the computername, or an empty string if there was an error </summary>
function GetComputerName: string;

///<summary> Determines the name of the user who runs this program.
///          @returns a string with the user logon name </summary>
function GetUserName: string;

///<summary> Returns the current user's home directory.
///          Examines the environment variable HOME and if that is not
///          set, it concatenates HOMEDRV and HOMEPATH </summary>
function GetHomeDir: string;

///<summary> Calls the windows function with the same name and returns its result </summary>
function ExpandEnvironmentStrings(const _WithVariables: string): string;
///<summary> Calls the windows API function GetEnvironmentStrings and returns them result
///          in the string list.
///          @param Vars is the string list that contains the environment
///          @returns true, if the function succeeded, false otherwise. </summary>
function GetEnvironmentVars(const _Vars: TStrings): Boolean;

///<summary> Reads an integer value from the registry.
///          @param RootKey is the HK_* constant specifying the registry branch to read
///          @param Key is a string specifying the name of registry key to read
///          @param Name is a string specifying the the name of the registry value to read
///          @param Value returns the integer value read from the registry, only valid if
///                       the function result is true.
///          @returns true, if an integer value could be read, false, if it does not exist
///                      or is not an integer value. </summary>
function GetRegValue(_RootKey: HKey; const _Key, _Name: string; out _Value: Integer): boolean; overload;

///<summary> Writes a string value from the registry.
///          @param RootKey is the HK_* constant specifying the registry branch to read
///          @param Key is a string specifying the name of registry key to read
///          @param Name is a string specifying the the name of the registry value to read
///          @param Value is the string value to write to the registry. </summary>
procedure SetRegValue(_RootKey: HKey; const _Key, _Name, _Value: string); overload;

///<summary> Reads a file's version information and returns the four parts of the version
///          number.
///          @param Filename is a string with the name of the file to check, if empty, the
///                 current program is checked.
///          @param Major is a word returning the major version number
///          @param Minor is a word returning the minor version number
///          @param Revision is a word returning the revision number
///          @param Build is a word returning the build number
///          @returns True, if version information was found,
///                   False if the file does not contain any version information </summary>
function GetFileBuildInfo(_Filename: string;
  out _Major, _Minor, _Revision, _Build: integer): boolean; overload;
function GetFileBuildInfo(const _Filename: string;
  out _Major, _Minor, _Revision, _Build: word): boolean; overload;
///<summary> Reads a file's version information and returns a string containing the version number as
///          Major.Minor.Revision.Build or 'unknown' if it can not be determined. </summary>
function GetFileBuildInfo(_Filename: string = ''; _AllowException: boolean = false): string; overload;

///<summary> Reads a file's product information and returns the four parts of the version
///          number.
///          @param Filename is a string with the name of the file to check, if empty, the
///                 current program is checked.
///          @param Major is a word returning the major version number
///          @param Minor is a word returning the minor version number
///          @param Revision is a word returning the revision number
///          @param Build is a word returning the build number
///          @returns True, if version information was found,
///                   False if the file does not contain any version information </summary>
function GetFileProductInfo(_Filename: string;
  out _Major, _Minor, _Revision, _Build: integer): boolean; overload;
function GetFileProductInfo(_Filename: string; _AllowException: boolean = false): string; overload;

///<summary> @returns the filename of the current module </summary>
function GetModuleFilename: string; overload;
function GetModuleFilename(const _Module: Cardinal): string; overload;

///<summary> registers an open command for a file extension
///          @param Extension is the file extension to register e.g. '.bla'
///          @param DocumentName is the user friendly name for the file type e.g. 'Bla bla file'
///          @param OpenCommand is the command that must be executed to open that file
///                             e.g. '"c:\program files\My Company\My App\myprog.exe" "%1"'
///                             Don't forget to put quotes around both, the executable name and
///                             the parameter, and also don't forget to pass the parameter.
///          @param ShortDocName is an internal, short name for the file type e.g. 'MyProg.bla'
//                               You should always supply one
procedure RegisterFileAssociation(const _Extension, _DocumentName, _OpenCommand: string); overload; deprecated;
procedure RegisterFileAssociation(const _Extension, _ShortDocName, _DocumentName, _OpenCommand: string); overload;

function OsHasNTSecurity: boolean;

///<summary> Checks whether the currently logged on user (the one who runs this process) has administrator rights
///          (In Win9x this always returns true, in WinNT+ it checks whether the user is member of the
///          administrators group </summary>
function CurrentUserHasAdminRights: Boolean;

///<summary> tries to open a file with the associated application
///          @param Filename is the name of the file to open
///          @returns true on success, false otherwise </summary>
function OpenFileWithAssociatedApp(const _Filename: string): boolean;

implementation

uses
  Registry,
  ShellApi,
  u_dzMiscUtils;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

function GetComputerName: string;
var
  Len: Cardinal;
begin
  Len := 2 * MAX_COMPUTERNAME_LENGTH; // just in case it is longer than 15 characters, you never know...
  SetLength(Result, Len + 1);
  if Windows.GetComputerName(@Result[1], Len) then
    SetLength(Result, Len)
  else
    Result := '';
end;

function GetUserName: string;
var
  Groesse: cardinal;
  LastError: Cardinal;
begin
  Groesse := 80;
  SetLength(Result, Groesse);
  if Windows.GetUsername(PChar(Result), Groesse) then begin
    SetLength(Result, Groesse - 1);
  end else begin
    LastError := GetLastError;
    RaiseLastOsErrorEx(LastError, _('%s (code %d) calling Windows.GetUsername'));
  end;
end;

function ExpandEnvironmentStrings(const _WithVariables: string): string;
var
  Res: integer;
  MaxLen: integer;
  LastError: Cardinal;
begin
  MaxLen := Length(_WithVariables) + 16 * 1024; // 16 KB should be enough for everybody... ;-)
  SetLength(Result, MaxLen);
  Res := Windows.ExpandEnvironmentStrings(PChar(_WithVariables), PChar(Result), MaxLen);
  if Res > MaxLen then begin
    MaxLen := Res + 1;
    SetLength(Result, MaxLen);
    Res := Windows.ExpandEnvironmentStrings(PChar(_WithVariables), PChar(Result), MaxLen);
  end;
  if Res = 0 then begin
    LastError := GetLastError;
    RaiseLastOsErrorEx(LastError, _('Error %1:s (%0:d) calling Windows.ExpandEnvironmentStrings'));
  end;
  SetLength(Result, Res - 1);
end;

function GetEnvironmentVars(const _Vars: TStrings): Boolean;
var
  Vars: PChar;
  P: PChar;
begin
  Result := false;
  _Vars.BeginUpdate;
  try
    _Vars.Clear;
    Vars := Windows.GetEnvironmentStrings;
    if Vars <> nil then begin
      try
        P := Vars;
        while P^ <> #0 do begin
          _Vars.Add(P);
          P := StrEnd(P);
          Inc(P);
        end;
      finally
        Windows.FreeEnvironmentStrings(Vars);
      end;
      Result := True;
    end;
  finally
    _Vars.EndUpdate;
  end;
end;

function GetHomeDir: string;
begin
  Result := GetEnvironmentVariable('HOME');
  if Result = '' then
    Result := GetEnvironmentVariable('HOMEDRIVE') + GetEnvironmentVariable('HOMEPATH');
end;

function GetRegValue(_RootKey: HKey; const _Key, _Name: string; out _Value: Integer): boolean;
var
  Reg: TRegistry;
begin
  Result := false;
  Reg := TRegistry.Create;
  try
    Reg.RootKey := _Rootkey;
    if Reg.OpenKeyReadonly(_Key) then
      try
        try
          _Value := Reg.ReadInteger(_Name);
          Result := true;
        except
          // ignore exceptions, return false
        end;
      finally
        Reg.CloseKey;
      end
  finally
    Reg.Free;
  end;
end;

procedure SetRegValue(_RootKey: HKey; const _Key, _Name, _Value: string); overload;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := _Rootkey;
    if Reg.OpenKey(_Key, true) then
      try
        Reg.WriteString(_Name, _Value);
      finally
        Reg.CloseKey;
      end
  finally
    Reg.Free;
  end;
end;

procedure RegisterFileAssociation(const _Extension, _ShortDocName, _DocumentName, _OpenCommand: string);
begin
  SetRegValue(HKEY_CLASSES_ROOT, _Extension, '', _ShortDocName);
  SetRegValue(HKEY_CLASSES_ROOT, _ShortDocName, '', _DocumentName);
  SetRegValue(HKEY_CLASSES_ROOT, Format('%s\shell\command', [_ShortDocName]), '', _OpenCommand);
end;

procedure RegisterFileAssociation(const _Extension, _DocumentName, _OpenCommand: string);
begin
  RegisterFileAssociation(_Extension, _DocumentName, _DocumentName, _OpenCommand);
end;

function GetModuleFilename(const _Module: Cardinal): string;
var
  Buffer: array[0..260] of Char;
begin
  SetString(Result, Buffer, Windows.GetModuleFileName(_Module, Buffer, SizeOf(Buffer)))
end;

function GetModuleFilename: string;
begin
  result := GetModuleFileName(HInstance);
end;

function GetFileBuildInfo(_Filename: string;
  out _Major, _Minor, _Revision, _Build: integer): boolean;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  if _Filename = '' then
    _Filename := GetModuleFileName;
  VerInfoSize := GetFileVersionInfoSize(PChar(_Filename), Dummy);
  Result := (VerInfoSize <> 0);
  if Result then begin
    GetMem(VerInfo, VerInfoSize);
    try
      GetFileVersionInfo(PChar(_Filename), 0, VerInfoSize, VerInfo);
      VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
      with VerValue^ do begin
        _Major := dwFileVersionMS shr 16;
        _Minor := dwFileVersionMS and $FFFF;
        _Revision := dwFileVersionLS shr 16;
        _Build := dwFileVersionLS and $FFFF;
      end;
    finally
      FreeMem(VerInfo, VerInfoSize);
    end;
  end;
end;

function GetFileProductInfo(_Filename: string;
  out _Major, _Minor, _Revision, _Build: integer): boolean;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  if _Filename = '' then
    _Filename := GetModuleFileName;
  VerInfoSize := GetFileVersionInfoSize(PChar(_Filename), Dummy);
  Result := (VerInfoSize <> 0);
  if Result then begin
    GetMem(VerInfo, VerInfoSize);
    try
      GetFileVersionInfo(PChar(_Filename), 0, VerInfoSize, VerInfo);
      VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
      with VerValue^ do begin
        _Major := dwProductVersionMS shr 16;
        _Minor := dwProductVersionMS and $FFFF;
        _Revision := dwProductVersionLS shr 16;
        _Build := dwProductVersionLS and $FFFF;
      end;
    finally
      FreeMem(VerInfo, VerInfoSize);
    end;
  end;
end;

function GetFileBuildInfo(const _Filename: string;
  out _Major, _Minor, _Revision, _Build: word): boolean;
var
  Major, Minor, Revision, Build: integer;
begin
  Result := GetFileBuildInfo(_Filename, Major, Minor, Revision, Build);
  if Result then begin
    _Major := Major;
    _Minor := Minor;
    _Revision := Revision;
    _Build := Build;
  end;
end;

function GetFileBuildInfo(_Filename: string; _AllowException: boolean): string;
var
  Major: integer;
  Minor: integer;
  Revision: integer;
  Build: integer;
begin
  if GetFileBuildInfo(_Filename, Major, Minor, Revision, Build) then
    Result := Format('%d.%d.%d.%d', [Major, Minor, Revision, Build])
  else if _AllowException then
    raise EOFNoFileinfo.CreateFmt(_('No version information available for %s'), [_Filename])
  else
    Result := 'unknown';
end;

function GetFileProductInfo(_Filename: string; _AllowException: boolean): string;
var
  Major: integer;
  Minor: integer;
  Revision: integer;
  Build: integer;
begin
  if GetFileProductInfo(_Filename, Major, Minor, Revision, Build) then
    Result := Format('%d.%d.%d.%d', [Major, Minor, Revision, Build])
  else if _AllowException then
    raise EOFNoFileinfo.CreateFmt(_('No version information available for %s'), [_Filename])
  else
    Result := 'unknown';
end;

function OsHasNTSecurity: boolean;
var
  vi: TOSVersionInfo;
begin
  FillChar(vi, SizeOf(vi), 0);
  vi.dwOSVersionInfoSize := SizeOf(vi);
  GetVersionEx(vi);
  Result := (vi.dwPlatformId = VER_PLATFORM_WIN32_NT);
end;

const
  SECURITY_NT_AUTHORITY: SID_IDENTIFIER_AUTHORITY = (Value: (0, 0, 0, 0, 0, 5)); // ntifs

  SECURITY_BUILTIN_DOMAIN_RID: DWORD = $00000020;
  DOMAIN_ALIAS_RID_ADMINS: DWORD = $00000220;
  DOMAIN_ALIAS_RID_USERS: DWORD = $00000221;
  DOMAIN_ALIAS_RID_GUESTS: DWORD = $00000222;
  DOMAIN_ALIAS_RID_POWER_: DWORD = $00000223;

function CurrentUserIsInAdminGroup: boolean;
var
  bSuccess: Boolean;
  psidAdministrators: Pointer;
  x: Integer;
  ptgGroups: PTokenGroups;
  hAccessToken: Cardinal;
  dwInfoBufferSize: Cardinal;
begin
  Result := False;
  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True, hAccessToken);
  if not bSuccess then begin
    if GetLastError = ERROR_NO_TOKEN then
      bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hAccessToken);
  end;
  if bSuccess then begin
    try
      GetMem(ptgGroups, 1024);
      try
        bSuccess := GetTokenInformation(hAccessToken, TokenGroups, ptgGroups, 1024, dwInfoBufferSize);
        if bSuccess then begin
          AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, psidAdministrators);
          try
{$R-}
            for x := 0 to ptgGroups.GroupCount - 1 do
              if EqualSid(psidAdministrators, ptgGroups.Groups[x].Sid) then begin
                Result := True;
                Break;
              end;
          finally
{$R+}
            FreeSid(psidAdministrators);
          end;
        end;
      finally
        FreeMem(ptgGroups);
      end;
    finally
      CloseHandle(hAccessToken);
    end;
  end;
end;

function CurrentUserHasAdminRights: Boolean;
begin
  if OsHasNTSecurity then
    Result := CurrentUserIsInAdminGroup
  else
    Result := true;
end;

function ShellExecEx(const FileName: string; const Parameters: string;
  const Verb: string; CmdShow: Integer): Boolean;
var
  Sei: TShellExecuteInfo;
begin
  FillChar(Sei, SizeOf(Sei), #0);
  Sei.cbSize := SizeOf(Sei);
  Sei.fMask := SEE_MASK_DOENVSUBST or SEE_MASK_FLAG_NO_UI;
  Sei.lpFile := PChar(FileName);
  if Parameters <> '' then
    Sei.lpParameters := PChar(Parameters)
  else
    sei.lpParameters := nil;
  if Verb <> '' then
    Sei.lpVerb := PChar(Verb)
  else
    Sei.lpVerb := nil;
  Sei.nShow := CmdShow;
  Result := ShellExecuteEx(@Sei);
end;

function OpenFileWithAssociatedApp(const _Filename: string): boolean;
begin
  Result := ShellExecEx(_Filename, '', 'open', SW_SHOWNORMAL);
end;

end.

