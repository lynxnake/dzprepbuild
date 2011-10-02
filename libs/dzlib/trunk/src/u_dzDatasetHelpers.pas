{.GXFormatter.config=twm}
///<summary> declares the IDatssetHelper unterface and the TDatasetHelper implementation
///          for typesafe access to database fields </summary>
unit u_dzDatasetHelpers;

interface

uses
  SysUtils,
  Classes,
  DB,
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
    function TryFieldAsString(const _Fieldname: string; out _Value: string): Boolean;
    ///<summary> in addition to TryFieldAsString also checks whether the string is non-empty </summary>
    function TryFieldAsNonEmptyString(const _Fieldname: string; out _Value: string): Boolean;
    ///<summary> sets the field as a string, if the value is empty set it to NULL </summary>
    procedure SetFieldStringNotEmpty(const _Fieldname: string; const _Value: string);

    ///<summary> returns the field value as an integer, raise an exception if it cannot be converted </summary>
    function FieldAsInteger(const _Fieldname: string): Integer; overload;
    ///<summary> returns the field value as an integer, return the default if it cannot be converted </summary>
    function FieldAsInteger(const _Fieldname: string; _Default: Integer): Integer; overload;
    ///<summary> returns the field value as an integer, raise an exception with the given error message if it cannot be converted </summary>
    function FieldAsInteger(const _Fieldname: string; const _Error: string): Integer; overload;
    function TryFieldAsInteger(const _Fieldname: string; out _Value: Integer): Boolean;

    ///<summary> returns the field value as a double, raise an exception if it cannot be converted </summary>
    function FieldAsDouble(const _Fieldname: string): Double; overload;
    ///<summary> returns the field value as a double, return the default if it cannot be converted </summary>
    function FieldAsDouble(const _Fieldname: string; const _Default: Double): Double; overload;
    ///<summary> returns the field value as a double, raise an exception with the given error message if it cannot be converted </summary>
    function FieldAsDouble(const _Fieldname: string; const _Error: string): Double; overload;
    function TryFieldAsDouble(const _Fieldname: string; out _Value: Double): Boolean;

    ///<summary> returns the field value as an extended, raise an exception if it cannot be converted </summary>
    function FieldAsExtended(const _Fieldname: string): Extended; overload;
    ///<summary> returns the field value as a extended, return the default if it cannot be converted </summary>
    function FieldAsExtended(const _Fieldname: string; const _Default: Extended): Extended; overload;
    ///<summary> returns the field value as a extended, raise an exception with the given error message if it cannot be converted </summary>
    function FieldAsExtended(const _Fieldname: string; const _Error: string): Extended; overload;
    function TryFieldAsExtended(const _Fieldname: string; out _Value: Extended): Boolean;

    ///<summary> returns the field value as a TDateTime, raise an exception if it cannot be converted </summary>
    function FieldAsDate(const _Fieldname: string): TDateTime; overload;
    function FieldAsDate(const _Fieldname: string; _Default: TDateTime): TDateTime; overload;
    function TryFieldAsDate(const _Fieldname: string; out _Date: TDateTime): Boolean;

    ///<summary> returns the field value as a boolean, raise an exception if it cannot be converted </summary>
    function FieldAsBoolean(const _FieldName: string): Boolean; overload;
    ///<summary> returns the field value as a boolean, return the default if it cannot be converted </summary>
    function FieldAsBoolean(const _FieldName: string; _Default: Boolean): Boolean; overload;
    ///<summary> returns the field value as a TNullableGuid record, note that the guid might be
    ///          invalid if the field contained NULL </summary>
    function FieldAsGuid(const _FieldName: string): TNullableGuid;
    ///<summary> tries to convert the field to a GUID, returns false, if that's not possible </summary>
    function TryFieldAsGuid(const _Fieldname: string; out _Value: TNullableGuid): Boolean;
    ///<summary> Opens the dataset </summary>
    procedure Open;
    ///<summary> Closes the dataset </summary>
    procedure Close;

    ///<summary> Moves to the first record of the dataset </summary>
    procedure First;
    ///<summary> Moves to the last record of the dataset </summary>
    procedure Last;
    ///<summary> Moves to the next record of the dataset, returns true if not EOF </summary>
    function Next: Boolean;
    ///<summary> Moves to the previous record of the dataset, returns true if not BOF </summary>
    function Prior: Boolean;
    ///<summary> Moves by Distance records (can be negative), returns the number of records actually moved </summary>
    function MoveBy(_Distance: Integer): Integer;
    ///<summary> Returns true if at the end of the dataset </summary>
    function Eof: Boolean;
    ///<summary> Returns true if at the beginning of the dataset </summary>
    function Bof: Boolean;

    procedure Append;
    ///<summary> insert a new record into the dataset </summary>
    procedure Insert;
    ///<summary> put the current record into edit mode </summary>
    procedure Edit;

    procedure Delete;

    ///<summary> post changes to the current record (must call Insert or Edit first) </summary>
    procedure Post;
    ///<summary> cancel changes to the current record (must call Insert or Edit first) </summary>
    procedure Cancel;

    function IsEmpty: Boolean;

    procedure DisableControls;
    procedure EnableControls;

    function Locate(const _KeyFields: string; const _KeyValues: Variant; _Options: TLocateOptions): Boolean;
    procedure SetParamByName(const _Param: string; _Value: variant);
    function TrySetParamByName(const _Param: string; _Value: variant): Boolean;

    ///<summary> returns the field value as variant (getter method for FieldValues property) </summary>
    function GetFieldValue(const _FieldName: string): Variant;
    ///<summary> sets the field value as variant (setter method for FieldValues property) </summary>
    procedure SetFieldValue(const _FieldName: string; const _Value: Variant);
    ///<summary> sets the field value, if the filed exists
    ///          @param Fieldname is name of the field to set
    ///          @param Value is the new value
    ///          @returns true, if the field exists, false otherwise </summary>
    function TrySetFieldValue(const _FieldName: string; const _Value: Variant): Boolean;
    procedure ClearField(const _Fieldname: string);

    function GetActive: Boolean;
    procedure SetActive(const _Value: Boolean);

    function HasField(const _Fieldname: string): Boolean;
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
    property Active: Boolean read GetActive write SetActive;
  end;

type
  ///<summary> implements the IDatasetHelper interface
  ///          Note: You might want to instantiate a TDatasetHelperBDE,
  ///                TDatasetHelperADO or TDatasetHelperTDBF instead. </summary>
  TDatasetHelper = class(TInterfacedObject, IDatasetHelper)
  private
    function FieldByName(const _Fieldname: string): TField;
    function GetActive: Boolean;
    procedure SetActive(const _Value: Boolean);
  protected
    FDataset: TDataset;
    FTableName: string;
  protected // implementation of IDatasetHelper, see there for a description
    function FieldAsString(const _Fieldname: string): string; overload;
    function FieldAsString(const _Fieldname, _Default: string): string; overload;
    function TryFieldAsString(const _Fieldname: string; out _Value: string): Boolean;
    function TryFieldAsNonEmptyString(const _Fieldname: string; out _Value: string): Boolean;
    procedure SetFieldStringNotEmpty(const _Fieldname: string; const _Value: string);

    function FieldAsInteger(const _Fieldname: string): Integer; overload;
    function FieldAsInteger(const _Fieldname: string; _Default: Integer): Integer; overload;
    function FieldAsInteger(const _Fieldname: string; const _Error: string): Integer; overload;
    function TryFieldAsInteger(const _Fieldname: string; out _Value: Integer): Boolean;

    function FieldAsDouble(const _Fieldname: string): Double; overload;
    function FieldAsDouble(const _Fieldname: string; const _Default: Double): Double; overload;
    function FieldAsDouble(const _Fieldname: string; const _Error: string): Double; overload;
    function TryFieldAsDouble(const _Fieldname: string; out _Value: Double): Boolean;

    function FieldAsExtended(const _Fieldname: string): Extended; overload;
    function FieldAsExtended(const _Fieldname: string; const _Default: Extended): Extended; overload;
    function FieldAsExtended(const _Fieldname: string; const _Error: string): Extended; overload;
    function TryFieldAsExtended(const _Fieldname: string; out _Value: Extended): Boolean;

    function FieldAsDate(const _Fieldname: string): TDateTime; overload;
    function FieldAsDate(const _Fieldname: string; _Default: TDateTime): TDateTime; overload;
    function TryFieldAsDate(const _Fieldname: string; out _Date: TDateTime): Boolean;

    function FieldAsBoolean(const _FieldName: string): Boolean; overload;
    function FieldAsBoolean(const _FieldName: string; _Default: Boolean): Boolean; overload;

    function FieldAsGuid(const _FieldName: string): TNullableGuid;
    function TryFieldAsGuid(const _Fieldname: string; out _Value: TNullableGuid): Boolean;

    procedure Open;
    procedure Close;

    procedure First;
    procedure Last;

    function Next: Boolean;
    function Prior: Boolean;
    function MoveBy(_Distance: Integer): Integer;

    function Eof: Boolean;
    function Bof: Boolean;

    procedure Append;
    procedure Insert;
    procedure Edit;

    procedure Delete;

    procedure Post;
    procedure Cancel;

    function IsEmpty: Boolean;

    procedure DisableControls;
    procedure EnableControls;

    function Locate(const _KeyFields: string; const _KeyValues: Variant; _Options: TLocateOptions): Boolean;
    procedure SetParamByName(const _Param: string; _Value: variant); virtual;
    function TrySetParamByName(const _Param: string; _Value: variant): Boolean; virtual;

    function GetFieldValue(const _FieldName: string): Variant;
    procedure SetFieldValue(const _FieldName: string; const _Value: Variant);
    function TrySetFieldValue(const _FieldName: string; const _Value: Variant): Boolean;
    procedure ClearField(const _Fieldname: string);
    function Fields: TFields;
    function HasField(const _Fieldname: string): Boolean;
    procedure ToNameValueList(_Values: TNameValueList; const _Ignore: array of string);
    procedure FromNameValueList(_Values: TNameValueList);

    property Active: Boolean read GetActive write SetActive;
    property FieldValues[const _FieldName: string]: Variant read GetFieldValue write SetFieldValue; default;
  public
    constructor Create(_Dataset: TDataset; const _TableName: string);
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

constructor TDatasetHelper.Create(_Dataset: TDataset; const _TableName: string);
begin
  inherited Create;
  FDataset := _Dataset;
  FTableName := _TableName;
end;

procedure TDatasetHelper.Delete;
begin
  FDataset.Delete;
end;

function TDatasetHelper.FieldByName(const _Fieldname: string): TField;
begin
  Result := FDataset.FindField(_FieldName);
  if not Assigned(Result) then
    raise EDatabaseError.CreateFmt(_('Field "%s" not found in table "%s".'), [_Fieldname, FTablename]);
end;

function TDatasetHelper.FieldAsDate(const _Fieldname: string): TDateTime;
begin
  Result := Var2DateTimeEx(FieldByName(_FieldName).Value, FTableName + '.' + _Fieldname);
end;

function TDatasetHelper.FieldAsDate(const _Fieldname: string; _Default: TDateTime): TDateTime;
begin
  if not TryFieldAsDate(_Fieldname, Result) then
    Result := _Default;
end;

function TDatasetHelper.TryFieldAsDate(const _Fieldname: string; out _Date: TDateTime): Boolean;
begin
  Result := not IsEmpty and TryVar2DateTime(FieldByName(_FieldName).Value, _Date);
end;

function TDatasetHelper.TryFieldAsExtended(const _Fieldname: string; out _Value: Extended): Boolean;
begin
  Result := not IsEmpty and TryVar2Ext(FieldByName(_FieldName).Value, _Value);
end;

function TDatasetHelper.TryFieldAsGuid(const _Fieldname: string; out _Value: TNullableGuid): Boolean;
begin
  if IsEmpty then
    Result := False
  else begin
    _Value.AssignVariant(FieldByName(_FieldName).Value);
    Result := _Value.IsValid;
  end;
end;

function TDatasetHelper.TryFieldAsInteger(const _Fieldname: string; out _Value: Integer): Boolean;
begin
  Result := not IsEmpty and TryVar2Int(FieldByName(_FieldName).Value, _Value);
end;

function TDatasetHelper.FieldAsDouble(const _Fieldname: string): Double;
begin
  Result := Var2DblEx(FieldByName(_FieldName).Value, FTableName + '.' + _Fieldname);
end;

function TDatasetHelper.FieldAsDouble(const _Fieldname, _Error: string): Double;
begin
  Result := Var2DblEx(FieldByName(_FieldName).Value, _Error);
end;

function TDatasetHelper.FieldAsExtended(const _Fieldname: string): Extended;
begin
  Result := Var2ExtEx(FieldByName(_FieldName).Value, FTableName + '.' + _Fieldname);
end;

function TDatasetHelper.FieldAsExtended(const _Fieldname: string; const _Default: Extended): Extended;
begin
  Result := Var2Ext(FieldByName(_FieldName).Value, _Default);
end;

function TDatasetHelper.FieldAsExtended(const _Fieldname, _Error: string): Extended;
begin
  Result := Var2ExtEx(FieldByName(_FieldName).Value, _Error);
end;

function TDatasetHelper.FieldAsGuid(const _FieldName: string): TNullableGuid;
begin
  Result.AssignVariant(FieldByName(_FieldName).Value);
end;

function TDatasetHelper.FieldAsInteger(const _Fieldname: string): Integer;
begin
  Result := Var2IntEx(FieldByName(_FieldName).Value, FTableName + '.' + _Fieldname);
end;

function TDatasetHelper.FieldAsInteger(const _Fieldname, _Error: string): Integer;
begin
  Result := Var2IntEx(FieldByName(_FieldName).Value, _Error);
end;

function TDatasetHelper.FieldAsString(const _Fieldname: string): string;
begin
  Result := Trim(Var2StrEx(FieldByName(_FieldName).Value, FTableName + '.' + _Fieldname));
end;

function TDatasetHelper.TryFieldAsString(const _Fieldname: string; out _Value: string): Boolean;
begin
  Result := not IsEmpty and TryVar2Str(FieldByName(_FieldName).Value, _Value);
end;

function TDatasetHelper.TryFieldAsNonEmptyString(const _Fieldname: string; out _Value: string): Boolean;
begin
  Result := TryFieldAsString(_Fieldname, _Value) and (_Value <> '');
end;

function TDatasetHelper.FieldAsBoolean(const _FieldName: string): Boolean;
begin
  Result := FieldAsInteger(_FieldName) <> 0;
end;

function TDatasetHelper.FieldAsDouble(const _Fieldname: string; const _Default: Double): Double;
begin
  if not TryFieldAsDouble(_Fieldname, Result) then
    Result := _Default;
end;

function TDatasetHelper.TryFieldAsDouble(const _Fieldname: string; out _Value: Double): Boolean;
begin
  Result := not IsEmpty and TryVar2Dbl(FieldByName(_FieldName).Value, _Value);
end;

function TDatasetHelper.FieldAsInteger(const _Fieldname: string; _Default: Integer): Integer;
begin
  if not TryFieldAsInteger(_Fieldname, Result) then
    Result := _Default;
end;

function TDatasetHelper.FieldAsString(const _Fieldname, _Default: string): string;
begin
  Result := Trim(Var2Str(FieldByName(_FieldName).Value, _Default));
end;

function TDatasetHelper.FieldAsBoolean(const _FieldName: string; _Default: Boolean): Boolean;
begin
  Result := FieldAsInteger(_FieldName, BoolToInt(_Default)) <> 0;
end;

procedure TDatasetHelper.SetFieldStringNotEmpty(const _Fieldname, _Value: string);
begin
  if _Value = '' then
    FieldByName(_FieldName).Clear
  else
    FieldByName(_FieldName).Value := _Value;
end;

procedure TDatasetHelper.ClearField(const _Fieldname: string);
begin
  FieldByName(_FieldName).Clear;
end;

procedure TDatasetHelper.Close;
begin
  FDataset.Close;
end;

procedure TDatasetHelper.ToNameValueList(_Values: TNameValueList; const _Ignore: array of string);

  function IsIgnored(const _s: string): Boolean;
  var
    s: string;
  begin
    Result := False;
    for s in _Ignore do begin
      if SameText(s, _s) then begin
        Result := True;
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
  i: Integer;
begin
  for i := 0 to _Values.Count - 1 do
    FieldValues[_Values[i].Name] := _Values[i].Value;
end;

function TDatasetHelper.Eof: Boolean;
begin
  Result := FDataset.Eof;
end;

procedure TDatasetHelper.Append;
begin
  FDataset.Append;
end;

function TDatasetHelper.Bof: Boolean;
begin
  Result := FDataset.Bof;
end;

procedure TDatasetHelper.First;
begin
  FDataset.First;
end;

function TDatasetHelper.Next: Boolean;
begin
  FDataset.Next;
  Result := not FDataset.Eof;
end;

function TDatasetHelper.Prior: Boolean;
begin
  FDataset.Prior;
  Result := not FDataset.Bof;
end;

procedure TDatasetHelper.Open;
begin
  FDataset.Open;
end;

function TDatasetHelper.GetActive: Boolean;
begin
  Result := FDataset.Active;
end;

procedure TDatasetHelper.SetActive(const _Value: Boolean);
begin
  FDataset.Active := _Value;
end;

function TDatasetHelper.GetFieldValue(const _FieldName: string): Variant;
begin
  Result := FieldByName(_FieldName).Value;
end;

function TDatasetHelper.HasField(const _Fieldname: string): Boolean;
begin
  Result := (FDataset.FindField(_Fieldname) <> nil);
end;

function TDatasetHelper.Fields: TFields;
begin
  Result := FDataset.Fields;
end;

procedure TDatasetHelper.SetFieldValue(const _FieldName: string; const _Value: Variant);
begin
  FieldByName(_FieldName).Value := _Value;
end;

function TDatasetHelper.TrySetFieldValue(const _FieldName: string; const _Value: Variant): Boolean;
var
  Field: TField;
begin
  Field := FDataset.FindField(_FieldName);
  Result := Assigned(Field);
  if Result then
    Field.Value := _Value;
end;

procedure TDatasetHelper.SetParamByName(const _Param: string; _Value: variant);
begin
  raise Exception.CreateFmt(_('SetParamByName is not supported for a %s.'), [FDataset.ClassName]);
end;

function TDatasetHelper.TrySetParamByName(const _Param: string; _Value: variant): Boolean;
begin
  raise Exception.CreateFmt(_('TrySetParamByName is not supported for a %s.'), [FDataset.ClassName]);
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

function TDatasetHelper.IsEmpty: Boolean;
begin
  Result := FDataset.IsEmpty;
end;

procedure TDatasetHelper.EnableControls;
begin
  FDataset.EnableControls;
end;

procedure TDatasetHelper.DisableControls;
begin
  FDataset.DisableControls;
end;

procedure TDatasetHelper.Last;
begin
  FDataset.Last;
end;

function TDatasetHelper.Locate(const _KeyFields: string; const _KeyValues: Variant;
  _Options: TLocateOptions): Boolean;
begin
  Result := FDataset.Locate(_KeyFields, _KeyValues, _Options);
end;

function TDatasetHelper.MoveBy(_Distance: Integer): Integer;
begin
  Result := FDataset.MoveBy(_Distance);
end;

procedure TDatasetHelper.Post;
begin
  FDataset.Post;
end;

end.

