unit u_dzNullableTypesUtils;

interface

uses
  SysUtils;

type
  EInvalidValue = class(Exception);

procedure StrToNumber(const _s: string; out _Value: integer); overload;
procedure StrToNumber(const _s: string; out _Value: single); overload;
procedure StrToNumber(const _s: string; out _Value: double); overload;
procedure StrToNumber(const _s: string; out _Value: extended); overload;

function TryStrToNumber(const _s: string; out _Value: integer): boolean; overload;
function TryStrToNumber(const _s: string; out _Value: Int64): boolean; overload;
function TryStrToNumber(const _s: string; out _Value: single): boolean; overload;
function TryStrToNumber(const _s: string; out _Value: double): boolean; overload;
function TryStrToNumber(const _s: string; out _Value: extended): boolean; overload;

function NumberToStr(_Value: integer): string; overload;
function NumberToStr(_Value: single): string; overload;
function NumberToStr(_Value: double): string; overload;
function NumberToStr(_Value: extended): string; overload;

function TryVar2Number(const _v: variant; out _Value: integer): boolean; overload;
function TryVar2Number(const _v: variant; out _Value: Int64): boolean; overload;
function TryVar2Number(const _v: variant; out _Value: single): boolean; overload;
function TryVar2Number(const _v: variant; out _Value: double): boolean; overload;
function TryVar2Number(const _v: variant; out _Value: extended): boolean; overload;

function GetNullableTypesFlagInterface: IInterface;

procedure DivideNumbers(_a, _b: Integer; out _Value: Integer); overload;
procedure DivideNumbers(_a, _b: Int64; out _Value: Int64); overload;
procedure DivideNumbers(_a, _b: Single; out _Value: Single); overload;
procedure DivideNumbers(_a, _b: Double; out _Value: Double); overload;
procedure DivideNumbers(_a, _b: Extended; out _Value: Extended); overload;

implementation

uses
  u_dzVariantUtils;

// this is a fake interfaced object that only exists as the VMT
// It can still be used to trick the compiler into believing an interface pointer is assigned

function NopAddref(inst: Pointer): Integer; stdcall;
begin
  Result := -1;
end;

function NopRelease(inst: Pointer): Integer; stdcall;
begin
  Result := -1;
end;

function NopQueryInterface(inst: Pointer; const IID: TGUID; out Obj): HResult; stdcall;
begin
  Result := E_NOINTERFACE;
end;

const
  FlagInterfaceVTable: array[0..2] of Pointer =
    (
    @NopQueryInterface,
    @NopAddref,
    @NopRelease
    );
const
  FlagInterfaceInstance: Pointer = @FlagInterfaceVTable;

function GetNullableTypesFlagInterface: IInterface;
begin
  Result := IInterface(@FlagInterfaceInstance);
end;

// StrToNumber

procedure StrToNumber(const _s: string; out _Value: integer);
begin
  _Value := StrToInt(_s);
end;

procedure StrToNumber(const _s: string; out _Value: single);
begin
  _Value := StrToFloat(_s);
end;

procedure StrToNumber(const _s: string; out _Value: double);
begin
  _Value := StrToFloat(_s);
end;

procedure StrToNumber(const _s: string; out _Value: extended);
begin
  _Value := StrToFloat(_s);
end;

// TryStrToNumber

function TryStrToNumber(const _s: string; out _Value: integer): boolean;
begin
  Result := TryStrToInt(_s, _Value);
end;

function TryStrToNumber(const _s: string; out _Value: Int64): boolean;
begin
  Result := TryStrToInt64(_s, _Value);
end;

function TryStrToNumber(const _s: string; out _Value: single): boolean;
begin
  Result := TryStrToFloat(_s, _Value);
end;

function TryStrToNumber(const _s: string; out _Value: double): boolean;
begin
  Result := TryStrToFloat(_s, _Value);
end;

function TryStrToNumber(const _s: string; out _Value: extended): boolean;
begin
  Result := TryStrToFloat(_s, _Value);
end;

// NumberToStr

function NumberToStr(_Value: integer): string;
begin
  Result := IntToStr(_Value);
end;

function NumberToStr(_Value: single): string;
begin
  Result := FloatToStr(_Value);
end;

function NumberToStr(_Value: double): string;
begin
  Result := FloatToStr(_Value);
end;

function NumberToStr(_Value: extended): string;
begin
  Result := FloatToStr(_Value);
end;

// TryVar2Number

function TryVar2Number(const _v: variant; out _Value: integer): boolean;
begin
  Result := TryVar2Int(_v, _Value);
end;

function TryVar2Number(const _v: variant; out _Value: Int64): boolean;
begin
  Result := TryVar2Int64(_v, _Value);
end;

function TryVar2Number(const _v: variant; out _Value: single): boolean;
begin
  Result := TryVar2Single(_v, _Value);
end;

function TryVar2Number(const _v: variant; out _Value: double): boolean;
begin
  Result := TryVar2Dbl(_v, _Value);
end;

function TryVar2Number(const _v: variant; out _Value: extended): boolean;
begin
  Result := TryVar2Ext(_v, _Value);
end;

procedure DivideNumbers(_a, _b: Integer; out _Value: Integer);
begin
  _Value := _a div _b;
end;

procedure DivideNumbers(_a, _b: Int64; out _Value: Int64);
begin
  _Value := _a div _b;
end;

procedure DivideNumbers(_a, _b: Single; out _Value: Single);
begin
  _Value := _a / _b;
end;

procedure DivideNumbers(_a, _b: Double; out _Value: Double);
begin
  _Value := _a / _b;
end;

procedure DivideNumbers(_a, _b: Extended; out _Value: Extended);
begin
  _Value := _a / _b;
end;

end.

