{.GXFormatter.config=twm}
/// <summary> implements some utility functions for converting TDateTime to and from strings
///           in ISO 6801 format (note that these functions do not implement the complete
///           standard but only the extended form without omitting date parts). </summary>
unit u_dzDateUtils;

{$I jedi.inc}

interface

uses
  Sysutils,
  u_dzTranslator;

type
  ///<summary> Similar to the DayMonday etc. constants in DateUtils, but starting
  ///           with Monday rather than Sunday and also as a typesafe enum </summary>
  TDayOfWeekEnum = (dowMonday, dowTuesday, dowWednesday, dowThursday, dowFriday, dowSaturday, dowSunday);
  ///<summary> subtype for month numbers </summary>
  TMonthNumbers = 1..12;
  //<summary> subtype for day numbers </summary>
  TDayOfMonthNumbers = 1..31;

///<summary> Same as SysUtils.GetDayOfTheWeek, but returns a TDayOfWeekEnum rather
///          than a word value </summary>
function GetDayOfTheWeek(_Date: TDateTime): TDayOfWeekEnum;

///<summary> returns the localized string for the day of the week </summary>
function DayOfWeek2Str(_Dow: TDayOfWeekEnum): string;

///</summary> returns the localized string for the month </summary>
function Month2Str(_Month: TMonthNumbers): string;

/// <summary>
/// Converts a TDateTime value to a string in ISO 8601 format
/// @param dt is the TDateTime value to convert
/// @param IncludeTime is a boolean that determines whether the time should be
///                    included, defaults to false
/// @returns a string with the date (and optionally the time) in the format
///          'yyyy-mm-dd hh:mm:ss'
/// </summary>
function DateTime2Iso(_dt: TDateTime; _IncludeTime: boolean = false): string; inline;
function Time2Iso(_dt: TDateTime; _IncludeSeconds: boolean = true): string; inline;
/// <summary>
/// converts a string that contains a time in ISO 8601 format to a TDateTime value
/// @param s is the string to convert, it must be in the form 'hh:mm:ss' or 'hh:mm'
/// @returns a TDateTime value with the time
/// </summary>
function Iso2Time(_s: string): TDateTime;
function TryIso2Time(_s: string; out _Time: TDateTime): boolean;
/// <summary>
/// converts a string that contains a date in ISO 8601 format to a TDateTime value
/// @param s is the string to convert, it must be in the form 'yyyy-mm-dd', it must
///          not contain a time
/// @returns a TDateTime value with the date
/// </summary>
function Iso2Date(const _s: string): TDateTime;
function TryIso2Date(const _s: string; out _Date: TDateTime): boolean;

/// <summary>
/// converts a string that contains a date and time in ISO 8601 format to a TDateTime value
/// @param s is the string to convert, it must be in the form 'yyyy-mm-dd hh:mm[:ss]'
/// @returns a TDateTime value with the date
/// </summary>
function Iso2DateTime(const _s: string): TDateTime;
function TryIso2DateTime(const _s: string; out _DateTime: TDateTime): boolean;

function Date2ddmmyyyy(_Date: TDateTime): string;
function ddmmyyyy2Date(const _s: string): TDateTime;
function Tryddmmyyyy2Date(const _s: string; out _Date: TDateTime): boolean;

function TryStr2Date(const _s: string; out _dt: TDateTime): boolean;
function Str2Date(const _s: string): TDateTime;

implementation

uses
  SysConst,
  DateUtils,
  u_dzStringUtils;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

function GetDayOfTheWeek(_Date: TDateTime): TDayOfWeekEnum;
var
  DayNo: word;
begin
  // 1=Su, 2=Mo ..
  DayNo := DateUtils.DayOfTheWeek(_Date);
  Result := TDayOfWeekEnum(DayNo - DateUtils.DayMonday);
end;

function DayOfWeek2Str(_Dow: TDayOfWeekEnum): string;
begin
  case _Dow of
    dowMonday: Result := _('Monday');
    dowTuesday: Result := _('Tuesday');
    dowWednesday: Result := _('Wednesday');
    dowThursday: Result := _('Thursday');
    dowFriday: Result := _('Friday');
    dowSaturday: Result := _('Saturday');
    dowSunday: Result := _('Sunday');
  else
    // should never happen ...
    raise exception.CreateFmt(_('Invalid value for DayOfWeek: %d'), [Ord(_Dow)]);
  end;
end;

function Month2Str(_Month: TMonthNumbers): string;
begin
  case _Month of
    1: Result := _('January');
    2: Result := _('February');
    3: Result := _('March');
    4: Result := _('April');
    5: Result := _('May');
    6: Result := _('June');
    7: Result := _('July');
    8: Result := _('August');
    9: Result := _('September');
    10: Result := _('October');
    11: Result := _('November');
    12: Result := _('December');
  else
    // should never happen ...
    raise Exception.CreateFmt(_('Invalid month number %d'), [_Month]);
  end;
end;

function DateTime2Iso(_dt: TDateTime; _IncludeTime: boolean = false): string;
begin
  if _IncludeTime then
    DateTimeToString(Result, 'yyyy-mm-dd hh:nn:ss', _dt) // do not translate
  else
    DateTimeToString(Result, 'yyyy-mm-dd', _dt); // do not translate
end;

function Date2ddmmyyyy(_Date: TDateTime): string;
begin
  DateTimeToString(Result, 'dd.mm.yyyy', _Date); // do not translate
end;

function Tryddmmyyyy2Date(const _s: string; out _Date: TDateTime): boolean;
var
  Settings: TFormatSettings;
begin
  Settings := GetUserDefaultLocaleSettings;
  Settings.DateSeparator := '.';
  Settings.ShortDateFormat := 'dd.mm.yyyy'; // do not translate
  Result := TryStrToDate(_s, _Date, Settings);
end;

function ddmmyyyy2Date(const _s: string): TDateTime;
var
  Settings: TFormatSettings;
begin
  Settings := GetUserDefaultLocaleSettings;
  Settings.DateSeparator := '.';
  Settings.ShortDateFormat := 'dd.mm.yyyy'; // do not translate
  Result := StrToDate(_s, Settings);
end;

function Time2Iso(_dt: TDateTime; _IncludeSeconds: boolean = true): string;
var
  fmt: string;
begin
  fmt := 'hh:nn'; // do not translate
  if _IncludeSeconds then
    fmt := fmt + ':ss'; // do not translate
  DateTimeToString(Result, fmt, _dt);
end;

function TryIso2Time(_s: string; out _Time: TDateTime): boolean;
var
  Settings: TFormatSettings;
begin
  Settings := GetUserDefaultLocaleSettings;
  Settings.TimeSeparator := ':';
  Settings.ShortTimeFormat := 'hh:nn:ss'; // do not translate
  Result := TryStrToTime(_s, _Time, Settings);
end;

function Iso2Time(_s: string): TDateTime;
var
  Settings: TFormatSettings;
begin
  Settings := GetUserDefaultLocaleSettings;
  Settings.TimeSeparator := ':';
  Settings.ShortTimeFormat := 'hh:nn:ss'; // do not translate
  Result := StrToTime(_s, Settings);
end;

function TryIso2Date(const _s: string; out _Date: TDateTime): boolean;
var
  Settings: TFormatSettings;
begin
  Settings := GetUserDefaultLocaleSettings;
  Settings.DateSeparator := '-';
  Settings.ShortDateFormat := 'yyyy-mm-dd'; // do not translate
  Result := TryStrToDate(_s, _Date, Settings);
end;

function Iso2Date(const _s: string): TDateTime;
var
  Settings: TFormatSettings;
begin
  Settings := GetUserDefaultLocaleSettings;
  Settings.DateSeparator := '-';
  Settings.ShortDateFormat := 'yyyy-mm-dd'; // do not translate
  Result := StrToDate(_s, Settings);
end;

function TryIso2DateTime(const _s: string; out _DateTime: TDateTime): boolean;
var
  Settings: TFormatSettings;
begin
  Settings := GetUserDefaultLocaleSettings;
  Settings.DateSeparator := '-';
  Settings.ShortDateFormat := 'yyyy-mm-dd'; // do not translate
  Settings.TimeSeparator := ':';
  Settings.ShortTimeFormat := 'hh:nn:ss'; // do not translate
  Result := TryStrToDateTime(_s, _DateTime, Settings);
end;

function Iso2DateTime(const _s: string): TDateTime;
var
  Settings: TFormatSettings;
begin
  Settings := GetUserDefaultLocaleSettings;
  Settings.DateSeparator := '-';
  Settings.ShortDateFormat := 'yyyy-mm-dd'; // do not translate
  Settings.TimeSeparator := ':';
  Settings.ShortTimeFormat := 'hh:nn:ss'; // do not translate
  Result := StrToDateTime(_s, Settings);
end;

function TryStr2Date(const _s: string; out _dt: TDateTime): boolean;
var
  UKSettings: TFormatSettings;
begin
  Result := true;
  // Try several different formats
  // format configured in Windows
  if not TryStrToDate(_s, _dt) then
    // German dd.mm.yyyy
    if not Tryddmmyyyy2Date(_s, _dt) then
      // ISO yyyy-mm-dd
      if not TryIso2Date(_s, _dt) then begin
        // United Kingdom: dd/mm/yyyy
        UKSettings := GetUserDefaultLocaleSettings;
        UKSettings.DateSeparator := '/';
        UKSettings.ShortDateFormat := 'dd/mm/yyyy';
        if not TryStrToDate(_s, _dt, UKSettings) then
          // nothing worked, give up
          Result := false;
      end;
end;

function Str2Date(const _s: string): TDateTime;
begin
  if not TryStr2Date(_s, Result) then
    raise EConvertError.CreateResFmt(@SInvalidDate, [_s]);
end;

end.

