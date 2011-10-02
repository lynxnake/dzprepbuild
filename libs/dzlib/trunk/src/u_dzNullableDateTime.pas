unit u_dzNullableDateTime;

interface

uses
  SysUtils,
  Variants,
  u_dzTranslator;

type
  TdzNullableDateTime = record
  private
    FIsValid: IInterface;
    FValue: TDateTime;
  public
    procedure Invalidate;
    function Value: TDateTime;
    function IsValid: boolean; inline;
    function GetValue(out _Value: TDateTime): boolean;
    procedure AssignVariant(_a: Variant);
    function ToVariant: Variant;
    function Dump: string;
    class operator Negative(_a: TdzNullableDateTime): TdzNullableDateTime;
    class operator Positive(_a: TdzNullableDateTime): TdzNullableDateTime;
//    class operator Inc(_a: TdzNullableDateTime): TdzNullableDateTime;
//    class operator Dec(_a: TdzNullableDateTime): TdzNullableDateTime;
    class operator Implicit(_Value: TDateTime): TdzNullableDateTime;
    class operator Implicit(_a: TdzNullableDateTime): TDateTime;
    class operator Explicit(const _s: string): TdzNullableDateTime;
    class operator Explicit(_a: TdzNullableDateTime): string;
    class operator LessThan(_a: TdzNullableDateTime; _b: TDateTime): boolean;
    class operator LessThanOrEqual(_a: TdzNullableDateTime; _b: TDateTime): boolean;
    class operator GreaterThan(_a: TdzNullableDateTime; _b: TDateTime): boolean;
    class operator GreaterThanOrEqual(_a: TdzNullableDateTime; _b: TDateTime): boolean;
    class operator Equal(_a: TdzNullableDateTime; _b: TDateTime): boolean;
    class operator NotEqual(_a: TdzNullableDateTime; _b: TDateTime): boolean;

    /// <summary> invalid values are considered smaller than any valid values
    /// and equal to each other </summary>
    class function Compare(_a, _b: TdzNullableDateTime): integer; static;
    class function Invalid: TdzNullableDateTime; static;
    class function FromVariant(_a: Variant): TdzNullableDateTime; static;
  end;

implementation

uses
  DateUtils,
  Types,
  u_dzNullableTypesUtils,
  u_dzVariantUtils;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

{ TdzNullableDateTime }

procedure TdzNullableDateTime.Invalidate;
begin
  FIsValid := nil;
end;

function TdzNullableDateTime.IsValid: boolean;
begin
  Result := Assigned(FIsValid);
end;

procedure TdzNullableDateTime.AssignVariant(_a: Variant);
begin
  if TryVar2DateTime(_a, FValue) then
    FIsValid := GetNullableTypesFlagInterface
  else
    FIsValid := nil;
end;

function TdzNullableDateTime.ToVariant: Variant;
begin
  if IsValid then
    Result := Value
  else
    Result := Variants.Null;
end;

class function TdzNullableDateTime.Compare(_a, _b: TdzNullableDateTime): integer;
begin
  Result := DateUtils.CompareDateTime(_a, _b);
end;

function TdzNullableDateTime.Dump: string;
begin
  if IsValid then
    Result := string(self)
  else
    Result := '<invalid>';
end;

class operator TdzNullableDateTime.Explicit(_a: TdzNullableDateTime): string;
begin
  Result := DateTimeToStr(_a.Value);
end;

class operator TdzNullableDateTime.Explicit(const _s: string): TdzNullableDateTime;
var
  dt: TDateTime;
begin
  if TryStrToDateTime(_s, dt) then
    Result := dt;
end;

class function TdzNullableDateTime.FromVariant(_a: Variant): TdzNullableDateTime;
begin
  Result.AssignVariant(_a);
end;

function TdzNullableDateTime.GetValue(out _Value: TDateTime): boolean;
begin
  Result := IsValid;
  if Result then
    _Value := FValue;
end;

class operator TdzNullableDateTime.LessThan(_a: TdzNullableDateTime; _b: TDateTime): boolean;
begin
  Result := (DateUtils.CompareDateTime(_a.Value, _b) = LessThanValue);
end;

class operator TdzNullableDateTime.LessThanOrEqual(_a: TdzNullableDateTime; _b: TDateTime): boolean;
begin
  Result := (DateUtils.CompareDateTime(_a.Value, _b) <> GreaterThanValue);
end;

class operator TdzNullableDateTime.Equal(_a: TdzNullableDateTime; _b: TDateTime): boolean;
begin
  Result := (DateUtils.CompareDateTime(_a.Value, _b) = EqualsValue);
end;

class operator TdzNullableDateTime.NotEqual(_a: TdzNullableDateTime; _b: TDateTime): boolean;
begin
  Result := (DateUtils.CompareDateTime(_a.Value, _b) <> EqualsValue);
end;

class operator TdzNullableDateTime.GreaterThan(_a: TdzNullableDateTime; _b: TDateTime): boolean;
begin
  Result := (DateUtils.CompareDateTime(_a.Value, _b) = GreaterThanValue);
end;

class operator TdzNullableDateTime.GreaterThanOrEqual(_a: TdzNullableDateTime; _b: TDateTime): boolean;
begin
  Result := (DateUtils.CompareDateTime(_a.Value, _b) <> LessThanValue);
end;

class operator TdzNullableDateTime.Implicit(_a: TdzNullableDateTime): TDateTime;
begin
  Result := _a.Value;
end;

class operator TdzNullableDateTime.Implicit(_Value: TDateTime): TdzNullableDateTime;
begin
  Result.FValue := _Value;
  Result.FIsValid := GetNullableTypesFlagInterface;
end;

class function TdzNullableDateTime.Invalid: TdzNullableDateTime;
begin
  Result.Invalidate;
end;

class operator TdzNullableDateTime.Negative(_a: TdzNullableDateTime): TdzNullableDateTime;
begin
  Result := -_a.Value;
end;

class operator TdzNullableDateTime.Positive(_a: TdzNullableDateTime): TdzNullableDateTime;
begin
  Result := _a.Value;
end;

function TdzNullableDateTime.Value: TDateTime;
begin
  if not IsValid then
    raise EInvalidValue.Create(_('NullableDateTime is invalid'));
  Result := FValue;
end;

end.

