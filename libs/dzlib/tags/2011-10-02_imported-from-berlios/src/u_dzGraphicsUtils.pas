unit u_dzGraphicsUtils;

interface

uses
  Windows,
  Types,
  Graphics;

///<summary> Returns the Rect's width </summary>
function TRect_Width(_Rect: TRect): integer; inline;

///<summary> Returns the Rect's height </summary>
function TRect_Height(_Rect: TRect): integer; inline;

///<summary> Returns the bounding box of the active clipping region </summary>
function TCanvas_GetClipRect(_Canvas: TCanvas): TRect;
procedure TCanvas_SetClipRect(_Canvas: TCanvas; _Rect: TRect);

///<summary> abbreviation for StretchBlt that takes TRect </summary>
function dzStretchBlt(_DestHandle: HDC; _DestRect: TRect; _SrcHandle: HDC; _SrcRect: TRect; _Rop: DWORD): LongBool; inline; overload;

///<summary> abbreviation for StretchBlt that takes TRect and TBitmap </summary>
function dzStretchBlt(_DestHandle: HDC; _DestRect: TRect; _Src: TBitmap; _Rop: DWORD): LongBool; inline; overload;

///<summary> abbreviation for StretchBlt that takes TPoint and TBitmap </summary>
function dzStretchBlt(_DestHandle: HDC; _DestPos: TPoint; _Src: TBitmap; _Rop: DWORD): LongBool; inline; overload;

///<summary> abbreviation for BitBlt that takes TRect and TBitmap </summary>
function dzBitBlt(_DestHandle: HDC; _DestRect: TRect; _Src: TBitmap; _Rop: DWORD): LongBool; inline; overload;

implementation

function TRect_Width(_Rect: TRect): integer; inline;
begin
  Result := _Rect.Right - _Rect.Left;
end;

function TRect_Height(_Rect: TRect): integer; inline;
begin
  Result := _Rect.Bottom - _Rect.Top;
end;

function dzStretchBlt(_DestHandle: HDC; _DestRect: TRect; _SrcHandle: HDC; _SrcRect: TRect; _Rop: DWORD): LongBool;
begin
  Result := StretchBlt(_DestHandle, _DestRect.Left, _DestRect.Top, TRect_Width(_DestRect), TRect_Height(_DestRect),
    _SrcHandle, _SrcRect.Left, _SrcRect.Top, TRect_Width(_SrcRect), TRect_Height(_SrcRect), _Rop);
end;

function dzStretchBlt(_DestHandle: HDC; _DestRect: TRect; _Src: TBitmap; _Rop: DWORD): LongBool;
begin
  Result := StretchBlt(_DestHandle, _DestRect.Left, _DestRect.Top, TRect_Width(_DestRect), TRect_Height(_DestRect),
    _Src.Canvas.Handle, 0, 0, _Src.Width, _Src.Height, _Rop);
end;

function dzStretchBlt(_DestHandle: HDC; _DestPos: TPoint; _Src: TBitmap; _Rop: DWORD): LongBool;
begin
  Result := StretchBlt(_DestHandle, _DestPos.X, _DestPos.Y, _Src.Width, _Src.Height,
    _Src.Canvas.Handle, 0, 0, _Src.Width, _Src.Height, _Rop);
end;

function dzBitBlt(_DestHandle: HDC; _DestRect: TRect; _Src: TBitmap; _Rop: DWORD): LongBool;
begin
  Result := BitBlt(_DestHandle, _DestRect.Left, _DestRect.Top, _DestRect.Right, _DestRect.Bottom,
    _Src.Canvas.Handle, 0, 0, SRCCOPY);
end;

function TCanvas_GetClipRect(_Canvas: TCanvas): TRect;
var
  RGN: THandle;
begin
  RGN := CreateRectRgn(0, 0, 0, 0);
  try
    GetClipRgn(_Canvas.Handle, RGN);
    GetRgnBox(RGN, Result);
  finally
    DeleteObject(RGN);
  end;
end;

procedure TCanvas_SetClipRect(_Canvas: TCanvas; _Rect: TRect);
var
  RGN: THandle;
begin
  RGN := CreateRectRgn(_Rect.Left, _Rect.Top, _Rect.Right, _Rect.Bottom);
  SelectClipRgn(_Canvas.Handle, RGN);
  DeleteObject(RGN);
end;

end.

