unit u_dzNullableTime;

interface

uses
  SysUtils,
  u_dzTranslator;

type
  TdzNullableTime = record
  private
    FIsValid: IInterface;
    FValue: TDateTime;
  public
    procedure Invalidate;
    function Value: TDateTime;
    function IsValid: Boolean;
    function GetValue(out _Value: TDateTime): boolean;
    procedure Encode(_Hour, _Minutes, _Seconds, _MSeconds: word);
    procedure Decode(out _Hour, _Minutes, _Seconds, _MSeconds: Word);
    procedure AssignVariant(_v: variant);
    function ForDisplay(_IncludeSeconds: boolean = True; _Include100th: boolean = False): string;
    function Dump: string;
    function ToHHmmSS: string;
    function ToHHmm: string;
    function Hour: word;
    function Minutes: word;
    function Seconds: word;
    function InHours: extended;
    function InMinutes: extended;
    function InSeconds: extended;
    procedure AddSeconds(_Seconds: extended);
    procedure SubtractSeconds(_Seconds: extended);
    class operator Implicit(_Value: TDateTime): TdzNullableTime;
    class operator Implicit(_a: TdzNullableTime): TDateTime;
    class operator Explicit(const _s: string): TdzNullableTime;
    class operator Explicit(_a: TdzNullableTime): string;
    class operator Subtract(_a, _b: TdzNullableTime): TdzNullableTime;
    class operator GreaterThan(_a, _b: TdzNullableTime): boolean;
    class operator LessThan(_a, _b: TdzNullableTime): boolean;
    class operator GreaterThanOrEqual(_a, _b: TdzNullableTime): boolean;
    class operator LessThanOrEqual(_a, _b: TdzNullableTime): boolean;
    class function FromVariant(_v: variant): TdzNullableTime; static;
    class function Now: TdzNullableTime; static;
  end;

implementation

uses
  DateUtils,
  u_dzDateUtils,
  u_dzConvertUtils,
  u_dzNullableTypesUtils;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

{ TdzNullableTime }

class operator TdzNullableTime.Explicit(const _s: string): TdzNullableTime;
begin
  if TryIso2Time(_s, Result.FValue) or TryStrToTime(_s, Result.FValue) then
    Result.FIsValid := GetNullableTypesFlagInterface
  else
    Result.FIsValid := nil;
end;

procedure TdzNullableTime.AddSeconds(_Seconds: extended);
begin
  FValue := Value + _Seconds / SecondsPerDay;
end;

function TdzNullableTime.Hour: word;
var
  m: Word;
  s: Word;
  ms: Word;
begin
  DecodeTime(Value, Result, m, s, ms);
end;

function TdzNullableTime.Minutes: word;
var
  h: Word;
  s: Word;
  ms: Word;
begin
  DecodeTime(Value, h, Result, s, ms);
end;

function TdzNullableTime.Seconds: word;
var
  h: Word;
  m: Word;
  ms: Word;
begin
  DecodeTime(Value, h, m, Result, ms);
end;

procedure TdzNullableTime.SubtractSeconds(_Seconds: extended);
begin
  AddSeconds(-_Seconds);
end;

function TdzNullableTime.ToHHmm: string;
begin
  Result := Time2Iso(Value, False);
end;

function TdzNullableTime.ToHHmmSS: string;
begin
  Result := Time2Iso(Value, True);
end;

procedure TdzNullableTime.AssignVariant(_v: variant);
begin
  if TryIso2Time(_v, FValue) then
    FIsValid := GetNullableTypesFlagInterface
  else
    FIsValid := nil;
end;

function TdzNullableTime.Dump: string;
begin
  if IsValid then
    Result := Time2Iso(FValue)
  else
    Result := '<invalid>';
end;

function TdzNullableTime.ForDisplay(_IncludeSeconds: boolean = True; _Include100th: boolean = False): string;
var
  H, M, S, MS: Word;
begin
  H := Trunc(Value * SecondsPerDay / SecondsPerHour); // allow for 24:00 -> not mod 24;
  M := Trunc(Value * SecondsPerDay / SecondsPerMinute) mod MinutesPerHour;
  S := Trunc(Value * SecondsPerDay) mod SecondsPerMinute;
  MS := Trunc(Value * SecondsPerDay * 100) mod 100;

  Result := Format('%.2d:%.2d', [H, M]);
  if _IncludeSeconds then begin
    Result := Result + Format(':%.2d', [S]);
    if _Include100th then
      Result := Result + Format('%.2f', [MS / 100]);
  end;
end;

procedure TdzNullableTime.Decode(out _Hour, _Minutes, _Seconds, _MSeconds: Word);
begin
  DecodeTime(Value, _Hour, _Minutes, _Seconds, _MSeconds);
end;

procedure TdzNullableTime.Encode(_Hour, _Minutes, _Seconds, _MSeconds: word);

  function TryEncodeTime(Hour, Min, Sec, MSec: Word; out Time: TDateTime): Boolean;
  // Copied from SysUtils.TryEncodeTime of Delphi 2007 with the following change:
  //   if (Hour < HoursPerDay) ....
  // changed to
  //   if (Hour <= HoursPerDay) ...
  // to allow for 24:00
  begin
    Result := False;
    if (Hour <= HoursPerDay) and (Min < MinsPerHour) and (Sec < SecsPerMin) and (MSec < MSecsPerSec) then begin
      Time := (Hour * (MinsPerHour * SecsPerMin * MSecsPerSec) +
        Min * (SecsPerMin * MSecsPerSec) +
        Sec * MSecsPerSec +
        MSec) / MSecsPerDay;
      Result := True;
    end;
  end;

begin
  if TryEncodeTime(_Hour, _Minutes, _Seconds, _MSeconds, FValue) then
    FIsValid := GetNullableTypesFlagInterface
  else
    FIsValid := nil;
end;

class operator TdzNullableTime.Explicit(_a: TdzNullableTime): string;
begin
  if _a.IsValid then
    Result := Time2Iso(_a.FValue)
  else
    Result := '';
end;

class function TdzNullableTime.FromVariant(_v: variant): TdzNullableTime;
begin
  Result.AssignVariant(_v);
end;

class operator TdzNullableTime.Implicit(_Value: TDateTime): TdzNullableTime;
begin
  Result.FValue := Frac(_Value);
  Result.FIsValid := GetNullableTypesFlagInterface;
end;

class operator TdzNullableTime.Implicit(_a: TdzNullableTime): TDateTime;
begin
  Result := _a.Value;
end;

function TdzNullableTime.GetValue(out _Value: TDateTime): boolean;
begin
  Result := IsValid;
  if Result then
    _Value := FValue;
end;

class operator TdzNullableTime.GreaterThan(_a, _b: TdzNullableTime): boolean;
begin
  Result := (_a.Value > _b.Value);
end;

class operator TdzNullableTime.GreaterThanOrEqual(_a, _b: TdzNullableTime): boolean;
begin
  Result := (_a.Value >= _b.Value);
end;

function TdzNullableTime.InHours: extended;
begin
  Result := FValue * HoursPerDay;
end;

function TdzNullableTime.InMinutes: extended;
begin
  Result := FValue * MinutesPerDay;
end;

function TdzNullableTime.InSeconds: extended;
begin
  Result := FValue * SecondsPerDay;
end;

procedure TdzNullableTime.Invalidate;
begin
  FIsValid := nil;
end;

function TdzNullableTime.IsValid: Boolean;
begin
  Result := FIsValid <> nil;
end;

class operator TdzNullableTime.LessThan(_a, _b: TdzNullableTime): boolean;
begin
  Result := (_a.Value < _b.Value);
end;

class operator TdzNullableTime.LessThanOrEqual(_a, _b: TdzNullableTime): boolean;
begin
  Result := (_a.Value <= _b.Value);
end;

class operator TdzNullableTime.Subtract(_a, _b: TdzNullableTime): TdzNullableTime;
begin
  Result := _a.Value - _b.Value;
end;

class function TdzNullableTime.Now: TdzNullableTime;
begin
  Result := SysUtils.Now;
end;

function TdzNullableTime.Value: TDateTime;
begin
  if not IsValid then
    raise EInvalidValue.Create(_('NullableTime value is invalid'));
  Result := FValue;
end;

end.

