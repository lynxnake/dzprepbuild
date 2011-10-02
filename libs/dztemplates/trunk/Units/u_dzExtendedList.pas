unit u_dzExtendedList;

interface

uses
  Classes;

type
  TExtendedEntry = class
  private
    FValue: Extended;
  public
    constructor Create(_Value: extended);
    property Value: Extended read FValue write FValue;
  end;

{$DEFINE __DZ_LIST_TEMPLATE__}
type
  _LIST_ANCESTOR_ = TObject;
  _LIST_CONTAINER_ = TList;
  _LIST_CONTAINER_ITEM_TYPE_ = pointer;
  _ITEM_TYPE_ = TExtendedEntry;
{$INCLUDE 't_dzListTemplate.tpl'}

type
  {: List for storing TExtendedEntry items }
  TdzExtendedList = class(_DZ_LIST_TEMPLATE_)
  protected
    {: Frees a TExtendedEntry }
    procedure FreeItem(_Item: TExtendedEntry); override;
  public
    procedure Add(_Value: extended); reintroduce;
    function Extract(_Idx: integer): extended; reintroduce;
  end;

implementation

{$INCLUDE 't_dzListTemplate.tpl'}

procedure TdzExtendedList.Add(_Value: extended);
begin
  inherited Add(TExtendedEntry.Create(_Value));
end;

function TdzExtendedList.Extract(_Idx: integer): extended;
var
  Item: TExtendedEntry;
begin
  Item := inherited Extract(_Idx);
  Result := Item.Value;
  FreeItem(Item);
end;

procedure TdzExtendedList.FreeItem(_Item: TExtendedEntry);
begin
  _Item.Free;
end;

{ TExtendedEntry }

constructor TExtendedEntry.Create(_Value: extended);
begin
  inherited Create;
  FValue := _Value;
end;

end.

