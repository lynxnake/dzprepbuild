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
  TdzNameValueObj = class
  protected
    fName: string;
    fValue: string;
  public
    constructor Create(const _Name, _Value: string);
    property Name: string read fName;
    property Value: string read fValue;
  end;

{$DEFINE __DZ_SORTED_OBJECT_LIST_TEMPLATE__}
type
  _LIST_ANCESTOR_ = TObject;
  _ITEM_TYPE_ = TdzNameValueObj;
  _KEY_TYPE_ = string;
{$INCLUDE 't_dzSortedObjectListTemplate.tpl'}

type
  ///<summary> List for storing TdzNameValueObj items sorted by String </summary>
  TdzNameValueList = class(_DZ_SORTED_OBJECT_LIST_TEMPLATE_)
  private
    function GetByName(const _Name: string): string;
    procedure SetByName(const _Name, _Value: string);
  protected
    ///<summary> return the key of an item for comparison </summary>
    function KeyOf(const _Item: TdzNameValueObj): string; override;
    ///<summary> compare the keys of two items, must return a value
    ///          < 0 if Key1 < Key2, = 0 if Key1 = Key2 and > 0 if Key1 > Key2 </summary>
    function Compare(const _Key1, _Key2: string): integer; override;
  public
    function Add(const _Name, _Value: string): integer;
    function ByNameDef(const _Name, _Default: string): string;
    function SearchByName(const _Name: string; out _Value: string): boolean;
    property ByName[const _Name: string]: string read GetByName write SetByName;
  end;

implementation

uses
  u_dztranslator;

{$INCLUDE 't_dzSortedObjectListTemplate.tpl'}

{ TdzNameValueObj }

constructor TdzNameValueObj.Create(const _Name, _Value: string);
begin
  inherited Create;
  fName := _Name;
  fValue := _Value;
end;

{ TdzNameValueList }

function TdzNameValueList.KeyOf(const _Item: TdzNameValueObj): string;
begin
  Result := _Item.Name;
end;

function TdzNameValueList.Compare(const _Key1, _Key2: string): integer;
begin
  Result := CompareText(_Key1, _Key2);
end;

function TdzNameValueList.Add(const _Name, _Value: string): integer;
begin
  Result := Insert(TdzNameValueObj.Create(_Name, _Value));
end;

function TdzNameValueList.SearchByName(const _Name: string; out _Value: string): boolean;
var
  Idx: integer;
begin
  Result := Find(_Name, Idx);
  if Result then
    _Value := Items[Idx].Value;
end;

function TdzNameValueList.GetByName(const _Name: string): string;
begin
  if not SearchByName(_Name, Result) then
    raise ENameNotFound.CreateFmt(_('Entry "%s" not found.'), [_Name]);
end;

procedure TdzNameValueList.SetByName(const _Name, _Value: string);
var
  Idx: integer;
begin
  if Find(_Name, Idx) then
    Items[Idx].fValue := _Value
  else
    Insert(TdzNameValueObj.Create(_Name, _Value));
end;

function TdzNameValueList.ByNameDef(const _Name, _Default: string): string;
begin
  if not SearchByName(_Name, Result) then
    Result := _Default;
end;

end.

