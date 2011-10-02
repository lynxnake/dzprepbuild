unit u_dzNameValueList;

interface

uses
  SysUtils,
  Classes,
  u_dzQuicksort;

type
  ENameValueColl = class(Exception);
  ENameNotFound = class(ENameValueColl);

type
  TNameValue = class
  private
    FName: string;
    FValue: string;
  public
    constructor Create(const _Name, _Value: string);
    property Name: string read FName;
    property Value: string read FValue write FValue;
  end;

{$DEFINE __DZ_SORTED_OBJECT_LIST_TEMPLATE__}
type
  _LIST_ANCESTOR_ = TObject;
  _ITEM_TYPE_ = TNameValue;
  _KEY_TYPE_ = string;
{$INCLUDE 't_dzSortedObjectListTemplate.tpl'}

type
  {: Sorted list for storing TNameValue items }
  TNameValueList = class(_DZ_SORTED_OBJECT_LIST_TEMPLATE_)
  private
    function GetByName(const _Name: string): string;
    procedure SetByName(const _Name, _Value: string);
  protected
    ///<summary> return the key of an item for comparison </summary>
    function KeyOf(const _Item: TNameValue): string; override;
    ///<summary> compare the keys of two items, must return a value
    ///          < 0 if Key1 < Key2, = 0 if Key1 = Key2 and > 0 if Key1 > Key2 </summary>
    function Compare(const _Key1, _Key2: string): integer; override;
  public
    function Add(const _Name, _Value: string): integer; reintroduce; overload;
    function ByNameDef(const _Name, _Default: string): string;
    function Find(const _Name: string; out _Value: string): boolean; overload;
    property ByName[const _Name: string]: string read GetByName write SetByName;
  end;

implementation

uses
  u_dztranslator;

{$INCLUDE 't_dzSortedObjectListTemplate.tpl'}

{ TNameValue }

constructor TNameValue.Create(const _Name, _Value: string);
begin
  inherited Create;
  FName := _Name;
  FValue := _Value;
end;

{ TNameValueList }

function TNameValueList.KeyOf(const _Item: TNameValue): string;
begin
  Result := _Item.Name;
end;

function TNameValueList.Compare(const _Key1, _Key2: string): integer;
begin
  Result := CompareText(_Key1, _Key2);
end;

function TNameValueList.Add(const _Name, _Value: string): integer;
begin
  Result := Add(TNameValue.Create(_Name, _Value));
end;

function TNameValueList.Find(const _Name: string; out _Value: string): boolean;
var
  nv: TNameValue;
begin
  Result := Find(_Name, nv);
  if Result then
    _Value := nv.Value;
end;

function TNameValueList.GetByName(const _Name: string): string;
begin
  if not Find(_Name, Result) then
    raise ENameNotFound.CreateFmt(_('Entry "%s" not found.'), [_Name]);
end;

procedure TNameValueList.SetByName(const _Name, _Value: string);
var
  Idx: integer;
begin
  if Find(_Name, Idx) then
    Items[Idx].fValue := _Value
  else
    Add(TNameValue.Create(_Name, _Value));
end;

function TNameValueList.ByNameDef(const _Name, _Default: string): string;
begin
  if not Find(_Name, Result) then
    Result := _Default;
end;

end.

