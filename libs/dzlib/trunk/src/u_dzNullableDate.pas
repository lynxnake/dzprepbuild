unit u_dzNullableDate;

interface

uses
  SysUtils,
  Variants,
  u_dzTranslator,
  u_dzDateUtils;

type
  TdzDayOfWeek = record
  public
    Enum: TDayOfWeekEnum;
    function AsString: string;
  end;

type
  TdzDay = record
  private
    FDayOfWeek: TDayOfWeekEnum;
  public
    Number: TDayOfMonthNumbers;
    ///<summary> This cannot just be a field because of an apparent compiler bug </summary>
    function DayOfWeek: TdzDayOfWeek;
    procedure Init(_Number: TDayOfMonthNumbers; _DOW: TDayOfWeekEnum);
  end;

type
  TdzMonth = record
  public
    Number: TMonthNumbers;
    function AsString: string;
  end;

type
  TdzNullableDate = record
  private
    FIsValid: IInterface;
    FValue: TDateTime;
  public
    procedure Invalidate;
    function Value: TDateTime;
    function IsValid: Boolean;
    function GetValue(out _Value: TDateTime): boolean;
    procedure AssignVariant(_a: Variant);
    function ToVariant: Variant;
    procedure Encode(_Year, _Month, _Day: word);
    procedure Decode(out _Year, _Month, _Day: word);
    function Year: Word;
    function Month: TdzMonth;
    function Day: TdzDay;
    function Dump: string;
    function ForDisplay: string;
    function ToDDmmYYYY: string;
    function ToYYYYmmDD: string;
    class operator Implicit(_Value: TDateTime): TdzNullableDate;
    class operator Implicit(_a: TdzNullableDate): TDateTime;
    class operator Explicit(const _s: string): TdzNullableDate;
    class operator Explicit(_a: TdzNullableDate): string;
    class function FromVariant(_v: variant): TdzNullableDate; static;
    class operator NotEqual(_a, _b: TdzNullableDate): boolean;
    class operator Equal(_a, _b: TdzNullableDate): boolean;
    class operator GreaterThan(_a, _b: TdzNullableDate): boolean;
    class operator GreaterThanOrEqual(_a, _b: TdzNullableDate): boolean;
    class operator LessThan(_a, _b: TdzNullableDate): boolean;
    class operator LessThanOrEqual(_a, _b: TdzNullableDate): boolean;
    class operator Add(_Date: TdzNullableDate; _Days: integer): TdzNullableDate;
    class operator Subtract(_Date: TdzNullableDate; _Days: integer): TdzNullableDate;
    class function Today: TdzNullableDate; static;
  end;

implementation

uses
  u_dzNullableTypesUtils,
  u_dzVariantUtils;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

{ TdzDayOfWeek }

function TdzDayOfWeek.AsString: string;
begin
  Result := u_dzDateUtils.DayOfWeek2Str(Enum);
end;

{ TdzDay }

function TdzDay.DayOfWeek: TdzDayOfWeek;
begin
  Result.Enum := FDayOfWeek;
end;

procedure TdzDay.Init(_Number: TDayOfMonthNumbers; _DOW: TDayOfWeekEnum);
begin
  Number := _Number;
  FDayOfWeek := _DOW;
end;

{ TdzMonth }

function TdzMonth.AsString: string;
begin
  Result := u_dzDateUtils.Month2Str(Number);
end;

{ TdzNullableDate }

class operator TdzNullableDate.Explicit(const _s: string): TdzNullableDate;
begin
  if TryIso2Date(_s, Result.FValue) or TryStrToDate(_s, Result.FValue) or Tryddmmyyyy2Date(_s, Result.FValue) then
    Result.FIsValid := GetNullableTypesFlagInterface
  else
    Result.FIsValid := nil;
end;

class operator TdzNullableDate.Add(_Date: TdzNullableDate; _Days: integer): TdzNullableDate;
begin
  Result := _Date.Value + _Days;
end;

procedure TdzNullableDate.AssignVariant(_a: Variant);
begin
  if TryVar2DateTime(_a, FValue) then
    FIsValid := GetNullableTypesFlagInterface
  else
    FIsValid := nil;
end;

function TdzNullableDate.Day: TdzDay;
var
  Year, Month, TheDay: Word;
begin
  Decode(Year, Month, TheDay);
  Result.Init(TheDay, u_dzDateUtils.GetDayOfTheWeek(Value));
end;

procedure TdzNullableDate.Decode(out _Year, _Month, _Day: word);
begin
  DecodeDate(Value, _Year, _Month, _Day);
end;

function TdzNullableDate.Dump: string;
begin
  if IsValid then
    Result := DateTime2Iso(FValue)
  else
    Result := '<invalid>';
end;

procedure TdzNullableDate.Encode(_Year, _Month, _Day: word);
begin
  if TryEncodeDate(_Year, _Month, _Day, FValue) then
    FIsValid := GetNullableTypesFlagInterface
  else
    FIsValid := nil;
end;

class operator TdzNullableDate.Explicit(_a: TdzNullableDate): string;
begin
  if _a.IsValid then
    Result := DateTime2Iso(_a.FValue)
  else
    Result := '';
end;

function TdzNullableDate.ForDisplay: string;
begin
  Result := DateTimeToStr(Value);
end;

class function TdzNullableDate.FromVariant(_v: variant): TdzNullableDate;
begin
  Result.AssignVariant(_v);
end;

class operator TdzNullableDate.Implicit(_Value: TDateTime): TdzNullableDate;
begin
  Result.FValue := _Value;
  if _Value <> 0 then
    Result.FIsValid := GetNullableTypesFlagInterface
  else
    Result.FIsValid := nil;
end;

class operator TdzNullableDate.Implicit(_a: TdzNullableDate): TDateTime;
begin
  Result := _a.Value;
end;

function TdzNullableDate.GetValue(out _Value: TDateTime): boolean;
begin
  Result := IsValid;
  if Result then
    _Value := FValue;
end;

class operator TdzNullableDate.GreaterThan(_a, _b: TdzNullableDate): boolean;
begin
  Result := _a.Value > _b.Value;
end;

class operator TdzNullableDate.GreaterThanOrEqual(_a, _b: TdzNullableDate): boolean;
begin
  Result := _a.Value >= _b.Value;
end;

procedure TdzNullableDate.Invalidate;
begin
  FIsValid := nil;
end;

function TdzNullableDate.IsValid: Boolean;
begin
  Result := FIsValid <> nil;
end;

class operator TdzNullableDate.LessThan(_a, _b: TdzNullableDate): boolean;
begin
  Result := _a.Value < _b.Value;
end;

class operator TdzNullableDate.LessThanOrEqual(_a, _b: TdzNullableDate): boolean;
begin
  Result := _a.Value <= _b.Value;
end;

function TdzNullableDate.Month: TdzMonth;
var
  Year, TheMonth, Day: Word;
begin
  Decode(Year, TheMonth, Day);
  Result.Number := TheMonth;
end;

class operator TdzNullableDate.NotEqual(_a, _b: TdzNullableDate): boolean;
begin
  Result := _a.Value <> _b.Value;
end;

class operator TdzNullableDate.Subtract(_Date: TdzNullableDate; _Days: integer): TdzNullableDate;
begin
  Result := _Date.Value - _Days;
end;

class operator TdzNullableDate.Equal(_a, _b: TdzNullableDate): boolean;
begin
  Result := _a.Value = _b.Value;
end;

class function TdzNullableDate.Today: TdzNullableDate;
begin
  Result := SysUtils.Date;
end;

function TdzNullableDate.ToDDmmYYYY: string;
begin
  Result := Date2ddmmyyyy(Value);
end;

function TdzNullableDate.ToVariant: Variant;
begin
  if IsValid then
    Result := FValue
  else
    Result := Variants.Null;
end;

function TdzNullableDate.ToYYYYmmDD: string;
begin
  Result := DateTime2Iso(Value);
end;

function TdzNullableDate.Value: TDateTime;
begin
  if not IsValid then
    raise EInvalidValue.Create(_('NullableDate value is invalid'));
  Result := FValue;
end;

function TdzNullableDate.Year: Word;
var
  Month, Day: Word;
begin
  Decode(Result, Month, Day);
end;

end.

