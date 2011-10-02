unit u_dzDbUtils;

interface

uses
  SysUtils,
  Classes,
  DBTables,
  DB;

///<summary> Deletes the table file if it exists, only tested for dbase tables
///          @returns true, if successfull, false otherwise </summary>
function TTable_DeleteTable(_tbl: TTable): boolean;

///<summary> Deletes all table indices, only tested for dbase tables </summary>
procedure TTable_DeleteAllIndices(_tbl: TTable);

///<summary> Adds a field definition to a table </summary>
procedure TTable_AddFieldDef(_tbl: TTable; const _Name: string; _DataType: TFieldType; _Precision, _Size: integer); inline;

implementation

function TTable_DeleteTable(_tbl: TTable): boolean;
begin
  Result := FileExists(IncludeTrailingPathDelimiter(_tbl.DatabaseName) + _tbl.TableName);
  if Result then
    _tbl.DeleteTable;
end;

procedure TTable_DeleteAllIndices(_tbl: TTable);
var
  i: Integer;
  sl: TStringList;
begin
  if _tbl.TableName = '' then
    exit;
  if _tbl.Active then _tbl.Active := False;
  _tbl.IndexName := '';
  sl := TStringList.Create;
  try
    _tbl.GetIndexNames(sl);
    for i := 0 to sl.Count - 1 do
      _tbl.DeleteIndex(sl[i]);
  finally
    sl.Free;
  end;
end;

procedure TTable_AddFieldDef(_tbl: TTable; const _Name: string; _DataType: TFieldType; _Precision, _Size: integer);
var
  fd: TFieldDef;
begin
  fd := _tbl.FieldDefs.AddFieldDef;
  fd.Name := _Name;
  fd.DataType := _DataType;
  fd.Precision := _Precision;
  fd.Size := _Size;
end;

end.

