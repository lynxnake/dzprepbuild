{.GXFormatter.config=twm}
///<summary> declares the IDatssetHelper unterface and the TDatasetHelper implementation
///          for typesafe access to database fields </summary>
unit u_dzDatasetHelpers;

interface

uses
  SysUtils,
  Classes,
  AdoDb,
  DB,
  DBTables,
  u_dzTranslator,
  u_dzGuidUtils,
  u_dzNameValueList;

type
  ///<summary> Interface definition for the Dataset-Helper, the idea is to have simplified
  ///          methods for reading field values, converting them to the appropriate data
  ///          type and generate standardized error messages if something goes wrong
  ///          that contain the table and field name rather than just saying
  ///          "Variant conversion error". </summary>
  IDatasetHelper = interface ['{756CC74A-1623-4FC4-A347-4CA3D90B4D69}']
    ///<summary> returns the field value as a string, raise an exception if it cannot be converted,
    ///          Note that strings are automatically trimmed. </summary>
    function FieldAsString(const _Fieldname: string): string; overload;
    ///<summary> returns the field value as a string, return the default if it cannot be converted
    ///          Note that strings are automatically trimmed. </summary>
    function FieldAsString(const _Fieldname, _Default: string): string; overload;
    function TryFieldAsString(const _Fieldname: string; out _Value: string): boolean;
    ///<summary> sets the field as a string, if the value is empty set it to NULL </summary>
    procedure SetFieldStringNotEmpty(const _Fieldname: string; const _Value: string);

    ///<summary> returns the field value as an integer, raise an exception if it cannot be converted </summary>
    function FieldAsInteger(const _Fieldname: string): integer; overload;
    ///<summary> returns the field value as an integer, return the default if it cannot be converted </summary>
    function FieldAsInteger(const _Fieldname: string; _Default: integer): integer; overload;
    ///<summary> returns the field value as an integer, raise an exception with the given error message if it cannot be converted </summary>
    function FieldAsInteger(const _Fieldname: string; const _Error: string): integer; overload;
    function TryFieldAsInteger(const _Fieldname: string; out _Value: integer): boolean;

    ///<summary> returns the field value as a double, raise an exception if it cannot be converted </summary>
    function FieldAsDouble(const _Fieldname: string): double; overload;
    ///<summary> returns the field value as a double, return the default if it cannot be converted </summary>
    function FieldAsDouble(const _Fieldname: string; const _Default: double): double; overload;
    ///<summary> returns the field value as a double, raise an exception with the given error message if it cannot be converted </summary>
    function FieldAsDouble(const _Fieldname: string; const _Error: string): double; overload;
    function TryFieldAsDouble(const _Fieldname: string; out _Value: double): boolean;

    ///<summary> returns the field value as an extended, raise an exception if it cannot be converted </summary>
    function FieldAsExtended(const _Fieldname: string): extended; overload;
    ///<summary> returns the field value as a extended, return the default if it cannot be converted </summary>
    function FieldAsExtended(const _Fieldname: string; const _Default: extended): extended; overload;
    ///<summary> returns the field value as a extended, raise an exception with the given error message if it cannot be converted </summary>
    function FieldAsExtended(const _Fieldname: string; const _Error: string): extended; overload;
    function TryFieldAsExtended(const _Fieldname: string; out _Value: extended): boolean;

    ///<summary> returns the field value as a TDateTime, raise an exception if it cannot be converted </summary>
    function FieldAsDate(const _Fieldname: string): TDateTime; overload;
    function FieldAsDate(const _Fieldname: string; _Default: TDateTime): TDateTime; overload;
    function TryFieldAsDate(const _Fieldname: string; out _Date: TDateTime): boolean;

    ///<summary> returns the field value as a boolean, raise an exception if it cannot be converted </summary>
    function FieldAsBoolean(const _FieldName: string): boolean; overload;
    ///<summary> returns the field value as a boolean, return the default if it cannot be converted </summary>
    function FieldAsBoolean(const _FieldName: string; _Default: boolean): boolean; overload;
    ///<summary> returns the field value as a TNullableGuid record, note that the guid might be
    ///          invalid if the field contained NULL </summary>
    function FieldAsGuid(const _FieldName: string): TNullableGuid;
    ///<summary> tries to convert the field to a GUID, returns false, if that's not possible </summary>
    function TryFieldAsGuid(const _Fieldname: string; out _Value: TNullableGuid): boolean;
    ///<summary> Opens the dataset </summary>
    procedure Open;
    ///<summary> Closes the dataset </summary>
    procedure Close;

    ///<summary> Moves to the first record of the dataset </summary>
    procedure First;
    ///<summary> Moves to the last record of the dataset </summary>
    procedure Last;
    ///<summary> Moves to the next record of the dataset, returns true if not EOF </summary>
    function Next: boolean;
    ///<summary> Moves to the previous record of the dataset, returns true if not BOF </summary>
    function Prior: boolean;
    ///<summary> Moves by Distance records (can be negative), returns the number of records actually moved </summary>
    function MoveBy(_Distance: integer): integer;
    ///<summary> Returns true if at the end of the dataset </summary>
    function Eof: boolean;
    ///<summary> Returns true if at the beginning of the dataset </summary>
    function Bof: boolean;

    ///<summary> insert a new record into the dataset </summary>
    procedure Insert;
    ///<summary> put the current record into edit mode </summary>
    procedure Edit;

    procedure Delete;

    ///<summary> post changes to the current record (must call Insert or Edit first) </summary>
    procedure Post;
    ///<summary> cancel changes to the current record (must call Insert or Edit first) </summary>
    procedure Cancel;

    function IsEmpty: boolean;
    function Locate(const _KeyFields: string; const _KeyValues: Variant; _Options: TLocateOptions): boolean;
    procedure SetParamByName(const _Param: string; _Value: variant);
    function TrySetParamByName(const _Param: string; _Value: variant): boolean;

    ///<summary> returns the field value as variant (getter method for FieldValues property) </summary>
    function GetFieldValue(const _FieldName: string): Variant;
    ///<summary> sets the field value as variant (setter method for FieldValues property) </summary>
    procedure SetFieldValue(const _FieldName: string; const _Value: Variant);
    ///<summary> sets the field value, if the filed exists
    ///          @param Fieldname is name of the field to set
    ///          @param Value is the new value
    ///          @returns true, if the field exists, false otherwise </summary>
    function TrySetFieldValue(const _FieldName: string; const _Value: Variant): boolean;
    procedure ClearField(const _Fieldname: string);

    function HasField(const _Fieldname: string): boolean;
    function Fields: TFields;

    ///<summary> Copies all values of the current record to the given NameValueList, ignoring
    ///          all fields that either contain NULL or are listed in Ignore.
    ///          @param NameValueList is a TdzNameValueList that returns the current record as name=value pairs
    ///          @param Ignore is an array of string with all field names that should not be copied
    ///</summary>
    procedure ToNameValueList(_Values: TNameValueList; const _Ignore: array of string);
    ///<summary> Copies all values from the given NameValueList to the current record
    ///          @param NameValueList is a TdzNameValueList that contains the values
    ///</summary>
    procedure FromNameValueList(_Values: TNameValueList);
    ///<summary> allows access to field values as variants </summary>
    property FieldValues[const _FieldName: string]: Variant read GetFieldValue write SetFieldValue; default;
  end;

type
  ///<summary> implements the IDatasetHelper interface </summary>
  TDatasetHelper = class(TInterfacedObject, IDatasetHelper)
  protected
    FDataset: TDataset;
    FTableName: string;
  public
    ///<summary> creates a TDatasetHelper for accessing a TQuery, TTable, TAdoTable or TAdoQuery </summary>
    constructor Create(_Table: TAdoTable); overload;
    constructor Create(_Table: TTable); overload;
    ///<summary> creates a TDatasetHelper for accessing a query
    ///          @param Query is the TAdoQuery to access
    ///          @param Tablename is the table name to use for automatically
    ///                           generated error messages </summary>
    constructor Create(_Query: TAdoQuery; const _Tablename: string); overload;
    constructor Create(_Query: TQuery; const _TableName: string); overload;
    constructor Create(_AdoDataset: TADODataSet; const _TableName: string); overload;
  public // implementation of IDatasetHelper, see there for a description
    function FieldAsString(const _Fieldname: string): string; overload;
    function FieldAsString(const _Fieldname, _Default: string): string; overload;
    function TryFieldAsString(const _Fieldname: string; out _Value: string): boolean;
    procedure SetFieldStringNotEmpty(const _Fieldname: string; const _Value: string);

    function FieldAsInteger(const _Fieldname: string): integer; overload;
    function FieldAsInteger(const _Fieldname: string; _Default: integer): integer; overload;
    function FieldAsInteger(const _Fieldname: string; const _Error: string): integer; overload;
    function TryFieldAsInteger(const _Fieldname: string; out _Value: integer): boolean;

    function FieldAsDouble(const _Fieldname: string): double; overload;
    function FieldAsDouble(const _Fieldname: string; const _Default: double): double; overload;
    function FieldAsDouble(const _Fieldname: string; const _Error: string): double; overload;
    function TryFieldAsDouble(const _Fieldname: string; out _Value: double): boolean;

    function FieldAsExtended(const _Fieldname: string): extended; overload;
    function FieldAsExtended(const _Fieldname: string; const _Default: extended): extended; overload;
    function FieldAsExtended(const _Fieldname: string; const _Error: string): extended; overload;
    function TryFieldAsExtended(const _Fieldname: string; out _Value: extended): boolean;

    function FieldAsDate(const _Fieldname: string): TDateTime; overload;
    function FieldAsDate(const _Fieldname: string; _Default: TDateTime): TDateTime; overload;
    function TryFieldAsDate(const _Fieldname: string; out _Date: TDateTime): boolean;

    function FieldAsBoolean(const _FieldName: string): boolean; overload;
    function FieldAsBoolean(const _FieldName: string; _Default: boolean): boolean; overload;

    function FieldAsGuid(const _FieldName: string): TNullableGuid;
    function TryFieldAsGuid(const _Fieldname: string; out _Value: TNullableGuid): boolean;

    procedure Open;
    procedure Close;

    procedure First;
    procedure Last;

    function Next: boolean;
    function Prior: boolean;
    function MoveBy(_Distance: integer): integer;

    function Eof: boolean;
    function Bof: boolean;

    procedure Insert;
    procedure Edit;

    procedure Delete;

    procedure Post;
    procedure Cancel;

    function IsEmpty: boolean;

    function Locate(const _KeyFields: string; const _KeyValues: Variant; _Options: TLocateOptions): boolean;
    procedure SetParamByName(const _Param: string; _Value: variant);
    function TrySetParamByName(const _Param: string; _Value: variant): boolean;

    function GetFieldValue(const _FieldName: string): Variant;
    procedure SetFieldValue(const _FieldName: string; const _Value: Variant);
    function TrySetFieldValue(const _FieldName: string; const _Value: Variant): boolean;
    procedure ClearField(const _Fieldname: string);
    function Fields: TFields;
    function HasField(const _Fieldname: string): boolean;
    procedure ToNameValueList(_Values: TNameValueList; const _Ignore: array of string);
    procedure FromNameValueList(_Values: TNameValueList);
    property FieldValues[const _FieldName: string]: Variant read GetFieldValue write SetFieldValue; default;
  end;

implementation

uses
  Variants,
  u_dzVariantUtils,
  u_dzMiscUtils;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

{ TDatasetHelper }

constructor TDatasetHelper.Create(_Table: TTable);
begin
  FDataset := _Table;
  FTableName := _Table.TableName;
end;

constructor TDatasetHelper.Create(_Query: TQuery; const _TableName: string);
begin
  FDataset := _Query;
  FTableName := _TableName;
end;

constructor TDatasetHelper.Create(_Table: TAdoTable);
begin
  inherited Create;
  FDataset := _Table;
  FTableName := _Table.TableName;
end;

constructor TDatasetHelper.Create(_Query: TAdoQuery; const _Tablename: string);
begin
  inherited Create;
  FDataset := _Query;
  FTableName := _Tablename;
end;

constructor TDatasetHelper.Create(_AdoDataset: TADODataSet; const _TableName: string);
begin
  FDataset := _AdoDataset;
  FTableName := _TableName;
end;

procedure TDatasetHelper.Delete;
begin
  FDataset.Delete;
end;

function TDatasetHelper.FieldAsDate(const _Fieldname: string): TDateTime;
begin
  Result := Var2DateTimeEx(FDataset[_Fieldname], FTableName + '.' + _Fieldname);
end;

function TDatasetHelper.FieldAsDate(const _Fieldname: string; _Default: TDateTime): TDateTime;
begin
  if not TryFieldAsDate(_Fieldname, Result) then
    Result := _Default;
end;

function TDatasetHelper.TryFieldAsDate(const _Fieldname: string; out _Date: TDateTime): boolean;
begin
  Result := not IsEmpty and TryVar2DateTime(FDataset[_Fieldname], _Date);
end;

function TDatasetHelper.TryFieldAsExtended(const _Fieldname: string; out _Value: extended): boolean;
begin
  Result := not IsEmpty and TryVar2Ext(FDataset[_Fieldname], _Value);
end;

function TDatasetHelper.TryFieldAsGuid(const _Fieldname: string; out _Value: TNullableGuid): boolean;
begin
  if IsEmpty then
    Result := false
  else begin
    _Value.AssignVariant(FDataset[_Fieldname]);
    Result := _Value.IsValid;
  end;
end;

function TDatasetHelper.TryFieldAsInteger(const _Fieldname: string; out _Value: integer): boolean;
begin
  Result := not IsEmpty and TryVar2Int(FDataset[_Fieldname], _Value);
end;

function TDatasetHelper.FieldAsDouble(const _Fieldname: string): double;
begin
  Result := Var2DblEx(FDataset[_Fieldname], FTableName + '.' + _Fieldname);
end;

function TDatasetHelper.FieldAsDouble(const _Fieldname, _Error: string): double;
begin
  Result := Var2DblEx(FDataset[_Fieldname], _Error);
end;

function TDatasetHelper.FieldAsExtended(const _Fieldname: string): extended;
begin
  Result := Var2ExtEx(FDataset[_Fieldname], FTableName + '.' + _Fieldname);
end;

function TDatasetHelper.FieldAsExtended(const _Fieldname: string; const _Default: extended): extended;
begin
  Result := Var2Ext(FDataset[_Fieldname], _Default);
end;

function TDatasetHelper.FieldAsExtended(const _Fieldname, _Error: string): extended;
begin
  Result := Var2ExtEx(FDataset[_Fieldname], _Error);
end;

function TDatasetHelper.FieldAsGuid(const _FieldName: string): TNullableGuid;
begin
  Result.AssignVariant(FDataset[_FieldName]);
end;

function TDatasetHelper.FieldAsInteger(const _Fieldname: string): integer;
begin
  Result := Var2IntEx(FDataset[_Fieldname], FTableName + '.' + _Fieldname);
end;

function TDatasetHelper.FieldAsInteger(const _Fieldname, _Error: string): integer;
begin
  Result := Var2IntEx(FDataset[_Fieldname], _Error);
end;

function TDatasetHelper.FieldAsString(const _Fieldname: string): string;
begin
  Result := Trim(Var2StrEx(FDataset[_Fieldname], FTableName + '.' + _Fieldname));
end;

function TDatasetHelper.TryFieldAsString(const _Fieldname: string; out _Value: string): boolean;
begin
  Result := not IsEmpty and TryVar2Str(FDataset[_Fieldname], _Value);
end;

function TDatasetHelper.FieldAsBoolean(const _FieldName: string): boolean;
begin
  Result := FieldAsInteger(_FieldName) <> 0;
end;

function TDatasetHelper.FieldAsDouble(const _Fieldname: string; const _Default: double): double;
begin
  if not TryFieldAsDouble(_Fieldname, Result) then
    Result := _Default;
end;

function TDatasetHelper.TryFieldAsDouble(const _Fieldname: string; out _Value: double): boolean;
begin
  Result := not IsEmpty and TryVar2Dbl(FDataset[_Fieldname], _Value);
end;

function TDatasetHelper.FieldAsInteger(const _Fieldname: string; _Default: integer): integer;
begin
  if not TryFieldAsInteger(_Fieldname, Result) then
    Result := _Default;
end;

function TDatasetHelper.FieldAsString(const _Fieldname, _Default: string): string;
begin
  Result := Trim(Var2Str(FDataset[_Fieldname], _Default));
end;

function TDatasetHelper.FieldAsBoolean(const _FieldName: string; _Default: boolean): boolean;
begin
  Result := FieldAsInteger(_FieldName, BoolToInt(_Default)) <> 0;
end;

procedure TDatasetHelper.SetFieldStringNotEmpty(const _Fieldname, _Value: string);
begin
  if _Value = '' then
    FDataset.Fields.FieldByName(_Fieldname).Clear
  else
    FDataset[_Fieldname] := _Value;
end;

procedure TDatasetHelper.ClearField(const _Fieldname: string);
begin
  FDataset.Fields.FieldByName(_Fieldname).Clear
end;

procedure TDatasetHelper.Close;
begin
  FDataset.Close;
end;

procedure TDatasetHelper.ToNameValueList(_Values: TNameValueList; const _Ignore: array of string);

  function IsIgnored(const _s: string): boolean;
  var
    s: string;
  begin
    Result := false;
    for s in _Ignore do begin
      if SameText(s, _s) then begin
        Result := true;
        exit;
      end;
    end;
  end;

var
  Field: TField;
  Fieldname: string;
  Value: string;
begin
  Assert(Assigned(_Values));

  for Field in Fields do begin
    Fieldname := Field.FieldName;
    if not IsIgnored(FieldName) then
      if TryFieldAsString(Fieldname, Value) then
        _Values.ByName[Fieldname] := Value;
  end;
end;

procedure TDatasetHelper.FromNameValueList(_Values: TNameValueList);
var
  i: integer;
begin
  for i := 0 to _Values.Count - 1 do
    FieldValues[_Values[i].Name] := _Values[i].Value;
end;

function TDatasetHelper.Eof: boolean;
begin
  Result := FDataset.Eof;
end;

function TDatasetHelper.Bof: boolean;
begin
  Result := FDataset.Bof;
end;

procedure TDatasetHelper.First;
begin
  FDataset.First;
end;

function TDatasetHelper.Next: boolean;
begin
  FDataset.Next;
  Result := not FDataset.Eof;
end;

function TDatasetHelper.Prior: boolean;
begin
  FDataset.Prior;
  Result := not FDataset.Bof;
end;

procedure TDatasetHelper.Open;
begin
  FDataset.Open;
end;

function TDatasetHelper.GetFieldValue(const _FieldName: string): Variant;
begin
  Result := FDataset[_FieldName];
end;

function TDatasetHelper.HasField(const _Fieldname: string): boolean;
begin
  Result := (FDataset.FindField(_Fieldname) <> nil);
end;

function TDatasetHelper.Fields: TFields;
begin
  Result := FDataset.Fields;
end;

procedure TDatasetHelper.SetFieldValue(const _FieldName: string; const _Value: Variant);
begin
  FDataset[_FieldName] := _Value;
end;

function TDatasetHelper.TrySetFieldValue(const _FieldName: string; const _Value: Variant): boolean;
var
  Field: TField;
begin
  Field := FDataset.FindField(_FieldName);
  Result := Assigned(Field);
  if Result then
    Field.Value := _Value;
end;

type
  THackAdoDataset = class(TCustomAdoDataset)
  end;

procedure TDatasetHelper.SetParamByName(const _Param: string; _Value: variant);
var
  i: Integer;
  Hack: THackAdoDataset;
  Query: TQuery;
begin
  // Do not use ParamByName -> only works if param is unique
  if FDataset is TCustomAdoDataset then begin
    Hack := THackAdoDataset(FDataset);
    for i := 0 to Hack.Parameters.Count - 1 do begin
      if SameText(Hack.Parameters[i].Name, _Param) then
        Hack.Parameters[i].Value := _Value;
    end;
  end else if FDataset is TQuery then begin
    Query := (FDataset as TQuery);
    for i := 0 to Query.Params.Count - 1 do
      if SameText(Query.Params[i].Name, _Param) then
        Query.Params[i].Value := _Value;
  end else
    raise Exception.CreateFmt(_('SetParamByName is not supported for a %s (only TQuery and TAdoDataset descendants).'), [FDataset.ClassName]);
end;

function TDatasetHelper.TrySetParamByName(const _Param: string; _Value: variant): boolean;
var
  AdoParam: TParameter;
  BdeParam: TParam;
begin
  if FDataset is TCustomAdoDataset then begin
    AdoParam := THackAdoDataset(FDataset).Parameters.FindParam(_Param);
    Result := Assigned(AdoParam);
    if Result then
      AdoParam.Value := _Value
  end else if FDataset is TQuery then begin
    BdeParam := (FDataset as TQuery).Params.FindParam(_Param);
    Result := Assigned(BdeParam);
    if Result then
      BdeParam.Value := _Value;
  end else
    raise Exception.CreateFmt(_('SetParamByName is not supported for a %s (only TQuery and TAdoDataset descendants).'), [FDataset.ClassName]);
end;

procedure TDatasetHelper.Cancel;
begin
  FDataset.Cancel;
end;

procedure TDatasetHelper.Edit;
begin
  FDataset.Edit;
end;

procedure TDatasetHelper.Insert;
begin
  FDataset.Insert;
end;

function TDatasetHelper.IsEmpty: boolean;
begin
  Result := FDataset.IsEmpty;
end;

procedure TDatasetHelper.Last;
begin
  FDataset.Last;
end;

function TDatasetHelper.Locate(const _KeyFields: string; const _KeyValues: Variant;
  _Options: TLocateOptions): boolean;
begin
  Result := FDataset.Locate(_KeyFields, _KeyValues, _Options);
end;

function TDatasetHelper.MoveBy(_Distance: integer): integer;
begin
  Result := FDataset.MoveBy(_Distance);
end;

procedure TDatasetHelper.Post;
begin
  FDataset.Post;
end;

end.

