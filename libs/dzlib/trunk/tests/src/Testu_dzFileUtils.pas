unit Testu_dzFileUtils;

interface

uses
  Windows,
  Classes,
  SysUtils,
  TestFramework,
  u_dzFileUtils,
  u_dzUnitTestUtils;

type
  TFileSystemTestCase = class(TdzTestCase)
  protected
    FTestDir: string;
    procedure SetUp; override;
    procedure TearDown; override;
    function CreateTestFile(const _Filename, _Content: string): string;
    procedure CheckTestfile(const _Filename, _Content: string);
    procedure CheckSubdirExists(const _Dirname: string);
  end;

type
  TestTFileSystem = class(TFileSystemTestCase)
  private
    FCallbackCount: integer;
    FSourceFile: string;
    FDestFile: string;
    procedure ProgressContinue(_Status: TCopyProgressStatus;
      var _Continue: TCopyProgressStatus.TProgressResult);
    procedure ProgressCancel(_Status: TCopyProgressStatus;
      var _Continue: TCopyProgressStatus.TProgressResult);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCopyFileWithProgressContinue;
    procedure TestCopyFileWithProgressCancel;
    procedure TestMoveFileWithProgressCancel;
  end;

  TestTDirectorySync = class(TFileSystemTestCase)
  private
    FLargeContent: string;
    FDirA: string;
    FDirB: string;
    FSync: TDirectorySync;
    FFile1: string;
    FFile2: string;
    FFile3: string;
    FFile4: string;
    FFile5: string;
    FFile6: string;
    FFileA7: string;
    FFileB7: string;
    FCallbacks: TStringList;
    FExistingFiles: TStringList;
    procedure OnSyncDirAbort(_Sender: TObject; const _Src, _Dst: string);
    procedure OnDirSyncCallback(_Sender: TObject; const _Src, _Dst: string);
    procedure OnFileSyncCallback(_Sender: TObject; const _Src, _Dst: string; _Total, _Done: Int64);
    procedure OnFileExistsCallback(_Sender: TObject; const _SrcFile, _DstFile: TFileInfoRec; var _Action: TFileExistsAction);
    procedure CheckSameText(const _Expected, _Actual, _Msg: string);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSyncOneWay;
    procedure TestSyncBoth;
    procedure TestSyncAbortImmediately;
    procedure TestSyncOneWayCallback;
    procedure TestCheckOneWay;
  end;

  TestTFileGenerationHandler_Base = class(TFileSystemTestCase)
  private
    FHandler: TFileGenerationHandler;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber_NotKeep = class(TestTFileGenerationHandler_Base)
  published
    procedure TestNoneExisting;
    procedure TestOneExisting;
    procedure TestAllExisting;
  end;

  TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber_Keep = class(TestTFileGenerationHandler_Base)
  published
    procedure TestNoneExisting;
    procedure TestOneExisting;
    procedure TestAllExisting;
  end;

  TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_NotKeep = class(TestTFileGenerationHandler_Base)
  protected
    procedure SetUp; override;
  published
    procedure TestNoneExisting;
    procedure TestOneExisting;
    procedure TestTwoExisting;
    procedure TestAllExisting;
  end;

  TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_Keep = class(TestTFileGenerationHandler_Base)
  protected
    procedure SetUp; override;
  published
    procedure TestNoneExisting;
    procedure TestOneExisting;
    procedure TestTwoExisting;
    procedure TestAllExisting;
  end;

  TestTFileGenerationHandler_OldestIsHighest_ResultContainsNumber_NotKeep = class(TestTFileGenerationHandler_Base)
  protected
    procedure SetUp; override;
  published
    procedure TestNoneExisting;
    procedure TestOneExisting;
    procedure TestAllExisting;
  end;

  TestTFileGenerationHandler_NotOldestIsHighest_ResultContainsNumber_NotKeep = class(TestTFileGenerationHandler_Base)
  protected
    procedure SetUp; override;
  published
    procedure TestNoneExisting;
    procedure TestOneExisting;
    procedure TestAllExisting;
  end;

implementation

{ TFileSystemTestCase }

procedure TFileSystemTestCase.CheckTestfile(const _Filename, _Content: string);
var
  t: TextFile;
  s: string;
begin
  Check(FileExists(FTestDir + _Filename), _Filename + ' does not exist');
  AssignFile(t, FTestDir + _Filename);
  Reset(t);
  Read(t, s);
  Close(t);
  CheckEquals(_Content, s, 'content of file ' + _Filename);
end;

procedure TFileSystemTestCase.CheckSubdirExists(const _Dirname: string);
begin
  Check(DirectoryExists(FTestDir + _Dirname), 'directory ' + _Dirname + ' missing');
end;

function TFileSystemTestCase.CreateTestFile(const _Filename, _Content: string): string;
var
  t: TextFile;
begin
  Result := FTestDir + _Filename;
  AssignFile(t, Result);
  Rewrite(t);
  WriteLn(t, _Content);
  Close(t);
end;

procedure TFileSystemTestCase.SetUp;
begin
  inherited;
  FTestDir := itpd(TFileSystem.CreateUniqueDirectory());
end;

procedure TFileSystemTestCase.TearDown;
begin
  TFileSystem.DelDirTree(FTestDir);
  inherited;
end;

const
  GENERATION_FILENAME = 'hallo';
  GENERATION_SUFFIX = '.txt';

{ TestTFileSystem }

procedure TestTFileSystem.ProgressCancel(_Status: TCopyProgressStatus;
  var _Continue: TCopyProgressStatus.TProgressResult);
begin
  _Continue := prCancel;
  Inc(FCallbackCount);
end;

procedure TestTFileSystem.ProgressContinue(_Status: TCopyProgressStatus;
  var _Continue: TCopyProgressStatus.TProgressResult);
begin
  _Continue := prContinue;
  Inc(FCallbackCount);
end;

procedure TestTFileSystem.SetUp;
const
  SOURCEFILE = 'sourcefile.txt';
  DESTFILE = 'destfile.txt';
begin
  inherited;
  FCallbackCount := 0;
  FSourceFile := CreateTestFile(SOURCEFILE, 'source');
  FDestFile := FTestDir + DESTFILE;
  if FileExists(FDestFile) then
    TFileSystem.DeleteFile(FDestFile);
end;

procedure TestTFileSystem.TearDown;
begin
  inherited;
  TFileSystem.DeleteFile(FSourceFile, false);
  TFileSystem.DeleteFile(FDestFile, false);
end;

procedure TestTFileSystem.TestCopyFileWithProgressContinue;
var
  Res: TFileSystem.TCopyFileWithProgressResult;
begin
  Res := TFileSystem.CopyFileWithProgress(FSourceFile, FDestFile, ProgressContinue);
  Check(Res = cfwOK, 'aborted or error');
  CheckTrue(FileExists(FDestFile), 'destination file missing');
  CheckEquals(2, FCallbackCount, 'Callback count wrong');
end;

procedure TestTFileSystem.TestMoveFileWithProgressCancel;
var
  Res: TFileSystem.TCopyFileWithProgressResult;
begin
  Res := TFileSystem.MoveFileWithProgress(FSourceFile, FDestFile, ProgressCancel, []);
  // Note: This move operation does not get cancelled because the file can be
  // renamed rather than copied and deleted. In that case the callback function
  // is never being called.
  Check(Res = cfwOK, 'OK expected');
  CheckTrue(FileExists(FDestFile), 'destination file exists');
end;

procedure TestTFileSystem.TestCopyFileWithProgressCancel;
var
  Res: TFileSystem.TCopyFileWithProgressResult;
begin
  Res := TFileSystem.CopyFileWithProgress(FSourceFile, FDestFile, ProgressCancel, []);
  Check(Res = cfwAborted, 'aborted expected');
  CheckEquals(1, FCallbackCount, 'Callback count wrong');
end;

{ TestTFileGenerationHandler_Base }

procedure TestTFileGenerationHandler_Base.SetUp;
begin
  inherited;
  FHandler := TFileGenerationHandler.Create(FTestDir + GENERATION_FILENAME, GENERATION_SUFFIX);
end;

procedure TestTFileGenerationHandler_Base.TearDown;
begin
  FHandler.Free;
  inherited;
end;

{ TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber }

procedure TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber_NotKeep.TestAllExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '1');
  CreateTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '2');
  CreateTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '3');
  CreateTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '4');
  CreateTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '5');
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  CheckTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '2');
  CheckTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '3');
  CheckTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '4');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_5' + GENERATION_SUFFIX), 'additional backup file exists');
end;

procedure TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber_NotKeep.TestNoneExisting;
var
  s: string;
begin
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
end;

procedure TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber_NotKeep.TestOneExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '1');
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_2' + GENERATION_SUFFIX), 'additional backup file exists');
end;

{ TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber_Keep }

procedure TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber_Keep.TestAllExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '1');
  CreateTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '2');
  CreateTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '3');
  CreateTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '4');
  CreateTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '5');
  s := FHandler.Execute(True);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '1');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  CheckTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '2');
  CheckTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '3');
  CheckTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '4');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_5' + GENERATION_SUFFIX), 'additional backup file exists');
end;

procedure TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber_Keep.TestNoneExisting;
var
  s: string;
begin
  s := FHandler.Execute(true);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
end;

procedure TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber_Keep.TestOneExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '1');
  s := FHandler.Execute(true);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '1');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_2' + GENERATION_SUFFIX), 'additional backup file exists');
end;

{ TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber }

procedure TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_NotKeep.SetUp;
begin
  inherited;
  FHandler.OldestIsHighest := false;
end;

procedure TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_NotKeep.TestAllExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '5');
  CreateTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '4');
  CreateTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '3');
  CreateTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '2');
  CreateTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '2');
  CheckTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '3');
  CheckTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '4');
  CheckTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '5');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_5' + GENERATION_SUFFIX), 'additional backup file exists');
end;

procedure TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_NotKeep.TestNoneExisting;
var
  s: string;
begin
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
end;

procedure TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_NotKeep.TestOneExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '1');
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_2' + GENERATION_SUFFIX), 'additional backup file exists');
end;

procedure TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_NotKeep.TestTwoExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '2');
  CreateTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  CheckTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '2');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_3' + GENERATION_SUFFIX), 'additional backup file exists');
end;

{ TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_Keep }

procedure TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_Keep.SetUp;
begin
  inherited;
  FHandler.OldestIsHighest := false;
end;

procedure TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_Keep.TestAllExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '5');
  CreateTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '4');
  CreateTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '3');
  CreateTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '2');
  CreateTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  s := FHandler.Execute(true);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '5');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '2');
  CheckTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '3');
  CheckTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '4');
  CheckTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '5');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_5' + GENERATION_SUFFIX), 'additional backup file exists');
end;

procedure TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_Keep.TestNoneExisting;
var
  s: string;
begin
  s := FHandler.Execute(true);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
end;

procedure TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_Keep.TestOneExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '1');
  s := FHandler.Execute(true);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '1');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_2' + GENERATION_SUFFIX), 'additional backup file exists');
end;

procedure TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_Keep.TestTwoExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '2');
  CreateTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  s := FHandler.Execute(true);
  CheckEquals(FTestDir + GENERATION_FILENAME + GENERATION_SUFFIX, s, 'filename');
  CheckTestfile(GENERATION_FILENAME + GENERATION_SUFFIX, '2');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  CheckTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '2');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_3' + GENERATION_SUFFIX), 'additional backup file exists');
end;

{ TestTFileGenerationHandler_OldestIsHighest_ResultContainsNumber }

procedure TestTFileGenerationHandler_OldestIsHighest_ResultContainsNumber_NotKeep.SetUp;
begin
  inherited;
  FHandler.ResultContainsNumber := true;
end;

procedure TestTFileGenerationHandler_OldestIsHighest_ResultContainsNumber_NotKeep.TestAllExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '2');
  CreateTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '3');
  CreateTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '4');
  CreateTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '5');
  CreateTestfile(GENERATION_FILENAME + '_5' + GENERATION_SUFFIX, '6');
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
  CheckTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '2');
  CheckTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '3');
  CheckTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '4');
  CheckTestfile(GENERATION_FILENAME + '_5' + GENERATION_SUFFIX, '5');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_6' + GENERATION_SUFFIX), 'additional backup file exists');
end;

procedure TestTFileGenerationHandler_OldestIsHighest_ResultContainsNumber_NotKeep.TestNoneExisting;
var
  s: string;
begin
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
end;

procedure TestTFileGenerationHandler_OldestIsHighest_ResultContainsNumber_NotKeep.TestOneExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
  CheckTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '1');
end;

{ TestTFileGenerationHandler_NotOldestIsHighest_ResultContainsNumber }

procedure TestTFileGenerationHandler_NotOldestIsHighest_ResultContainsNumber_NotKeep.SetUp;
begin
  inherited;
  FHandler.OldestIsHighest := false;
  FHandler.ResultContainsNumber := true;
end;

procedure TestTFileGenerationHandler_NotOldestIsHighest_ResultContainsNumber_NotKeep.TestAllExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  CreateTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '2');
  CreateTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '3');
  CreateTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '4');
  CreateTestfile(GENERATION_FILENAME + '_5' + GENERATION_SUFFIX, '5');
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + '_5' + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '2');
  CheckTestfile(GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, '3');
  CheckTestfile(GENERATION_FILENAME + '_3' + GENERATION_SUFFIX, '4');
  CheckTestfile(GENERATION_FILENAME + '_4' + GENERATION_SUFFIX, '5');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_6' + GENERATION_SUFFIX), 'additional backup file exists');
end;

procedure TestTFileGenerationHandler_NotOldestIsHighest_ResultContainsNumber_NotKeep.TestNoneExisting;
var
  s: string;
begin
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
end;

procedure TestTFileGenerationHandler_NotOldestIsHighest_ResultContainsNumber_NotKeep.TestOneExisting;
var
  s: string;
begin
  CreateTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  s := FHandler.Execute(false);
  CheckEquals(FTestDir + GENERATION_FILENAME + '_2' + GENERATION_SUFFIX, s, 'filename');
  CheckFalse(FileExists(s), 'file exists');
  CheckTestfile(GENERATION_FILENAME + '_1' + GENERATION_SUFFIX, '1');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_3' + GENERATION_SUFFIX), 'additional backup file exists');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_4' + GENERATION_SUFFIX), 'additional backup file exists');
  CheckFalse(FileExists(FTestDir + GENERATION_FILENAME + '_5' + GENERATION_SUFFIX), 'additional backup file exists');
end;

{ TestTDirectorySync }

procedure TestTDirectorySync.SetUp;
begin
  inherited;
  FDirA := FTestDir + 'a\';
  FDirB := FTestDir + 'b\';
  TFileSystem.CreateDir(FDirA);
  TFileSystem.CreateDir(FDirB);

  FLargeContent := StringOfChar('a', 5 * 1024 * 1024);

  FFile1 := CreateTestfile('a\file1.txt', 'File1');
  FFile2 := CreateTestfile('a\.txt', 'File2');
  FFile3 := CreateTestfile('a\file3', FLargeContent);
  TFileSystem.CreateDir(FDirA + '\Sub1');
  TFileSystem.CreateDir(FDirA + '\Sub2');
  FFile4 := CreateTestfile('a\Sub2\file4.txt', 'File4');

  FFile5 := CreateTestFile('b\file5.txt', 'File5');
  TFileSystem.CreateDir(FDirB + '\Sub3');
  FFile6 := CreateTestFile('b\sub3\file6.txt', 'File6');
  TFileSystem.CreateDir(FDirB + '\Sub4');

  TFileSystem.CreateDir(FDirA + '\Sub5');
  TFileSystem.CreateDir(FDirB + '\Sub5');

  TFileSystem.CreateDir(FDirA + '\Sub6');
  TFileSystem.CreateDir(FDirB + '\Sub6');
  FFileA7 := CreateTestFile('a\sub6\file7.txt', 'FileA7');
  FFileB7 := CreateTestFile('b\sub6\file7.txt', 'FileB7');

  FCallbacks := TStringList.Create;

  FSync := TDirectorySync.Create;
end;

procedure TestTDirectorySync.TearDown;
begin
  FSync.Free;
  FCallbacks.Free;
  inherited;
end;

procedure TestTDirectorySync.TestSyncOneWay;
var
  Enum: TSimpleDirEnumerator;
  Files: TStringList;
  cnt: integer;
begin
  FSync.SyncOneWay(FDirA, FDirB);
  Enum := TSimpleDirEnumerator.Create(FDirB + '*.*');
  try
    Files := TStringList.Create;
    cnt := Enum.FindAll(Files);
    Files.Free;
  finally
    Enum.Free;
  end;
  CheckEquals(10, cnt, 'number of files and subdirs');
  CheckTestfile('b\' + ExtractFileName(FFile1), 'File1');
  CheckTestfile('b\' + ExtractFileName(FFile2), 'File2');
  CheckTestfile('b\' + ExtractFileName(FFile3), FLargeContent);
  CheckSubdirExists('b\Sub1');
  CheckSubdirExists('b\Sub2');
  CheckTestfile('b\Sub2\' + ExtractFileName(FFile4), 'File4');
  CheckTestfile('b\' + ExtractFileName(FFile5), 'File5');
  CheckSubdirExists('b\Sub3');
  CheckTestfile('b\Sub3\' + ExtractFileName(FFile6), 'File6');
  CheckSubdirExists('b\Sub4');

  CheckSubdirExists('b\Sub5');
  CheckSubdirExists('b\Sub6');
  CheckTestfile('b\Sub6\' + ExtractFileName(FFileB7), 'FileB7');
end;

procedure TestTDirectorySync.TestSyncOneWayCallback;
var
  Expected: TStringList;
  i: Integer;
begin
  FSync.OnSyncingDir := OnDirSyncCallback;
  FSync.OnSyncingFile := OnFileSyncCallback;
  FSync.SyncOneWay(FDirA, FDirB);

  Expected := TStringList.Create;
  try
    Expected.Add(FDirA + ' -> ' + FDirB);
    Expected.Add(FDirA + '.txt -> ' + FDirB + '.txt (0 of 7)');
    Expected.Add(FDirA + '.txt -> ' + FDirB + '.txt (7 of 7)');
    Expected.Add(FDirA + 'file1.txt -> ' + FDirB + 'file1.txt (0 of 7)');
    Expected.Add(FDirA + 'file1.txt -> ' + FDirB + 'file1.txt (7 of 7)');
    for i := 0 to 80 do
      Expected.Add(FDirA + 'file3 -> ' + FDirB + Format('file3 (%d of 5242882)', [i * 65536]));
    Expected.Add(FDirA + 'file3 -> ' + FDirB + 'file3 (5242882 of 5242882)');
    Expected.Add(FDirA + 'Sub1 -> ' + FDirB + 'Sub1');
    Expected.Add(FDirA + 'Sub2 -> ' + FDirB + 'Sub2');
    Expected.Add(FDirA + 'Sub2\file4.txt -> ' + FDirB + 'Sub2\file4.txt (0 of 7)');
    Expected.Add(FDirA + 'Sub2\file4.txt -> ' + FDirB + 'Sub2\file4.txt (7 of 7)');
    Expected.Add(FDirA + 'Sub5 -> ' + FDirB + 'Sub5');
    Expected.Add(FDirA + 'Sub6 -> ' + FDirB + 'Sub6');
    CheckEqualsMultiline(Expected.Text, FCallbacks.Text);
  finally
    Expected.Free;
  end;
end;

procedure TestTDirectorySync.OnDirSyncCallback(_Sender: TObject; const _Src, _Dst: string);
begin
  FCallbacks.Add(_Src + ' -> ' + _Dst);
end;

procedure TestTDirectorySync.OnFileSyncCallback(_Sender: TObject; const _Src, _Dst: string; _Total, _Done: Int64);
begin
  FCallbacks.Add(_Src + ' -> ' + _Dst + ' (' + IntToStr(_Done) + ' of ' + IntToStr(_Total) + ')');
end;

procedure TestTDirectorySync.OnSyncDirAbort(_Sender: TObject; const _Src, _Dst: string);
begin
  SysUtils.Abort;
end;

procedure TestTDirectorySync.CheckSameText(const _Expected, _Actual, _Msg: string);
begin
  if not SameText(_Expected, _Actual) then
    FailNotEquals(_Expected, _Actual, _Msg);
end;

procedure TestTDirectorySync.OnFileExistsCallback(_Sender: TObject; const _SrcFile, _DstFile: TFileInfoRec; var _Action: TFileExistsAction);
begin
  FExistingFiles.Add(_SrcFile.Filename + ' <> ' + _DstFile.Filename);
  CheckEquals(_SrcFile.Size, _DstFile.Size, 'Size');
  CheckEquals(_SrcFile.Timestamp, _DstFile.Timestamp, 'Timestamp');
end;

procedure TestTDirectorySync.TestCheckOneWay;
begin
  FExistingFiles := TStringList.Create;
  try
    FSync.OnFileExists := OnFileExistsCallback;
    FSync.CheckOneWay(FDirA, FDirB);
    CheckEquals(1, FExistingFiles.Count, 'existing count');
    CheckSameText(FFileA7 + ' <> ' + FFileB7, FExistingFiles[0], 'File7');
  finally
    FExistingFiles.Free;
  end;
end;

procedure TestTDirectorySync.TestSyncAbortImmediately;
var
  Enum: TSimpleDirEnumerator;
  Files: TStringList;
  cnt: integer;
begin
  FSync.OnSyncingDir := OnSyncDirAbort;
  try
    FSync.SyncOneWay(FDirA, FDirB);
  except on EAbort do
      ;
  end;
  Enum := TSimpleDirEnumerator.Create(FDirB + '*.*');
  try
    Files := TStringList.Create;
    cnt := Enum.FindAll(Files);
    Files.Free;
  finally
    Enum.Free;
  end;
  CheckEquals(5, cnt, 'number of files and subdirs');
end;

procedure TestTDirectorySync.TestSyncBoth;
var
  Enum: TSimpleDirEnumerator;
  Files: TStringList;
  cnt: integer;
begin
  FSync.SyncBothWays(FDirA, FDirB);

  Enum := TSimpleDirEnumerator.Create(FDirB + '*.*');
  try
    Files := TStringList.Create;
    cnt := Enum.FindAll(Files);
    Files.Free;
  finally
    Enum.Free;
  end;
  CheckEquals(10, cnt, 'number of files and subdirs');
  CheckTestfile('b\' + ExtractFileName(FFile1), 'File1');
  CheckTestfile('b\' + ExtractFileName(FFile2), 'File2');
  CheckTestfile('b\' + ExtractFileName(FFile3), FLargeContent);
  CheckSubdirExists('b\Sub1');
  CheckSubdirExists('b\Sub2');
  CheckTestfile('b\Sub2\' + ExtractFileName(FFile4), 'File4');
  CheckTestfile('b\' + ExtractFileName(FFile5), 'File5');
  CheckSubdirExists('b\Sub3');
  CheckTestfile('b\Sub3\' + ExtractFileName(FFile6), 'File6');
  CheckSubdirExists('b\Sub4');

  CheckSubdirExists('b\Sub5');
  CheckSubdirExists('b\Sub6');
  CheckTestfile('b\Sub6\' + ExtractFileName(FFileB7), 'FileB7');

  Enum := TSimpleDirEnumerator.Create(FDirA + '*.*');
  try
    Files := TStringList.Create;
    cnt := Enum.FindAll(Files);
    Files.Free;
  finally
    Enum.Free;
  end;
  CheckEquals(10, cnt, 'number of files and subdirs');
  CheckTestfile('a\' + ExtractFileName(FFile1), 'File1');
  CheckTestfile('a\' + ExtractFileName(FFile2), 'File2');
  CheckTestfile('a\' + ExtractFileName(FFile3), FLargeContent);
  CheckSubdirExists('a\Sub1');
  CheckSubdirExists('a\Sub2');
  CheckTestfile('a\Sub2\' + ExtractFileName(FFile4), 'File4');
  CheckTestfile('a\' + ExtractFileName(FFile5), 'File5');
  CheckSubdirExists('a\Sub3');
  CheckTestfile('a\Sub3\' + ExtractFileName(FFile6), 'File6');
  CheckSubdirExists('a\Sub4');

  Check(DirectoryExists(FDirA + 'Sub5'), 'directory Sub5 missing');
  Check(DirectoryExists(FDirA + 'Sub6'), 'directory Sub6 missing');
  CheckTestfile('a\Sub6\' + ExtractFileName(FFileB7), 'FileA7');
end;

initialization
  RegisterTest('FileUtils', TestTFileSystem.Suite);
  RegisterTest('FileUtils\Generations', TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber_NotKeep.Suite);
  RegisterTest('FileUtils\Generations', TestTFileGenerationHandler_OldestIsHighest_NotResultContainsNumber_Keep.Suite);
  RegisterTest('FileUtils\Generations', TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_NotKeep.Suite);
  RegisterTest('FileUtils\Generations', TestTFileGenerationHandler_NotOldestIsHighest_NotResultContainsNumber_Keep.Suite);
  RegisterTest('FileUtils\Generations', TestTFileGenerationHandler_OldestIsHighest_ResultContainsNumber_NotKeep.Suite);
  RegisterTest('FileUtils\Generations', TestTFileGenerationHandler_NotOldestIsHighest_ResultContainsNumber_NotKeep.Suite);
  RegisterTest('FileUtils', TestTDirectorySync.Suite);
end.

