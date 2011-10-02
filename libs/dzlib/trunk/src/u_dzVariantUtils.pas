{: several utilty functions for Variants }
unit u_dzVariantUtils;

interface

uses
  SysUtils,
  Variants,
  u_dzTranslator;

type
  ///<summary> raised if there is a conversion error in one of the Var2XxxEx functions </summary>
  EVariantConvertError = class(Exception);
  ///<summary> raised if the variant passed to one of the Var2XxxEx functions is null </summary>
  EVarIsNull = class(EVariantConvertError);
  ///<summary> raised if the variant passed to one of the Var2XxxEx functions is empty </summary>
  EVarIsEmpty = class(EVariantConvertError);

///<summary> converts a variant to its string representation (for debugging / logging) </summary>
function toString(_v: OleVariant): string; overload;

///<summary> Checks whether a variant is a type that can be assigned to an integer (signed 32 bit),
///          Note: Excludes longword and Int64, even if the value may be <= MaxLongInt </summary>
function VarIsInteger(_v: variant): boolean;

///<summary> Checks whether a variant is of a type that can be assigned to a longword (unsigned 32 bit),
//           Note: Excludes signed integers, even if the value may be positive </summary>
function VarIsLongWord(_v: variant): boolean;

///<summary> Checks whether a variant is of a type that can be assigned to an Int64 (signed 64 bit) </summary>
function VarIsInt64(_v: variant): boolean;

// Variant to other type conversion functions
// TryVar2Xxx converts from variant to type Xxx, returns false, if
// the variant is NULL.
// Var2Xxx converts from variant to type Xxx and returns the Default if the
// variant is NULL.
// Var2XxxEx converts from variant to type Xxx, but raises an exception if
// variant is NULL, using the Source for the message.

///<summary> Converts a variant to an integer.
///          If v is null or empty, it returns false
///          @param v Variant value to convert
///          @param Value is the variants integer value, only valid if the function
///                       returns true.
///          @returns true, if the variant could be converted to integer, false if not. </summary>
function TryVar2Int(const _v: variant; out _Value: integer): boolean;
function TryVar2Int64(const _v: variant; out _Value: int64): boolean;

///<summary> Converts a variant to an integer.
///          If v is null or empty, it returns the Default.
///          @param v Variant value to convert
///          @param Default Value to return if v is empty or null
///          @returns the integer value of v or the Default if v can not be converted </summary>
function Var2Int(const _v: variant; _Default: integer): integer;

///<summary> Converts a variant to an integer.
///          Raises an exception if v can not be converted.
///          @param v Variant value to convert
///          @param Source string to include in the exception message
///          @returns the integer value of v
///          @raises EVarIsNull if v is null
///          @raises EVarIsEmpty if v is empty
///          @raises EVariantConvertError if there is some other conversion error </summary>
function Var2IntEx(const _v: variant; const _Source: string): integer;

///<summary> tries to convert a variant to a boolean
///          @param b contains the value if the conversion succeeds
///          @returns true on success, false otherwise </summary>
function TryVar2Bool(const _v: variant; out _b: Boolean): boolean;

///<summary> Converts a variant to a boolean </summary>
function Var2BoolEx(const _v: variant; const _Source: string): boolean;

///<summary> Converts a variant to the string representation of an integer.
///          If v is null or empty, it returns the NullValue.
///          @param v Variant value to convert
///          @param NullValue String value to return if v is empty or null
///          @returns the string representation of the integer value of v or the
///                   NullValue if v can not be converted </summary>
function Var2IntStr(const _v: variant; const _NullValue: string = '*NULL*'): string;

///<summary> tries to convert a variant to a single
///          If v is null or empty, it returns false.
///          @param v Variant value to convert
///          @param Value is the variant's single value, only valid if the function
///                       returns true.
///          @returns true, if the variant could be converted to single, false if not
///          @raises EVariantConvertError if there is some other conversion error </summary>
function TryVar2Single(const _v: variant; out _Value: single): boolean;

///<summary> tries to convert a variant to a double
///          If v is null or empty, it returns false.
///          @param v Variant value to convert
///          @param Value is the variant's double value, only valid if the function
///                       returns true.
///          @returns true, if the variant could be converted to double, false if not
///          @raises EVariantConvertError if there is some other conversion error </summary>
function TryVar2Dbl(const _v: variant; out _Value: double): boolean;

///<summary> Converts a variant to a double.
///          If v is null or empty, it returns the Default.
///          @param v Variant value to convert
///          @param Default Value to return if v is empty or null
///          @returns the double value of v or the Default if v can not be converted </summary>
function Var2Dbl(const _v: variant; const _Default: double): double;

///<summary> Converts a variant to a double.
///          Raises an exception if v can not be converted.
///          @param v Variant value to convert
///          @param Source string to include in the exception message
///          @returns the double value of v
///          @raises EVarIsNull if v is null
///          @raises EVarIsEmpty if v is empty
///          @raises EVariantConvertError if there is some other conversion error </summary>
function Var2DblEx(const _v: variant; const _Source: string): double;

///<summary> Converts a variant to the string representation of a double.
///          If v is null or empty, it returns the Default.
///          It uses Float2Str (not FloatToStr) with a '.' as decimal separator.
///          @param v Variant value to convert
///          @param NullValue String value to return if v is empty or null
///          @returns the string representation of the double value of v or the
///                   NullValue if v can not be converted </summary>
function Var2DblStr(const _v: variant; const _NullValue: string = '*NULL*'): string;

///<summary> tries to convert a variant to an extended
///          If v is null or empty, it returns false.
///          @param v Variant value to convert
///          @param Value is the variant's extended value, only valid if the function
///                       returns true.
///          @returns true, if the variant could be converted to extended, false if not
///          @raises EVariantConvertError if there is some other conversion error </summary>
function TryVar2Ext(const _v: variant; out _Value: extended): boolean;

///<summary> Converts a variant to an extended.
///          Raises an exception if v can not be converted.
///          @param v Variant value to convert
///          @param Source string to include in the exception message
///          @returns the extended value of v
///          @raises EVarIsNull if v is null
///          @raises EVarIsEmpty if v is empty
///          @raises EVariantConvertError if there is some other conversion error </summary>
function Var2ExtEx(const _v: variant; const _Source: string): extended;

///<summary> Converts a variant to an extended.
///          If v is null or empty, it returns the Default.
///          @param v Variant value to convert
///          @param Default Value to return if v is empty or null
///          @returns the extended value of v or the Default if v can not be converted </summary>
function Var2Ext(const _v: variant; const _Default: extended): extended;

///<summary> Converts a variant to a TDateTime.
///          Raises an exception if v can not be converted.
///          @param v Variant value to convert
///          @param Source string to include in the exception message
///          @returns the TDateTime value of v
///          @raises EVarIsNull if v is null
///          @raises EVarIsEmpty if v is empty
///          @raises EVariantConvertError if there is some other conversion error </summary>
function Var2DateTimeEx(const _v: variant; const _Source: string): TDateTime;

function TryVar2DateTime(const _v: Variant; out _dt: TDateTime): boolean;

///<summary> Converts a variant to an ISO format DateTime string (yyyy-mm-dd hh:mm:ss)
///          @param v Variant value to convert
///          @param NullValue String value to return if v is empty or null
///          @returns an ISO format DateTime string of v or NullValue if v can not be converted </summary>
function Var2DateTimeStr(const _v: variant; const _NullValue: string = '*NULL*'): string;

///<summary> Converts a variant to an ISO format Date string (yyyy-mm-dd)
///          @param v Variant value to convert
///          @param NullValue String value to return if v is empty or null
///          @returns an ISO format Date string of v or NullValue if v can not be converted </summary>
function Var2DateStr(const _v: variant; const _NullValue: string = '*NULL*'): string;

///<summary> Converts a variant to a string
///          If v is null or empty, it returns false.
///          @param v Variant value to convert
///          @param Value is the variant's string value, only valid if the function
///                       returns true.
///          @returns true, if the variant could be converted to double, false if not </summary>
function TryVar2Str(const _v: variant; out _Value: string): boolean;

///<summary> Converts a variant to a string.
///          If v is null or empty, it returns the Default.
///          @param v Variant value to convert
///          @param Default Value to return if v is empty or null
///          @returns the string value of v or the Default if v can not be converted </summary>
function Var2Str(const _v: variant; const _Default: string = '*NULL*'): string;

///<summary> Converts a variant to a string.
///          Raises an exception if v can not be converted.
///          @param v Variant value to convert
///          @param Source string to include in the exception message
///          @returns the string value of v
///          @raises EVarIsNull if v is null
///          @raises EVarIsEmpty if v is empty
///          @raises EVariantConvertError if there is some other conversion error </summary>
function Var2StrEx(_v: variant; const _Source: string): string;

implementation

uses
  u_dzConvertUtils;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

function toString(_v: OleVariant): string;
var
  i, j: Integer;
begin
  try
    case VarType(_v) of
      varEmpty: result := '<Empty>'; // do not translate
      varNull: result := '<Null>'; // do not translate
      varSmallint: result := VarToStr(_v);
      varInteger: result := VarToStr(_v);
      varSingle: result := VarToStr(_v);
      varDouble: result := VarToStr(_v);
      varCurrency: result := VarToStr(_v);
      varDate: result := VarToStr(_v);
      varOleStr: result := VarToStr(_v);
      varDispatch: result := VarToStr(_v);
      varString: result := VarToStr(_v);
      varArray: begin
          if VarArrayDimCount(_v) = 1 then begin
            for i := VarArrayLowBound(_v, 1) to VarArrayHighBound(_v, 1) do
              result := result + toString(_v[i]);
          end else if VarArrayDimCount(_v) = 2 then begin
            for i := VarArrayLowBound(_v, 1) to VarArrayHighBound(_v, 1) do
              for j := VarArrayLowBound(_v, 1) to VarArrayHighBound(_v, 1) do
                result := result + toString(_v[i, j]);
          end else
            result := '3dim-array not supported'; // do not translate
        end;
    else
      result := '<Unknown Type>'; // do not translate
    end;
    result := result + ' (' + VarTypeAsText(VarType(_v)) + ')';
  except
    on ex: Exception do
      result := result + '#ERROR: ' + ex.Message; // do not translate
  end;
end;

function VarIsInteger(_v: variant): boolean;
begin
  Result := VarIsType(_V, [varSmallInt, varInteger, varShortInt, varByte, varWord]);
end;

function VarIsLongWord(_v: variant): boolean;
begin
  Result := VarIsType(_V, [varByte, varWord, varLongWord]);
end;

function VarIsInt64(_v: variant): boolean;
begin
  Result := VarIsType(_V, [varSmallInt, varInteger, varShortInt, varByte, varWord, varLongWord, varInt64]);
end;

function TryVar2Int(const _v: variant; out _Value: integer): boolean;
begin
  Result := not VarIsNull(_v) and not VarIsEmpty(_v);
  if Result then
    try
      _Value := _v;
    except
      on e: EVariantError do
        Result := False;
    end;
end;

function TryVar2Int64(const _v: variant; out _Value: int64): boolean;
begin
  Result := not VarIsNull(_v) and not VarIsEmpty(_v);
  if Result then
    try
      _Value := _v;
    except
      on e: EVariantError do
        Result := False;
    end;
end;

function Var2Int(const _v: variant; _Default: integer): integer;
begin
  if not TryVar2Int(_v, Result) then
    Result := _Default;
end;

function Var2IntEx(const _v: variant; const _Source: string): integer;
const
  EXPECTED = 'Integer'; // do not translate
begin
  if VarIsNull(_v) then
    raise EVarIsNull.CreateFmt(_('Variant is Null, should be %s: %s'), [EXPECTED, _Source]);
  if VarIsEmpty(_v) then
    raise EVarIsEmpty.CreateFmt(_('Variant is Empty, should be %s: %s'), [EXPECTED, _Source]);
  try
    Result := _v;
  except
    on e: EVariantError do
      raise EVariantConvertError.CreateFmt(_('Variant can not be converted to %s: %s'), [EXPECTED, _Source]);
  end;
end;

function TryVar2Bool(const _v: variant; out _b: Boolean): boolean;
begin
  Result := not VarIsNull(_v) and not VarIsEmpty(_v);
  if Result then begin
    try
      _b := _v;
    except
      on e: EVariantError do
        Result := false;
    end;
  end;
end;

function Var2BoolEx(const _v: variant; const _Source: string): boolean;
const
  EXPECTED = 'Boolean'; // do not translate
begin
  if VarIsNull(_v) then
    raise EVarIsNull.CreateFmt(_('Variant is Null, should be %s: %s'), [EXPECTED, _Source]);
  if VarIsEmpty(_v) then
    raise EVarIsEmpty.CreateFmt(_('Variant is Empty, should be %s: %s'), [EXPECTED, _Source]);
  try
    Result := _v;
  except
    on e: EVariantError do
      raise EVariantConvertError.CreateFmt(_('Variant can not be converted to %s: %s'), [EXPECTED, _Source]);
  end;
end;

function Var2IntStr(const _v: variant; const _NullValue: string = '*NULL*'): string;
var
  Value: integer;
begin
  if TryVar2Int(_v, Value) then
    Result := IntToStr(Value)
  else
    Result := _NullValue;
end;

function Var2DateTimeEx(const _v: variant; const _Source: string): TDateTime;
const
  EXPECTED = 'Date'; // do not translate
begin
  if VarIsNull(_v) then
    raise EVarIsNull.CreateFmt(_('Variant is Null, should be %s: %s'), [EXPECTED, _Source]);
  if VarIsEmpty(_v) then
    raise EVarIsEmpty.CreateFmt(_('Variant is Empty, should be %s: %s'), [EXPECTED, _Source]);
  try
    Result := _v;
  except
    on e: EVariantError do
      raise EVariantConvertError.CreateFmt(_('Variant can not be converted to %s: %s'), [EXPECTED, _Source]);
  end;
end;

function TryVar2DateTime(const _v: Variant; out _dt: TDateTime): boolean;
begin
  Result := VarIsType(_v, varDate);
  if Result then
    _dt := VarToDateTime(_v);
end;

function Var2DateTimeStr(const _v: variant; const _NullValue: string = '*NULL*'): string;
var
  Value: TDateTime;
begin
  if VarIsNull(_v) or VarIsEmpty(_v) then
    Result := _NullValue
  else
    try
      Value := _v;
      Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', Value); // do not translate
    except
      Result := _NullValue;
    end;
end;

function Var2DateStr(const _v: variant; const _NullValue: string = '*NULL*'): string;
var
  Value: TDateTime;
begin
  if VarIsNull(_v) or VarIsEmpty(_v) then
    Result := _NullValue
  else
    try
      Value := _v;
      Result := FormatDateTime('yyyy-mm-dd', Value); // do not translate
    except
      Result := _NullValue;
    end;
end;

function TryVar2Single(const _v: variant; out _Value: single): boolean;
const
  EXPECTED = 'single'; // do not translate
begin
  Result := not VarIsNull(_v) and not VarIsEmpty(_v);
  if Result then
    try
      _Value := _v;
    except
      on e: EVariantError do
        raise EVariantConvertError.CreateFmt(_('Variant can not be converted to %s'), [EXPECTED]);
    end;
end;

function TryVar2Dbl(const _v: variant; out _Value: double): boolean;
const
  EXPECTED = 'double'; // do not translate
begin
  Result := not VarIsNull(_v) and not VarIsEmpty(_v);
  if Result then
    try
      _Value := _v;
    except
      on e: EVariantError do
        raise EVariantConvertError.CreateFmt(_('Variant can not be converted to %s'), [EXPECTED]);
    end;
end;

function TryVar2Ext(const _v: variant; out _Value: extended): boolean;
const
  EXPECTED = 'extended'; // do not translate
begin
  Result := not VarIsNull(_v) and not VarIsEmpty(_v);
  if Result then
    try
      _Value := _v;
    except
      on e: EVariantError do
        raise EVariantConvertError.CreateFmt(_('Variant can not be converted to %s'), [EXPECTED]);
    end;
end;

function Var2Dbl(const _v: variant; const _Default: double): double;
begin
  if not TryVar2Dbl(_v, Result) then
    Result := _Default
end;

function Var2DblEx(const _v: variant; const _Source: string): double;
const
  EXPECTED = 'double'; // do not translate
begin
  if VarIsNull(_v) then
    raise EVarIsNull.CreateFmt(_('Variant is Null, should be %s: %s'), [EXPECTED, _Source]);
  if VarIsEmpty(_v) then
    raise EVarIsEmpty.CreateFmt(_('Variant is Empty, should be %s: %s'), [EXPECTED, _Source]);
  try
    Result := _v;
  except
    on e: EVariantError do
      raise EVariantConvertError.CreateFmt(_('Variant can not be converted to %s: %s'), [EXPECTED, _Source]);
  end;
end;

function Var2ExtEx(const _v: variant; const _Source: string): extended;
const
  EXPECTED = 'extended'; // do not translate
begin
  if VarIsNull(_v) then
    raise EVarIsNull.CreateFmt(_('Variant is Null, should be %s: %s'), [EXPECTED, _Source]);
  if VarIsEmpty(_v) then
    raise EVarIsEmpty.CreateFmt(_('Variant is Empty, should be %s: %s'), [EXPECTED, _Source]);
  try
    Result := _v;
  except
    on e: EVariantError do
      raise EVariantConvertError.CreateFmt(_('Variant can not be converted to %s: %s'), [EXPECTED, _Source]);
  end;
end;

function Var2Ext(const _v: variant; const _Default: extended): extended;
begin
  if not TryVar2Ext(_v, Result) then
    Result := _Default
end;

function Var2DblStr(const _v: variant; const _NullValue: string = '*NULL*'): string;
var
  Value: double;
begin
  if TryVar2Dbl(_v, Value) then
    Result := Float2Str(Value)
  else
    Result := _NullValue;
end;

function TryVar2Str(const _v: variant; out _Value: string): boolean;
const
  EXPECTED = 'String'; // do not translate
begin
  Result := not VarIsNull(_v) and not VarIsEmpty(_v);
  if Result then
    try
      _Value := _v;
    except
      on e: EVariantError do
        raise EVariantConvertError.CreateFmt(_('Variant can not be converted to %s'), [EXPECTED]);
    end;
end;

function Var2Str(const _v: variant; const _Default: string): string;
begin
  if not TryVar2Str(_v, Result) then
    Result := _Default
end;

function Var2StrEx(_v: variant; const _Source: string): string;
const
  EXPECTED = 'string'; // do not translate
begin
  if VarIsNull(_v) then
    raise EVarIsNull.CreateFmt(_('Variant is Null, should be %s: %s'), [EXPECTED, _Source]);
  if VarIsEmpty(_v) then
    raise EVarIsEmpty.CreateFmt(_('Variant is Empty, should be %s: %s'), [EXPECTED, _Source]);
  try
    Result := _v;
  except
    on e: EVariantError do
      raise EVariantConvertError.CreateFmt(_('Variant can not be converted to %s: %s'), [EXPECTED, _Source]);
  end;
end;

end.

