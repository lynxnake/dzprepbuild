{.GXFormatter.config=twm}
unit u_dzTranslator;

{$I jedi.inc}

{$IFNDEF NO_TRANSLATION}
// for now uses gnugettext
{$DEFINE gnugettext}
{$ELSE}
{$IFNDEF NO_TRANSLATION_HINT}
{$MESSAGE HINT 'translation is turned off, remove NO_TRANSLATION define to turn it on'}
{$ENDIF}
{$ENDIF}

interface

uses
  SysUtils,
{$IFDEF gnugettext}
  // NOTE: If you don't want any translations, define "NO_TRANSLATION" for your project
  gnugettext, // libs\dxgettext
  languagecodes,
{$ENDIF}
  Classes;

function _(const _s: string): string;
function GetText(const _s: string): string; inline;
function dzGetText(const _s: string): string; inline;
function DGetText(const _s: string; const _TextDomain: string = ''): string;
///<summary> use this if you pass variables rather than constants to avoid warnings in the dxgettext tool </summary>
function dzDGetText(const _s: string; const _TextDomain: string = ''): string; inline;
procedure TranslateComponent(_Object: TComponent; const _TextDomain: string = '');
procedure RetranslateComponent(_Object: TComponent; const _TextDomain: string = '');
procedure AddDomainForResourceString(const _Domain: string);
procedure SelectTextDomain(const _Domain: string);
procedure TP_GlobalIgnoreClass(_IgnClass: TClass);
function TP_TryGlobalIgnoreClass(_IgnClass: TClass): boolean;
procedure TP_GlobalIgnoreClassProperty(_IgnClass: TClass; const _PropertyName: string);
procedure UseLanguage(_LanguageCode: string);
function GetCurrentLanguage: string;
procedure GetListOfLanguages(const _Domain: string; _Codes: TStrings; _Languages: TStrings = nil);

type
  {: use this for translation of special strings that might not be in the same language
     as the program (e.g. a German program generating an English report }
  IdzTranslator = interface ['{FD88CFEE-F2D6-45FB-BBD2-D3C6BE066683}']
    function GetText(const _s: string): string;
  end;

function GenerateTranslator(const _LanguageCode: string): IdzTranslator;

implementation

uses
  Controls,
  ActnList,
  Graphics,
  ExtCtrls;

function _(const _s: string): string;
begin
{$IFDEF gnugettext}
  Result := gnugettext._(_s);
{$ELSE}
  Result := _s;
{$ENDIF}
end;

function GetText(const _s: string): string;
begin
  Result := u_dzTranslator._(_s);
end;

function dzGetText(const _s: string): string;
begin
  Result := u_dzTranslator._(_s);
end;

function DGetText(const _s: string; const _TextDomain: string = ''): string;
begin
{$IFDEF gnugettext}
  Result := gnugettext.DGetText(_TextDomain, _s);
{$ELSE}
  Result := _s;
{$ENDIF}
end;

function dzDGetText(const _s: string; const _TextDomain: string = ''): string; inline;
begin
  Result := DGetText(_s, _TextDomain);
end;

procedure TranslateComponent(_Object: TComponent; const _TextDomain: string = '');
begin
{$IFDEF gnugettext}
  gnugettext.TranslateComponent(_Object, _TextDomain);
{$ENDIF}
end;

procedure RetranslateComponent(_Object: TComponent; const _TextDomain: string = '');
begin
{$IFDEF gnugettext}
  gnugettext.RetranslateComponent(_Object, _TextDomain);
{$ENDIF}
end;

procedure AddDomainForResourceString(const _Domain: string);
begin
{$IFDEF gnugettext}
  gnugettext.AddDomainForResourceString(_Domain);
{$ENDIF}
end;

procedure SelectTextDomain(const _Domain: string);
begin
{$IFDEF gnugettext}
  gnugettext.textdomain(_Domain);
{$ENDIF}
end;

procedure TP_GlobalIgnoreClass(_IgnClass: TClass);
begin
{$IFDEF gnugettext}
  gnugettext.TP_GlobalIgnoreClass(_IgnClass);
{$ENDIF}
end;

function TP_TryGlobalIgnoreClass(_IgnClass: TClass): boolean;
begin
{$IFDEF gnugettext}
  Result := gnugettext.TP_TryGlobalIgnoreClass(_IgnClass);
{$ELSE}
  Result := true;
{$ENDIF}
end;

procedure TP_GlobalIgnoreClassProperty(_IgnClass: TClass; const _PropertyName: string);
begin
{$IFDEF gnugettext}
  gnugettext.TP_GlobalIgnoreClassProperty(_IgnClass, _PropertyName);
{$ENDIF}
end;

procedure UseLanguage(_LanguageCode: string);
begin
{$IFDEF gnugettext}
  gnugettext.UseLanguage(_LanguageCode);
{$ENDIF}
end;

procedure GetListOfLanguages(const _Domain: string; _Codes: TStrings; _Languages: TStrings = nil);
{$IFDEF gnugettext}
var
  i: integer;
{$ENDIF}
begin
{$IFDEF gnugettext}
  _Codes.Clear;
  gnugettext.DefaultInstance.GetListOfLanguages(_Domain, _Codes);
  if Assigned(_Languages) then begin
    _Languages.Clear;
    for i := 0 to _Codes.Count - 1 do begin
      _Languages.Add(languagecodes.getlanguagename(_Codes[i]));
    end;
  end;
{$ENDIF}
end;

function GetCurrentLanguage: string;
begin
{$IFDEF gnugettext}
  Result := gnugettext.GetCurrentLanguage;
{$ENDIF}
end;
type
  TdzTranslator = class(TInterfacedObject, IdzTranslator)
  protected
{$IFDEF gnugettext}
    fGetTextInstance: TGnuGettextInstance;
{$ENDIF}
  protected
    function GetText(const _s: string): string;
  public
    constructor Create(const _LanguageCode: string);
  end;

constructor TdzTranslator.Create(const _LanguageCode: string);
begin
  inherited Create;
{$IFDEF gnugettext}
  fGetTextInstance := TGnuGettextInstance.Create;
  fGetTextInstance.UseLanguage(_LanguageCode);
{$ENDIF}
end;

function TdzTranslator.GetText(const _s: string): string;
begin
{$IFDEF gnugettext}
  Result := fGetTextInstance.gettext(_s);
{$ELSE}
  Result := _s;
{$ENDIF}
end;

function GenerateTranslator(const _LanguageCode: string): IdzTranslator;
begin
  Result := TdzTranslator.Create(_LanguageCode);
end;

{$IFDEF gnugettext}
initialization
  // translate runtime library
{$IFDEF DELPHI6}
  AddDomainForResourceString('delphi6');
{$ELSE}{$IFDEF DELPHI7}
  AddDomainForResourceString('delphi7');
{$ELSE}{$IFDEF DELPHI10}
  AddDomainForResourceString('delphi2006');
{$ELSE}{$IFDEF DELPHI11}
  AddDomainForResourceString('delphi2007');
{$ELSE}{$IFDEF DELPHI12}
  AddDomainForResourceString('delphi2009');
{$ELSE}{$IFDEF DELPHI14}
  AddDomainForResourceString('delphi2010');
{$ELSE}{$IFDEF DELPHI15}
  // until we get Delphi XP translations, we use those from Delphi 2010
  AddDomainForResourceString('delphi2010');
{$ELSE}
  'unknown Delphi version!';
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}

  // ignore these VCL properties / classes
  TP_GlobalIgnoreClassProperty(TAction, 'Category');
  TP_GlobalIgnoreClassProperty(TControl, 'ImeName');
  TP_GlobalIgnoreClassProperty(TControl, 'HelpKeyword');
  TP_TryGlobalIgnoreClass(TFont);
  TP_GlobalIgnoreClassProperty(TNotebook, 'Pages');

// for more ignores, see u_dzTranslatorDB and u_dzTranslatorADO

{$IFDEF DXGETTEXTDEBUG}
  gnugettext.DefaultInstance.DebugLogToFile(ExtractFilePath(GetModuleName(HInstance)) + 'dxgettext.log');
{$ENDIF DXGETTEXTDEBUG}

{$ENDIF gnugettext}
end.

