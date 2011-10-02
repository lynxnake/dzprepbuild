{.GXFormatter.config=twm}
/// <summary>
/// Integer to string and string to integer conversion functions for decimal
/// hexadecimal and custom number bases. This was taken from u_dzStringUtils
/// which originally was a Delphi conversion of TwmStringFunc.
/// </summary>
unit u_dzConvertUtils;

{$I jedi.inc}

interface

uses
  SysUtils,
  u_dzTranslator;

var
  /// <summary>
  /// contains the User's format setting, but with decimal separator = '.' and no thousands separator
  /// </summary>
  DZ_FORMAT_DECIMAL_POINT: TFormatSettings;

type
  /// <summary>
  /// Raised by the number conversion functions if a digit is invalid for the
  /// given base.
  /// </summary>
  EdzConvert = class(Exception);
  EDigitOutOfRange = class(EdzConvert);
  /// <summary>
  /// raised if there is a conversion error in one of the Str2XxxEx functions
  /// </summary>
  EStringConvertError = class(EdzConvert);

type
  ULong = LongWord;

type
  TBaseN = 2..36;

const
  MinInt64 = Int64($8000000000000000);
  MaxInt64 = Int64($7FFFFFFFFFFFFFFF);
  MaxLongWord = $FFFFFFFF;

const
  /// <summary>
  /// String containing all characters that can be used as digits
  /// </summary>
  DIGIT_CHARS: string = '0123456789ABCDEFGHIJKlMNOPQRSTUVWXYZ';

// Str <-> Decimal conversion
/// <summary>
/// Returns true if A is a valid decimal digit
/// </summary>
function isDecDigit(_a: char): boolean;
/// <summary>
/// Returns true if S is a valid positive decimal number
/// </summary>
function isDec(const _s: string): boolean;
/// <summary>
/// Converts a decimal digit to its number equivalent
/// Raises EDigitOutOfRange if there is an invalid digit.
/// </summary>
function DecDigit2Long(_a: char): LongInt;
/// <summary>
/// Converts a string representing a positive decimal number to a number
///   Raises EDigitOutOfRange if there is an invalid digit.
/// </summary>
function Dec2Long(const _s: string): ULong;
/// <summary>
/// Converts a positive number to its 2 digit decimal representation (left pads with '0')
/// </summary>
function Long2Dec2(_l: ULong): string;
/// <summary>
/// Converts a positive number to its 4 digit decimal representation (left pads with '0')
/// </summary>
function Long2Dec4(_l: ULong): string;
/// <summary>
/// Converts a positive number to its N digit decimal representation (left pads with '0')
/// </summary>
function Long2DecN(_l: ULong; _n: ULong): string;
/// <summary>
/// Converts a positive number to its decimal representation
/// </summary>
function Long2Dec(_l: ULong): string;

// Str <-> Hex conversion
/// <summary>
/// Returns true if A is a valid hexadecimal (base 16) digit
/// </summary>
function isHexDigit(_a: char): boolean;
/// <summary>
/// Returns true if S is a valid hexadecimal (base 16) number
/// </summary>
function isHex(const _s: string): boolean;
/// <summary>
/// Converts a hexadecimal digit to its number equivalent
/// Raises EDigitOutOfRange if there is an invalid digit.
/// </summary>
function HexDigit2Long(_a: char): LongInt;
/// <summary>
/// Converts a string representing a hexadecimal number to a number
/// @Raises EDigitOutOfRange if there is an invalid digit. }
/// </summary>
function Hex2Long(const _s: string): ULong;
/// <summary>
/// Converts a number to its hexadecimal representation }
/// </summary>
function Long2Hex(_l: ULong): string;
/// <summary>
/// converts a number to its hexadecimal representation left padding with 0 to a length of 2 }
/// </summary>
function Long2Hex2(_l: ULong): string;

// Str <-> any numeric system conversion
/// <summary>
/// Returns true if A is a valid digit in the given Base. }
/// </summary>
function isDigit(_a: char; _Base: TBaseN): boolean;
/// <summary>
/// Returns true if S is a valid number in the given Base. }
/// </summary>
function isNumber(const _s: string; _Base: TBaseN): boolean;
/// <summary>
/// Converts a Base digit to its number equivalent.
/// @Raises EDigitOutOfRange if there is an invalid digit. }
/// </summary>
function Digit2Long(_a: char; _Base: TBaseN): LongInt;
/// <summary>
/// Converts a string representing a number in Base to a number.
/// @Raises EDigitOutOfRange if there is an invalid digit. }
/// </summary>
function Num2Long(const _s: string; _Base: TBaseN): ULong;
/// <summary>
/// Converts a number to its Base representation. }
/// </summary>
function Long2Num(_l: ULong; _Base: byte): string;
/// <summary>
/// Returns the number of characters in S that are valid digits in the given Base. }
/// </summary>
function isNumberN(const _s: string; _Base: TBaseN): integer;

/// <summary>
/// Converts a string of the form '-hh:mm:ss', 'hh:mm:ss',
/// '+hh:mm:ss', 'mm:ss' or 'ss' to a number of seconds.
/// </summary>
function TimeStrToSeconds(const _Zeit: string): integer;
/// <summary>
/// deprecated, use SecondsToTimeStr instead
/// </summary>
function SecondsToStr(_Seconds: integer): string; deprecated;
/// <summary>
/// Converts a number of seconds to a string of the form
/// 'hh:mm:ss'. The string will always contain hours and minutes
/// even if Seconds < 60.
/// </summary>
function SecondsToTimeStr(_Seconds: integer): string;
{$IFDEF Delphi7up}
function TimeToSeconds(_Zeit: TDateTime): integer; deprecated;
{$ENDIF}

/// <summary>
/// Converts a string to an integer.
/// If s can not be converted, it returns the Default.
/// @param(s string to convert)
/// @param(Default value to return if s can not be converted)
/// @returns(the integer value of s or Default, if s can not be converted) }
/// </summary>
function Str2Int(_s: string; _Default: integer): integer; overload;

/// <summary>
/// Converts a string to an integer.
/// If s can not be converted, it raises an exception EStringConvertError.
/// @param(s string to convert)
/// @param(Source string to include in the exception message)
/// @returns(the integer value of s)
/// @raises(EStringConvertError if s can not be converted) }
/// </summary>
function Str2Int(_s: string; const _Source: string): integer; overload;

/// <summary>
/// Converts a string to an int64.
/// If s can not be converted, it returns the Default.
/// @param(s string to convert)
/// @param(Default value to return if s can not be converted)
/// @returns(the int64 value of s or Default, if s can not be converted) }
/// </summary>
function Str2Int64(_s: string; _Default: Int64): Int64; overload;

/// <summary>
/// Converts a string to an int64.
/// If s can not be converted, it raises an exception EStringConvertError.
/// @param(s string to convert)
/// @param(Source string to include in the exception message)
/// @returns(the integer value of s)
/// @raises(EStringConvertError if s can not be converted) }
/// </summary>
function Str2Int64(_s: string; const _Source: string): Int64; overload;

/// <summary>
/// tries to guess the decimal separator }
/// </summary>
function GuessDecimalSeparator(const _s: string): char;

/// <summary>
/// Converts a string to a float.
/// If s can not be converted, it returns the Default.
/// @param s string to convert
/// @param Default value to return if s can not be converted
/// @param DecSeparator is the decimal separator, defaults to '.'
///        if passed as #0, GuessDecimalSeparator is called to guess it
/// @returns the float value of s or Default, if s can not be converted }
/// </summary>
function Str2Float(_s: string; _Default: extended; _DecSeparator: char = '.'): extended; overload;

/// <summary>
/// Converts a string to a float.
/// If s can not be converted, it raises an exception EStringConvertError.
/// @param(s string to convert)
/// @param(Source string to include in the exception message)
/// @param DecSeparator is the decimal separator, defaults to '.'
///        if passed as #0, GuessDecimalSeparator is called to guess it
/// @returns(the float value of s)
/// @raises(EStringConvertError if s can not be converted) }
/// </summary>
function Str2Float(_s: string; const _Source: string; _DecSeparator: char = '.'): extended; overload;

/// <summary>
/// tries to convert a string to a float, returns false if it fails
/// @param s is the string to convert
/// @param flt is the float, only valid if the function returns true
/// @param DecSeparator is the decimal separator to use, defaults to '.',
///        if passed as #0, GuessDecimalSeparator is called to guess it
/// @returns true, if s could be converted, false otherwise }
/// </summary>
function TryStr2Float(_s: string; out _flt: extended; _DecSeparator: char = '.'): boolean; overload;
/// <summary>
/// tries to convert a string to a float, returns false if it fails
/// @param s is the string to convert
/// @param flt is the float, only valid if the function returns true
/// @param DecSeparator is the decimal separator to use, defaults to '.',
///        if passed as #0, GuessDecimalSeparator is called to guess it
/// @returns true, if s could be converted, false otherwise }
/// </summary>
function TryStr2Float(_s: string; out _flt: double; _DecSeparator: char = '.'): boolean; overload;
function TryStr2Float(_s: string; out _flt: single; _DecSeparator: char = '.'): boolean; overload;

/// <summary>
/// Converts a floating point number to a string using the given decimal separator
/// in "General number format" with 15 significant digits
/// @param(flt is an extended floating point value)
/// @param(DecSeparator is the decimal separator to use)
/// @returns(a string representation of the floating point value) }
/// </summary>
function Float2Str(_flt: extended; _DecSeparator: char = '.'): string; overload;

/// <summary>
/// Converts a floating point number to a string using the given with, number of decimals
/// and a '.' as decimal separator, if width is too small the smallest representation possible
/// will be used (eg. Float2Str(5.24, 3, 2, '.') = '5.24')
/// @param flt is an extended floating point value
/// @param Width is the total number of digits (including the decimal separator
/// @param Decimals is the number of decimals to use
/// @returns a string representation of the floating point value }
/// </summary>
function Float2Str(_flt: extended; _Width, _Decimals: integer): string; overload;

/// <summary>
/// Converts a floating point number to a string using the given number of decimals
/// and a '.' as decimal separator.
/// @param flt is an extended floating point value
/// @param Decimals is the number of decimals to use
/// @returns a string representation of the floating point value }
/// </summary>
function Float2Str(_flt: extended; _Decimals: integer): string; overload;

/// <summary>
/// Tries to round a floating point value to a word value
/// @param flt is the value to convert
/// @param wrd returns the word value, only valid if result = true
/// @returns true, if the result can be stored i a word, false otherwise.
/// </summary>
function TryRound(_flt: extended; out _wrd: word): boolean;

/// <summary>
/// these contants refer to the "Xx binary byte" units as defined by the
/// International Electronical Commission (IEC) and endorsed by the
/// IEE and CiPM
/// </summary>
const
  OneKibiByte = Int64(1024);
  OneMebiByte = Int64(1024) * OneKibiByte;
  OneGibiByte = Int64(1024) * OneMebiByte;
  OneTebiByte = Int64(1024) * OneGibiByte;
  OnePebiByte = Int64(1024) * OneTebiByte;
  OneExbiByte = Int64(1024) * OnePebiByte;

/// <summary>
/// Converts a file size to a human readable string, e.g. 536870912000 = 5.00 GiB (gibibyte) }
/// </summary>
function FileSizeToHumanReadableString(_FileSize: Int64): string;

const
  SecondsPerMinute = 60;
  MinutesPerHour = 60;
  SecondsPerHour = SecondsPerMinute * MinutesPerHour;
  HoursPerDay = 24;
  MinutesPerDay = HoursPerDay * MinutesPerHour;
  SecondsPerDay = MinutesPerDay * SecondsPerMinute;

/// <summary>
/// returns a human readable string of the form '5d 23h' or '25h 15m' or '20m 21s' }
/// </summary>
function SecondsToHumanReadableString(_Seconds: Int64): string;

/// <summary>
/// returns the default locale settings as read from the user's regional settings
/// </summary>
function GetUserDefaultLocaleSettings: TFormatSettings; deprecated; // use u_dzStringUtils.GetSystemDefaultLocaleSettings instead
/// <summary>
/// returns the default locale settings as read from the system's regional settings
/// </summary>
function GetSystemDefaultLocaleSettings: TFormatSettings; deprecated; // use u_dzStringUtils.GetSystemDefaultLocaleSettings instead

///<summary>
/// returns the long word split into an array of byte
/// @param Value is the LongWord value to split
/// @param MsbFirst, if true the most significant byte is the first in the array (Motorola format)
///                  if false the least significatn byte is the first in the array (Intel format)
///</summary>
function LongWord2ByteArr(_Value: LongWord; _MsbFirst: boolean = false): TBytes;

///<summary>
/// returns the the array of byte combined into a LongWord
/// @param Value is the array to combine
/// @param MsbFirst, if true the most significant byte is the first in the array (Motorola format)
///                  if false the least significatn byte is the first in the array (Intel format)
///</summary>
function ByteArr2LongWord(const _Arr: array of byte; _MsbFirst: boolean = false): LongWord;

///<summary>
/// returns a 16 bit in reversed byte order, e.g. $1234 => $3412)
/// aka converts intel (little endian) to motorola (big endian) byte order format
/// (This is just an alias for system.swap for consistency with Swap32.)
///</summary
function Swap16(_Value: word): word; inline;

///<summary>
/// returns a 32 bit value in reversed byte order e.g. $12345678 -> $78563412
/// aka converts intel (little endian) to motorola (big endian) byte order format
///</summary>
function Swap32(_Value: LongWord): LongWord;

implementation

uses
  Windows,
  DateUtils,
  StrUtils,
  u_dzStringUtils;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

function isDigit(_a: char; _Base: TBaseN): boolean;
begin
  Result := (Pos(UpCase(_a), LeftStr(DIGIT_CHARS, _Base)) <> 0);
end;

function isNumber(const _s: string; _Base: TBaseN): boolean;
var
  i: integer;
begin
  Result := False;
  if Length(_s) = 0 then
    Exit;
  for i := 1 to Length(_s) do
    if not isDigit(_s[i], _Base) then
      Exit;
  Result := True;
end;

function isNumberN(const _s: string; _Base: TBaseN): integer;
begin
  Result := 0;
  while (Result < Length(_s)) and isDigit(_s[Result + 1], _Base) do
    Inc(Result);
end;

function Digit2Long(_a: char; _Base: TBaseN): LongInt;
begin
  Result := Pos(UpCase(_a), LeftStr(DIGIT_CHARS, _Base));
  if Result = 0 then
    raise EDigitOutOfRange.CreateFmt(_('Digit out of range %s'), [_a]);
  Dec(Result);
end;

function Num2Long(const _s: string; _Base: TBaseN): ULong;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to Length(_s) do
    if isDigit(_s[i], _Base) then
      Result := (Result * _Base + ULong(Pos(UpCase(_s[i]), DIGIT_CHARS)) - 1)
    else
      raise EDigitOutOfRange.CreateFmt(_('Digit #%d (%s) out of range'), [i, _s[i]]);
end;

function Long2Num(_l: ULong; _Base: byte): string;
var
  m: byte;
begin
  Result := '';
  while _l > 0 do begin
    m := _l mod _Base;
    _l := _l div _Base;
    Result := DIGIT_CHARS[m + 1] + Result;
  end;
  if Result = '' then
    Result := '0';
end;

function isHexDigit(_a: char): boolean;
begin
  Result := isDigit(_a, 16);
end;

function isHex(const _s: string): boolean;
begin
  Result := isNumber(_s, 16);
end;

function HexDigit2Long(_a: char): LongInt;
begin
  Result := Digit2Long(_a, 16);
end;

function Hex2Long(const _s: string): ULong;
begin
  Result := Num2Long(_s, 16);
end;

function Long2Hex(_l: ULong): string;
begin
  Result := Long2Num(_l, 16);
end;

function Long2Hex2(_l: ULong): string;
begin
  Result := Long2Hex(_l);
  if Length(Result) < 2 then
    Result := '0' + Result;
end;

function isDecDigit(_a: char): boolean;
begin
  Result := isDigit(_a, 10);
end;

function isDec(const _s: string): boolean;
begin
  Result := isNumber(_s, 10);
end;

function DecDigit2Long(_a: char): LongInt;
begin
  Result := Digit2Long(_a, 10);
end;

function Dec2Long(const _s: string): ULong;
var
  c: integer;
  l: LongInt;
begin
  Val(_s, l, c);
  Result := l
end;

function Long2Dec(_l: ULong): string;
var
  s: AnsiString;
begin
  Str(_l, s);
  Result := string(s);
end;

function Long2Dec2(_l: ULong): string;
begin
  Result := Long2DecN(_l, 2);
end;

function Long2Dec4(_l: ULong): string;
begin
  Result := Long2DecN(_l, 4);
end;

function Long2DecN(_l: ULong; _n: ULong): string;
begin
  Result := Long2Dec(_l);
  if ULong(Length(Result)) < _n then
    Insert(DupeString('0', _n - ULong(Length(Result))), Result, 1);
end;

function TimeToSeconds(_Zeit: TDateTime): integer;
begin
  Result := SecondOfTheDay(_Zeit);
end;

function SecondsToTimeStr(_Seconds: integer): string;
begin
  if _Seconds < 0 then begin
    Result := '-';
    _Seconds := -_Seconds;
  end else
    Result := '';
  Result := Result + Format('%.2d:%.2d:%.2d', [_Seconds div 3600, (_Seconds div 60) mod 60, _Seconds mod 60]);
end;

function SecondsToStr(_Seconds: integer): string;
begin
  Result := SecondsToTimeStr(_Seconds);
end;

function TimeStrToSeconds(const _Zeit: string): integer;
var
  Zeit: string;
  s: string;
  Len: integer;
  Sign: integer;
begin
  Len := Length(_Zeit);
  if Len = 0 then begin
    Result := 0;
    exit;
  end;

  Sign := 1;
  case _Zeit[1] of
    '-': begin
        Zeit := TailStr(_Zeit, 2);
        Sign := -1;
      end;
    '+', ' ':
      Zeit := TailStr(_Zeit, 2);
  else
    Zeit := _Zeit;
  end;

  s := ExtractFirstWord(Zeit, [':']);
  if s = '' then
    Result := 0
  else
    Result := StrToInt(s);

  s := ExtractFirstWord(Zeit, [':']);
  if s <> '' then
    Result := Result * 60 + StrToInt(s);

  s := ExtractFirstWord(Zeit, [':']);
  if s <> '' then
    Result := Result * 60 + StrToInt(s);

  Result := Result * Sign;
end;

function Float2Str(_flt: extended; _DecSeparator: char = '.'): string;
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings := DZ_FORMAT_DECIMAL_POINT;
  FormatSettings.DecimalSeparator := _DecSeparator;
  Result := SysUtils.FloatToStr(_Flt, FormatSettings);
end;

function Float2Str(_flt: extended; _Width, _Decimals: integer): string;
var
  s: AnsiString;
begin
  Str(_flt: _Width: _Decimals, s);
  Result := string(s);
end;

function Float2Str(_flt: extended; _Decimals: integer): string;
begin
  Result := Float2Str(_flt, 0, _Decimals);
end;

function TryRound(_flt: extended; out _wrd: word): boolean;
begin
  Result := (_flt >= 0) and (_flt <= $FFFF);
  if Result then
    try
      _wrd := Round(_flt);
    except
      Result := false;
    end;
end;

function Str2Int(_s: string; _Default: integer): integer;
var
  e: integer;
begin
  Val(_s, Result, e);
  if e <> 0 then
    Result := _Default
end;

function Str2Int(_s: string; const _Source: string): integer;
var
  e: integer;
begin
  Val(_s, Result, e);
  if e <> 0 then
    raise EStringConvertError.CreateFmt(_('"%s" is not a valid integer value: %s'), [_s, _Source]);
end;

function Str2Int64(_s: string; _Default: Int64): Int64;
var
  e: integer;
begin
  Val(_s, Result, e);
  if e <> 0 then
    Result := _Default
end;

function Str2Int64(_s: string; const _Source: string): Int64;
var
  e: integer;
begin
  Val(_s, Result, e);
  if e <> 0 then
    raise EStringConvertError.CreateFmt(_('"%s" is not a valid Int64 value: %s'), [_s, _Source]);
end;

function GuessDecimalSeparator(const _s: string): char;
var
  i: integer;
  //  DotCnt: integer;
  CommaCnt: integer;
begin
  //  DotCnt := 0;
  CommaCnt := 0;
  Result := '.';
  for i := 1 to length(_s) do begin
    case _s[i] of
      '.': begin
            //            Inc(DotCnt);
          Result := '.';
        end;
      ',': begin
          Inc(CommaCnt);
          Result := ',';
        end;
    end;
  end;
  if (Result = ',') and (CommaCnt = 1) then
    exit;
  Result := '.';
end;

function TryStr2Float(_s: string; out _flt: extended; _DecSeparator: char = '.'): boolean;
var
  FmtSettings: TFormatSettings;
begin
  if _DecSeparator = #0 then
    _DecSeparator := GuessDecimalSeparator(_s);
  FmtSettings.DecimalSeparator := _DecSeparator;
  Result := TextToFloat(PChar(_s), _flt, fvExtended, FmtSettings);
end;

function TryStr2Float(_s: string; out _flt: double; _DecSeparator: char = '.'): boolean;
var
  flt: extended;
begin
  Result := TryStr2Float(_s, flt, _DecSeparator);
  if Result then
    _flt := flt;
end;

function TryStr2Float(_s: string; out _flt: single; _DecSeparator: char = '.'): boolean;
var
  flt: extended;
begin
  Result := TryStr2Float(_s, flt, _DecSeparator);
  if Result then
    _flt := flt;
end;

function Str2Float(_s: string; _Default: extended; _DecSeparator: char = '.'): extended;
begin
  if not TryStr2Float(_s, Result, _DecSeparator) then
    Result := _Default
end;

function Str2Float(_s: string; const _Source: string; _DecSeparator: char = '.'): extended;
begin
  if not TryStr2Float(_s, Result, _DecSeparator) then
    raise EStringConvertError.CreateFmt(_('"%s" is not a valid floating point value: %s'), [_s, _Source]);
end;

function FileSizeToHumanReadableString(_FileSize: Int64): string;
begin
  if _FileSize > 5 * OneExbiByte then
    Result := Format(_('%.2f EiB'), [_FileSize / OneExbiByte])
  else if _FileSize > 5 * OnePebiByte then
    Result := Format(_('%.2f PiB'), [_FileSize / OnePebiByte])
  else if _FileSize > 5 * OneTebiByte then
    Result := Format(_('%.2f TiB'), [_FileSize / OneTebiByte])
  else if _FileSize > 5 * OneGibiByte then
    Result := Format(_('%.2f GiB'), [_FileSize / OneGibiByte])
  else if _FileSize > 5 * OneMebiByte then
    Result := Format(_('%.2f MiB'), [_FileSize / OneMebiByte])
  else if _FileSize > 5 * OneKibiByte then
    Result := Format(_('%.2f KiB'), [_FileSize / OneKibiByte])
  else
    Result := Format(_('%d Bytes'), [_FileSize]);
end;

function SecondsToHumanReadableString(_Seconds: Int64): string;
begin
  if _Seconds > SecondsPerDay then
    // Days and hours, ignore minutes and seconds
    Result := Format(_('%dd %dh'), [_Seconds div SecondsPerDay, (_Seconds div SecondsPerHour) mod HoursPerDay])
  else if _Seconds > Round(1.5 * SecondsPerHour) then
    // Hours and minutes, ignore seconds
    Result := Format(_('%dh %dm'), [_Seconds div SecondsPerHour, (_Seconds div SecondsPerMinute) mod MinutesPerHour])
  else if _Seconds > Round(1.5 * SecondsPerMinute) then
    // Minutes and seconds
    Result := Format(_('%dm %ds'), [_Seconds div SecondsPerMinute, _Seconds mod SecondsPerMinute])
  else
    // Seconds only
    Result := Format(_('%ds'), [_Seconds]);
end;

function GetSystemDefaultLocaleSettings: TFormatSettings;
begin
{$ifdef RTL220_UP}
  Result := TFormatSettings.Create(GetSystemDefaultLCID);
{$else}
  GetLocaleFormatSettings(GetSystemDefaultLCID, Result);
{$endif}
end;

function GetUserDefaultLocaleSettings: TFormatSettings;
begin
{$ifdef RTL220_UP}
  Result := TFormatSettings.Create(GetUserDefaultLCID);
{$else}
  GetLocaleFormatSettings(GetUserDefaultLCID, Result);
{$endif}
end;

function LongWord2ByteArr(_Value: LongWord; _MsbFirst: boolean = false): TBytes;
begin
  SetLength(Result, SizeOf(_Value));
  if _MsbFirst then begin
    Result[0] := _Value shr 24 and $FF;
    Result[1] := _Value shr 16 and $FF;
    Result[2] := _Value shr 8 and $FF;
    Result[3] := _Value shr 0 and $FF;
  end else begin
    Result[3] := _Value shr 24 and $FF;
    Result[2] := _Value shr 16 and $FF;
    Result[1] := _Value shr 8 and $FF;
    Result[0] := _Value shr 0 and $FF;
  end;
end;

function ByteArr2LongWord(const _Arr: array of byte; _MsbFirst: boolean = false): LongWord;
begin
  if Length(_Arr) <> SizeOf(Result) then
    raise Exception.CreateFmt(_('Length of byte array (%d) does not match size of a LongWord (%d)'), [Length(_Arr), SizeOf(Result)]);
  if _MsbFirst then begin
    Result := _Arr[0] shl 24 + _Arr[1] shl 16 + _Arr[2] shl 8 + _Arr[3];
  end else begin
    Result := _Arr[3] shl 24 + _Arr[2] shl 16 + _Arr[1] shl 8 + _Arr[0];
  end;
end;

function Swap16(_Value: word): word; inline;
begin
  Result := swap(_Value);
end;

function Swap32(_Value: LongWord): LongWord;
asm
  bswap eax
end;


initialization
  DZ_FORMAT_DECIMAL_POINT := u_dzStringUtils.GetUserDefaultLocaleSettings;
  DZ_FORMAT_DECIMAL_POINT.DecimalSeparator := '.';
  DZ_FORMAT_DECIMAL_POINT.ThousandSeparator := #0;
end.

