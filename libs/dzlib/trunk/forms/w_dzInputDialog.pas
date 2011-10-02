unit w_dzInputDialog;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls;

type
  Tf_dzInputDialog = class(TForm)
    l_Query: TLabel;
    ed_Input: TEdit;
    b_Ok: TButton;
    b_Cancel: TButton;
  private
  public
    class function InputQuery(const _Caption: string; const _Prompt: string; var _Value: string): Boolean;
    class function InputBox(const _Caption: string; const _Prompt: string; const _Default: string): string;
    class function Execute(_Owner: TWinControl; const _Caption: string; const _Prompt: string; var _Value: string): Boolean;
    class procedure Display(_Owner: TWinControl; const _Caption, _Prompt, _Value: string);
  end;

implementation

{$R *.dfm}

uses
  u_dzVclUtils;

{ Tf_dzInputDialog }

class procedure Tf_dzInputDialog.Display(_Owner: TWinControl; const _Caption, _Prompt, _Value: string);
var
  frm: Tf_dzInputDialog;
begin
  frm := Tf_dzInputDialog.Create(_Owner);
  try
    TForm_CenterOn(frm, _Owner);
    frm.Caption := _Caption;
    frm.l_Query.Caption := _Prompt;
    frm.ed_Input.Text := _Value;
    frm.b_Ok.Visible := false;
    frm.b_Cancel.Caption := 'Close';
    frm.b_Cancel.Default := true;
    frm.ShowModal;
  finally
    FreeAndNil(frm);
  end;
end;

class function Tf_dzInputDialog.Execute(_Owner: TWinControl; const _Caption,
  _Prompt: string; var _Value: string): Boolean;
var
  frm: Tf_dzInputDialog;
begin
  frm := Tf_dzInputDialog.Create(_Owner);
  try
    TForm_CenterOn(frm, _Owner);
    frm.Caption := _Caption;
    frm.l_Query.Caption := _Prompt;
    frm.ed_Input.Text := _Value;
    Result := (frm.ShowModal = mrOk);
    if Result then
      _Value := frm.ed_Input.Text;
  finally
    FreeAndNil(frm);
  end;
end;

class function Tf_dzInputDialog.InputBox(const _Caption, _Prompt, _Default: string): string;
begin
  Result := _Default;
  if not InputQuery(_Caption, _Prompt, Result) then
    Result := _Default;
end;

class function Tf_dzInputDialog.InputQuery(const _Caption, _Prompt: string; var _Value: string): Boolean;
begin
  Result := Execute(nil, _Caption, _Prompt, _Value);
end;

end.

