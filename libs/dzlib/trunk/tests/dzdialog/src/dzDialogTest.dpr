program dzDialogTest;

uses
  Forms,
  w_dzDialogText in 'w_dzDialogText.pas' {f_dzDialogTest},
  w_dzDialog in '..\..\..\forms\w_dzDialog.pas' {f_dzDialog},
  u_dzTranslator in '..\..\..\src\u_dzTranslator.pas',
  u_dzVclUtils in '..\..\..\src\u_dzVclUtils.pas',
  u_dzConvertUtils in '..\..\..\src\u_dzConvertUtils.pas',
  u_dzStringUtils in '..\..\..\src\u_dzStringUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tf_dzDialogTest, f_dzDialogTest);
  Application.Run;
end.
