{.GXFormatter.config=twm}
/// <summary>
/// Implements functions which work on classes but are not methods.
/// @autor(twm)
/// </summary>
unit u_dzClassUtils;

interface

uses
  SysUtils,
  Classes,
  Contnrs,
  IniFiles,
  u_dzTranslator;

// NOTE: The naming convention is <extended-class>_<Methodname>

type
  /// <summary>
  /// raised by StringByObj if no matching entry was found
  /// </summary>
  EObjectNotFound = class(Exception);

/// <summary>
/// Removes trailing spaces from all lines in Strings as well as empty lines
/// from the end of Strings, returns true if at least one string was shortened
/// or an empty string was removed.
/// @param Strings is the TStrings class to work on.
/// @returns true, if something was changed, false otherwise
/// </summary>
function TStrings_RemoveTrailingSpaces(_Strings: TStrings): boolean;

/// <summary>
/// Free a TStrings object including all it's Object[n]s
/// </summary>
procedure TStrings_FreeWithObjects(_Strings: TStrings);

/// <summary>
/// Frees all objects stored in the TStrings intance and returns the instance,
/// meant to be called like
/// @code( TStrings_FreeAllObjects(sl).Free; ) or
/// @code( TStrings_FreeAllObjects(sl).Clear; )
/// </summary>
function TStrings_FreeAllObjects(_Strings: TStrings): TStrings;

/// <summary>
/// frees the object and delets the entry from the list
/// </summary>
procedure TStrings_DeleteAndFreeObject(_Strings: TStrings; _Idx: integer);

///<summary>
/// searches the given Obj in _Strings.Objects (does a linear search)
/// @param Obj is the object to search for
/// @param Idx will contain the index of the item, if found. Only valid if result is true
/// @returns true, if found, false otherwise
function TStrings_GetObjectIndex(_Strings: TStrings; _Obj: pointer; out _Idx: integer): boolean;

/// <summary>
/// Free a TList object an all TObjects it contains
/// NOTE: this function is obsolete, use contnrs.TObjectList instead!
/// </summary>
procedure TList_FreeWithItems(var _List: TList); deprecated; // use contnrs.TObjectList

/// <summary>
/// Extracts the Idx'th item from the list without freeing it.
/// </summary>
function TObjectList_Extract(_lst: TObjectList; _Idx: integer): TObject;

/// <summary>
/// Write a string to the stream
/// @param Stream is the TStream to write to.
/// @param s is the string to write
/// @returns the number of bytes written.
/// </summary>
function TStream_WriteString(_Stream: TStream; const _s: string): integer;

/// <summary>
/// Write a ShortString to the stream as binary, that is the length byte followed by len content bytes
/// @param Stream is the TStream to write to.
/// @param s is the string to write
/// @returns the number of bytes written.
/// </summary>
function TStream_WriteShortStringBinary(_Stream: TStream; const _s: ShortString): integer;

/// <summary>
/// Reads a ShortString as written by TStream_WriteShortStringBinary
/// @param Stream is the TStream to write to.
/// @returns the string read
/// </summary>
function TStream_ReadShortStringBinary(_Stream: TStream): ShortString;

/// <summary>
/// Write a string to the stream appending CRLF
/// @param Stream is the TStream to write to.
/// @param s is the string to write
/// @returns the number of bytes written.
/// </summary>
function TStream_WriteStringLn(_Stream: TStream; const _s: string): integer;

/// <summary>
/// Read a line from a stream, that is, a string ending in CRLF
/// @param Stream is the TStream to read from.
/// @param s returns the read string, without the CRLF
/// @returns the number of bytes read, excluding the CRLF
/// </summary>
function TStream_ReadStringLn(_Stream: TStream; out _s: string): integer;

/// <summary>
/// Write formatted data to the stream appending CRLF
/// @param Stream is the TStream to write to.
/// @param Format is a format string as used in sysutils.format
/// @param Args is an array of const as used in sysutils.format
/// @returns the number of bytes written.
/// </summary>
function TStream_WriteFmtLn(_Stream: TStream; const _Format: string; _Args: array of const): integer;

/// <summary>
/// returns the string which has the given value as Object
/// @param Strings is the TStrings to search
/// @param Obj is a pointer to match
/// @param RaiseException is a boolean that controls whether an exception should
///           be raised (if true) if the Obj cannot be found or an empty strin should
///           be returned (if false), Default = true
/// @returns the string whose object matches Obj or an empty string, if none
///          was found and RaiseExeption was false
/// @raises EObjectNotFound if a matching object was not found and RaiseException
///         is true.
/// </summary>
function TStrings_StringByObj(_Strings: TStrings; _Obj: pointer; _RaiseException: boolean = true): string;

/// <summary>
/// determines the string which has the given value as Object
/// @param Strings is the TStrings to search
/// @param Obj is a pointer to match
/// @param Value is the string whose object matches Obj, only valid if result is true
/// @returns true, if a matching object was found, false otherwise
/// </summary>
function TStrings_TryStringByObj(_Strings: TStrings; _Obj: pointer; out _Value: string): boolean;

/// <summary>
/// reads a char from an ini file, if the value is longer than one char, it returns
/// the first char, if it is empty, it returns the default
/// </summary>
function TIniFile_ReadChar(_Ini: TCustomIniFile; const _Section, _Ident: string; _Default: char): char;

///<summary> Like TIniFile.ReadString but allows to specify whether to use the Default if the read string
///          is empty. </summary>
function TIniFile_ReadString(_Ini: TCustomIniFile; const _Section, _Ident: string; const _Default: string; _DefaultIfEmtpy: boolean = false): string; overload;
///<summary> Like TIniFile.ReadString but allows to specify whether to use the Default if the read string
///          is empty. </summary>
function TIniFile_ReadString(const _Filename: string; const _Section, _Ident: string; const _Default: string; _DefaultIfEmtpy: boolean = false): string; overload;
///<summary>
/// Reads a string from the ini-file, raises an exception if the value is empty </summary>
function TIniFile_ReadString(_Ini: TCustomIniFile; const _Section, _Ident: string): string; overload;

///<summary>
/// reads a string list from an ini file section of the form
/// [section]
/// count=2
/// Item0=blab
/// Item1=blub
/// @returns the number of strings read
/// </summary>
function TIniFile_ReadStrings(_Ini: TCustomIniFile; const _Section: string; _st: TStrings): integer;

///<summary>
/// Tries to read a floating point value from the ini-file, always using '.' as decimal separator.
/// @returns true, if a value could be read and converted
///</summary>
function TIniFile_TryReadFloat(_Ini: TCustomIniFile; const _Section, _Ident: string; out _Value: extended): boolean; overload;
function TIniFile_ReadFloat(_Ini: TCustomIniFile; const _Section, _Ident: string; out _Value: extended): boolean; overload deprecated; // use TryReadFloat instead
function TIniFile_ReadFloat(_Ini: TCustomIniFile; const _Section, _Ident: string): extended; overload;

///<summary>
/// Writes a floating point value to the ini-file, always using '.' as decimal separator.
///</summary>
procedure TIniFile_WriteFloat(_Ini: TCustomIniFile; const _Section, _Ident: string; _Value: extended);

///<summary>
/// Reads an integer from the ini-file, raises an exception if the value is not an integer </summary>
function TIniFile_ReadInt(_Ini: TCustomIniFile; const _Section, _Ident: string): integer;

/// <summary>
/// Reads the given section from the given .INI file and returns it as a TStrings
/// @raises Exception if the section does not exist. </summary>
procedure TIniFile_ReadSection(const _Filename, _Section: string; _sl: TStrings); inline;

implementation

uses
  StrUtils,
  u_dzConvertUtils,
  u_dzStringUtils;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

procedure TList_FreeWithItems(var _List: TList);
var
  i: integer;
begin
  if Assigned(_List) then begin
    for i := 0 to _List.Count - 1 do
      TObject(_List[i]).Free;
    _List.Free;
    _List := nil;
  end;
end;

function TObjectList_Extract(_lst: TObjectList; _Idx: integer): TObject;
var
  b: boolean;
begin
  b := _lst.OwnsObjects;
  _lst.OwnsObjects := false;
  try
    Result := _lst[_Idx];
    _lst.Delete(_Idx);
  finally
    _lst.OwnsObjects := b;
  end;
end;

function TStrings_RemoveTrailingSpaces(_Strings: tStrings): boolean;
var
  i: integer;
  s: string;
  Trailing: boolean;
  p: integer;
  Len: integer;
begin
  Result := false;
  Trailing := true;
  for i := _Strings.Count - 1 downto 0 do begin
    s := _Strings[i];
    Len := Length(s);
    p := Len;
    while (p > 0) and (s[p] = ' ') do
      Dec(p);
    if Len <> p then begin
      Result := true;
      s := LeftStr(s, p);
    end;
    if Trailing and (s = '') then begin
      Result := true;
      _Strings.Delete(i);
    end else begin
      Trailing := false;
      _Strings[i] := s;
    end;
  end;
end;

function TStrings_FreeAllObjects(_Strings: TStrings): TStrings;
var
  i: Integer;
begin
  for i := 0 to _Strings.Count - 1 do
    _Strings.Objects[i].Free;
  Result := _Strings;
end;

procedure TStrings_FreeWithObjects(_Strings: TStrings);
begin
  TStrings_FreeAllObjects(_Strings).Free;
end;

procedure TStrings_DeleteAndFreeObject(_Strings: TStrings; _Idx: integer);
begin
  _Strings.Objects[_Idx].Free;
  _Strings.Delete(_Idx);
end;

function TStrings_GetObjectIndex(_Strings: TStrings; _Obj: pointer; out _Idx: integer): boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to _Strings.Count - 1 do begin
    Result := (_Strings.Objects[i] = _Obj);
    if Result then begin
      _Idx := i;
      exit;
    end;
  end;
end;

function TStream_WriteString(_Stream: TStream; const _s: string): integer;
begin
  Result := _Stream.Write(pChar(_s)^, Length(_s));
end;

function TStream_WriteShortStringBinary(_Stream: TStream; const _s: ShortString): integer;
var
  Len: Byte;
begin
  Len := Ord(_s[0]);
  Result := _Stream.Write(Len, SizeOf(Len));
  if Len > 0 then
    Result := Result + _Stream.Write(_s[1], Len);
end;

function TStream_ReadShortStringBinary(_Stream: TStream): ShortString;
var
  Len: byte;
begin
  _Stream.Read(Len, SizeOf(Len));
  Result[0] := AnsiChar(Chr(Len));
  if Len > 0 then
    _Stream.Read(Result[1], Len);
end;

function TStream_WriteStringLn(_Stream: TStream; const _s: string): integer;
begin
  Result := TStream_WriteString(_Stream, _s);
  Result := Result + TStream_WriteString(_Stream, #13#10);
end;

function TStream_WriteFmtLn(_Stream: TStream; const _Format: string; _Args: array of const): integer;
begin
  Result := TStream_WriteStringLn(_Stream, Format(_Format, _Args));
end;

function TStream_ReadStringLn(_Stream: TStream; out _s: string): integer;
var
  OldPos: integer;
  EndString: integer;
  NewPos: integer;
  c: char;
begin
  Assert(SizeOf(c) = 1, 'This works only with one byte characters!'); // do not translate

  // twm: this is not really efficient, because it reads single bytes, if it becomes a problem, optimize it ;-)
  OldPos := _Stream.Position;
  EndString := OldPos;
  NewPos := OldPos;
  while true do begin
    if _Stream.Read(c, 1) = 0 then begin // end of file
      EndString := _Stream.Position;
      NewPos := EndString;
      break;
    end else if c = #13 then begin
      EndString := _Stream.Position - 1;
      if _Stream.Read(c, 1) = 0 then
        NewPos := _Stream.Position
      else if c = #10 then
        NewPos := _Stream.Position
      else
        NewPos := _Stream.Position - 1;
      break;
    end;
  end;
  Result := EndString - OldPos;
  SetLength(_s, Result);
  if Result <> 0 then begin
    _Stream.Position := OldPos;
    _Stream.Read(_s[1], Length(_s));
  end;
  _Stream.Position := NewPos;
end;

function TStrings_TryStringByObj(_Strings: TStrings; _Obj: pointer; out _Value: string): boolean;
var
  i: integer;
begin
  for i := 0 to _Strings.Count - 1 do
    if _Strings.Objects[i] = _Obj then begin
      _Value := _Strings[i];
      Result := true;
      exit;
    end;
  Result := false;
end;

function TStrings_StringByObj(_Strings: TStrings; _Obj: pointer; _RaiseException: boolean = true): string;
begin
  if not TStrings_TryStringByObj(_Strings, _Obj, Result) then begin
    if _RaiseException then
      raise EObjectNotFound.Create(_('no matching object found'));
    Result := '';
  end;
end;

function TIniFile_ReadChar(_Ini: TCustomIniFile; const _Section, _Ident: string; _Default: char): char;
var
  s: string;
begin
  s := _Ini.ReadString(_Section, _Ident, _Default);
  if s = '' then
    s := _Default;
  Result := s[1];
end;

function TIniFile_ReadString(_Ini: TCustomIniFile; const _Section, _Ident: string; const _Default: string; _DefaultIfEmtpy: boolean = false): string;
begin
  Result := _Ini.ReadString(_Section, _Ident, _Default);
  if (Result = '') and _DefaultIfEmtpy then
    Result := _Default;
end;

function TIniFile_ReadString(const _Filename: string; const _Section, _Ident: string; const _Default: string; _DefaultIfEmtpy: boolean = false): string; overload;
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(_Filename);
  try
    Result := TIniFile_ReadString(Ini, _Section, _Ident, _Default, _DefaultIfEmtpy);
  finally
    FreeAndNil(Ini);
  end;
end;

function TIniFile_ReadString(_Ini: TCustomIniFile; const _Section, _Ident: string): string;
begin
  Result := _Ini.ReadString(_Section, _Ident, '');
  if Result = '' then
    raise Exception.CreateFmt(_('Invalid empty string value in ini file for [%s]%s'), [_Section, _Ident]);
end;

function TIniFile_ReadStrings(_Ini: TCustomIniFile; const _Section: string; _st: TStrings): integer;
var
  i: integer;
begin
  Result := _Ini.ReadInteger(_Section, 'Count', 0);
  for i := 0 to Result - 1 do
    _st.Add(_Ini.ReadString(_Section, 'Item' + IntToStr(i), ''));
end;

function TIniFile_TryReadFloat(_Ini: TCustomIniFile; const _Section, _Ident: string; out _Value: extended): boolean;
var
  s: string;
begin
  s := _Ini.ReadString(_Section, _Ident, '');
  Result := TryStr2Float(s, _Value);
end;

function TIniFile_ReadFloat(_Ini: TCustomIniFile; const _Section, _Ident: string; out _Value: extended): boolean;
begin
  Result := TIniFile_TryReadFloat(_Ini, _Section, _Ident, _Value);
end;

function TIniFile_ReadFloat(_Ini: TCustomIniFile; const _Section, _Ident: string): extended;
var
  s: string;
begin
  s := _Ini.ReadString(_Section, _Ident, '');
  if not TryStr2Float(s, Result) then
    raise Exception.CreateFmt(_('Invalid floating point value %s in ini file for [%s]%s'), [s, _Section, _Ident]);
end;

procedure TIniFile_WriteFloat(_Ini: TCustomIniFile; const _Section, _Ident: string; _Value: extended);
begin
  _Ini.WriteString(_Section, _Ident, Float2Str(_Value));
end;

function TIniFile_ReadInt(_Ini: TCustomIniFile; const _Section, _Ident: string): integer;
var
  s: string;
begin
  s := _Ini.ReadString(_Section, _Ident, '');
  if not TryStrToInt(s, Result) then
    raise Exception.CreateFmt(_('Invalid integer value "%s" in ini file for [%s]%s'), [s, _Section, _Ident]);
end;

procedure TIniFile_ReadSection(const _Filename, _Section: string; _sl: TStrings);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(_Filename);
  try
    if not Ini.SectionExists(_Section) then
      raise Exception.CreateFmt('Section %s does not exist in file %s.', [_Section, _Filename]);
    Ini.ReadSection(_Section, _sl);
  finally
    FreeAndNil(Ini);
  end;
end;

end.

