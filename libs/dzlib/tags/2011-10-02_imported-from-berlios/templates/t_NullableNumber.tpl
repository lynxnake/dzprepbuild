{$IFNDEF __DZ_NULLABLE_NUMBER_TEMPLATE__}
unit t_NullableNumber;

interface

uses
  SysUtils,
  Variants,
  u_dzNullableTypesUtils;

/// These types must be declared for each class built on this template
type
  // can be integer, int64, single, double, extended and possibly some other
  // numerical types (e.g. currency) which I have not(!) tested.
  _NULLABLE_TYPE_BASE_ = int64;

{$ENDIF __DZ_NULLABLE_NUMBER_TEMPLATE__}

{$IFNDEF __DZ_NULLABLE_NUMBER_TEMPLATE_SECOND_PASS__}

type
  _NULLABLE_NUMBER_ = record
  private
    FIsValid: IInterface;
    FValue: _NULLABLE_TYPE_BASE_;
  public
    procedure Invalidate;
    function Value: _NULLABLE_TYPE_BASE_;
    function IsValid: boolean; inline;
    function GetValue(out _Value: _NULLABLE_TYPE_BASE_): boolean;
    procedure AssignVariant(_a: Variant);
    function ToVariant: Variant;
    function Dump: string;
    class operator Negative(_a: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Positive(_a: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Inc(_a: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Dec(_a: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Add(_a, _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Add(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): _NULLABLE_NUMBER_;
    class operator Add(_a: _NULLABLE_TYPE_BASE_; _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Subtract(_a, _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Subtract(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): _NULLABLE_NUMBER_;
    class operator Subtract(_a: _NULLABLE_TYPE_BASE_; _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Multiply(_a, _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Multiply(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): _NULLABLE_NUMBER_;
    class operator Multiply(_a: _NULLABLE_TYPE_BASE_; _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Divide(_a, _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Divide(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): _NULLABLE_NUMBER_;
    class operator Divide(_a: _NULLABLE_TYPE_BASE_; _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
    class operator Implicit(_Value: _NULLABLE_TYPE_BASE_): _NULLABLE_NUMBER_;
    class operator Implicit(_a: _NULLABLE_NUMBER_): _NULLABLE_TYPE_BASE_;
    class operator Explicit(const _s: string): _NULLABLE_NUMBER_;
    class operator Explicit(_a: _NULLABLE_NUMBER_): string;
    class operator LessThan(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): boolean;
    class operator LessThanOrEqual(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): boolean;
    class operator GreaterThan(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): boolean;
    class operator GreaterThanOrEqual(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): boolean;
    class operator Equal(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): boolean;
    class operator NotEqual(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): boolean;

    /// <summary> invalid values are considered smaller than any valid values
    /// and equal to each other </summary>
    class function Compare(_a, _b: _NULLABLE_NUMBER_): integer; static;
    class function Invalid: _NULLABLE_NUMBER_; static;
    class function FromVariant(_a: Variant): _NULLABLE_NUMBER_; static;
  end;

{$ENDIF __DZ_NULLABLE_NUMBER_TEMPLATE_SECOND_PASS__}

{$IFNDEF __DZ_NULLABLE_NUMBER_TEMPLATE__}
{$DEFINE __DZ_NULLABLE_NUMBER_TEMPLATE_SECOND_PASS__}

implementation

uses
  Math,
  u_dzTranslator,
  u_dzVariantUtils;

{$ENDIF __DZ_NULLABLE_NUMBER_TEMPLATE__}

{$IFDEF __DZ_NULLABLE_NUMBER_TEMPLATE_SECOND_PASS__}

{ _NULLABLE_NUMBER_ }

class operator _NULLABLE_NUMBER_.Negative(_a: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
begin
  Result := -_a.Value;
end;

class operator _NULLABLE_NUMBER_.Positive(_a: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
begin
  Result := _a.Value;
end;

class operator _NULLABLE_NUMBER_.Inc(_a: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
begin
  Result := _a.Value + 1;
end;

class operator _NULLABLE_NUMBER_.Dec(_a: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
begin
  Result := _a.Value - 1;
end;

class operator _NULLABLE_NUMBER_.Add(_a, _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
begin
  if not _a.IsValid or not _b.IsValid then
    raise EInvalidValue.Create(_('Cannot add two nullable values if one of them is not valid'));
  Result := _a.Value + _b.Value;
end;

class operator _NULLABLE_NUMBER_.Add(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): _NULLABLE_NUMBER_;
begin
  if not _a.IsValid then
    raise EInvalidValue.Create(_('Cannot add to a nullable value if it is not valid'));
  Result := _a.Value + _b;
end;

class operator _NULLABLE_NUMBER_.Add(_a: _NULLABLE_TYPE_BASE_; _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
begin
  if not _b.IsValid then
    raise EInvalidValue.Create(_('Cannot add to a nullable value if it is not valid'));
  Result := _a + _b.Value;
end;

class operator _NULLABLE_NUMBER_.Subtract(_a, _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
begin
  if not _a.IsValid or not _b.IsValid then
    raise EInvalidValue.Create(_('Cannot subtract two nullable values if one of them is not valid'));
  Result := _a.Value - _b.Value;
end;

class operator _NULLABLE_NUMBER_.Subtract(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): _NULLABLE_NUMBER_;
begin
  if not _a.IsValid then
    raise EInvalidValue.Create(_('Cannot subtract from a nullable value if it is not valid'));
  Result := _a.Value - _b;
end;

class operator _NULLABLE_NUMBER_.Subtract(_a: _NULLABLE_TYPE_BASE_; _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
begin
  if not _b.IsValid then
    raise EInvalidValue.Create(_('Cannot subtract from a value if it is not valid'));
  Result := _a - _b.Value;
end;

class operator _NULLABLE_NUMBER_.Multiply(_a, _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
begin
  if not _a.IsValid or not _b.IsValid then
    raise EInvalidValue.Create(_('Cannot multiply two nullable values if one of them is not valid'));
  Result := _a.Value * _b.Value;
end;

class operator _NULLABLE_NUMBER_.Multiply(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): _NULLABLE_NUMBER_;
begin
  if not _a.IsValid then
    raise EInvalidValue.Create(_('Cannot multiply a nullable value if it is not valid'));
  Result := _a.Value * _b;
end;

class operator _NULLABLE_NUMBER_.Multiply(_a: _NULLABLE_TYPE_BASE_; _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
begin
  if not _b.IsValid then
    raise EInvalidValue.Create(_('Cannot multiply a nullable value if it is not valid'));
  Result := _a * _b.Value;
end;

class operator _NULLABLE_NUMBER_.Divide(_a, _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
var
  Res: _NULLABLE_TYPE_BASE_;
begin
  if not _a.IsValid or not _b.IsValid then
    raise EInvalidValue.Create(_('Cannot divide two nullable values if one of them is not valid'));
  DivideNumbers(_a.Value, _b.Value, Res);
  Result := Res;
end;

class operator _NULLABLE_NUMBER_.Divide(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): _NULLABLE_NUMBER_;
var
  Res: _NULLABLE_TYPE_BASE_;
begin
  if not _a.IsValid then
    raise EInvalidValue.Create(_('Cannot divide a nullable value if it is not valid'));
  DivideNumbers(_a.Value, _b, Res);
  Result := Res;
end;

class operator _NULLABLE_NUMBER_.Divide(_a: _NULLABLE_TYPE_BASE_; _b: _NULLABLE_NUMBER_): _NULLABLE_NUMBER_;
var
  Res: _NULLABLE_TYPE_BASE_;
begin
  if not _b.IsValid then
    raise EInvalidValue.Create(_('Cannot divide by a nullable value if it is not valid'));
  DivideNumbers(_a, _b, Res);
  Result := Res;
end;

class operator _NULLABLE_NUMBER_.Explicit(const _s: string): _NULLABLE_NUMBER_;
begin
  if TryStrToNumber(_s, Result.FValue) then
    Result.FIsValid := GetNullableTypesFlagInterface
  else
    Result.FIsValid := nil;
end;

class operator _NULLABLE_NUMBER_.Explicit(_a: _NULLABLE_NUMBER_): string;
begin
  if _a.IsValid then
    Result := NumberToStr(_a.Value)
  else
    Result := '';
end;

class function _NULLABLE_NUMBER_.FromVariant(_a: Variant): _NULLABLE_NUMBER_;
begin
  Result.AssignVariant(_a);
end;

class operator _NULLABLE_NUMBER_.Implicit(_Value: _NULLABLE_TYPE_BASE_): _NULLABLE_NUMBER_;
begin
  Result.FValue := _Value;
  Result.FIsValid := GetNullableTypesFlagInterface;
end;

class operator _NULLABLE_NUMBER_.Implicit(_a: _NULLABLE_NUMBER_): _NULLABLE_TYPE_BASE_;
begin
  Result := _a.Value;
end;

procedure _NULLABLE_NUMBER_.AssignVariant(_a: Variant);
begin
  if TryVar2Number(_a, FValue) then
    FIsValid := GetNullableTypesFlagInterface
  else
    FIsValid := nil;
end;

class function _NULLABLE_NUMBER_.Compare(_a, _b: _NULLABLE_NUMBER_): integer;
begin
  if _a.IsValid then begin
    if _b.IsValid then
      Result := Math.CompareValue(_a.Value, _b.Value)
    else
      Result := 1;
  end else if not _b.IsValid then
    Result := 0
  else
    Result := -1;
end;

function _NULLABLE_NUMBER_.Dump: string;
begin
  if IsValid then
    Result := NumberToStr(FValue)
  else
    Result := '<invalid>';
end;

function _NULLABLE_NUMBER_.ToVariant: Variant;
begin
  if IsValid then
    Result := Value
  else
    Result := Variants.Null;
end;

function _NULLABLE_NUMBER_.GetValue(out _Value: _NULLABLE_TYPE_BASE_): boolean;
begin
  Result := IsValid;
  if Result then
    _Value := FValue;
end;

procedure _NULLABLE_NUMBER_.Invalidate;
begin
  FIsValid := nil;
end;

function _NULLABLE_NUMBER_.IsValid: boolean;
begin
  Result := FIsValid <> nil;
end;

class operator _NULLABLE_NUMBER_.LessThan(_a: _NULLABLE_NUMBER_;
  _b: _NULLABLE_TYPE_BASE_): boolean;
begin
  Result := _a.Value < _b;
end;

class operator _NULLABLE_NUMBER_.LessThanOrEqual(_a: _NULLABLE_NUMBER_;
  _b: _NULLABLE_TYPE_BASE_): boolean;
begin
  Result := _a.Value <= _b;
end;

class operator _NULLABLE_NUMBER_.GreaterThan(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): boolean;
begin
  Result := _a.Value > _b;
end;

class operator _NULLABLE_NUMBER_.GreaterThanOrEqual(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): boolean;
begin
  Result := _a.Value >= _b;
end;

class operator _NULLABLE_NUMBER_.Equal(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): boolean;
begin
  Result := _a.Value = _b;
end;

class operator _NULLABLE_NUMBER_.NotEqual(_a: _NULLABLE_NUMBER_; _b: _NULLABLE_TYPE_BASE_): boolean;
begin
  Result := _a.Value <> _b;
end;

class function _NULLABLE_NUMBER_.Invalid: _NULLABLE_NUMBER_;
begin
  Result.Invalidate;
end;

function _NULLABLE_NUMBER_.Value: _NULLABLE_TYPE_BASE_;
begin
  if not IsValid then
    raise EInvalidValue.Create(_('Nullable value is invalid'));
  Result := FValue;
end;

{$ENDIF __DZ_NULLABLE_NUMBER_TEMPLATE_SECOND_PASS__}

{$DEFINE __DZ_NULLABLE_NUMBER_TEMPLATE_SECOND_PASS__}

{$IFNDEF __DZ_NULLABLE_NUMBER_TEMPLATE__}
{$WARNINGS OFF}
end.
{$ENDIF __DZ_NULLABLE_NUMBER_TEMPLATE__}

