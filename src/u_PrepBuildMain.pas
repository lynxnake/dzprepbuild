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
    function HandleExecOption(const _Command: string; _VersionInfo: TVersionInfo; const _Project: string): Integer;
    procedure WriteRcFile(const _Project: string; _VersionInfo: TVersionInfo; const _Icon: string);
    procedure DumpCmd;
    procedure WriteMainfestRcFile(const _Project: string; const _ManifestFile: string);
    function FileMaskOptionsToStr(const _IsPrivateBuild, _IsSpecialBuild: Boolean): string;
  protected
    procedure InitCmdLineParser; override;
    function doExecute: Integer; override;
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
  d_DProjVersionInfo,
  d_ManifestVersionInfo;

{ TPrepBuildMain }

function DateTimeToString(const _Format: string; _dt: TDateTime): string;
begin
  SysUtils.DateTimeToString(Result, _Format, _dt);
end;

function TPrepBuildMain.FileMaskOptionsToStr(const _IsPrivateBuild, _IsSpecialBuild: Boolean): string;

  procedure AddParam(var _Output: string; const _Param: string);
  begin
    if (_Output <> '') then begin
      _Output := _Output + '|';
    end;
    _Output := _Output + _Param;
  end;

begin
  Result := '';

  if _IsPrivateBuild then begin
    AddParam(Result, 'VS_FF_PRIVATEBUILD');
  end;

  if _IsSpecialBuild then begin
    AddParam(Result, 'VS_FF_SPECIALBUILD');
  end;

  if (Result = '') then begin
    Result := '0';
  end;
end;

procedure TPrepBuildMain.WriteRcFile(const _Project: string; _VersionInfo: TVersionInfo; const _Icon: string);
var
  fn: string;
  FileFlags: string;
  CommentText: string;
  t: TextFile;
begin
  fn := ChangeFileExt(_Project, '_Version.rc');
  WriteLn('Writing rc file ', fn);
  Assignfile(t, fn);
  Rewrite(t);
  try
    FileFlags := FileMaskOptionsToStr(_VersionInfo.IsPrivateBuild, _VersionInfo.IsSpecialBuild);
    WriteLn(t, {    } 'LANGUAGE LANG_ENGLISH,SUBLANG_ENGLISH_US');
    WriteLn(t);
    WriteLn(t, {    } '1 VERSIONINFO LOADONCALL MOVEABLE DISCARDABLE IMPURE');
    WriteLn(t, Format('FILEVERSION %d, %d, %d, %d', [_VersionInfo.MajorVer, _VersionInfo.MinorVer, _VersionInfo.Release, _VersionInfo.Build]));
    WriteLn(t, Format('PRODUCTVERSION %d, %d, %d, %d',
      [_VersionInfo.MajorVer, _VersionInfo.MinorVer, _VersionInfo.Release, _VersionInfo.Build]));
    WriteLn(t, {    } 'FILEFLAGSMASK VS_FFI_FILEFLAGSMASK');
    if FileFlags <> '0' then begin
      WriteLn(t, Format('FILEFLAGS %s', [FileFlags]));
    end;
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
    WriteLn(t, Format('   VALUE "LegalCopyright", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.LegalCopyRight)]));
    WriteLn(t, Format('   VALUE "LegalTrademarks", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.LegalTrademarks)]));
    WriteLn(t, Format('   VALUE "OriginalFilename", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.OriginalFilename)]));
    WriteLn(t, Format('   VALUE "ProductName", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.ProductName)]));
    WriteLn(t, Format('   VALUE "ProductVersion", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.ProductVersion)]));
    WriteLn(t, Format('   VALUE "Comments", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.Comments)]));
    WriteLn(t, Format('   VALUE "Revision", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.SCMRevision)]));
    WriteLn(t, Format('   VALUE "BuildDateTime", "%s\000"', [_VersionInfo.ResolveVariables(_VersionInfo.BuildDateTime)]));
    CommentText := _VersionInfo.ResolveVariables(_VersionInfo.PrivateBuildComments);
    if _VersionInfo.IsPrivateBuild or (CommentText <> '') then begin
      WriteLn(t, Format('   VALUE "PrivateBuild", "%s\000"', [CommentText]));
    end;
    CommentText := _VersionInfo.ResolveVariables(_VersionInfo.SpecialBuildComments);
    if _VersionInfo.IsSpecialBuild or (CommentText <> '') then begin
      WriteLn(t, Format('   VALUE "SpecialBuild", "%s\000"', [CommentText]));
    end;
    WriteLn(t, {    } '  }');
    WriteLn(t, {    } ' }');
    WriteLn(t, {    } ' BLOCK "VarFileInfo"');
    WriteLn(t, {    } ' {');
    WriteLn(t, {    } '  VALUE "Translation", 1033, 1252');
    WriteLn(t, {    } ' }');
    WriteLn(t, {    } '}');
    if _Icon <> '' then begin
      WriteLn(t);
      WriteLn(t, Format('MAINICON ICON LOADONCALL MOVEABLE DISCARDABLE IMPURE "%s"', [ChangeFileExt(_Icon, '.ico')]));
    end;
  finally
    Close(t);
  end;
end;

procedure TPrepBuildMain.WriteMainfestRcFile(const _Project: string; const _ManifestFile: string);
var
  fn: string;
  t: TextFile;
begin
  fn := ChangeFileExt(_Project, '_Manifest.rc');
  WriteLn('Writing mainfest rc file ', fn);
  Assignfile(t, fn);
  Rewrite(t);
  try
    WriteLn(t, '#define MANIFEST_RESOURCE_ID 1');
    WriteLn(t, '#define RT_MANIFEST 24');
    WriteLn(t, Format('MANIFEST_RESOURCE_ID RT_MANIFEST "%s"', [ChangeFileExt(_ManifestFile, '.manifest')]));
  finally
    Close(t);
  end;
end;

function TPrepBuildMain.HandleExecOption(const _Command: string; _VersionInfo: TVersionInfo; const _Project: string): Integer;
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
      Executor.Environment.Values[DZ_VERSION + 'Copyright'] := _VersionInfo.LegalCopyRight;
      Executor.Environment.Values[DZ_VERSION + 'Trademark'] := _VersionInfo.LegalTrademarks;
      Executor.Environment.Values[DZ_VERSION + 'Comments'] := _VersionInfo.Comments;
      Executor.Environment.Values[DZ_VERSION + 'Revision'] := _VersionInfo.SCMRevision;
      Executor.Environment.Values[DZ_VERSION + 'BuildDateTime'] := _VersionInfo.BuildDateTime;
      Executor.Environment.Values[DZ_VERSION + 'IsPrivateBuild'] := BoolToStr(_VersionInfo.IsPrivateBuild, True);
      Executor.Environment.Values[DZ_VERSION + 'IsSpecialBuild'] := BoolToStr(_VersionInfo.IsSpecialBuild, True);
      Executor.Environment.Values[DZ_VERSION + 'PrivateBuild'] := _VersionInfo.PrivateBuildComments;
      Executor.Environment.Values[DZ_VERSION + 'SpecialBuild'] := _VersionInfo.SpecialBuildComments;
    end;

    Executor.doExecute;
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
begin
  Result := AnsiDequotedStr(_s, '"');
end;

function TPrepBuildMain.doExecute: Integer;
var
  Param: string;
  VerInfoAccess: IVersionInfoAccess;
  VersionInfo: TVersionInfo;
  IntValue: Integer;
  IconFile: string;
  Project: string;
  InputManifest: string;
  Manifest: string;
  IgnoreManifestErrors: Boolean;
  s: string;
begin
  try
    WriteLn('dzPrepBuild version ' + TApplication_GetFileVersion + ' built ' + TApplication_GetProductVersion);

    if FGetOpt.OptionsFoundList.Count = 0 then
      Usage(_('You must supply some options.'));

    if FGetOpt.OptionPassed('dumpcmd') then
      DumpCmd;

    Project := '';
    if FGetOpt.OptionPassed('ReadDof', Project) then begin
      Project := UnquoteStr(Project);
      VerInfoAccess := TDofVersionInfo.Create(Project);
    end;

    if FGetOpt.OptionPassed('ReadBdsProj', Project) then begin
      if Assigned(VerInfoAccess) then
        raise Exception.Create(_('You can only pass one of --ReadDof, --ReadBdsproj, --ReadDproj or --ReadIni'));
      Project := UnquoteStr(Project);
      VerInfoAccess := Tdm_BdsProjVersionInfo.Create(Project);
    end;

    if FGetOpt.OptionPassed('ReadIni', Project) then begin
      if Assigned(VerInfoAccess) then
        raise Exception.Create(_('You can only pass one of --ReadDof, --ReadBdsproj, --ReadDproj  or --ReadIni'));
      Project := UnquoteStr(Project);
      VerInfoAccess := TCentralIniVersionInfo.Create(Project);
    end;

    if FGetOpt.OptionPassed('ReadDproj', Project) then begin
      if Assigned(VerInfoAccess) then
        raise Exception.Create(_('You can only pass one of --ReadDof, --ReadBdsproj, --ReadDproj  or --ReadIni'));
      Project := UnquoteStr(Project);
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
        VersionInfo.LegalCopyRight := UnquoteStr(Param);
        WriteLn('Setting LegalCopyright to ', VersionInfo.LegalCopyRight);
      end;

      if FGetOpt.OptionPassed('Trademark', Param) then begin
        VersionInfo.LegalTrademarks := UnquoteStr(Param);
        WriteLn('Setting LegalTrademarks to ', VersionInfo.LegalTrademarks);
      end;

      if FGetOpt.OptionPassed('Comments', Param) then begin
        VersionInfo.Comments := UnquoteStr(Param);
        WriteLn('Setting Comments to ', VersionInfo.Comments);
      end;

      if FGetOpt.OptionPassed('SvnRevision', Param) then begin
        //*** add a svn revision as integer ("0" if not a number)
        VersionInfo.SCMRevision := IntToStr(StrToIntDef(UnquoteStr(Param), 0));
        WriteLn('Setting SCMRevision to ', VersionInfo.SCMRevision);
      end;

      if FGetOpt.OptionPassed('GitRevision', Param) then begin
        //*** gitRevision overwrites the svn revision
        VersionInfo.SCMRevision := UnquoteStr(Param);
        WriteLn('Setting SCMRevision to ', VersionInfo.SCMRevision);
      end;

      if FGetOpt.OptionPassed('BuildDateTime', Param) then begin
        VersionInfo.BuildDateTime := UnquoteStr(Param);
        WriteLn('Setting BuildDateTime to ', VersionInfo.BuildDateTime);
      end;

      if FGetOpt.OptionPassed('IsPrivateBuild', Param) then begin
        VersionInfo.IsPrivateBuild := StrToBool(UnquoteStr(Param));
        WriteLn('Setting IsPrivateBuild to ', VersionInfo.IsPrivateBuild);
      end;

      if FGetOpt.OptionPassed('IsSpecialBuild', Param) then begin
        VersionInfo.IsSpecialBuild := StrToBool(UnquoteStr(Param));
        WriteLn('Setting IsSpecialBuild to ', VersionInfo.IsSpecialBuild);
      end;

      if FGetOpt.OptionPassed('PrivateBuild', Param) then begin
        VersionInfo.PrivateBuildComments := UnquoteStr(Param);
        WriteLn('Setting PrivateBuildComments to ', VersionInfo.PrivateBuildComments);
      end;

      if FGetOpt.OptionPassed('SpecialBuild', Param) then begin
        VersionInfo.SpecialBuildComments := UnquoteStr(Param);
        WriteLn('Setting SpecialBuildComments to ', VersionInfo.SpecialBuildComments);
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
        VerInfoAccess := Tdm_DProjVersionInfo.Create(Param);
        WriteLn('Updating ', VerInfoAccess.VerInfoFilename);
        VerInfoAccess.WriteToFile(VersionInfo);
      end;

      if FGetOpt.OptionPassed('InputManifest', Param) then begin
        InputManifest := UnquoteStr(Param);
      end else
        InputManifest := '';

      if FGetOpt.OptionPassed('Manifest', Param) then begin
        Manifest := Param;
      end else
        Manifest := '';

      if FGetOpt.OptionPassed('IgnoreManifestErrors') then
        IgnoreManifestErrors := True
      else
        IgnoreManifestErrors := False;

      if FGetOpt.OptionPassed('UpdateManifest') then begin
        try
          if InputManifest <> '' then
            WriteLn('Reading manifest from ', InputManifest);
          VerInfoAccess := Tdm_ManifestVersionInfo.Create(Manifest, InputManifest);
          WriteLn('Updating ', VerInfoAccess.VerInfoFilename);
          VerInfoAccess.WriteToFile(VersionInfo);
        except
          on e: Exception do begin
            if IgnoreManifestErrors then
              WriteLn('Warning: Ignoring manifest error: ', e.Message, '(', e.ClassName, ')')
            else
              raise;
          end;
        end;
      end;

      if FGetOpt.OptionPassed('WriteManifestRc', Param) then begin
        WriteMainfestRcFile(Param, Manifest);
      end;

      if FGetOpt.OptionPassed('Icon', IconFile) then begin
        IconFile := UnquoteStr(IconFile);
        WriteLn('Adding icon to rcfile from ', IconFile);
      end else
        IconFile := '';

      if FGetOpt.OptionPassed('WriteRc', Param) then begin
        Param := UnquoteStr(Param);
        WriteRcFile(Param, VersionInfo, IconFile);
      end;

      if FGetOpt.OptionPassed('Exec', Param) then begin
        Param := UnquoteStr(Param);
        WriteLn('Executing ', Param);
        Flush(Output);
        HandleExecOption(Param, VersionInfo, Project);
      end;

    finally
      FreeAndNil(VersionInfo);
    end;
    Result := 0;
  except
    on e: EAbort do begin
      raise;
    end;
    on e: Exception do begin
      s := 'Error: ' + e.Message + ' (' + e.ClassName + ')';
      WriteLn(s);
      Result := 1;
    end;
  end;
end;

procedure TPrepBuildMain.InitCmdLineParser;
begin
  inherited;
  FGetOpt.RegisterOption('dumpcmd', _('dump the commandline and exit (for debug purposes)'), False);

  FGetOpt.RegisterOption('ReadDof', _('read a .dof file to get the version information'), True);
  FGetOpt.RegisterOption('ReadBdsproj', _('read a .bdsproj file to get the version information'), True);
  FGetOpt.RegisterOption('ReadIni', _('read a .ini file to get the version information'), True);
  FGetOpt.RegisterOption('ReadDproj', _('Read a .dproj file to get the version information'), True);

  FGetOpt.RegisterOption('MajorVer', _('set the major version number (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('MinorVer', _('set the minor version number (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('Release', _('set the release number (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('Build', _('set the build number (overwrites value from -ReadXxx option)'), True);

  FGetOpt.RegisterOption('FileDesc', _('set the file description (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('InternalName', _('set the internal name (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('OriginalName', _('set the original file name (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('Product', _('set the product name (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('ProductVersion', _('set the product version (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('Company', _('set the company name (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('Copyright', _('set the legal copyright (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('Trademark', _('set the legal trademark (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('Comments', _('set the comments (overwrites value from -ReadXxx option)'), True);

  FGetOpt.RegisterOption('SvnRevision', _('set the Revision (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('GitRevision', _('set the Revision (overwrites value from SvnRevision and -ReadXxx option)'), True);
  FGetOpt.RegisterOption('BuildDateTime', _('set the BuildDateTime (overwrites value from -ReadXxx option)'), True);

  FGetOpt.RegisterOption('IsPrivateBuild', _('set the private build flag (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('IsSpecialBuild', _('set the special build flag (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('PrivateBuild', _('set the private build comments (overwrites value from -ReadXxx option)'), True);
  FGetOpt.RegisterOption('SpecialBuild', _('set the special build comments (overwrites value from -ReadXxx option)'), True);

  FGetOpt.RegisterOption('IncBuild', _('increment the build number'), False);

  FGetOpt.RegisterOption('UpdateDof', _('update a .dof file with the version information'), True);
  FGetOpt.RegisterOption('UpdateBdsproj', _('update a .bdsproj file with the version information'), True);
  FGetOpt.RegisterOption('UpdateIni', _('update a .ini file with the version information'), True);
  FGetOpt.RegisterOption('UpdateDproj', _('update a .dproj file with the version information'), True);

  FGetOpt.RegisterOption('InputManifest', _('read the contents for the .manifest for the UpdateManifest option from this file'), True);
  FGetOpt.RegisterOption('Manifest', _('Name of the .manifest file for the UpdateManifest and WriteManifestRc options'), True);
  FGetOpt.RegisterOption('UpdateManifest', _('update the .manifest file (given with the Manifest option) with the version information'));
  FGetOpt.RegisterOption('IgnoreManifestErrors', _('ignore any errors caused by the UpdateManifest option'));
  FGetOpt.RegisterOption('WriteManifestRc', _('Write an .rc file for embedding the .manifest file given with the Manifest option'), True);

  FGetOpt.RegisterOption('Icon', _('Assign an icon file to add to the .rc file'), True);

  FGetOpt.RegisterOption('WriteRc', _('write version info to a .rc file'), True);

  FGetOpt.RegisterOption('Exec', _('execute the given program or script with extended environment'), True);
end;

initialization
  MainClass := TPrepBuildMain;
end.

