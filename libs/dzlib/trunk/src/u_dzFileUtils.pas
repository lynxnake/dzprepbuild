{.GXFormatter.config=twm}
/// <summary>
/// implements utility functions for file accesss
/// </summary>
unit u_dzFileUtils;

{$I jedi.inc}

interface

uses
  Windows,
  SysUtils,
  Classes,
  u_dzTranslator;

type
  EFileUtils = class(Exception);
  ECreateUniqueDir = class(EFileUtils);
  /// <summary>
  /// raised by DelTree if the DirName parameter is not a valid directory name
  /// </summary>
  EDirNotFound = class(EFileUtils);
  EPathTooLong = class(EFileUtils);
  EInvalidPropertyCombination = class(EFileUtils);
  EFileNotFound = class(EFileUtils);

type
  TFileAttributes = (
    dfaReadonly,
    dfaHidden, // Hidden files
    dfaSysFile, //	System files
    dfaVolumeID, //	Volume ID files
    dfaDirectory, //	Directory files
    dfaArchive // Archive files
    );

  TFileAttributeSet = set of TFileAttributes;

  TFileInfoRec = record
  public
    Filename: string;
    Size: Int64;
    Timestamp: TDateTime;
  end;

type
  /// <summary>
  /// a simple wrapper around FindFirst/FindNext which allows to search for
  /// specified attributes only (e.g. only directories), it automatically
  /// ignores the special '.' and '..' directories.
  /// </summary>
  TSimpleDirEnumerator = class
  protected
    /// stores the search mask ('c:\windows\*.exe')
    FMask: string;
    /// set of attributes a file must match
    FMustHaveAttr: TFileAttributeSet;
    /// set of attributes a file may have
    FMayHaveAttr: TFileAttributeSet;
    /// internally used TSearchRec structure
    FSr: TSearchRec;
    /// true if FindFirst was called and returned no error code
    FActive: boolean;
    /// number of matching files found
    FMatchCount: integer;
  public
    /// <summary>
    /// Creates a TSimpleDirEnumerator, sets the Mask, MustHaveAttr and MayHaveAttr
    /// properties.
    /// MustHaveAttr is set to [] and MayHaveAttr is set to include all possible
    /// attributes, so calling FindNext will find any files or subdirectories,
    /// but the special '.' and '..' directories
    /// @param Mask is the file search mask and should include a path
    /// </summary>
    constructor Create(const _Mask: string; _MayHaveAttr: TFileAttributeSet =
      [dfaHidden, dfaSysFile, dfaVolumeID, dfaDirectory, dfaArchive]);
    /// <summary>
    /// Destructor, will call FindClose if necessary
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    /// creates a TSimpleDirEnumerator, calls its FindAll method and frees it
    /// @param IncludePath determines whether the List of filenames includes the full path or not
    /// </summary>
    class function Execute(const _Mask: string; _List: TStrings;
      _MayHaveAttr: TFileAttributeSet = [dfaHidden, dfaSysFile, dfaVolumeID, dfaDirectory, dfaArchive];
      _IncludePath: boolean = False): integer;
    /// <summary>
    /// Calls SysUtils.FindFirst on first call and SysUtls.FindNext in later
    /// calls.
    /// @param Filename is the name of the file found, if result is true, if you need
    ///       more information about it, use the SR property, note that it
    ///       does not include the path
    /// @Returns true, if a matching file was found, false otherwise
    /// </summary>
    function FindNext(out _Filename: string): boolean; overload;
    /// <summary>
    /// Calls SysUtils.FindFirst on first call and SysUtls.FindNext in later
    /// calls. If it returns true, use the SR property to get information about
    /// the file. See the overloaded @link(FindNext) version if you need only
    /// the filename.
    /// @Returns true, if a matching file was found, false otherwise
    /// </summary>
    function FindNext: boolean; overload;
    /// <summary>
    /// Calls FindNext until it returns false, stores all filenames in List and
    /// returns the number of files found.
    /// @param List is a TStrings object which will be filled with the filenames
    ///        of matching files, may be nil.
    /// @param IncludePath determines whether the List of filenames includes the full path or not
    /// @returns the number of matching files
    /// </summary>
    function FindAll(_List: TStrings = nil; _IncludePath: boolean = false): integer;
    /// <summary>
    /// Calls FindClose so FindNext will start again. Reset does not change any
    /// properties (e.g. Mask, MustHaveAttr, MayHaveAttr)
    /// </summary>
    procedure Reset;
    /// <summary>
    /// Returns the number of matches so far, that is the number of successful
    /// calls to FindNext
    /// </summary>
    property MatchCount: integer read FMatchCount;
    /// <summary>
    /// Returns the search mask
    /// </summary>
    property Mask: string read FMask; // write fMask;
    /// <summary>
    /// the set of attributes a file must have to be found by FindNext
    /// </summary>
    property MustHaveAttr: TFileAttributeSet read FMustHaveAttr write FMustHaveAttr;
    /// <summary>
    /// the set of allowed attributes for a file to be found by FindNext
    /// </summary>
    property MayHaveAttr: TFileAttributeSet read FMayHaveAttr write FMayHaveAttr;
    /// <summary>
    /// the search rec containing additional information about the file
    /// </summary>
    property Sr: TSearchRec read FSr;
  end;

type
  /// <summary>
  /// Represents the status of a CopyFile/MoveFileWithProgress operation, passed
  /// as parameter to the callback function.
  /// </summary>
  TCopyProgressStatus = class
  public
  {(*}
  type
    /// <summary>
    /// possible return values for the callback function
    /// </summary>
    TProgressResult = (
      prContinue, // continue with the copy/move operation
      prCancel,   // cancel the operation, cannot be resumed
      prStop,     // stop the operation, can be resumed, if cfwRestartable was passed
      prQuiet);   // continue the operation, do not call the callback
    /// <summary>
    /// reason for calling the callback function
    /// </summary>
    TProgressReason = (
      prChunkFinished, // a chunk of the file has been copied
      prStreamSwitch); // started to copy a new stream (set in the first callback)
  {*)}
  protected
    FTotalFileSize: LARGE_INTEGER;
    FTotalBytesTransferred: LARGE_INTEGER;
    FStreamSize: LARGE_INTEGER;
    FStreamBytesTransferred: LARGE_INTEGER;
    FStreamNumber: LongWord;
    FCallbackReason: TProgressReason;
    FSourceFile: THandle;
    FDestinationFile: THandle;
  public
    /// <summary>
    /// total size of the file
    /// </summary>
    property TotalFileSize: LARGE_INTEGER read FTotalFileSize;
    /// <summary>
    /// total bytes that have been transferred so far
    /// </summary>
    property TotalBytesTransferred: LARGE_INTEGER read FTotalBytesTransferred;
    /// <summary>
    /// size of the stream that is currently being transferred
    /// </summary>
    property StreamSize: LARGE_INTEGER read FStreamSize;
    /// <summary>
    /// bytes of the current stream taht have been transferred so far
    /// </summary>
    property StreamBytesTransferred: LARGE_INTEGER read FStreamBytesTransferred;
    /// <summary>
    /// Number of the current stream, starts with 1 (usually always 1)
    /// </summary>
    property StreamNumber: LongWord read FStreamNumber;
    /// <summary>
    /// reason for callback
    /// </summary>
    property CallbackReason: TProgressReason read FCallbackReason;
    /// <summary>
    /// Handle of source file
    /// </summary>
    property SourceFile: THandle read FSourceFile;
    /// <summary>
    /// Handle of destination file
    /// </summary>
    property DestinationFile: THandle read FDestinationFile;
  end;

  ///<summary>
  /// Type for OnCopyFileProgress event
  ///  @param Status is the currenct status of the operation
  ///  @param Continue determines whether to continue copying or aborting, defaults
  ///         to prContinue
  /// </summary>
  TCopyFileProgressEvt = procedure(_Status: TCopyProgressStatus;
    var _Continue: TCopyProgressStatus.TProgressResult) of object;

  /// <summary>
  /// defines the action to take if a file already exists but has a different content
  /// </summary>
  TFileExistsAction = (feaIgnore, feaOverwrite);
  TQueryFileSyncAction = (fsaCopy, fsaSkip);
  TOnSyncing = procedure(_Sender: TObject; const _SrcDir, _DstDir: string) of object;
  TOnSyncingFile = procedure(_Sender: TObject; const _Source, _Dest: string; _Total, _Done: Int64) of object;

  ///<summary>
  /// called if a destination file already exists
  /// @param Action is the action to take, default is feaIgnore
  ///</summary>
  TOnFileExists = procedure(_Sender: TObject; const _SrcFile, _DstFile: TFileInfoRec;
    var _Action: TFileExistsAction) of object;

  ///<summary>
  /// Called instead of TOnFileExists if a destination file does not exist to allow filtering
  /// of e.g. file types.
  /// @param SyncIt must be set to false if the file should be skipped, default is true for copying the file
  ///</summary>
  TOnQueryFileSync = procedure(_Sender: TObject; const _SrcFile: TFileInfoRec; const _DstFile: string;
    var _Action: TQueryFileSyncAction) of object;

  /// <summary>
  /// Synchronizes two directories
  /// </summary>
  TDirectorySync = class
  private
    FCurrentSource: string;
    FCurrentDest: string;
    FOnSyncingDir: TOnSyncing;
    FOnSyncingFile: TOnSyncingFile;
    FOnFileExists: TOnFileExists;
    FOnQueryFileSync: TOnQueryFileSync;
//    FOnDifferentFileExists: TOnDifferentFileExists;
//    FCheckContent: boolean;
//    procedure doOnDifferentFileExists(const _Filename: string; var _Action: TFileExistsAction);
    procedure doOnSyncingDir(const _SrcDir, _DstDir: string);
    ///<summary>
    /// Called before once before copying a file and possible several times while it is being
    /// copied to display a progress. </summary>
    procedure doOnSyncingFile(const _SrcFile, _DstFile: string; _Total, _Done: Int64);
    function doOnFileExists(const _SrcDir, _DstDir, _Filename: string): TFileExistsAction;
    function doOnQueryFileSync(const _SrcFile, _DstFile: string): TQueryFileSyncAction;
    procedure ProgressStatusCallback(_Status: TCopyProgressStatus; var _Continue: TCopyProgressStatus.TProgressResult);
  public
    /// <summary>
    /// Checks if there are files in the source directory that are already in
    /// the destination directory, for each file that exists, the OnFileExists
    /// event is called.
    /// </summary>
    procedure CheckOneWay(const _SrcDir, _DstDir: string);
    /// <summary>
    /// copies all files from DirA to DirB if they don't already exist
    /// (not implemented: if CheckContent=true, the content existing files will be checked and if
    ///                   it doesn't match, OnDifferentFileExists is called)
    /// @param FlattenDirHierarchy determines whether all files should be copied
    ///                            directly DstDir or if subdirectories should
    ///                            be created, default is false
    /// </summary>
    procedure SyncOneWay(const _SrcDir, _DstDir: string; _FlattenDirHierarchy: boolean = false);
    /// <summary>
    /// calls SyncOneWay(DirA, DirB) and SyncOneWay(DirB, DirA)
    /// (not implemented: if CheckContent=true, the content existing files will be checked and if
    ///                   it doesn't match, OnDifferentFileExists is called)
    /// </summary>
    procedure SyncBothWays(const _DirA, _DirB: string);
//    {! Not implemented: Called, if the content of an existing file is different }
//    property OnDifferentFileExists: TOnDifferentFileExists read FOnDifferentFileExists write FOnDifferentFileExists;
//    {! Not implemented: if true, OnDifferentFileExists will be called }
//    property CheckContent: boolean read FCheckContent write FCheckContent default false;
    /// <summary>
    /// called when a new directory is entered, to abort synchronization,
    /// raise an exception (e.g. SysUtils.Abort), and catch it in the calling method
    /// </summary>
    property OnSyncingDir: TOnSyncing read FOnSyncingDir write FOnSyncingDir;
    /// <summary>
    /// called when a file is being copied, to abort synchronization,
    /// raise an exception (e.g. SysUtils.Abort), and catch it in the calling method
    /// </summary>
    property OnSyncingFile: TOnSyncingFile read FOnSyncingFile write FOnSyncingFile;
    /// <summary>
    /// called from CheckOneWay if a destination file already exists
    /// </summary>
    property OnFileExists: TOnFileExists read FOnFileExists write FOnFileExists;
    ///<summary>
    /// Called from CheckOneWay instead of OnFileExists if the destination file does not
    /// exist. This is to allow filtering on e.g. file type.
    ///</summary>
    property OnQueryFileSync: TOnQueryFileSync read FOnQueryFileSync write FOnQueryFileSync;
  end;

  IUniqueTempDir = interface ['{D9A4A428-66AE-4BBC-B1CA-22CE4DE2FACB}']
    function Path: string;
  end;

  /// <summary>
  /// This class owns all utility functions as class methods so they don't pollute the name space
  /// </summary>
  TFileSystem = class
  public
  {(*}
  type
    TCopyFileFlags = (cfFailIfExists, cfForceOverwrite, cfRaiseException);
    TCopyFileFlagSet = set of TCopyFileFlags;
    TMatchingFileResult = (mfNotFound, mfDirectory, mfFile, mfSpecial);
    TCopyFileWithProgressFlags = (cfwFailIfExists, cfwRestartable, cfwRaiseException);
    TCopyFileWithProgressFlagSet = set of TCopyFileWithProgressFlags;
    TCopyFileWithProgressResult = (cfwOK, cfwAborted, cfwError);
    TMoveFileWithProgressFlags = (
      mfwFailIfExists, /// < fail if the destination file already exists
      mfwAllowCopy,    /// < allow using copy and delete if necessary
      mfwDelayUntilReboot, /// < wait until next reboot for moving the file
      mfwWriteThrough, /// < Setting this value guarantees that a move performed as a copy and delete operation is flushed to disk before the function returns.
      mfwFailIfNotTrackable, /// < The function fails if the source file is a link source, but the file cannot be tracked after the move.
      mfwRaiseException); /// < raise an exception if there is an error
    TMoveFileWithProgressFlagSet = set of TMoveFileWithProgressFlags;
  const
    /// <summary>
    /// set of char constant containing all characters that are invalid in a filename
    /// </summary>
    INVALID_FILENAME_CHARS: set of AnsiChar = ['\', '/', ':', '*', '?', '"', '<', '>', '|'];
  {*)}
    /// <summary>
    /// Returns a temporary filename.
    /// @param Directory is a string with the directory to create the file in, defaults
    ///                  to the TEMP directory.
    /// @param Prefix is a string with a prefix for the filename, defaults to 'dz'.
    /// @param Unique is an word that the function converts to a hexadecimal string
    /// for use in creating the temporary filename.)
    /// <ul>
    ///   <li>If Unique is nonzero, the function appends the hexadecimal string to
    ///       <b>Prefix</b>
    ///       to form the temporary filename. In this case, the function does not create
    ///       the specified file, and does not test whether the filename is unique.</li>
    ///   <li>If Unique is zero, the function uses a hexadecimal string derived
    ///       from the current system time. In this case, the function uses different
    ///       values until it finds a unique filename, and then it creates the file
    ///       in the <b>Directory</b>.</li>
    /// </ul>
    /// @returns a filename to use for a temporary file.
    /// </summary>
    class function GetTempFileName(_Directory: string = ''; const _Prefix: string = 'dz';
      _Unique: word = 0): string;
//    ///<summary>
//    /// Returns a temporary filename which is ensured not to already exist before but has been created
//    /// in this call.
//    /// @param Directory is a string with the directory to create the file in, defaults
//    ///                  to the TEMP directory.
//    /// @param Prefix is a string with a prefix for the filename, defaults to 'dz'.
//    /// @param Ext is the extension for the filename, defaults to '.tmp'.
//    ///</summary>
//    class function GetTempFileNameEx(_Directory: string = ''; const _Prefix: string = 'dz';
//      const _Ext: string = '.tmp'): string;
    /// <summary>
    /// Calls the corresponding Windows function and returns the short path name
    /// for an *existing* file or directory.
    /// </summary>
    class function GetShortPathname(const _LongName: string): string;

    /// <summary>
    /// Creates a unique subdirectory under BaseDir with the given Prefix
    /// if Basedir is an empty string the system's %TEMP% directory is used.
    /// @returns the name of the created directory
    /// </summary>
    class function CreateUniqueDirectory(_BaseDir: string = ''; const _Prefix: string = 'dz'): string;
    class function CreateUniqueTempDir(_Prefix: string = 'dz'): IUniqueTempDir;

    /// <summary>
    /// Calls the Win32Api function GetTempPath but returns a string rather than
    /// a PChar.
    /// @returns a string with the TEMP directory
    /// </summary>
    class function GetTempPath: string;

    /// <summary>
    /// Moves the file Source to Dest using the Windows MoveFile function.
    /// @param Source is a string containing the name of the existing file
    /// @param Dest is a string containing the destination file name
    /// @param RaiseException is a boolean which controls whether the function
    ///        retrieves the Windows error and raises an exception
    ///        if it fails. If false, it will not raise an exception
    ///        but just return false if moving the file fails.
    /// @returns true, if the file could be moved, false otherwise.
    /// </summary>
    class function MoveFile(const _Source, _Dest: string; _RaiseException: boolean = true): boolean;

    /// <summary>
    /// Copies the file Source to Dest using the Windows CopyFile function.
    /// @param Source is a string containing the name of the existing file
    /// @param Dest is a string containing the destination file name
    /// @param FailIfExists is a boolean specifying whether the copy operation
    ///        should fail if the destination file already exists.
    /// @param RaiseException is a boolean which controls whether the function
    ///        retrieves the Windows error and raises an exception
    ///        if it fails. If false, it will not raise an exception
    ///        but just return false if copying the file fails.
    /// @param ForceOverwrite is a boolean which controls whether the function removes
    ///        a read-only flag from the destination file if necessary.
    /// @returns true, if the file could be copied, false otherwise.
    /// @raises  EOSError if an error occurs and cfwRaiseException was passed
    /// </summary>
    class function CopyFile(const _Source, _Dest: string; _FailIfExists: boolean = true;
      _RaiseException: boolean = true; _ForceOverwrite: boolean = false): boolean; overload;

    /// <summary>
    /// Copies the file Source to Dest using the Windows CopyFile function.
    /// @param Source is a string containing the name of the existing file
    /// @param Dest is a string containing the destination file name
    /// @param Flags is a set of TCopyFileFlags specifying whether the copy operation
    ///        cfFailIfExists: fail if the destination file already exists.
    ///        cfForceOverwrite: remove a read-only flag from the destination file if necessary.
    ///        cfRaiseException: retrieve the Windows error and raise an exception if it fails.
    ///          If not set, it will not raise an exception but just return false if
    ///          copying the file fails.
    /// @returns true, if the file could be copied, false otherwise.
    /// @raises  EOSError if an error occurs and cfwRaiseException was passed
    /// </summary>
    class function CopyFile(const _Source, _Dest: string;
      _Flags: TCopyFileFlagSet = [cfRaiseException]): boolean; overload;

    /// <summary>
    /// Copies the file Source to Dest using the Windows CopyFileEx function which
    /// allows for a progress callback
    /// @param Source is a string containing the name of the existing file
    /// @param Dest is a string containing the destination file name
    /// @param Flags is a set of TCopyFileWithProgressFlags specifying whether the copy operation
    ///        cfwFailIfExists: fail if the destination file already exists.
    ///        cfwRestartable: stores information in the destination file that allows
    ///          to restart a stopped copy operation
    ///        cfwRaiseException: retrieve the Windows error and raise an exception if it fails.
    ///          If not set, it will not raise an exception but just return cfwAborted
    ///          or cfwError if copying the file fails. (set by default)
    /// @returns cfeOK, if the copying succeeds, cfeAborted if the copying was aborted or
    ///          stopped in the callback function and cfeError on any other error.
    /// @raises  EOSError if an error occurs and cfwRaiseException was passed
    /// </summary>
    class function CopyFileWithProgress(const _Source, _Dest: string; _Progress: TCopyFileProgressEvt;
      _Flags: TCopyFileWithProgressFlagSet = [cfwRaiseException]): TCopyFileWithProgressResult;

    ///<summary>
    /// Copies all files that match the given Mask from SrcDir to DestDir and
    /// returns the number of files that were copied.
    /// If cfRaiseException is set in Flags, any error will raise an EOsError exception
    /// and the copying process will be aborted, otherwise errors will be silently
    /// ignored.
    /// If a destination file exists depending on the other Flag values the following
    /// happens:
    /// * If cfFailIfExists is set, the file is skipped or an exception is raised
    /// * If cfFailIfExists is not set, the file will be overwritten. If that fails
    ///   the file is skipped or an exception is raised
    /// * If cfFailIfExists is not set and cfForceOverwrite is set, the function
    ///   will also try to overwrite readonly files.
    /// if FilesSkipped is given, all skipped files will be added to that list (may be nil)
    ///</summary>
    class function CopyMatchingFiles(const _Mask, _SrcDir, _DestDir: string; _Flags: TCopyFileFlagset;
      _FilesSkipped: TStrings = nil): integer;

    /// <summary>
    /// Copies the file Source to Dest using the Windows MoveFileWithProgress function which
    /// allows for a progress callback
    /// NOTE: If the file can be moved rather than copied, no call to the callback
    ///       function will occur!
    /// @param Source is a string containing the name of the existing file
    /// @param Dest is a string containing the destination file name
    /// @param Flags is a set of TCopyFileWithProgressFlags specifying whether the copy operation
    ///        cfwFailIfExists: fail if the destination file already exists.
    ///        cfwRestartable: stores information in the destination file that allows
    ///          to restart a stopped copy operation
    ///        cfwRaiseException: retrieve the Windows error and raise an exception if it fails.
    ///          If not set, it will not raise an exception but just return cfwAborted
    ///          or cfwError if copying the file fails. (set by default)
    /// @returns cfeOK, if the copying succeeds, cfeAborted if the copying was aborted or
    ///          stopped in the callback function and cfeError on any other error.
    /// @raises  EOSError if an error occurs and cfwRaiseException was passed
    /// </summary>
    class function MoveFileWithProgress(const _Source, _Dest: string; _Progress: TCopyFileProgressEvt;
      _Flags: TMoveFileWithProgressFlagSet = [mfwRaiseException]): TCopyFileWithProgressResult;

    /// <summary>
    /// Creates a directory (parent directories must already exist)
    /// @param DirectoryName is the name for the new directory
    /// @param RaiseException determines whether an exception is raised on error, default = true
    /// @returns true, if the directory was created
    /// @raises EOSError if there was an error and RaiseException was true
    /// </summary>
    class function CreateDir(const _DirectoryName: string; _RaiseException: boolean = true): boolean;

    /// <summary>
    /// Creates a new directory, including the creation of parent directories as needed.
    /// @param DirectoryPath is the name for the new directory
    /// @param RaiseException determines whether an exception is raised on error, default = true
    /// @returns true, if the directory was created
    /// @raises EOSError if there was an error and RaiseException was true
    /// </summary>
    class function ForceDir(const _DirectoryPath: string; _RaiseException: boolean = true): boolean;

    /// <summary>
    /// Sets a file's readonly flag
    /// @param Filename is the file to change
    /// @param Set determines whether to set or clear the flag
    /// @returns true, if the readonly flag has been changed
    /// @raises EOSError if there was an error and RaiseException was true
    /// </summary>
    class function SetReadonly(const _Filename: string; _Set: boolean; _RaiseException: boolean = true): boolean;

    /// <summary>
    /// Deletes the file using the SysUtils.DeleteFile function.
    /// @param Filename is a string containing the name of the file
    /// @param RaiseException is a boolean which controls whether the function
    ///        retrieves the Windows error and raises an exception
    ///        if it fails. If false, it will not raise an exception
    ///        but just return false if moving the file fails.
    /// @param Force is a boolean which controls whether this function will try to delete
    ///        readonly files, If true, it will use SetFileAttr to reset the
    ///        readonly attribut and try to delete the file again.
    /// @returns true, if the file could be deleted, false otherwise.
    /// @raises EOSError if there was an error and RaiseException was true
    /// </summary>
    class function DeleteFile(const _Filename: string; _RaiseException: boolean = true;
      _Force: boolean = false): boolean;

    /// <summary>
    /// Deletes all files in a directory matching a given filemask (non-recursive)
    /// @param Dir is a string containting the directory in which the files are to be
    ///            deleted, must NOT be empty
    /// @param Mask is a string containting the file search mask, all files matching
    ///             this mask will be deleted
    /// @param RaiseException is a boolean which controls whether the function
    ///                       retrieves the Windows error and raises an exception
    ///                       if it fails. If false, it will not raise an exception
    ///                       but just return false if moving the file fails.
    /// @param Force is a boolean which controls whether this function will try to delete
    ///              readonly files, If true, it will use SetFileAttr to reset the
    ///              readonly attribut and try to delete the file again.
    /// @param ExceptMask is a string contaning a mask for files not to delete even if they
    ///                   match the Mask, defaults to an empty string meaning no exceptions.
    ///                   The comparison is case insensitive.
    /// @returns the number of files that could not be deleted.
    /// @raises EOSError if there was an error and RaiseException was true
    /// </summary>
    class function DeleteMatchingFiles(const _Dir, _Mask: string;
      _RaiseException: boolean = true; _Force: boolean = false): integer; overload;
    class function DeleteMatchingFiles(const _Dir, _Mask: string; _ExceptMask: string = '';
      _RaiseException: boolean = true; _Force: boolean = false): integer; overload; deprecated;
    class function DeleteMatchingFiles(const _Dir, _Mask: string; const _ExceptMasks: array of string;
      _RaiseException: boolean = true; _Force: boolean = false): integer; overload;

    /// <summary>
    /// tries to find a matching file
    /// @param Mask is the filename mask to match
    /// @param Filename is the name of the file which has been found, only valid if result <> mfNotFound
    /// @returns mfNotFound, if no file was found, or mfDirectory, mfFile or mfSpecial
    ///          describing the type of the file which has been found
    /// </summary>
    class function FindMatchingFile(const _Mask: string; out _Filename: string): TMatchingFileResult;

    ///<summary>
    /// @param RaiseException determines whether an exception should be raised if the file does not exist
    /// @raises Exception if the file does not exist and RaiseException is true
    class function FileExists(const _Filename: string; _RaiseException: boolean = false): boolean;

    ///<summary>
    /// @param RaiseException determines whether an exception should be raised if the directory does not exist
    /// @raises Exception if the directory does not exist and RaiseException is true
    class function DirExists(const _DirName: string; _RaiseException: boolean = false): boolean;

    /// <summary>
    /// deletes an empty directory using the SysUtils function RemoveDir
    /// The function will fail if the directory is not empty.
    /// @param DirName is the name of the directory to delete
    /// @param RaiseExceptin is a boolean which controls whether the function
    ///                      retrieves the Windows error and raises an exception
    ///                      if it fails. If false, it will not raise an exception
    ///                      but just return false if deleting the directory fails.
    /// @param Force is a boolean which controls whether this function will try to delete
    ///              readonly directories, If true, it will use SetFileAttr to reset the
    ///              readonly attribut and try to delete the directory again.
    /// @returns true, if the directory could be deleted, false otherwise.
    /// @raises EOSError if there was an error and RaiseException was true
    /// </summary>
    class function RemoveDir(const _Dirname: string; _RaiseException: boolean = true;
      _Force: boolean = false): boolean;

    /// <summary>
    /// function is deprecated, use DelDirTree instead!
    /// Note the different order of parameters of the new function!
    /// </summary>
    class function DelTree(const _Dirname: string; _Force: boolean = false;
      _RaiseException: boolean = true): boolean; deprecated;
    /// <summary>
    /// Deletes a directory with all files and subdirectories.
    /// Note: This new function has a different order of parameters than
    ///       the old DelTree function.
    /// @param Dirname is the name of the directory to delete
    /// @param RaiseExceptin is a boolean which controls whether the function
    ///                      retrieves the Windows error and raises an exception
    ///                      if it fails. If false, it will not raise an exception
    ///                      but just return false if deleting the directory fails.
    /// @param Force specifies whether it should also delete readonly files
    /// @returns true, if the directory could be deleted, false otherwise.
    /// @raises EOSError if there was an error and RaiseException was true
    /// </summary>
    class function DelDirTree(const _Dirname: string; _RaiseException: boolean = true;
      _Force: boolean = false): boolean;

    /// <summary>
    /// reads a text file and returns its content as a string
    /// @param Filename is the name of the file to read
    /// @returns the file's content as a string
    /// </summary>
    class function ReadTextFile(const _Filename: string): string;

    /// <summary>
    /// checks whether the given string is a valid filename (without path), that is
    /// does not contain one of the characters defined in INVALID_FILENAME_CHARS
    /// @param s is the string to check
    /// @param AllowDot determines whether a dot ('.') is allowed in the filename
    ///        the default is true, but you might not want that
    /// @returns true, if the string is a valid filename, false otherwise
    /// </summary>
    class function IsValidFilename(const _s: string; _AllowDot: boolean = true): boolean; overload;
    /// <summary>
    /// checks whether the given string is a valid filename (without path), that is
    /// does not contain one of the characters defined in INVALID_FILENAME_CHARS and
    /// returns the first error position.
    /// @param s is the string to check
    /// @param ErrPos is the first error position, only valid it result = false
    /// @param AllowDot determines whether a dot ('.') is allowed in the filename
    ///        the default is true, but you might not want that
    /// @returns true, if the string is a valid filename, false otherwise
    /// </summary>
    class function IsValidFilename(const _s: string; out _ErrPos: integer; _AllowDot: boolean = true): boolean; overload;

    /// <summary> Returns true if the file exists and is readonly </summary>
    class function IsFileReadonly(const _Filename: string): boolean;

    /// <summary>
    /// creates a backup of the file appending the current date and time to the base
    /// file name. See also TFileGenerationHandler.
    /// @param Filename is the name of the file to back up
    /// @param BackupDir is a directory in which to create the backup file, if empty
    ///                  the same directory as the original file is used
    /// @returns the full filename of the created backup file
    /// </summary>
    class function BackupFile(const _Filename: string; _BackupDir: string = ''): string;

    /// <summary>
    /// @returns a TFileInfoRec containing the filename, filesize and last access
    ///          timestamp of the file
    /// </summary>
    class function GetFileInfo(const _Filename: string): TFileInfoRec;
    /// <summary> tries to get the file information containing filename, filesize
    ///           and last access timestamp of the file.
    ///           @param Info will contain these values, only valid if result = true
    /// </summary>
    class function TryGetFileInfo(const _Filename: string; out _Info: TFileInfoRec): boolean;
    class function TryGetFileSize(const _Filename: string; out _Size: Int64): boolean;
    class function GetFileSize(const _Filename: string): Int64;

    /// <summary>
    /// Returns the free space (in bytes) on the disk with the given drive letter
    /// </summary>
    class function DiskFree(_DriveLetter: AnsiChar): Int64;
    class function GetVolumeName(_DriveLetter: AnsiChar): string;
    class function GetRemoteVolumeName(const _Share: string): string;
    class procedure GetLocalVolumeNames(_sl: TStrings; _HdOnly: boolean = False; _IgnoreEmpty: Boolean = True);

    ///<summary> changes the "full" file extension where "full" means it handles multiple
    ///          extensions like .doc.exe </summary>
    class function ChangeFileExtFull(const _Filename, _NewExt: string): string;
    ///<summary> extracts the "full" file extension where "full" means it handles multiple
    ///          extensions like .doc.exe </summary>
    class function ExtractFileExtFull(const _Filename: string): string;
    ///<summary> removes the "full" file extension where "full" means it handles multiple
    ///          extensions like .doc.exe </summary>
    class function RemoveFileExtFull(const _Filename: string): string;
  end;

type
  /// <summary>
  /// callback event for generating a filename for the given generation
  ///  </summary>
  TOnGenerateFilename = procedure(_Sender: TObject; _Generation: integer; var _Filename: string) of object;
type
  /// <summary>
  /// This class handles keeping generations of files, e.g. log files. The default
  /// is to keep 10 generations
  /// </summary>
  TFileGenerationHandler = class
  private
    FBaseName: string;
    FSuffix: string;
    FOnGenerateFilename: TOnGenerateFilename;
    FMaxGenerations: integer;
    FResultContainsNumber: boolean;
    FOldestIsHighest: boolean;
    FPrependZeros: integer;
    function GenerateFilename(_Generation: integer): string;
  public
    /// <summary>
    /// @param BaseName is the base filename to which by default _<n> followed by
    ///                 the Suffix will be appended
    /// @param Suffix is the suffix for the filename, usually an extension which
    ///               must include the dot (.), but it is also possible to pass
    ///               an arbitrary string like '_backup'.
    /// </summary>
    constructor Create(const _BaseName, _Suffix: string);
    /// <summary>
    /// generates the filename and returns it
    /// </summary>
    function Execute(_KeepOriginal: boolean): string;
    /// <summary>
    /// the maximum of file generations that should be kept
    /// </summary>
    property MaxGenerations: integer read FMaxGenerations write FMaxGenerations default 5;
    /// <summary>
    /// should the resulting filename contain a number?
    /// </summary>
    property ResultContainsNumber: boolean read FResultContainsNumber write FResultContainsNumber default false;
    /// <summary>
    /// does the oldest file have the highest number?
    /// </summary>
    property OldestIsHighest: boolean read FOldestIsHighest write FOldestIsHighest default true;
    property PrependZeros: integer read FPrependZeros write FPrependZeros default 0;
    /// <summary>
    /// allows read access to the file's base name as passed to the constructor
    /// </summary>
    property BaseName: string read FBaseName;
    property Suffix: string read FSuffix;
    /// <summary>
    /// callback event for generating a filename for the given generation
    /// </summary>
    property OnGenerateFilename: TOnGenerateFilename read FOnGenerateFilename write FOnGenerateFilename;
  end;

/// <summary>
/// This is an abbreviation for IncludeTrailingPathDelimiter
/// </summary>
function itpd(const _Dirname: string): string; inline;

///<summary>
/// This is an abbreviation for ExcludeTrailingPathDelimiter
///</summary>
function etpd(const _Dirname: string): string; inline;

implementation

uses
  StrUtils,
  Masks,
  u_dzMiscUtils,
  u_dzStringUtils,
  u_dzDateUtils,
  u_dzFileStreams;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

function itpd(const _Dirname: string): string; inline;
begin
  Result := IncludeTrailingPathDelimiter(_Dirname);
end;

function etpd(const _Dirname: string): string; inline;
begin
  Result := ExcludeTrailingPathDelimiter(_Dirname);
end;

{ TSimpleDirEnumerator }

constructor TSimpleDirEnumerator.Create(const _Mask: string;
  _MayHaveAttr: TFileAttributeSet = [dfaHidden, dfaSysFile, dfaVolumeID, dfaDirectory, dfaArchive]);
begin
  FMask := _Mask;
  FMustHaveAttr := [];
  FMayHaveAttr := _MayHaveAttr;
end;

destructor TSimpleDirEnumerator.Destroy;
begin
  Reset;
  inherited;
end;

class function TSimpleDirEnumerator.Execute(const _Mask: string; _List: TStrings;
  _MayHaveAttr: TFileAttributeSet = [dfaHidden, dfaSysFile, dfaVolumeID, dfaDirectory, dfaArchive];
  _IncludePath: boolean = false): integer;
var
  enum: TSimpleDirEnumerator;
begin
  enum := TSimpleDirEnumerator.Create(_Mask, _MayHaveAttr);
  try
    Result := enum.FindAll(_List, _IncludePath);
  finally
    FreeAndNil(enum);
  end;
end;

function TSimpleDirEnumerator.FindAll(_List: TStrings = nil; _IncludePath: boolean = false): integer;
var
  s: string;
  Path: string;
begin
  if _IncludePath then
    Path := ExtractFilePath(FMask)
  else
    Path := '';
  Result := 0;
  while FindNext(s) do begin
    Inc(Result);
    if Assigned(_List) then
      _List.Add(Path + s);
  end;
end;

function TSimpleDirEnumerator.FindNext(out _Filename: string): boolean;
var
  Res: integer;
  Attr: integer;

  function AttrOk(_EnumAttr: TFileAttributes; _SysAttr: integer): boolean;
  begin
    Result := true;
    if _EnumAttr in FMustHaveAttr then
      if (Attr and _SysAttr) = 0 then
        Result := false;
  end;

  procedure CondAddAttr(_EnumAttr: TFileAttributes; _SysAttr: integer);
  begin
    if _EnumAttr in FMayHaveAttr then
      Attr := Attr + _SysAttr;
  end;

begin
  repeat
    if not FActive then begin
      FMatchCount := 0;
      Attr := 0;
      CondAddAttr(dfaReadOnly, SysUtils.faReadOnly);
      CondAddAttr(dfaHidden, SysUtils.faHidden);
      CondAddAttr(dfaSysFile, SysUtils.faSysFile);
      CondAddAttr(dfaVolumeID, SysUtils.faVolumeID);
      CondAddAttr(dfaDirectory, SysUtils.faDirectory);
      CondAddAttr(dfaArchive, SysUtils.faArchive);
      Res := FindFirst(FMask, Attr, FSr);
      Result := (Res = 0);
      if Result then
        FActive := true;
    end else begin
      Res := SysUtils.FindNext(FSr);
      Result := (Res = 0);
    end;
    if not Result then
      exit;
    if (sr.Name = '.') or (sr.Name = '..') then
      Continue;
    if FMustHaveAttr <> [] then begin
      Attr := FSr.Attr;
      if not AttrOk(dfaReadonly, SysUtils.faReadOnly) then
        Continue;
      if not AttrOk(dfaHidden, SysUtils.faHidden) then
        Continue;
      if not AttrOk(dfaSysFile, SysUtils.faSysFile) then
        Continue;
      if not AttrOk(dfaVolumeID, SysUtils.faVolumeID) then
        Continue;
      if not AttrOk(dfaDirectory, SysUtils.faDirectory) then
        Continue;
      if not AttrOk(dfaArchive, SysUtils.faArchive) then
        Continue;
    end;
    Inc(FMatchCount);
    _Filename := sr.Name;
    exit;
  until false;
end;

function TSimpleDirEnumerator.FindNext: boolean;
var
  s: string;
begin
  Result := FindNext(s);
end;

procedure TSimpleDirEnumerator.Reset;
begin
  if FActive then
    FindClose(FSr);
  FActive := false;
end;

{ TFileSystem }

class function TFileSystem.GetTempPath: string;
var
  Res: integer;
  LastError: integer;
begin
  SetLength(Result, 1024);
  Res := Windows.GetTempPath(1024, PChar(Result));
  if Res < 0 then begin
    // GetLastError must be called before _(), otherwise the error code gets lost
    LastError := GetLastError;
    RaiseLastOSErrorEx(LastError, _('TFileSystem.GetTempPath: %1:s (code: %0:d) calling Windows.GetTempPath'));
  end;
  if Res > 1024 then begin
    SetLength(Result, Res + 1);
    Res := Windows.GetTempPath(Res + 1, PChar(Result));
    if Res < 0 then begin
      // GetLastError must be called before _(), otherwise the error code gets lost
      LastError := GetLastError;
      RaiseLastOsErrorEx(LastError, _('TFileSystem.GetTempPath: %1:s (code: %0:d) calling Windows.GetTempPath (2nd)'));
    end;
  end;
  SetLength(Result, Res);
end;

// declared wrongly in WINDOWS

function GetVolumeInformation(lpRootPathName: PChar;
  lpVolumeNameBuffer: PChar; nVolumeNameSize: DWORD; lpVolumeSerialNumber: PDWORD;
  lpMaximumComponentLength, lpFileSystemFlags: LPDWORD;
  lpFileSystemNameBuffer: PChar; nFileSystemNameSize: DWORD): BOOL; stdcall; external kernel32 name 'GetVolumeInformationA';

class function TFileSystem.GetVolumeName(_DriveLetter: AnsiChar): string;
begin
  Result := GetRemoteVolumeName(_DriveLetter + ':\');
end;

class function TFileSystem.GetRemoteVolumeName(const _Share: string): string;
var
  Res: LongBool;
begin
  SetLength(Result, MAX_PATH + 1);
  Res := GetVolumeInformation(PChar(itpd(_Share)), PChar(Result), Length(Result), nil, nil, nil, nil, 0);
  if Res then begin
    Result := PChar(Result);
  end else
    Result := '';
end;

class procedure TFileSystem.GetLocalVolumeNames(_sl: TStrings; _HdOnly: boolean = False; _IgnoreEmpty: Boolean = True);
type
  TDriveType = (dtUnknown, dtNoDrive, dtFloppy, dtFixed, dtNetwork, dtCDROM, dtRAM);
var
  DriveBits: set of 0..25;
  DriveNum: Integer;
  DriveChar: AnsiChar;
  DriveType: TDriveType;
  s: string;
begin
  Integer(DriveBits) := Windows.GetLogicalDrives;
  for DriveNum := 0 to 25 do begin
    if not (DriveNum in DriveBits) then
      Continue;
    DriveChar := AnsiChar(DriveNum + Ord('a'));
    DriveType := TDriveType(Windows.GetDriveType(PChar(DriveChar + ':\')));
    if not _HdOnly or (DriveType = dtFixed) then begin
      s := GetVolumeName(DriveChar);
      if s <> '' then begin
        _sl.AddObject(s, Pointer(DriveNum));
      end else begin
        if not _IgnoreEmpty then begin
          s := _('<no volume name>');
          _sl.AddObject(s, Pointer(DriveNum));
        end;
      end;
    end;
  end;
end;

class function TFileSystem.CreateDir(const _DirectoryName: string;
  _RaiseException: boolean = true): boolean;
var
  LastError: Cardinal;
begin
  Result := SysUtils.CreateDir(_DirectoryName);
  if not Result then begin
    if _RaiseException then begin
      // GetLastError must be called before _(), otherwise the error code gets lost
      LastError := GetLastError;
      // duplicate % so they get passed through the format function
      RaiseLastOsErrorEx(LastError, Format(_('Error %%1:s (%%0:d) creating directory "%s"'), [_DirectoryName]));
    end;
  end;
end;

class function TFileSystem.CreateUniqueDirectory(_BaseDir: string = ''; const _Prefix: string = 'dz'): string;
var
  Pid: DWord;
  Counter: integer;
  Ok: boolean;
  s: string;
begin
  if _BaseDir = '' then
    _BaseDir := GetTempPath;
  Pid := GetCurrentProcessId;
  s := itpd(_BaseDir) + _Prefix + '_' + IntToStr(Pid) + '_';
  Counter := 0;
  Ok := false;
  while not OK do begin
    Result := s + IntToStr(Counter);
    OK := CreateDir(Result, false);
    if not OK then begin
      Inc(Counter);
      if Counter > 1000 then
        raise ECreateUniqueDir.CreateFmt(_('Could not find a unique directory name based on "%s"'), [Result]);
    end;
  end;
end;

type
  TUniqueTempDir = class(TInterfacedObject, IUniqueTempDir)
  private
    FPath: string;
    function Path: string;
  public
    constructor Create(const _Path: string);
    destructor Destroy; override;
  end;

class function TFileSystem.CreateUniqueTempDir(_Prefix: string): IUniqueTempDir;
var
  s: string;
begin
  s := CreateUniqueDirectory(GetTempPath, _Prefix);
  Result := TUniqueTempDir.Create(s);
end;

class function TFileSystem.GetTempFileName(_Directory: string = ''; const _Prefix: string = 'dz';
  _Unique: word = 0): string;
var
  Res: integer;
  LastError: Cardinal;
begin
  if _Directory = '' then
    _Directory := GetTempPath;
  SetLength(Result, MAX_PATH);
  Res := Windows.GetTempFileName(PChar(_Directory), PChar(_Prefix), _Unique, PChar(Result));
  if Res = 0 then begin
    // GetLastError must be called before _(), otherwise the error code gets lost
    LastError := GetLastError;
    RaiseLastOsErrorEx(LastError, _('TFileSystem.GetTempFilename: %1:s (Code: %0:d) calling Windows.GetTempFileName'));
  end;
  Result := PChar(Result); // remove trailing characters
end;

//class function TFileSystem.GetTempFileNameEx(_Directory: string; const _Prefix,
//  _Ext: string): string;
//var
//  st: TdzFile;
//  i: Integer;
//begin
//  if _Directory = '' then
//    _Directory := GetTempPath;
//  for i := 0 to 256 * 16 - 1 do begin
//    Result := itpd(_Directory) + _Prefix + IntToHex(MainThreadID, 3) + IntToHex(Random(256 * 16), 2) + _Ext;
//    st := TdzFile.Create(Result);
//    try
//      st.AccessMode := faReadWrite;
//      st.ShareMode := fsNoSharing;
//      st.CreateDisposition := fcCreateFailIfExists;
//      if st.OpenNoException then
//        exit;
//    finally
//      FreeAndNil(st);
//    end;
//  end;
//  raise Exception.CreateFmt(_('Unable to create a temporary file from %s.'), [itpd(_Directory) + _Prefix + '*' + _Ext]);
//end;

class function TFileSystem.TryGetFileInfo(const _Filename: string;
  out _Info: TFileInfoRec): boolean;
var
  sr: TSearchRec;
  Res: integer;
begin
  Res := FindFirst(_Filename, faAnyFile, sr);
  Result := (Res = 0);
  if Result then begin
    try
      _Info.Filename := _Filename;
      _Info.Size := sr.Size;
{$IFDEF RTL220_UP}
      _Info.Timestamp := sr.TimeStamp;
{$ELSE}
      _Info.Timestamp := FileDateToDateTime(sr.Time);
{$ENDIF}
    finally
      FindClose(sr);
    end;
  end;
end;

class function TFileSystem.GetFileInfo(const _Filename: string): TFileInfoRec;
begin
  if not TryGetFileInfo(_Filename, Result) then
    raise EFileNotFound.CreateFmt(_('File not found: "%s"'), [_Filename]);
end;

class function TFileSystem.GetFileSize(const _Filename: string): Int64;
begin
  if not TryGetFileSize(_Filename, Result) then
    raise EFileNotFound.CreateFmt(_('File not found: "%s"'), [_Filename]);
end;

class function TFileSystem.TryGetFileSize(const _Filename: string;
  out _Size: Int64): boolean;
var
  Info: TFileInfoRec;
begin
  Result := TryGetFileInfo(_Filename, Info);
  if Result then
    _Size := Info.Size;
end;

class function TFileSystem.DiskFree(_DriveLetter: AnsiChar): Int64;
var
  ErrorMode: Cardinal;
begin
  if _DriveLetter in ['a'..'z'] then
    _DriveLetter := UpCase(_DriveLetter);

  if not (_DriveLetter in ['A'..'Z']) then
    Result := -1
  else begin
    ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    try
      try
        Result := SysUtils.DiskFree(Ord(_DriveLetter) - Ord('A') + 1);
      except
        Result := -1;
      end;
    finally
      SetErrorMode(ErrorMode);
    end;
  end;
end;

class function TFileSystem.GetShortPathname(const _LongName: string): string;
var
  Res: integer;
  LastError: Cardinal;
begin
  SetLength(Result, MAX_PATH);
  Res := Windows.GetShortPathname(PChar(_LongName), PChar(Result), Length(Result));
  if Res = 0 then begin
    LastError := GetLastError;
    RaiseLastOsErrorEx(LastError, _('TFileSystem.GetShortPathname: %1:s (Code: %0:d) calling Windows.GetShortPathname'));
  end else if Res > MAX_PATH then
    raise EPathTooLong.CreateFmt(_('Short pathname is longer than MAX_PATH (%d) characters'), [MAX_PATH]);
  Result := PChar(Result); // truncate at first #0
end;

class function TFileSystem.MoveFile(const _Source, _Dest: string; _RaiseException: boolean = true): boolean;
var
  LastError: Cardinal;
begin
  Result := Windows.MoveFile(PChar(_Source), PChar(_Dest));
  if not Result and _RaiseException then begin
    LastError := GetLastError;
    // duplicate % so they get passed through the format function
    RaiseLastOsErrorEx(LastError, Format(_('Error %%1:s (%%0:d) while trying to move "%s" to "%s".'), [_Source, _Dest]));
  end;
end;

class function TFileSystem.SetReadonly(const _Filename: string; _Set: boolean; _RaiseException: boolean = true): boolean;
var
  Attr: integer;
  LastError: Cardinal;
begin
  Attr := FileGetAttr(_Filename);
  if _Set then
    Attr := Attr or SysUtils.faReadOnly
  else
    Attr := Attr and not SysUtils.faReadOnly;
  if FileSetAttr(_Filename, Attr) <> 0 then begin
    if _RaiseException then begin
      LastError := GetLastError;
      // duplicate % so they get passed through the format function
      RaiseLastOsErrorEx(LastError, Format(_('Error %%1:s (%%0:d) while changing the readonly flag of "%s"'), [_Filename]));
    end;
    Result := false
  end else
    Result := true;
end;

class function TFileSystem.CopyFile(const _Source, _Dest: string; _FailIfExists: boolean = true;
  _RaiseException: boolean = true; _ForceOverwrite: boolean = false): boolean;
var
  LastError: Cardinal;
begin
  Result := Windows.CopyFile(PChar(_Source), PChar(_Dest), _FailIfExists);
  if not Result and not _FailIfExists and _ForceOverwrite then begin
    SetReadonly(_Dest, False, false);
    Result := Windows.CopyFile(PChar(_Source), PChar(_Dest), _FailIfExists);
  end;
  if not Result and _RaiseException then begin
    LastError := GetLastError;
    // duplicate % so they get passed through the format function
    RaiseLastOsErrorEx(LastError, Format(_('Error %%1:s (%%0:d) while trying to copy "%s" to "%s".'), [_Source, _Dest]));
  end;
end;

class function TFileSystem.BackupFile(const _Filename: string; _BackupDir: string = ''): string;
var
  Ext: string;
  FilenameOnly: string;
  Base: string;
begin
  if _BackupDir = '' then
    _BackupDir := ExtractFilePath(_Filename);
  _BackupDir := itpd(_BackupDir);
  FilenameOnly := ExtractFileName(_Filename);
  Ext := ExtractFileExt(FilenameOnly);
  Base := ChangeFileExt(FilenameOnly, '');
  Result := _BackupDir + Base + '_' + ReplaceChars(DateTime2Iso(now, true), ': ', '-_') + Ext;
  CopyFile(_Filename, Result, true);
end;

class function TFileSystem.CopyFile(const _Source, _Dest: string; _Flags: TCopyFileFlagSet): boolean;
begin
  Result := CopyFile(_Source, _Dest,
    cfFailIfExists in _Flags,
    cfRaiseException in _Flags,
    cfForceOverwrite in _Flags);
end;

type
  TProgressRedir = class(TCopyProgressStatus)
  strict private
    FOnProgress: TCopyFileProgressEvt;
  private
    CancelFlag: BOOL;
    // should an exception be raised within the OnProgress callback, it is stored here
    FExceptAddr: pointer;
    FExceptMsg: string;
    FExceptClass: string;
    function doProgress(): TCopyProgressStatus.TProgressResult;
  public
    constructor Create(_OnProgress: TCopyFileProgressEvt);
  end;

//  PROGRESS_CONTINUE = 0;
//  PROGRESS_CANCEL = 1;
//  PROGRESS_STOP = 2;
//  PROGRESS_QUIET = 3;

//  CALLBACK_CHUNK_FINISHED = $00000000;
//  CALLBACK_STREAM_SWITCH = $00000001;

function ProgressCallback(
  _TotalFileSize, _TotalBytesTransferred, _StreamSize, _StreamBytesTransferred: LARGE_INTEGER;
  _StreamNumber, _CallbackReason: LongWord;
  _SourceFile, _DestinationFile: THandle; _Data: pointer): LongWord; far; stdcall;
var
  Status: TProgressRedir;
begin
  try
    Status := TProgressRedir(_Data);
    Status.FTotalFileSize := _TotalFileSize;
    Status.FTotalBytesTransferred := _TotalBytesTransferred;
    Status.FStreamSize := _StreamSize;
    Status.FStreamBytesTransferred := _StreamBytesTransferred;
    Status.FStreamNumber := _StreamNumber;
    case _CallbackReason of
      CALLBACK_CHUNK_FINISHED: Status.FCallbackReason := prChunkFinished;
      CALLBACK_STREAM_SWITCH: Status.FCallbackReason := prStreamSwitch;
    else
    // Shouldn't happen, assume CALLBACK_CHUNK_FINISHED for now
      Status.FCallbackReason := prChunkFinished;
    end;
    Status.FSourceFile := _SourceFile;
    Status.FDestinationFile := _DestinationFile;
    case Status.doProgress() of
      prContinue: Result := PROGRESS_CONTINUE;
      prCancel: Result := PROGRESS_CANCEL;
      prStop: Result := PROGRESS_STOP;
      prQuiet: Result := PROGRESS_QUIET;
    else // should not happen, assume prContinue
      Result := PROGRESS_CONTINUE;
    end;
  except
    // Ignore exceptions here since the progess display should not affect the actual copying.
    // Any exceptions whithin doProgress should be handled there and communicated to the main
    // thread.
    Result := PROGRESS_CONTINUE;
  end;
end;

//  COPY_FILE_FAIL_IF_EXISTS = $00000001;
//  COPY_FILE_RESTARTABLE = $00000002;

class function TFileSystem.CopyFileWithProgress(const _Source, _Dest: string;
  _Progress: TCopyFileProgressEvt;
  _Flags: TCopyFileWithProgressFlagSet = [cfwRaiseException]): TCopyFileWithProgressResult;
var
  Redir: TProgressRedir;
  Flags: DWORD;
  Res: BOOL;
  LastError: DWORD;
begin
  Result := cfwError;
  Redir := TProgressRedir.Create(_Progress);
  try
    Flags := 0;
    if cfwFailIfExists in _Flags then
      Flags := Flags or COPY_FILE_FAIL_IF_EXISTS;
    if cfwRestartable in _Flags then
      Flags := Flags or COPY_FILE_RESTARTABLE;
    Res := Windows.CopyFileEx(PChar(_Source), PChar(_Dest), @ProgressCallback, Redir,
      @Redir.CancelFlag, Flags);
    if Redir.FExceptAddr <> nil then begin
      if cfwRaiseException in _Flags then begin
        raise Exception.CreateFmt(_('Error %s (%s) in progress callback while trying to copy "%s" to "%s".'), [Redir.FExceptMsg, Redir.FExceptClass, _Source, _Dest])at Redir.FExceptAddr;
      end;
      Result := cfwError;
      exit;
    end;
    if not Res then begin
      LastError := GetLastError;
      if LastError = ERROR_REQUEST_ABORTED then
        Result := cfwAborted
      else begin
        if cfwRaiseException in _Flags then begin
          // duplicate % so they get passed through the format function
          RaiseLastOsErrorEx(LastError, Format(_('Error %%1:s (%%0:d) while trying to copy "%s" to "%s".'), [_Source, _Dest]));
        end;
        Result := cfwError;
      end;
    end else
      Result := cfwOK;
  finally
    FreeAndNil(Redir);
  end;
end;

class function TFileSystem.CopyMatchingFiles(const _Mask, _SrcDir, _DestDir: string;
  _Flags: TCopyFileFlagset; _FilesSkipped: TStrings = nil): integer;
var
  Files: TStringList;
  s: string;
  SrcDirBs: string;
  DestDirBs: string;
begin
  Result := 0;
  SrcDirBs := itpd(_SrcDir);
  DestDirBs := itpd(_DestDir);
  Files := TStringList.Create;
  try
    TSimpleDirEnumerator.Execute(SrcDirBs + _Mask, Files, [dfaHidden, dfaSysFile, dfaArchive]);
    for s in Files do begin
      if CopyFile(SrcDirBs + s, DestDirBs + s, _Flags) then
        Inc(Result)
      else begin
        if Assigned(_FilesSkipped) then
          _FilesSkipped.Add(s);
      end;
    end;
  finally
    FreeAndNil(Files);
  end;
end;

//  MOVEFILE_REPLACE_EXISTING       = $00000001;
//  MOVEFILE_COPY_ALLOWED           = $00000002;
//  MOVEFILE_DELAY_UNTIL_REBOOT     = $00000004;
//  MOVEFILE_WRITE_THROUGH          = $00000008;
//  MOVEFILE_CREATE_HARDLINK        = $00000010;
//  MOVEFILE_FAIL_IF_NOT_TRACKABLE  = $00000020;

class function TFileSystem.MoveFileWithProgress(const _Source, _Dest: string;
  _Progress: TCopyFileProgressEvt;
  _Flags: TMoveFileWithProgressFlagSet = [mfwRaiseException]): TCopyFileWithProgressResult;
var
  Redir: TProgressRedir;
  Flags: DWORD;
  Res: BOOL;
  LastError: DWORD;
begin
  Redir := TProgressRedir.Create(_Progress);
  try
    Flags := MOVEFILE_REPLACE_EXISTING;
    if mfwFailIfExists in _Flags then
      Flags := Flags - MOVEFILE_COPY_ALLOWED;
    if mfwAllowCopy in _Flags then
      Flags := Flags or MOVEFILE_COPY_ALLOWED;
    if mfwDelayUntilReboot in _Flags then
      Flags := Flags or MOVEFILE_DELAY_UNTIL_REBOOT;
    if mfwWriteThrough in _Flags then
      Flags := Flags or MOVEFILE_WRITE_THROUGH;
    if mfwFailIfNotTrackable in _Flags then
      Flags := Flags or MOVEFILE_FAIL_IF_NOT_TRACKABLE;
    Res := Windows.MoveFileWithProgress(PChar(_Source), PChar(_Dest),
      @ProgressCallback, Redir, Flags);
    if not Res then begin
      LastError := GetLastError;
      if mfwRaiseException in _Flags then begin
        // duplicate % so they get passed through the format function
        RaiseLastOsErrorEx(LastError, Format(_('Error %%1:s (%%0:d) while trying to copy "%s" to "%s".'), [_Source, _Dest]));
      end;

      if LastError = ERROR_REQUEST_ABORTED then
        Result := cfwAborted
      else
        Result := cfwError;
    end else
      Result := cfwOK;
  finally
    FreeAndNil(Redir);
  end;
end;

class function TFileSystem.DeleteFile(const _Filename: string; _RaiseException: boolean = true;
  _Force: boolean = false): boolean;
var
  Attr: integer;
  LastError: Cardinal;
begin
  Result := SysUtils.DeleteFile(_Filename);
  if not Result and _Force then begin
    Attr := FileGetAttr(_Filename);
    Attr := Attr and not SysUtils.faReadOnly;
    FileSetAttr(_Filename, Attr);
    Result := SysUtils.DeleteFile(_Filename);
  end;
  if not Result and _RaiseException then begin
    LastError := GetLastError;
    // duplicate % so they get passed through the format function
    RaiseLastOsErrorEx(LastError, Format(_('Error %%1:s (%%0:d) deleting file "%s"'), [_Filename]));
  end;
end;

class function TFileSystem.DeleteMatchingFiles(const _Dir, _Mask: string;
  _RaiseException, _Force: boolean): integer;
begin
  Result := DeleteMatchingFiles(_Dir, _Mask, [], _RaiseException, _Force);
end;

class function TFileSystem.DeleteMatchingFiles(const _Dir, _Mask: string;
  _ExceptMask: string; _RaiseException, _Force: boolean): integer;
begin
  Result := DeleteMatchingFiles(_Dir, _Mask, [_ExceptMask], _RaiseException, _Force);
end;

class function TFileSystem.DeleteMatchingFiles(const _Dir, _Mask: string;
  const _ExceptMasks: array of string; _RaiseException,
  _Force: boolean): integer;

  function MatchesAnyExceptMask(const _s: string): boolean;
  var
    i: Integer;
    Mask: string;
  begin
    for i := Low(_ExceptMasks) to High(_ExceptMasks) do begin
      Mask := LowerCase(_ExceptMasks[i]);
      if MatchesMask(_s, Mask) then begin
        Result := true;
        exit;
      end;
    end;
    Result := false;
  end;

var
  sr: TSearchRec;
  Dir: string;
begin
  Assert(_Dir <> '', 'Dir parameter must not be an empty string');
  Assert(_Mask <> '', 'Dir parameter must not be an empty string');

  Result := 0;
  Dir := IncludeTrailingPathDelimiter(_Dir);
  if 0 = FindFirst(Dir + _Mask, faAnyFile, sr) then begin
    try
      repeat
        if (sr.Name <> '.') and (sr.Name <> '..') then
          if ((sr.Attr and (SysUtils.faVolumeID or SysUtils.faDirectory)) = 0) then
            if not MatchesAnyExceptMask(LowerCase(sr.Name)) then
              if not DeleteFile(Dir + sr.Name, _RaiseException, _Force) then
                Inc(Result);
      until 0 <> FindNext(sr);
    finally
      FindClose(sr);
    end;
  end;
end;

class function TFileSystem.FileExists(const _Filename: string; _RaiseException: boolean = false): boolean;
var
  OldErrorMode: Cardinal;
begin
  OldErrorMode := SetErrorMode(SEM_NOOPENFILEERRORBOX);
  try
    Result := SysUtils.FileExists(_Filename);
  finally
    SetErrorMode(OldErrorMode)
  end;
  if not Result and _RaiseException then
    raise Exception.CreateFmt(_('File not found: %s'), [_Filename]);
end;

class function TFileSystem.DirExists(const _DirName: string; _RaiseException: boolean = false): boolean;
var
  OldErrorMode: Cardinal;
begin
  OldErrorMode := SetErrorMode(SEM_NOOPENFILEERRORBOX);
  try
    Result := SysUtils.DirectoryExists(_DirName);
  finally
    SetErrorMode(OldErrorMode)
  end;
  if not Result and _RaiseException then
    raise Exception.CreateFmt(_('Directory not found: %s'), [_DirName]);
end;

class function TFileSystem.FindMatchingFile(const _Mask: string; out _Filename: string): TMatchingFileResult;
var
  sr: TSearchRec;
begin
  Result := mfNotFound;
  if 0 = FindFirst(_Mask, faAnyFile, sr) then
    try
      repeat
        if (sr.Name <> '.') and (sr.Name <> '..') then begin
          _Filename := sr.Name;
          if (sr.Attr and SysUtils.faVolumeID) <> 0 then
            Result := mfSpecial
          else if (sr.Attr and SysUtils.faDirectory) <> 0 then
            Result := mfDirectory
          else
            Result := mfFile;
          exit;
        end;
      until 0 <> FindNext(sr);
    finally
      FindClose(sr);
    end;
end;

class function TFileSystem.ForceDir(const _DirectoryPath: string; _RaiseException: boolean = true): boolean;
var
  LastError: Cardinal;
begin
  try
    Result := SysUtils.ForceDirectories(_DirectoryPath);
  except
    on e: Exception do begin
      // ForceDirectories can raise EInOutError if the directory path contains empty parts
      if _RaiseException then
        raise Exception.CreateFmt(_('Error creating directory "%s": %s (%s)'), [_DirectoryPath, e.Message, e.ClassName]);
      Result := false;
      exit;
    end;
  end;
  if not Result and _RaiseException then begin
    LastError := GetLastError;
    // duplicate % so they get passed through the format function
    RaiseLastOsErrorEx(LastError, Format(_('Error %%1:s (%%0:d) creating directory "%s"'), [_DirectoryPath]));
  end;
end;

class function TFileSystem.RemoveDir(const _Dirname: string; _RaiseException: boolean = true; _Force: boolean = false): boolean;
var
  Attr: integer;
  LastError: Cardinal;
begin
  Result := SysUtils.RemoveDir(_Dirname);
  if not Result and _Force then begin
    Attr := FileGetAttr(_Dirname);
    Attr := Attr and not SysUtils.faReadOnly;
    FileSetAttr(_Dirname, Attr);
    Result := SysUtils.RemoveDir(_Dirname);
  end;
  if not Result and _RaiseException then begin
    LastError := GetLastError;
    // duplicate % so they get passed through the format function
    RaiseLastOsErrorEx(LastError, Format(_('Error %%1:s (%%0:d) deleting directory "%s"'), [_Dirname]));
  end;
end;

class function TFileSystem.DelTree(const _Dirname: string; _Force: boolean = false; _RaiseException: boolean = true): boolean;
begin
  Result := DelDirTree(_Dirname, _RaiseException, _Force);
end;

class function TFileSystem.DelDirTree(const _Dirname: string; _RaiseException,
  _Force: boolean): boolean;
var
  sr: TSearchRec;
  Filename: string;
begin
  Result := DirectoryExists(ExcludeTrailingPathDelimiter(_Dirname));
  if not Result then begin
    if _RaiseException then
      raise EDirNotFound.CreateFmt(_('"%s" does not exist or is not a directory'), [_DirName]);
    exit;
  end;
  if 0 = FindFirst(IncludeTrailingPathDelimiter(_Dirname) + '*.*', faAnyFile, sr) then
    try
      repeat
        if (sr.Name = '.') or (sr.Name = '..') then begin
            // ignore
        end else begin
          Filename := IncludeTrailingPathDelimiter(_Dirname) + sr.Name;
          if (sr.Attr and SysUtils.faDirectory) <> 0 then begin
            Result := DelDirTree(Filename, _RaiseException, _Force);
            if not Result then
              exit;
          end else begin
            Result := DeleteFile(Filename, _RaiseException, _Force);
            if not Result then
              exit;
          end;
        end;
      until 0 <> FindNext(sr);
    finally
      SysUtils.FindClose(sr);
    end;
  Result := RemoveDir(_Dirname, _RaiseException, _Force);
end;

class function TFileSystem.ReadTextFile(const _Filename: string): string;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromFile(_Filename);
    Result := sl.Text;
  finally
    FreeAndNil(sl);
  end;
end;

class function TFileSystem.IsFileReadonly(const _Filename: string): boolean;
var
  Attributes: Word;
begin
  Result := False;
  if FileExists(_Filename) then begin
    Attributes := FileGetAttr(_Filename);
    Result := ((Attributes and SysUtils.faReadOnly) <> 0);
  end;
end;

class function TFileSystem.IsValidFilename(const _s: string; out _ErrPos: integer; _AllowDot: boolean = true): boolean;
var
  i: Integer;
  NotAllowed: TCharSet;
begin
  Result := False;

  if _s = '' then begin
    _ErrPos := 0;
    exit;
  end;

  if Length(_s) > MAX_PATH then begin
    _ErrPos := MAX_PATH;
    exit;
  end;

  NotAllowed := INVALID_FILENAME_CHARS;
  if not _AllowDot then
    Include(NotAllowed, '.');
  for i := 1 to Length(_s) do begin
    if CharInSet(_s[i], NotAllowed) then begin
      _ErrPos := i;
      Exit;
    end;
  end;
  Result := True;
end;

class function TFileSystem.IsValidFilename(const _s: string; _AllowDot: boolean = true): boolean;
var
  ErrPos: integer;
begin
  Result := IsValidFilename(_s, ErrPos, _AllowDot);
end;

class function TFileSystem.ExtractFileExtFull(const _Filename: string): string;
var
  p: Integer;
begin
  p := Pos('.', _Filename);
  if p = 0 then
    Result := ''
  else
    Result := TailStr(_Filename, p + 1);
  if Result <> '' then
    Result := '.' + Result;
end;

class function TFileSystem.RemoveFileExtFull(const _Filename: string): string;
var
  Path: string;
  fn: string;
  p: Integer;
begin
  Path := ExtractFilePath(_FileName);
  fn := ExtractFileName(_Filename);
  p := Pos('.', fn);
  if p = 0 then
    Result := fn
  else
    Result := LeftStr(fn, p - 1);

  if Path <> '' then begin
    itpd(Path);
    Result := Path + Result;
  end;
end;

class function TFileSystem.ChangeFileExtFull(const _Filename: string; const _NewExt: string): string;
begin
  Result := RemoveFileExtFull(_Filename) + _NewExt;
end;

{ TProgressRedir }

constructor TProgressRedir.Create(_OnProgress: TCopyFileProgressEvt);
begin
  inherited Create;
  FOnProgress := _OnProgress;
end;

function TProgressRedir.doProgress(): TCopyProgressStatus.TProgressResult;
begin
  Result := prContinue;
  try
    if Assigned(FOnProgress) then
      FOnProgress(Self, Result);
  except
    on e: Exception do begin
      FExceptAddr := ExceptAddr;
      FExceptMsg := e.Message;
      FExceptClass := e.ClassName;
    end;
  end;
end;

{ TFileGenerationHandler }

constructor TFileGenerationHandler.Create(const _BaseName, _Suffix: string);
begin
  inherited Create;
  FMaxGenerations := 5;
  FOldestIsHighest := true;
  FResultContainsNumber := false;
  FPrependZeros := 0;
  FBaseName := _BaseName;
  FSuffix := _Suffix;
end;

function TFileGenerationHandler.Execute(_KeepOriginal: boolean): string;

  function doNoNumberOldIsHighest(): string;
  var
    i: Integer;
    dst: string;
    src: string;
    MaxGen: integer;
  begin
    MaxGen := FMaxGenerations - 1;
    for i := MaxGen - 1 downto 1 do begin
      dst := GenerateFilename(i + 1);
      if FileExists(dst) then
        TFileSystem.DeleteFile(dst);
      src := GenerateFilename(i);
      if FileExists(src) then
        TFileSystem.MoveFile(src, dst);
    end;
    dst := GenerateFilename(1);
    Result := GenerateFilename(0);
    if FileExists(dst) then
      TFileSystem.DeleteFile(dst);
    if FileExists(Result) then begin
      if _KeepOriginal then
        TFileSystem.CopyFile(Result, dst, true)
      else
        TFileSystem.MoveFile(Result, dst);
    end;
  end;

  function doNumberOldIsHighest(): string;
  var
    i: Integer;
    dst: string;
    src: string;
    MaxGen: integer;
  begin
    MaxGen := FMaxGenerations;
    for i := MaxGen - 1 downto 1 do begin
      dst := GenerateFilename(i + 1);
      if FileExists(dst) then
        TFileSystem.DeleteFile(dst);
      src := GenerateFilename(i);
      if FileExists(src) then
        TFileSystem.MoveFile(src, dst);
    end;
    Result := GenerateFilename(1);
  end;

  function doNoNumberOldIsLowest(): string;
  var
    i: Integer;
    MaxGen: integer;
    src: string;
    dst: string;
    SlotFound: Boolean;
  begin
    Result := GenerateFilename(0);
    if not FileExists(Result) then
      exit;

    SlotFound := false;
    MaxGen := FMaxGenerations - 1;
    for i := 1 to MaxGen do begin
      dst := GenerateFilename(i);
      if not FileExists(dst) then begin
        SlotFound := true;
        break;
      end;
    end;

    if not SlotFound then begin
      dst := GenerateFilename(1);
      if FileExists(dst) then
        TFileSystem.DeleteFile(dst);
      for i := 2 to MaxGen do begin
        src := GenerateFilename(i);
        if FileExists(src) then
          TFileSystem.MoveFile(src, dst);
        dst := src;
      end;
    end;

    if _KeepOriginal then
      TFileSystem.CopyFile(Result, dst, true)
    else
      TFileSystem.MoveFile(Result, dst);
  end;

  function doNumberOldIsLowest(): string;
  var
    i: Integer;
    MaxGen: integer;
  begin
    MaxGen := FMaxGenerations;
    for i := 1 to MaxGen do begin
      Result := GenerateFilename(i);
      if not FileExists(Result) then
        exit;
    end;

    TFileSystem.DeleteFile(GenerateFilename(1));
    for i := 2 to MaxGen do begin
      TFileSystem.MoveFile(GenerateFilename(i), GenerateFilename(i - 1));
    end;
    Result := GenerateFilename(MaxGen);
    if _KeepOriginal then
      TFileSystem.CopyFile(GenerateFilename(MaxGen - 1), Result, true);
  end;

begin
  if FResultContainsNumber then begin
    if _KeepOriginal then
      raise EInvalidPropertyCombination.Create(_('Combination of ResultContainsNumber and KeepOriginal is not allowed'));
    if FOldestIsHighest then begin
      Result := doNumberOldIsHighest();
    end else begin
      Result := doNumberOldIsLowest();
    end;
  end else begin
    if FOldestIsHighest then begin
      Result := doNoNumberOldIsHighest();
    end else begin
      Result := doNoNumberOldIsLowest();
    end;
  end;
end;

function TFileGenerationHandler.GenerateFilename(_Generation: integer): string;
begin
  if _Generation = 0 then
    Result := FBaseName + FSuffix
  else begin
    if FPrependZeros = 0 then
      Result := FBaseName + '_' + IntToStr(_Generation) + FSuffix
    else
      Result := Format('%s_%.*u%s', [FBaseName, FPrependZeros, _Generation, FSuffix]);
  end;
  if Assigned(FOnGenerateFilename) then
    FOnGenerateFilename(Self, _Generation, Result);
end;

{ TDirectorySync }

//procedure TDirectorySync.doOnDifferentFileExists(const _Filename: string; var _Action: TFileExistsAction);
//begin
//  _Action := feaIgnore;
//  if Assigned(FOnDifferentFileExists) then
//    FOnDifferentFileExists(_Filename, _Action);
//end;

function TDirectorySync.doOnFileExists(const _SrcDir, _DstDir, _Filename: string): TFileExistsAction;
var
  Src: TFileInfoRec;
  Dst: TFileInfoRec;
begin
  Result := feaIgnore;
  if not Assigned(FOnFileExists) then
    exit;
  if not TFileSystem.TryGetFileInfo(_SrcDir + _Filename, Src) then
    exit;
  if not TFileSystem.TryGetFileInfo(_DstDir + _Filename, Dst) then
    exit;

  FOnFileExists(self, Src, Dst, Result);
end;

function TDirectorySync.doOnQueryFileSync(const _SrcFile, _DstFile: string): TQueryFileSyncAction;
var
  Src: TFileInfoRec;
begin
  Result := fsaCopy;
  if not Assigned(FOnQueryFileSync) then
    exit;

  if not TFileSystem.TryGetFileInfo(_SrcFile, Src) then begin
    // File vanished
    Result := fsaSkip;
    exit;
  end;
  FOnQueryFileSync(self, Src, _DstFile, Result);
end;

procedure TDirectorySync.doOnSyncingDir(const _SrcDir, _DstDir: string);
begin
  if Assigned(FOnSyncingDir) then
    FOnSyncingDir(Self, _SrcDir, _DstDir);
end;

procedure TDirectorySync.doOnSyncingFile(const _SrcFile, _DstFile: string; _Total, _Done: Int64);
begin
  if Assigned(FOnSyncingFile) then
    FOnSyncingFile(self, _SrcFile, _DstFile, _Total, _Done);
end;

procedure TDirectorySync.ProgressStatusCallback(_Status: TCopyProgressStatus;
  var _Continue: TCopyProgressStatus.TProgressResult);
begin
  try
    doOnSyncingFile(FCurrentSource, FCurrentDest, _Status.TotalFileSize.QuadPart, _Status.TotalBytesTransferred.QuadPart);
  except
    on e: EAbort do
      _Continue := prCancel;
  end;
end;

procedure TDirectorySync.CheckOneWay(const _SrcDir, _DstDir: string);
var
  Filename: string;
  EnumA: TSimpleDirEnumerator;
  DstDirBS: string;
  SrcDirBS: string;
begin
  doOnSyncingDir(_SrcDir, _DstDir);
  SrcDirBS := itpd(_SrcDir);
  DstDirBS := itpd(_DstDir);
  EnumA := TSimpleDirEnumerator.Create(SrcDirBS + '*.*');
  try
    while EnumA.FindNext(Filename) do begin
      if (EnumA.Sr.Attr and SysUtils.faDirectory) <> 0 then begin
        CheckOneWay(SrcDirBS + Filename, DstDirBS + Filename);
      end else if FileExists(DstDirBS + Filename) then begin
        doOnFileExists(SrcDirBS, DstDirBS, Filename);
      end else begin
        doOnSyncingFile(SrcDirBS + Filename, DstDirBS + Filename, EnumA.Sr.Size, 0);
      end;
    end;
  finally
    FreeAndNil(EnumA);
  end;
end;

procedure TDirectorySync.SyncOneWay(const _SrcDir, _DstDir: string; _FlattenDirHierarchy: boolean = false);
var
  Filename: string;
  EnumA: TSimpleDirEnumerator;
  DstDirBS: string;
  SrcDirBS: string;
begin
  doOnSyncingDir(_SrcDir, _DstDir);
  SrcDirBS := itpd(_SrcDir);
  DstDirBS := itpd(_DstDir);
  if not DirectoryExists(DstDirBS) then
    TFileSystem.ForceDir(DstDirBS);
  EnumA := TSimpleDirEnumerator.Create(SrcDirBS + '*.*');
  try
    while EnumA.FindNext(Filename) do begin
      FCurrentSource := SrcDirBS + Filename;
      if (EnumA.Sr.Attr and SysUtils.faDirectory) <> 0 then begin
        if _FlattenDirHierarchy then
          FCurrentDest := _DstDir
        else begin
          FCurrentDest := DstDirBS + Filename;
        end;
        SyncOneWay(FCurrentSource, FCurrentDest, _FlattenDirHierarchy);
      end else begin
        FCurrentDest := DstDirBS + Filename;
        if FileExists(FCurrentDest) then begin
          if doOnFileExists(SrcDirBS, DstDirBS, Filename) = feaOverwrite then begin
            doOnSyncingFile(FCurrentSource, FCurrentDest, EnumA.Sr.Size, 0);
            if cfwOK <> TFileSystem.CopyFileWithProgress(FCurrentSource, FCurrentDest, ProgressStatusCallback, []) then
              SysUtils.Abort;
          end;
        end else if doOnQueryFileSync(FCurrentSource, FCurrentDest) = fsaCopy then begin
          doOnSyncingFile(FCurrentSource, FCurrentDest, EnumA.Sr.Size, 0);
          if cfwOK <> TFileSystem.CopyFileWithProgress(FCurrentSource, FCurrentDest, ProgressStatusCallback, [cfwFailIfExists]) then
            SysUtils.Abort;
        end;
      end;
    end;
  finally
    FreeAndNil(EnumA);
  end;
end;

procedure TDirectorySync.SyncBothWays(const _DirA, _DirB: string);
begin
  SyncOneWay(_DirA, _DirB);
  SyncOneWay(_DirB, _DirA);
end;

{ TUniqueTempDir }

constructor TUniqueTempDir.Create(const _Path: string);
begin
  inherited Create;
  FPath := _Path;
end;

destructor TUniqueTempDir.Destroy;
begin
  // delete directory, fail silently on errors
  TFileSystem.DelDirTree(FPath, False);
  inherited;
end;

function TUniqueTempDir.Path: string;
begin
  Result := FPath;
end;

end.

