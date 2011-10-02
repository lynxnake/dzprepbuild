{.GXFormatter.config=twm}
///<summary> declares TdzDllLoader class to make handling of DLLs easier </summary>
unit u_dzDllLoader;

interface

uses
  Windows,
  SysUtils,
  u_dzTranslator,
  u_dzVersionInfo,
  u_dzCustomDllLoader;

type
  ///<summary> wrapper for the Load/FreeLibrary and GetProcAddress API calls </summary>
  TdzDllLoader = class(TdzCustomDllLoader)
  protected
    ///<summary> module handle of dll as returned by LoadLibrary </summary>
    FDllHandle: THandle;
    ///<summary> Version info of dll </summary>
    FDllVersion: IFileInfo;
    procedure LoadDll; override;
    procedure UnloadDll; override;
  public
    ///<summary> calls GetProcAddress and raises ENoEntryPoint if it returns nil
    ///          @param EntryPoint is the name of the entry point to get
    ///          @param DefaultFunc is a function pointer to assign if the entry point cannot be found
    ///                             if it is nil, an ENoEntryPoint exception will be raise in that case.
    ///                             Note: This function pointer must match the calling convention of
    ///                             the entry point and unless the calling convention is cdecl
    ///                             it must also match number of parameters of the entry point.
    ///                             See also the NotSupportedN functions in this unit.
    ///          @returns a pointer to the entry pointer
    ///          @raises ENoEntryPoint on failure </summary>
    function TryGetProcAddress(const _EntryPoint: string; _DefaultFunc: pointer = nil): pointer; overload; override;
    ///<summary> calls GetProcAddress for MSC mangled entry points and raises ENoEntryPoint if it returns nil
    ///          @param EntryPoint is the name of the entry point to get
    ///          @param DWordParams is the number of DWord parameters of the entry point, used to
    ///                             generate the actual name of the entry point
    ///          @param DefaultFunc is a function pointer to assign if the entry point cannot be found
    ///                             if it is nil, an ENoEntryPoint exception will be raised in that case.
    ///                             Note: This function pointer must match the calling convention of
    ///                             the entry point and unless the calling convention is cdecl
    ///                             it must also match number of parameters of the entry point.
    ///                             See also the NotSupportedN functions in u_dzDllLoader.
    ///          @returns a pointer to the entry pointer
    ///          @raises ENoEntryPoint on failure </summary>
    function TryGetProcAddress(const _EntryPoint: string; _DWordParams: integer; _DefaultFunc: pointer = nil): pointer; overload; override;
  public
    ///<summary> assumes that the dll has already been loaded and uses the given DllHandle,
    ///          NOTE: The destructor will call FreeLibrary anyway, so make sure you don't
    ///                store the dll handle anywhere else! </summary>
    constructor Create(const _DllName: string; _DllHandle: THandle); overload;
    ///<summary> Generates a TVersionInfo object on demand and returns it </summary>
    function DllVersion: IFileInfo;
    ///<summary> returns the full path of the dll that has been loaded </summary>
    function DllFilename: string; override;
  end;

implementation

uses
  u_dzMiscUtils,
  u_dzOsUtils;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

{ TdzDllLoader }

constructor TdzDllLoader.Create(const _DllName: string; _DllHandle: THandle);
begin
  inherited Create;
  FDllName := _DllName;
  FDllHandle := _DllHandle;
end;

function TdzDllLoader.DllFilename: string;
begin
  Result := GetModuleFilename(FDllHandle);
end;

function TdzDllLoader.DllVersion: IFileInfo;
begin
  if not Assigned(FDllVersion) then begin
    FDllVersion := TFileInfo.Create(FDllName);
    FDllVersion.AllowExceptions := false;
  end;
  Result := FDllVersion;
end;

procedure TdzDllLoader.LoadDll;
begin
  FDllHandle := LoadLibrary(PChar(FDllName));
  if FDllHandle = 0 then
    raise EDllLoadError.CreateFmt(_('Could not load %s.'), [FDllName]);
end;

function TdzDllLoader.TryGetProcAddress(const _EntryPoint: string; _DWordParams: integer; _DefaultFunc: pointer): pointer;
var
  EntryPoint: string;
begin
  EntryPoint := '_' + _EntryPoint + '@' + IntToStr(_DWordParams);
  Result := TryGetProcAddress(EntryPoint, _DefaultFunc);
end;

function TdzDllLoader.TryGetProcAddress(const _EntryPoint: string; _DefaultFunc: pointer = nil): pointer;
var
  ErrCode: integer;
begin
  Result := GetProcAddress(FDllHandle, PChar(_EntryPoint));
  if not Assigned(Result) then begin
    if Assigned(_DefaultFunc) then
      Result := _DefaultFunc
    else begin
      ErrCode := GetLastError;
      RaiseLastOsErrorEx(ErrCode, Format(_('Could not find entry point %s in %s'#13#10'ERROR= %%d, %%s'), [_EntryPoint, FDllName]));
    end;
  end;
end;

procedure TdzDllLoader.UnloadDll;
begin
  if FDllHandle <> 0 then
    FreeLibrary(FDllHandle);
  FDllHandle := 0;
end;

end.

