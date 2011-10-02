unit u_PrepBuildMain;

interface

uses
  Windows,
  SysUtils,
  StrUtils,
  u_dzDefaultMain,
  u_dzGetOpt,
  u_VersionInfo,
  i_VersionInfoAccess;

type
  TPrepBuildMain = class(TDefaultMain)
  private
    function HandleExecOption(const _Command: string; _VersionInfo: TVersionInfo; const _Project: string): integer;
    procedure WriteRcFile(const _Project: string; _VersionInfo: TVersionInfo; const _Icon: string);
    procedure DumpCmd;
  protected
    procedure InitCmdLineParser; override;
    function doExecute: integer; override;
  public

  end;

implementation

uses
  Dialogs,
  u_dzTranslator,
  u_dzExecutor,
  u_dzJclUtils,
  u_dzShellApiUtils,
  u_DofVersionInfo,
  d_BdsProjVersionInfo,
  u_CentralIniVersionInfo,
  d_DProjVersionInfo;

{ TPrepBuildMain }

function DateTimeToString(const _Format: string; _dt: TDateTime): string;
begin
  SysUtils.DateTimeToString(Result, _Format, _dt);
end;

procedure TPrepBuildMain.WriteRcFile(const _Project: string; _VersionInfo: TVersionInfo; const _Icon: string);
var
  fn: string;
  t: TextFile;
begin
  fn := ChangeFileExt(_Project, '_Version.rc');
  WriteLn('Writing rc file ', fn);
  Assignfile(t, fn);
  Rewrite(t);
  try
    WriteLn(t, {    } 'LANGUAGE LANG_ENGLISH,SUBLANG_ENGLISH_US');
    WriteLn(t);
    WriteLn(t, {    } '1 VERSIONINFO LOADONCALL MOVEABLE DISCARDABLE IMPURE');
    WriteLn(t, Format('FILEVERSION %d, %d, %d, %d', [_VersionInfo.MajorVer, _VersionInfo.MinorVer, _VersionInfo.Release, _VersionInfo.Build]));
    WriteLn(t, Format('PRODUCTVERSION %d, %d, %d, %d',
      [_VersionInfo.MajorVer, _VersionInfo.MinorVer, _VersionInfo.Release, _VersionInfo.Build]));
    WriteLn(t, {    } 'FILEFLAGSMASK VS_FFI_FILEFLAGSMASK');
    WriteLn(t, {    } 'FILEOS VOS__WINDOWS32');
    WriteLn(t, {    } 'FILETYPE VFT_APP');
    WriteLn(t, {    } '{');
    WriteLn(t, {    } ' BLOCK "StringFileInfo"');
    WriteLn(t, {    } ' {');
    WriteLn(t, {    } '  BLOCK "040904E4"');
    WriteLn(t, {    } '  {');
    WriteLn(t, Format('   VALUE "CompanyName", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.CompanyName)]));
    WriteLn(t, Format('   VALUE "FileDescription", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.FileDescription)]));
    WriteLn(t, Format('   VALUE "FileVersion", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.FileVersion)]));
    WriteLn(t, Format('   VALUE "InternalName", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.InternalName)]));
    WriteLn(t, Format('   VALUE "LegalCopyright", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.LegalCopyright)]));
    WriteLn(t, Format('   VALUE "LegalTrademarks", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.LegalTrademarks)]));
    WriteLn(t, Format('   VALUE "OriginalFilename", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.OriginalFilename)]));
    WriteLn(t, Format('   VALUE "ProductName", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.ProductName)]));
    WriteLn(t, Format('   VALUE "ProductVersion", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.ProductVersion)]));
    WriteLn(t, Format('   VALUE "Comments", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.Comments)]));
    WriteLn(t, {    } '  }');
    WriteLn(t, {    } ' }');
    WriteLn(t, {    } ' BLOCK "VarFileInfo"');
    WriteLn(t, {    } ' {');
    WriteLn(t, {    } '  VALUE "Translation", 1033, 1252');
    WriteLn(t, {    } ' }');
    WriteLn(t, {    } '}');
    if _Icon <> '' then begin
      WriteLn(t);
      WriteLn(t, Format('MAINICON ICON LOADONCALL MOVEABLE DISCARDABLE IMPURE %s', [ChangeFileExt(_Icon, '.ico')]));
    end;
  finally
    Close(t);
  end;
end;

function TPrepBuildMain.HandleExecOption(const _Command: string; _VersionInfo: TVersionInfo; const _Project: string): integer;
const
  DZ_MY_DOCUMENTS = 'dzMyDocuments';
  DZ_DATE = 'dzDate';
  DZ_TIME = 'dzTime';
  DZ_DATE_TIME = 'dzDateTime';
  DZ_VERSION = 'dzVersion.';
  DZ_PROJECT = 'dzProject';
  DZ_PREPBUILD = 'dzPrepBuild';
var
  MyDoc: string;
  Executor: TExecutor;
  dt: TDateTime;
begin
  MyDoc := TWindowsShell.GetMyDocumentsDir();
  Executor := TExecutor.Create;
  try
    Executor.ExeName := GetEnvironmentVariable('ComSpec');
    Executor.Commandline := '/c ' + _Command;
    Executor.Environment.Values[DZ_MY_DOCUMENTS] := MyDoc;

    dt := Now;
    Executor.Environment.Values[DZ_DATE] := DateTimeToString('yyyy-mm-dd', dt);
    Executor.Environment.Values[DZ_TIME] := DateTimeToString('hh-nn-ss', dt);
    Executor.Environment.Values[DZ_DATE_TIME] := DateTimeToString('yyyy-mm-dd_hh-nn-ss', dt);
    Executor.Environment.Values[DZ_PREPBUILD] := ExeName;

    if _Project <> '' then
      Executor.Environment.Values[DZ_PROJECT] := ChangeFileExt(_Project, '');

    if Assigned(_VersionInfo) then begin
      Executor.Environment.Values[DZ_VERSION + 'MajorVer'] := IntToStr(_VersionInfo.MajorVer);
      Executor.Environment.Values[DZ_VERSION + 'MinorVer'] := IntToStr(_VersionInfo.MinorVer);
      Executor.Environment.Values[DZ_VERSION + 'Release'] := IntToStr(_VersionInfo.Release);
      Executor.Environment.Values[DZ_VERSION + 'Build'] := IntToStr(_VersionInfo.Build);
      Executor.Environment.Values[DZ_VERSION + 'FileDesc'] := _VersionInfo.FileDescription;
      Executor.Environment.Values[DZ_VERSION + 'InternalName'] := _VersionInfo.InternalName;
      Executor.Environment.Values[DZ_VERSION + 'OriginalName'] := _VersionInfo.OriginalFilename;
      Executor.Environment.Values[DZ_VERSION + 'Product'] := _VersionInfo.ProductName;
      Executor.Environment.Values[DZ_VERSION + 'ProductVersion'] := _VersionInfo.ProductVersion;
      Executor.Environment.Values[DZ_VERSION + 'Company'] := _VersionInfo.CompanyName;
      Executor.Environment.Values[DZ_VERSION + 'Copyright'] := _VersionInfo.LegalCopyright;
      Executor.Environment.Values[DZ_VERSION + 'Trademark'] := _VersionInfo.LegalTrademarks;
      Executor.Environment.Values[DZ_VERSION + 'Comments'] := _VersionInfo.Comments;
    end;

    Executor.Execute;
    Executor.Wait(INFINITE);
    Result := Executor.ExitCode;
  finally
    Executor.Free;
  end;
end;

procedure TPrepBuildMain.DumpCmd;
var
  i: Integer;
  s: string;
begin
  s := GetCurrentDir + #13#10 + ParamStr(0) + #13#10;
  for i := 0 to FGetOpt.OptionsFoundList.Count - 1 do begin
    s := s + FGetOpt.OptionsFoundList.Items[i].Name + '=' + FGetOpt.OptionsFoundList.Items[i].Value + #13#10;
  end;
  MessageDlg(s, mtInformation, [mbOK], 0);
  SysUtils.Abort;
end;

function UnquoteStr(const _s: string): string;
var
  s: PChar;
  p: PChar;
begin
  s := StrNew(PChar(_s));
  try
    p := s;
    Result := AnsiExtractQuotedStr(p, '"');
  finally
    StrDispose(s);
  end;
end;

function TPrepBuildMain.doExecute: integer;
var
  Param: string;
  VerInfoAccess: IVersionInfoAccess;
  VersionInfo: TVersionInfo;
  IntValue: integer;
  IconFile: string;
  Project: string;
begin
  WriteLn('dzPrepBuild version ' + TApplication_GetFileVersion + ' built ' + TApplication_GetProductVersion);

  if FGetOpt.OptionsFoundList.Count = 0 then
    Usage(_('You must supply some options.'));

  if FGetOpt.OptionPassed('dumpcmd') then
    DumpCmd;

  Project := '';
  if FGetOpt.OptionPassed('ReadDof', Project) then
    VerInfoAccess := TDofVersionInfo.Create(Project);

  if FGetOpt.OptionPassed('ReadBdsProj', Project) then begin
    if Assigned(VerInfoAccess) then
      raise Exception.Create(_('You can only pass one of --ReadDof, --ReadBdsproj, --ReadDproj or --ReadIni'));
    VerInfoAccess := Tdm_BdsProjVersionInfo.Create(Project);
  end;

  if FGetOpt.OptionPassed('ReadIni', Project) then begin
    if Assigned(VerInfoAccess) then
      raise Exception.Create(_('You can only pass one of --ReadDof, --ReadBdsproj, --ReadDproj  or --ReadIni'));
    VerInfoAccess := TCentralIniVersionInfo.Create(Project);
  end;

  if FGetOpt.OptionPassed('ReadDproj', Project) then begin
    if Assigned(VerInfoAccess) then
      raise Exception.Create(_('You can only pass one of --ReadDof, --ReadBdsproj, --ReadDproj  or --ReadIni'));
    VerInfoAccess := Tdm_DProjVersionInfo.Create(Project);
  end;

  VersionInfo := TVersionInfo.Create;
  try
    if Assigned(VerInfoAccess) then begin
      WriteLn('Reading ' + VerInfoAccess.VerInfoFilename);
      VerInfoAccess.ReadFromFile(VersionInfo);
      VerInfoAccess := nil;
    end;

    if FGetOpt.OptionPassed('MajorVer', Param) then begin
      if not TryStrToInt(Param, IntValue) then
        raise Exception.Create(_('Parameter for MajorVer must be a number'));
      WriteLn('Setting MajorVer to ', IntValue);
      VersionInfo.MajorVer := IntValue;
    end;

    if FGetOpt.OptionPassed('MinorVer', Param) then begin
      if not TryStrToInt(Param, IntValue) then
        raise Exception.Create(_('Parameter for MinorVer must be a number'));
      WriteLn('Setting MinorVer to ', IntValue);
      VersionInfo.MinorVer := IntValue;
    end;

    if FGetOpt.OptionPassed('Release', Param) then begin
      if not TryStrToInt(Param, IntValue) then
        raise Exception.Create(_('Parameter for Release must be a number'));
      WriteLn('Setting Release to ', IntValue);
      VersionInfo.Release := IntValue;
    end;

    if FGetOpt.OptionPassed('Build', Param) then begin
      if not TryStrToInt(Param, IntValue) then
        raise Exception.Create(_('Parameter for Build must be a number'));
      WriteLn('Setting Build to ', IntValue);
      VersionInfo.Build := IntValue;
    end;

    if FGetOpt.OptionPassed('FileDesc', Param) then begin
      VersionInfo.FileDescription := UnquoteStr(Param);
      WriteLn('Setting FileDescription to ', VersionInfo.FileDescription);
    end;

    if FGetOpt.OptionPassed('InternalName', Param) then begin
      VersionInfo.InternalName := UnquoteStr(Param);
      WriteLn('Setting InternalName to ', VersionInfo.InternalName);
    end;

    if FGetOpt.OptionPassed('OriginalName', Param) then begin
      VersionInfo.OriginalFilename := UnquoteStr(Param);
      WriteLn('Setting OriginalFilename to ', VersionInfo.OriginalFilename);
    end;

    if FGetOpt.OptionPassed('Product', Param) then begin
      VersionInfo.ProductName := UnquoteStr(Param);
      WriteLn('Setting ProductName to ', VersionInfo.ProductName);
    end;

    if FGetOpt.OptionPassed('ProductVersion', Param) then begin
      VersionInfo.ProductVersion := UnquoteStr(Param);
      WriteLn('Setting ProductVersion to ', VersionInfo.ProductVersion);
    end;

    if FGetOpt.OptionPassed('Company', Param) then begin
      VersionInfo.CompanyName := UnquoteStr(Param);
      WriteLn('Setting CompanyName to ', VersionInfo.CompanyName);
    end;

    if FGetOpt.OptionPassed('Copyright', Param) then begin
      VersionInfo.LegalCopyright := UnquoteStr(Param);
      WriteLn('Setting LegalCopyright to ', VersionInfo.LegalCopyright);
    end;

    if FGetOpt.OptionPassed('Trademark', Param) then begin
      VersionInfo.LegalTrademarks := UnquoteStr(Param);
      WriteLn('Setting LegalTrademarks to ', VersionInfo.LegalTrademarks);
    end;

    if FGetOpt.OptionPassed('Comments', Param) then begin
      VersionInfo.Comments := UnquoteStr(Param);
      WriteLn('Setting Comments to ', VersionInfo.Comments);
    end;

    if FGetOpt.OptionPassed('IncBuild') then begin
      VersionInfo.Build := VersionInfo.Build + 1;
      WriteLn('Incrementing build number to ', VersionInfo.Build);
    end;

    VersionInfo.UpdateFileVersion;
    WriteLn('FileVersion is now ', VersionInfo.FileVersion);

    if FGetOpt.OptionPassed('UpdateDof', Param) then begin
      VerInfoAccess := TDofVersionInfo.Create(Param);
      WriteLn('Updating ', VerInfoAccess.VerInfoFilename);
      VerInfoAccess.WriteToFile(VersionInfo);
    end;

    if FGetOpt.OptionPassed('UpdateBdsproj', Param) then begin
      VerInfoAccess := Tdm_BdsProjVersionInfo.Create(Param);
      WriteLn('Updating ', VerInfoAccess.VerInfoFilename);
      VerInfoAccess.WriteToFile(VersionInfo);
    end;

    if FGetOpt.OptionPassed('UpdateIni', Param) then begin
      VerInfoAccess := TCentralIniVersionInfo.Create(Param);
      WriteLn('Updating ', VerInfoAccess.VerInfoFilename);
      VerInfoAccess.WriteToFile(VersionInfo);
    end;

    if FGetOpt.OptionPassed('UpdateDproj', Param) then begin
      VerInfoAccess := Tdm_DprojVersionInfo.Create(Param);
      WriteLn('Updating ', VerInfoAccess.VerInfoFilename);
      VerInfoAccess.WriteToFile(VersionInfo);
    end;

    if FGetOpt.OptionPassed('Icon', IconFile) then
      WriteLn('Adding icon to rcfile from ', IconFile)
    else
      IconFile := '';

    if FGetOpt.OptionPassed('WriteRc', Param) then begin
      WriteRcFile(Param, VersionInfo, IconFile);
    end;

    if FGetOpt.OptionPassed('Exec', Param) then begin
      WriteLn('Executing ', Param);
      Flush(Output);
      HandleExecOption(Param, VersionInfo, Project);
    end;

  finally
    FreeAndNil(VersionInfo);
  end;

  Result := 0;
end;

procedure TPrepBuildMain.InitCmdLineParser;
begin
  inherited;
  FGetOpt.RegisterOption('dumpcmd', _('dump the commandline and exit (for debug purposes)'), false);

  FGetOpt.RegisterOption('ReadDof', _('read a .dof file to get the version information'), true);
  FGetOpt.RegisterOption('ReadBdsproj', _('read a .bdsproj file to get the version information'), true);
  FGetOpt.RegisterOption('ReadIni', _('read a .ini file to get the version information'), true);
  FGetOpt.RegisterOption('ReadDproj', _('Read a .dproj file to get the version information'), true);

  FGetOpt.RegisterOption('MajorVer', _('set the major version number (overwrites value from -ReadXxx option)'), true);
  FGetOpt.RegisterOption('MinorVer', _('set the minor version number (overwrites value from -ReadXxx option)'), true);
  FGetOpt.RegisterOption('Release', _('set the release number (overwrites value from -ReadXxx option)'), true);
  FGetOpt.RegisterOption('Build', _('set the build number (overwrites value from -ReadXxx option)'), true);

  FGetOpt.RegisterOption('FileDesc', _('set the file description (overwrites value from -ReadXxx option)'), true);
  FGetOpt.RegisterOption('InternalName', _('set the internal name (overwrites value from -ReadXxx option)'), true);
  FGetOpt.RegisterOption('OriginalName', _('set the original file name (overwrites value from -ReadXxx option)'), true);
  FGetOpt.RegisterOption('Product', _('set the product name (overwrites value from -ReadXxx option)'), true);
  FGetOpt.RegisterOption('ProductVersion', _('set the product version (overwrites value from -ReadXxx option)'), true);
  FGetOpt.RegisterOption('Company', _('set the company name (overwrites value from -ReadXxx option)'), true);
  FGetOpt.RegisterOption('Copyright', _('set the legal copyright (overwrites value from -ReadXxx option)'), true);
  FGetOpt.RegisterOption('Trademark', _('set the legal trademark (overwrites value from -ReadXxx option)'), true);
  FGetOpt.RegisterOption('Comments', _('set the comments (overwrites value from -ReadXxx option)'), true);

  FGetOpt.RegisterOption('IncBuild', _('increment the build number'), false);

  FGetOpt.RegisterOption('UpdateDof', _('update a .dof file with the version information'), true);
  FGetOpt.RegisterOption('UpdateBdsproj', _('update a .bdsproj file with the version information'), true);
  FGetOpt.RegisterOption('UpdateIni', _('update a .ini file with the version information'), true);
  FGetOpt.RegisterOption('UpdateDproj', _('update a .dproj file with the version information'), true);

  FGetOpt.RegisterOption('Icon', _('Assign an icon file to add to the .rc file'), true);

  FGetOpt.RegisterOption('WriteRc', _('write version info to a .rc file'), true);

  FGetOpt.RegisterOption('Exec', _('execute the given program or script with extended environment'), true);
end;

initialization
  MainClass := TPrepBuildMain;
end.

