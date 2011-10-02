unit u_dzDbCreatorDescription;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Variants,
  u_dzTranslator,
  u_dzVariableDescList;

type
  EdzDbDescription = class(Exception);
  EdzDbCyclicTableReferences = class(EdzDbDescription);
  EdzDbNoSuchColumn = class(EdzDbDescription);
  EdzDbIndexAlreadyExisting = class(EdzDbDescription);
  EdzDbScriptDoesNotExist = class(EdzDbDescription);
  EdzDbNoVariableWithThatName = class(EdzDbDescription);

type
  TIndexType = (itNoIndex, itPrimaryKey, itForeignKey, itUnique, itNotUnique);

  TNullAllowed = (naNotNull, naNull);
  TSortOrder = (soAscending, soDescending);
  TFieldDataType = (dtLongInt, dtDouble, dtText, dtMemo, dtDate, dtGUID);

const
  CHKSUM_FIELD = 'chksum';

function NullAllowedToYesNo(_NullAllowed: TNullAllowed): string;
function YesNoToNullAllowed(const _s: string): TNullAllowed;
function SortOrderToString(_SortOrder: TSortOrder): string;
function StringToSortOrder(const _s: string): TSortOrder;
function DataTypeToString(_DataType: TFieldDataType): string;
function StringToDataType(const _s: string): TFieldDataType;
function BoolToString(const _Bool: boolean): string;
function StringToBool(const _s: string): boolean;

type
  IdzDbTableRow = interface ['{29465039-37C5-4C73-8369-81CD27B382C0}']
    function GetCount: integer;
    property Count: integer read GetCount;

    function GetValue(_Idx: integer): string;
    procedure SetValue(_Idx: integer; const _Value: string);
    property Value[_Idx: integer]: string read GetValue write SetValue; default;
    function IsNull(_Idx: integer): boolean;
  end;

type
  IdzDbTableDescription = interface;

  IdzDbColumnDescription = interface ['{4315793D-F2E3-4583-AD15-6EBE2ADBDAD3}']
    function GetName: string;
    function GetDataType: TFieldDataType;
    function GetSize: integer;
    function GetComment: string;
    function GetAllowNull: TNullAllowed;

    function GetDefaultValue: Variant;
    procedure SetDefaultValue(const _DefaultValue: Variant);

    function GetAutoInc: boolean;
    procedure SetAutoInc(_AutoInc: boolean);

    function GetIsForeignKey: boolean;
    function GetForeignKeyColumn: IdzDbColumnDescription;
    function GetForeignKeyTable: IdzDbTableDescription;
    procedure SetForeignKey(const _ForeignKeyColumn: IdzDbColumnDescription;
      const _ForeignKeyTable: IdzDbTableDescription);

    procedure SetIndexType(_IndexType: TIndexType);
    function GetIsPrimaryKey: boolean;
    function GetIsUniqueIndex: boolean;

    function GetData: pointer;
    procedure SetData(_Data: pointer);

    function FormatData(_v: variant; out _s: string): boolean;
    function GetDefaultString(out _s: string): boolean;

    function GetStartIdx: integer;
    procedure AdjustStartIdx(_MaxIdx: integer);

    property Name: string read GetName;
    property DataType: TFieldDataType read GetDataType;
    property Size: integer read GetSize;
    property Comment: string read GetComment;
    property AllowNull: TNullAllowed read GetAllowNull;

    property DefaultValue: Variant read GetDefaultValue write SetDefaultValue;
    property AutoInc: boolean read GetAutoInc write SetAutoInc;
    property IsForeignKey: boolean read GetIsForeignKey;
    property ForeignKeyTable: IdzDbTableDescription read GetForeignKeyTable;
    property ForeignKeyColumn: IdzDbColumnDescription read GetForeignKeyColumn;
    property IsPrimaryKey: boolean read GetIsPrimaryKey;
    property IsUniqueIndex: boolean read GetIsUniqueIndex;
    property Data: pointer read GetData write SetData;
  end;

  TdzDbColumnDescription = class(TInterfacedObject, IdzDbColumnDescription)
  private
  protected
    // required fields for all data types
    FName: string;
    FDataType: TFieldDataType;

    // required depending on DataType
    FSize: integer;

    // optional fields with default values
    FAllowNull: TNullAllowed;
    FComment: string;
    FAutoInc: boolean;
    FDefaultValue: OleVariant;
    FForeignKeyTable: IdzDbTableDescription;
    FForeignKeyColumn: IdzDbColumnDescription;
    FSortOrder: TSortOrder;
    FData: pointer;
    FStartIdx: integer;
    FIsForeignKey: boolean;
    FIndexType: TIndexType;

    function GetName: string; virtual;
    function GetDataType: TFieldDataType; virtual;
    function GetSize: integer; virtual;
    function GetComment: string; virtual;
    function GetAllowNull: TNullAllowed; virtual;

    function GetDefaultValue: Variant; virtual;
    procedure SetDefaultValue(const _DefaultValue: Variant); virtual;

    function GetAutoInc: boolean; virtual;
    procedure SetAutoInc(_AutoInc: boolean); virtual;

    function GetIsPrimaryKey: boolean;
    function GetIsUniqueIndex: boolean;
    procedure SetIndexType(_IndexType: TIndexType);

    function GetIsForeignKey: boolean; virtual;
    function GetForeignKeyColumn: IdzDbColumnDescription; virtual;
    function GetForeignKeyTable: IdzDbTableDescription; virtual;
    procedure SetForeignKey(const _ForeignKeyColumn: IdzDbColumnDescription;
      const _ForeignKeyTable: IdzDbTableDescription); virtual;

    function GetData: pointer;
    procedure SetData(_Data: pointer);

    function GetStartIdx: integer;
    procedure AdjustStartIdx(_MaxIdx: integer);

    function FormatData(_v: variant; out _s: string): boolean;
    function GetDefaultString(out _s: string): boolean;
  public
    constructor Create(const _Name: string; _DataType: TFieldDataType;
      _Size: integer; const _Comment: string = '';
      _AllowNull: TNullAllowed = naNull);
  end;

  TdzColumnDescriptionClass = class of TdzDbColumnDescription;

  IdzDbIndexDescription = interface ['{4590F042-1F96-4A59-9CC6-249BEEC8A677}']
    function GetIsUniq: boolean;
    function GetIsPrimaryKey: boolean;
    function GetIsForeignKey: boolean;
    procedure SetRefTable(const _RefTable: string);
    function GetRefTable: string;
    function GetIndexType: TIndexType;
    function GetColumnCount: integer;
    function GetColumns(_Idx: integer): IdzDbColumnDescription;
    function GetColumnsSortorder(_Idx: integer): TSortOrder;
    procedure AlterColumnSortOrder(_ColumnName: string; _SortOrder: TSortOrder);
    procedure AppendColumn(_ColumnName: string; _SortOrder: TSortOrder = soAscending); overload;
    procedure AppendColumn(_Column: IdzDbColumnDescription; _SortOrder: TSortOrder = soAscending); overload;
    function GetName: string;
    procedure SetName(const _Name: string);

    property Name: string read GetName write SetName;
    property IsUniq: boolean read GetIsUniq;
    property IsPrimaryKey: boolean read GetIsPrimaryKey;
    property IsForeignKey: boolean read GetIsForeignKey;
    property RefTable: string read GetRefTable write SetRefTable;
    property ColumnCount: integer read GetColumnCount;
    property Column[_Idx: integer]: IdzDbColumnDescription read GetColumns; default;
    property ColumnSortorder[_Idx: integer]: TSortOrder read GetColumnsSortorder;
  end;

  TdzDbIndexDescription = class(TInterfacedObject, IdzDbIndexDescription)
  private
    FIsForeignKey, FIsPrimaryKey, FIsUniq: boolean;
    FColumns: TList;
    FTable: IdzDbTableDescription;
    FRefTable: string;
    FName: string;
  protected

    function GetName: string; virtual;
    procedure SetName(const _Name: string);
    function GetIsUniq: boolean; virtual;
    function GetIsPrimaryKey: boolean; virtual;
    function GetIsForeignKey: boolean; virtual;
    function GetIndexType: TIndexType; virtual;
    function GetColumnCount: integer; virtual;
    function GetColumnsSortorder(_Idx: integer): TSortOrder;
    procedure SetRefTable(const _RefTable: string);
    function GetRefTable: string;

    function GetColumns(_Idx: integer): IdzDbColumnDescription; virtual;
    procedure AppendColumn(_ColumnName: string; _SortOrder: TSortOrder = soAscending); overload;
    procedure AppendColumn(_Column: IdzDbColumnDescription; _SortOrder: TSortOrder = soAscending); overload;
    procedure AlterColumnSortOrder(_ColumnName: string; _SortOrder: TSortOrder); virtual;
  public
    constructor Create(const _Table: IdzDbTableDescription; const _Name: string;
      const _IsPrimaryKey, _IsUniq, _IsForeign: boolean); overload;
    constructor Create(const _Table: IdzDbTableDescription; const _Name: string;
      _IndexType: TIndexType); overload;
    destructor Destroy; override;
  end;

  IdzDbTableDescription = interface ['{7AD81B22-3CB6-47F4-86B4-CE0B526D6E29}']
    function GetName: string;
    function GetComment: string;
    function GetColumnDescClass: TdzColumnDescriptionClass;
    procedure SetColumnDescClass(_ColumnDescClass: TdzColumnDescriptionClass);
    function GetColumns(_Idx: integer): IdzDbColumnDescription;
    function GetIndices(_Idx: integer): IdzDbIndexDescription;
    function GetIndiceCount: integer;
    function GetColumnCount: integer;
    function GetPrimaryKey: IdzDbIndexDescription;
    function GetData: pointer;
    procedure SetData(const _Data: pointer);

    function AppendColumn(const _Name: string; _DataType: TFieldDataType;
      _Size: integer = 0; const _Comment: string = '';
      _AllowNull: TNullAllowed = naNull): IdzDbColumnDescription;

    ///<summary> deletes a column description but does not check for references,
    ///          USE WITH CARE!
    ///          @param(Idx is the index of the column to delete) </summary>
    procedure DeleteColumn(_Idx: integer);

    ///<summary> sorts the columns on the following criteria:
    ///          1. primary keys
    ///          2. foreign keys, sorted alphabetically
    ///          3. other columns, sorted alphabetically
    ///          4. the chksum column, if it exists </summary>
    procedure SortColumns;

    function AppendIndex(const _Name: string; const _IsPrimaryKey, _IsUniq, _IsForeign: boolean): IdzDbIndexDescription; overload;
    function AppendIndex(_IndexType: TIndexType): IdzDbIndexDescription; overload;
    function AppendIndex(const _Index: IdzDbIndexDescription): integer; overload;
    procedure DeleteIndex(_Idx: integer);
    function GenerateIndexName(_IndexType: TIndexType): string;

    function ColumnByName(const _Name: string): IdzDbColumnDescription;
    function IndexByName(const _Name: string): IdzDbIndexDescription;
    function ColumnIndex(const _Name: string): integer;

    function GetRowCount: integer;
    function AppendRow: IdzDbTableRow;
    function GetRows(_Idx: integer): IdzDbTableRow;

    property RowCount: integer read GetRowCount;
    property Rows[_Idx: integer]: IdzDbTableRow read GetRows;

    property Name: string read GetName;
    property Comment: string read GetComment;
    property ColumnDescClass: TdzColumnDescriptionClass read GetColumnDescClass write SetColumnDescClass;
    property Columns[_Idx: integer]: IdzDbColumnDescription read GetColumns;
    property Indices[_Idx: integer]: IdzDbIndexDescription read GetIndices;
    property ColumnCount: integer read GetColumnCount;
    property IndiceCount: integer read GetIndiceCount;
    property PrimaryKey: IdzDbIndexDescription read GetPrimaryKey;
    property Data: pointer read GetData write SetData;
  end;

type
  TdzDbTableDescription = class(TInterfacedObject, IdzDbTableDescription)
  private
    function CompareColumns(_Idx1, _Idx2: integer): integer;
    procedure SwapColumns(_Idx1, _Idx2: integer);
    function UniqueKeyCount: integer;
  protected
    FName: string;
    FComment: string;
    FColumns: TInterfaceList;
    FIndices: TInterfaceList;
    FColumnDescClass: TdzColumnDescriptionClass;
    FData: pointer;
    FRows: TInterfaceList;
    function AppendColumn(const _Name: string; _DataType: TFieldDataType;
      _Size: integer; const _Comment: string = '';
      _AllowNull: TNullAllowed = naNull): IdzDbColumnDescription;
    procedure DeleteColumn(_Idx: integer);
    ///<summary> sorts the columns on the following criteria:
    ///          1. primary keys
    ///          2. foreign keys, sorted alphabetically
    ///          3. other columns, sorted alphabetically
    ///          4. the chksum column, if it exists </summary>
    procedure SortColumns;

    function GetName: string; virtual;
    function GetComment: string; virtual;
    function GetColumnDescClass: TdzColumnDescriptionClass; virtual;
    procedure SetColumnDescClass(_ColumnDescClass: TdzColumnDescriptionClass); virtual;
    function GetColumns(_Idx: integer): IdzDbColumnDescription; virtual;
    function GetColumnCount: integer; virtual;
    function GetPrimaryKey: IdzDbIndexDescription; virtual;
    function GetData: pointer; virtual;
    procedure SetData(const _Data: pointer); virtual;
    function ColumnByName(const _Name: string): IdzDbColumnDescription;
    function IndexByName(const _Name: string): IdzDbIndexDescription;
    function ColumnIndex(const _Name: string): integer;
    function GetRowCount: integer;
    function AppendRow: IdzDbTableRow;
    function GetRows(_Idx: integer): IdzDbTableRow;
    function AppendIndex(const _Name: string;
      const _IsPrimaryKey, _IsUniq, _IsForeign: boolean): IdzDbIndexDescription; overload;
    function AppendIndex(_IndexType: TIndexType): IdzDbIndexDescription; overload;
    function AppendIndex(const _Index: IdzDbIndexDescription): integer; overload;
    procedure DeleteIndex(_Idx: integer);
    function GetIndiceCount: integer;
    function GetIndices(_Idx: integer): IdzDbIndexDescription;
    function HasPrimaryKey: boolean;
    function ForeignKeyCount: integer;
    function GenerateIndexName(_IndexType: TIndexType): string;
  public
    constructor Create(const _Name: string; const _Comment: string = '');
    destructor Destroy; override;
  end;

  TdzTableDescriptionClass = class of TdzDbTableDescription;

  //type
  //  IdzDbUserDescription = interface ['{89051F40-4CAC-4E42-B311-4247E2C60AC3}']
  //    function GetName: string;
  //    function GetPassword: string;
  //    property Name: string read GetName;
  //    property Password: string read GetPassword;
  //  end;
  //
  //type
  //  TdzDbUserDescription = class(TInterfacedObject, IdzDbUserDescription)
  //  protected
  //    fName: string;
  //    fPassword: string;
  //    function GetName: string; virtual;
  //    function GetPassword: string; virtual;
  //  public
  //    constructor Create(const _Name, _Password: string);
  //  end;
  //
  //type
  //  TdzDbUserDescriptionClass = class of TdzDbUserDescription;

type
  TdzDbVariableDescription = class(TInterfacedObject, IdzDbVariableDescription)
  private
    FName: string;
    FValue: string;
    FDeutsch: string;
    FEnglish: string;
    FTag: string;
    FValType: string;
    FEditable: boolean;
    FAdvanced: boolean;
  protected
    function GetName: string;
    function GetValue: string;
    procedure SetValue(const _Value: string);
    function GetEnglish: string;
    function GetDeutsch: string;
    function GetTag: string;
    function GetValType: string;
    function GetEditable: boolean;
    function GetAdvanced: boolean;
  public
    constructor Create(const _Name, _Value, _Deutsch, _English, _Tag, _ValType: string;
      const _Editable, _Advanced: boolean);
  end;

const
  SCRIPT_NAME_CREATETABLES = 'createtables';
  SCRIPT_NAME_DROPTABLES = 'droptables';
  SCRIPT_NAME_INSERTDATA = 'insertdata';

type
  IdzDbScriptDescription = interface ['{4DDB0C34-BE68-4399-AB2C-4004AF014516}']
    function GetName: string;
    procedure GetStatements(_Statements: TStringList);
    procedure AppendStatement(const _Statement: string);
    function GetEnglish: string;
    function GetDeutsch: string;
    function GetMandatory: boolean;
    function GetActive: boolean;
    procedure SetActive(_Active: boolean);

    property Active: boolean read GetActive write SetActive;
    property Mandatory: boolean read GetMandatory;
    property Deutsch: string read GetDeutsch;
    property English: string read GetEnglish;
    property Name: string read GetName;
  end;

type
  TdzDbScriptDescription = class(TInterfacedObject, IdzDbScriptDescription)
  private
    FName: string;
    FStatements: TStringList;
    FDeutsch: string;
    FEnglish: string;
    FActive: boolean;
    FMandatory: boolean;
  protected
    function GetName: string;
    procedure GetStatements(_Statements: TStringList);
    procedure AppendStatement(const _Statement: string);
    function GetEnglish: string;
    function GetDeutsch: string;
    function GetActive: boolean;
    procedure SetActive(_Active: boolean);
    function GetMandatory: boolean;
  public
    constructor Create(const _Name, _Deutsch, _English: string;
      const _Active, _Mandatory: boolean);
    destructor Destroy; override;
  end;

type
  IdzDbVariableDefaultDescription = interface ['{064A8E6E-0A86-483A-8309-FD8EB5E169E9}']
    function GetName: string;
    function GetValue: string;

    property Value: string read GetValue;
    property Name: string read GetName;
  end;

type
  TdzDbVariableDefaultDescription = class(TInterfacedObject, IdzDbVariableDefaultDescription)
  private
    FName: string;
    FValue: string;
  protected
    function GetName: string;
    function GetValue: string;
  public
    constructor Create(const _Name, _Value: string);
  end;

type
  IdzDbDefaultTypeDescription = interface ['{67B80A84-9E62-4ECD-A3F2-4371EC0F68E6}']
    function AppendVariableDefault(const _Name, _Value: string): IdzDbVariableDefaultDescription;
    function GetName: string;
    function GetVariableDefaults(_Idx: integer): IdzDbVariableDefaultDescription;
    function GetVariableDefaultsCount: integer;
    function VariableDefaultByName(_Name: string): IdzDbVariableDefaultDescription;
    function Clone: IdzDbDefaultTypeDescription;
    property VariableDefaults[_Idx: integer]: IdzDbVariableDefaultDescription read GetVariableDefaults;
    property VariableDefaultsCount: integer read GetVariableDefaultsCount;
    property Name: string read GetName;
  end;

type
  TdzDbDefaultTypeDescription = class(TInterfacedObject, IdzDbDefaultTypeDescription)
  private
    FName: string;
    FVariabeDefaults: TInterfaceList;
  protected
    function AppendVariableDefault(const _Name, _Value: string): IdzDbVariableDefaultDescription;
    function GetName: string;
    function VariableDefaultByName(_Name: string): IdzDbVariableDefaultDescription;
    function GetVariableDefaults(_Idx: integer): IdzDbVariableDefaultDescription;
    function GetVariableDefaultsCount: integer;
    function Clone: IdzDbDefaultTypeDescription;
  public
    constructor Create(const _Name: string);
    destructor Destroy; override;
  end;

type
  IdzDbVersionNTypeAncestor = interface ['{4EE70315-5D2A-43E0-AAE6-A7E4C1769178}']
    procedure ApplyDefault(_Default: IdzDbDefaultTypeDescription);

    function AppendDefault(_Name: string): IdzDbDefaultTypeDescription;
    function AppendVariable(const _Name, _Value, _Deutsch, _English, _Tag, _ValType: string;
      const _Editable, _Advanced: boolean): IdzDbVariableDescription;
    function AppendScript(const _Name, _Deutsch, _English: string;
      const _Active, _Mandatory: boolean): IdzDbScriptDescription;
    function PrependScript(const _Name, _Deutsch, _English: string;
      const _Active, _Mandatory: boolean): IdzDbScriptDescription;

    function DefaultByName(_Name: string): IdzDbDefaultTypeDescription;
    function VariableByName(_Name: string): IdzDbVariableDescription;
    function ScriptByName(_Name: string): IdzDbScriptDescription;

    function GetDefaults(_Idx: integer): IdzDbDefaultTypeDescription;
    function GetDefaultsCount: integer;

    function GetVariables(_Idx: integer): IdzDbVariableDescription;
    function GetVariablesCount: integer;

    function GetScripts(_Idx: integer): IdzDbScriptDescription;
    function GetScriptsCount: integer;

    function GetName: string;
    function GetEnglish: string;
    function GetDeutsch: string;
    function GetDbTypeName: string;
    function GetVersionName: string;

    property Variables[_Idx: integer]: IdzDbVariableDescription read GetVariables;
    property VariablesCount: integer read GetVariablesCount;

    property Scripts[_Idx: integer]: IdzDbScriptDescription read GetScripts;
    property ScriptsCount: integer read GetScriptsCount;

    property Defaults[_Idx: integer]: IdzDbDefaultTypeDescription read GetDefaults;
    property DefaultsCount: integer read GetDefaultsCount;

    property Name: string read GetName;
    property English: string read GetEnglish;
    property Deutsch: string read GetDeutsch;
    property DbTypeName: string read GetDbTypeName;
    property VersionName: string read GetVersionName;

  end;

type
  TdzDbVersionNTypeAncestor = class(TInterfacedObject, IdzDbVersionNTypeAncestor)
  private
    FDbTypeName: string;
    FEnglish: string;
    FDeutsch: string;
  protected
    FDefaultTypes: TInterfaceList;
    FVariables: TdzDbVariableDescriptionList;
    FScripts: TInterfaceList;

    procedure ApplyDefault(_Default: IdzDbDefaultTypeDescription);

    function AppendDefault(_Name: string): IdzDbDefaultTypeDescription;
    function AppendVariable(const _Name, _Value, _Deutsch, _English, _Tag, _ValType: string;
      const _Editable, _Advanced: boolean): IdzDbVariableDescription;
    function AppendScript(const _Name, _Deutsch, _English: string;
      const _Active, _Mandatory: boolean): IdzDbScriptDescription;

    function PrependScript(const _Name, _Deutsch, _English: string;
      const _Active, _Mandatory: boolean): IdzDbScriptDescription;

    function DefaultByName(_Name: string): IdzDbDefaultTypeDescription;
    function VariableByName(_Name: string): IdzDbVariableDescription;
    function ScriptByName(_Name: string): IdzDbScriptDescription;

    function GetDefaults(_Idx: integer): IdzDbDefaultTypeDescription;
    function GetDefaultsCount: integer;

    function GetVariables(_Idx: integer): IdzDbVariableDescription;
    function GetVariablesCount: integer;

    function GetScripts(_Idx: integer): IdzDbScriptDescription;
    function GetScriptsCount: integer;

    function GetName: string;
    function GetEnglish: string;
    function GetDeutsch: string;
    function GetDbTypeName: string; virtual;
    function GetVersionName: string; virtual;
  public
    constructor Create(const _DbTypeName, _English, _Deutsch: string);
    destructor Destroy; override;
  end;

type
  IdzDbVersionDescription = interface(IdzDbVersionNTypeAncestor)['{46DBD9D8-F384-453F-823F-755094C68146}']
  end;

type
  TdzDbVersionDescription = class(TdzDbVersionNTypeAncestor, IdzDbVersionDescription)
  private
    FVersionName: string;
  protected
    function GetVersionName: string; override;
    function AppendDefault(_Name: string): IdzDbDefaultTypeDescription;
    function AppendVariable(const _Name, _Value, _Deutsch, _English, _Tag, _ValType: string;
      const _Editable, _Advanced: boolean): IdzDbVariableDescription;
    function AppendScript(const _Name, _Deutsch, _English: string;
      const _IsDefault, _Mandatory: boolean): IdzDbScriptDescription;
  public
    constructor Create(const _VersionName, _English, _Deutsch: string; const _Parent: IdzDbVersionNTypeAncestor);
  end;

type
  IdzDbTypeDescription = interface(IdzDbVersionNTypeAncestor)['{70DE35FC-7550-4770-81D5-8D9DA957305A}']
    function AppendVersion(const _Name, _English, _Deutsch: string): IdzDbVersionDescription;
    function GetVersions(_Idx: integer): IdzDbVersionDescription;
    function GetVersionsCount: integer;

    property Versions[_Idx: integer]: IdzDbVersionDescription read GetVersions;
    property VersionsCount: integer read GetVersionsCount;
  end;

type
  TdzDbTypeDescription = class(TdzDbVersionNTypeAncestor, IdzDbTypeDescription)
  private
    FVersions: TInterfaceList;
  protected
    function AppendVersion(const _Name, _English, _Deutsch: string): IdzDbVersionDescription;
    function GetVersions(_Idx: integer): IdzDbVersionDescription;
    function GetVersionsCount: integer;
  public
    constructor Create(const _Name, _English, _Deutsch: string);
    destructor Destroy; override;
  end;

type
  IdzDbDescription = interface ['{D80C6BD0-A25E-4964-A431-AD8FED0B6C92}']
    function CreateTable(const _Name: string; const _Comment: string = ''): IdzDbTableDescription;
    function AppendTable(const _Name: string; const _Comment: string = ''): IdzDbTableDescription;
    function AppendDbType(const _Name, _English, _Deutsch: string): IdzDbTypeDescription;
    //    function AppendUser(const _Name, _Password: string): IdzDbUserDescription;
    function GetTables(_Idx: integer): IdzDbTableDescription;
    function GetTopologicalSortedTables(_Idx: integer): IdzDbTableDescription;
    function GetTableCount: integer;
    function GetUserCount: integer;
    //    function GetUsers(_Idx: integer): IdzDbUserDescription;
    function GetColumnDescClass: TdzColumnDescriptionClass;
    function GetName: string;
    procedure SetName(_Name: string);
    function GetPrefix: string;
    procedure SetPrefix(_Prefix: string);
    function GetTableDescClass: TdzTableDescriptionClass;
    //    function GetUserDescClass: TdzDbUserDescriptionClass;
    procedure SetColumnDescClass(const _ColumnDescClass: TdzColumnDescriptionClass);
    procedure SetTableDescClass(const _TableDescClass: TdzTableDescriptionClass);
    //    procedure SetUserDescClass(const _UserDescClass: TdzDbUserDescriptionClass);
    function GetSqlStatements: TStrings;
    function TableByName(const _Name: string): IdzDbTableDescription;
    function DbTypeByName(const _Name: string): IdzDbTypeDescription;
    procedure SetProgramm(const _Identifier, _Name: string);
    function GetProgName: string;
    function GetProgIdentifier: string;
    function GetDbTypes(_Idx: integer): IdzDbTypeDescription;
    function GetDbTypesCount: integer;

    function GetHasTables: boolean;
    function GetHasData: boolean;
    property Name: string read GetName write SetName;
    property Prefix: string read GetPrefix write SetPrefix;
    property Tables[_Idx: integer]: IdzDbTableDescription read GetTables;
    property TopologicalSortedTables[_Idx: integer]: IdzDbTableDescription read GetTopologicalSortedTables;
    property TableCount: integer read GetTableCount;
    //    property Users[_Idx: integer]: IdzDbUserDescription read GetUsers;
    property UserCount: integer read GetUserCount;
    property TableDescClass: TdzTableDescriptionClass read GetTableDescClass write SetTableDescClass;
    property ColumnDescClass: TdzColumnDescriptionClass read GetColumnDescClass write SetColumnDescClass;
    //    property UserDescClass: TdzDbUserDescriptionClass read GetUserDescClass write SetUserDescClass;
    property SqlStatements: TStrings read GetSqlStatements;
    property ProgName: string read GetProgName;
    property ProgIdentifier: string read GetProgIdentifier;
    property DbTypes[_Idx: integer]: IdzDbTypeDescription read GetDbTypes;
    property DbTypesCount: integer read GetDbTypesCount;
    property HasTables: boolean read GetHasTables;
    property HasData: boolean read GetHasData;
  end;

type
  TdzDbDescription = class(TInterfacedObject, IdzDbDescription)
  protected
    FPrefix: string;
    FName: string;
    FConfig: string;
    FTables: TInterfaceList;
    FDbTypes: TInterfaceList;
    FUsers: TInterfaceList;
    FProgName: string;
    FProgIdentifier: string;
    FTopologicalTableOrder: array of integer;

    FTableDescClass: TdzTableDescriptionClass;
    //    FUserDescClass: TdzDbUserDescriptionClass;
    FColumnDescClass: TdzColumnDescriptionClass;
    fSqlStatements: TStringList;

    function CreateTable(const _Name: string; const _Comment: string = ''): IdzDbTableDescription; virtual;
    function AppendTable(const _Name: string; const _Comment: string = ''): IdzDbTableDescription; virtual;
    //    function AppendUser(const _Name, _Password: string): IdzDbUserDescription; virtual;
    function AppendDbType(const _Name, _English, _Deutsch: string): IdzDbTypeDescription;
    function GetTables(_Idx: integer): IdzDbTableDescription; virtual;
    function GetTopologicalSortedTables(_Idx: integer): IdzDbTableDescription;
    function GetTableCount: integer; virtual;
    function GetUserCount: integer; virtual;
    //    function GetUsers(_Idx: integer): IdzDbUserDescription; virtual;
    function GetColumnDescClass: TdzColumnDescriptionClass; virtual;
    function GetName: string; virtual;
    procedure SetName(_Name: string);
    function GetPrefix: string; virtual;
    procedure SetPrefix(_Prefix: string);
    function GetTableDescClass: TdzTableDescriptionClass; virtual;
    //    function GetUserDescClass: TdzDbUserDescriptionClass; virtual;
    procedure SetColumnDescClass(const _ColumnDescClass: TdzColumnDescriptionClass); virtual;
    procedure SetTableDescClass(const _TableDescClass: TdzTableDescriptionClass); virtual;
    //    procedure SetUserDescClass(const _UserDescClass: TdzDbUserDescriptionClass); virtual;
    function GetSqlStatements: TStrings;
    function TableByName(const _Name: string): IdzDbTableDescription;
    function DbTypeByName(const _Name: string): IdzDbTypeDescription;
    procedure SetProgramm(const _Identifier, _Name: string);
    function GetProgName: string;
    function GetProgIdentifier: string;
    function GetDbTypes(_Idx: integer): IdzDbTypeDescription;
    function GetDbTypesCount: integer;
    function GetHasTables: boolean;
    function GetHasData: boolean;

  public
    constructor Create(const _Name, _Prefix: string);
    destructor Destroy; override;
  end;

implementation

uses
  u_dzVariantUtils,
  u_dzQuicksort,
  u_dzLogging;

type
  TdzDbColNSortorder = class
  public
    FColumn: IdzDbColumnDescription;
    FSortOrder: TSortOrder;
    constructor Create(const _Column: IdzDbColumnDescription; const _SortOrder: TSortOrder);
  end;

type
  TdzTableRow = class(TInterfacedObject, IdzDbTableRow)
  private
    FStrings: array of string;
    FNull: array of boolean;
  protected
    function GetCount: integer;
    function GetValue(_Idx: integer): string;
    procedure SetValue(_Idx: integer; const _Value: string);
    function IsNull(_Idx: integer): boolean;
    constructor Create(_ColCount: integer);
  end;

function NullAllowedToYesNo(_NullAllowed: TNullAllowed): string;
begin
  case _NullAllowed of
    naNotNull: Result := 'no';
    naNull: Result := 'yes';
  else
    raise EConvertError.Create(_('Invalid TNullAllowed value'));
  end;
end;

function YesNoToNullAllowed(const _s: string): TNullAllowed;
begin
  if AnsiSameText('yes', _s) then
    Result := naNull
  else if AnsiSameText('no', _s) then
    Result := naNotNull
  else
    raise EConvertError.CreateFmt(_('%s is not in ''yes''/''no'''), [_s]);
end;

function SortOrderToString(_SortOrder: TSortOrder): string;
begin
  case _SortOrder of
    soAscending: Result := 'Ascending';
    soDescending: Result := 'Descending';
  else
    raise EConvertError.Create(_('Invalid TSortOrder value'));
  end;
end;

function StringToSortOrder(const _s: string): TSortOrder;
begin
  if AnsiSameText('Ascending', _s) or (_s = '') then
    Result := soAscending
  else if AnsiSameText('Descending', _s) then
    Result := soDescending
  else
    raise EConvertError.CreateFmt(_('%s is not a valid TSortOrder name'), [_s]);
end;

function DataTypeToString(_DataType: TFieldDataType): string;
begin
  case _DataType of
    dtLongInt: Result := 'LongInt';
    dtDouble: Result := 'Double';
    dtText: Result := 'Text';
    dtMemo: Result := 'Memo';
    dtDate: Result := 'Date';
    dtGuid: Result := 'GUID';
  else
    raise EConvertError.Create(_('Invalid TFieldDataType value'));
  end;
end;

function StringToDataType(const _s: string): TFieldDataType;
begin
  if AnsiSameText(_s, 'LongInt') then
    Result := dtLongInt
  else if AnsiSameText(_s, 'Double') then
    Result := dtDouble
  else if AnsiSameText(_s, 'Text') then
    Result := dtText
  else if AnsiSameText(_s, 'Memo') then
    Result := dtMemo
  else if AnsiSameText(_s, 'Date') then
    Result := dtDate
  else if AnsiSameText(_s, 'GUID') then
    Result := dtGuid
  else
    raise EConvertError.CreateFmt(_('%s is not a valid TFieldDataType name'), [_s]);
end;

function BoolToString(const _Bool: boolean): string;
begin
  if _Bool then
    Result := 'true'
  else
    Result := 'false'
end;

function StringToBool(const _s: string): boolean;
begin
  if (_s = '0') or (_s = '') or AnsiSameText(_s, 'false') or AnsiSameText(_s, 'no') then
    Result := false
  else if (_s = '1') or AnsiSameText(_s, 'true') or AnsiSameText(_s, 'yes') then
    Result := true
  else
    raise EConvertError.Create(_('Invalid boolean value'));
end;

{ TdzDbColumnDescription }

constructor TdzDbColumnDescription.Create(const _Name: string;
  _DataType: TFieldDataType; _Size: integer; const _Comment: string;
  _AllowNull: TNullAllowed);
begin
  inherited Create;
  FName := _Name;
  FDataType := _DataType;
  FSize := _Size;
  FAllowNull := _AllowNull;
  FComment := _Comment;
  FAutoInc := false;
  FDefaultValue := NULL;
  FStartIdx := 1;
  FIsForeignKey := false;
end;

function TdzDbColumnDescription.GetAllowNull: TNullAllowed;
begin
  Result := FAllowNull;
end;

function TdzDbColumnDescription.GetAutoInc: boolean;
begin
  Result := FAutoInc;
end;

function TdzDbColumnDescription.GetComment: string;
begin
  Result := FComment;
end;

function TdzDbColumnDescription.GetDataType: TFieldDataType;
begin
  Result := FDataType;
end;

function TdzDbColumnDescription.GetDefaultValue: Variant;
begin
  Result := FDefaultValue;
end;

function TdzDbColumnDescription.GetForeignKeyTable: IdzDbTableDescription;
begin
  Result := FForeignKeyTable;
end;

procedure TdzDbColumnDescription.SetForeignKey(const _ForeignKeyColumn: IdzDbColumnDescription;
  const _ForeignKeyTable: IdzDbTableDescription);
begin
  Assert(Assigned(_ForeignKeyColumn), 'ForeignKeyColumn must not be NIL');
  Assert(Assigned(_ForeignKeyTable), 'ForeignKeyTable must not be NIL');

  FIsForeignKey := true;
  FForeignKeyTable := _ForeignKeyTable;
  FForeignKeyColumn := _ForeignKeyColumn;

  Assert(GetDataType = FForeignKeyColumn.DataType, _('Data type of foreign key and primary key of referenced table do not match'));
end;

function TdzDbColumnDescription.GetName: string;
begin
  Result := FName;
end;

function TdzDbColumnDescription.GetSize: integer;
begin
  Result := FSize;
end;

procedure TdzDbColumnDescription.SetAutoInc(_AutoInc: boolean);
begin
  FAutoInc := _AutoInc;
end;

procedure TdzDbColumnDescription.SetDefaultValue(const _DefaultValue: Variant);
begin
  if not VarIsNull(_DefaultValue) and not VarIsEmpty(_DefaultValue) then
    FDefaultValue := _DefaultValue
  else
    FDefaultValue := NULL;
end;

function TdzDbColumnDescription.GetData: pointer;
begin
  Result := FData;
end;

procedure TdzDbColumnDescription.SetData(_Data: pointer);
begin
  FData := _Data;
end;

function TdzDbColumnDescription.GetStartIdx: integer;
begin
  Result := FStartIdx;
end;

procedure TdzDbColumnDescription.AdjustStartIdx(_MaxIdx: integer);
begin
  if FStartIdx <= _MaxIdx then
    FStartIdx := _MaxIdx + 1;
end;

function TdzDbColumnDescription.FormatData(_v: variant; out _s: string): boolean;
begin
  Result := not VarIsNull(_v) or VarIsEmpty(_v);
  case FDataType of
    dtDate:
      _s := Var2DateTimeStr(_v);
    dtText:
      _s := Var2Str(_v, '');
    dtLongint:
      _s := Var2IntStr(_v);
    dtDouble:
      _s := Var2DblStr(_v, '');
  else
    { TODO -otwm -ccheck : Ob das bei Memos so funktioniert, ist mehr als zweifelhaft. }
    _s := Var2Str(_v, '');
  end;
end;

function TdzDbColumnDescription.GetDefaultString(out _s: string): boolean;
begin
  Result := FormatData(FDefaultValue, _s);
end;

function TdzDbColumnDescription.GetForeignKeyColumn: IdzDbColumnDescription;
begin
  Result := FForeignKeyColumn;
end;

function TdzDbColumnDescription.GetIsForeignKey: boolean;
begin
  Result := FIsForeignKey
end;

function TdzDbColumnDescription.GetIsPrimaryKey: boolean;
begin
  Result := (FIndexType = itPrimaryKey);
end;

function TdzDbColumnDescription.GetIsUniqueIndex: boolean;
begin
  Result := (FIndexType = itUnique);
end;

procedure TdzDbColumnDescription.SetIndexType(_IndexType: TIndexType);
begin
  case _IndexType of
    itPrimaryKey:
      FIndexType := _IndexType;
    itUnique:
      if FIndexType in [itNoIndex, itNotUnique] then
        FIndexType := _IndexType;
    itNotUnique:
      if FIndexType = itNoIndex then
        FIndexType := _IndexType;
  end;
end;

{ TdzDbTableDescription }

constructor TdzDbTableDescription.Create(const _Name, _Comment: string);
begin
  inherited Create;
  FName := _Name;
  FComment := _Comment;
  FColumns := TInterfaceList.Create;
  FIndices := TInterfaceList.Create;
  FColumnDescClass := TdzDbColumnDescription;
  FRows := TInterfaceList.Create;
end;

destructor TdzDbTableDescription.Destroy;
begin
  FRows.Free;
  FColumns.Free;
  FIndices.Free;
  inherited;
end;

function TdzDbTableDescription.AppendColumn(const _Name: string;
  _DataType: TFieldDataType; _Size: integer; const _Comment: string;
  _AllowNull: TNullAllowed): IdzDbColumnDescription;
begin
  Result := FColumnDescClass.Create(_Name, _DataType, _Size, _Comment, _AllowNull);
  FColumns.Add(Result);
end;

function TdzDbTableDescription.GetColumnDescClass: TdzColumnDescriptionClass;
begin
  Result := FColumnDescClass;
end;

function TdzDbTableDescription.GetComment: string;
begin
  Result := FComment;
end;

function TdzDbTableDescription.GetName: string;
begin
  Result := FName;
end;

procedure TdzDbTableDescription.SetColumnDescClass(_ColumnDescClass: TdzColumnDescriptionClass);
begin
  FColumnDescClass := _ColumnDescClass;
end;

function TdzDbTableDescription.GetColumnCount: integer;
begin
  Result := FColumns.Count;
end;

function TdzDbTableDescription.GetColumns(_Idx: integer): IdzDbColumnDescription;
begin
  Result := FColumns[_Idx] as IdzDbColumnDescription;
end;

function TdzDbTableDescription.ColumnByName(const _Name: string): IdzDbColumnDescription;
var
  i: integer;
begin
  for i := 0 to FColumns.Count - 1 do begin
    Result := FColumns[i] as IdzDbColumnDescription;
    if AnsiSameText(Result.Name, _Name) then
      exit;
  end;
  Result := nil;
end;

function TdzDbTableDescription.ColumnIndex(const _Name: string): integer;
var
  i: integer;
  Column: IdzDbColumnDescription;
begin
  for i := 0 to FColumns.Count - 1 do begin
    Column := FColumns[i] as IdzDbColumnDescription;
    if AnsiSameText(Column.Name, _Name) then begin
      Result := i;
      exit;
    end;
  end;
  Result := -1;
end;

procedure TdzDbTableDescription.DeleteColumn(_Idx: integer);
begin
  FColumns.Delete(_Idx);
end;

function TdzDbTableDescription.GetPrimaryKey: IdzDbIndexDescription;
var
  i: integer;
begin
  for i := 0 to GetIndiceCount - 1 do begin
    Result := GetIndices(i);
    if Result.IsPrimaryKey then
      exit;
  end;
  result := nil;
end;

function CompareBool(_Bool1, _Bool2: boolean): integer;
begin
  Result := 0;
  if _Bool1 then begin
    if not _Bool2 then
      Result := -1;
  end else if _Bool2 then
    Result := 1;
end;

function TdzDbTableDescription.CompareColumns(_Idx1, _Idx2: integer): integer;
var
  Col1, Col2: IdzDbColumnDescription;
begin
  Col1 := FColumns[_Idx1] as IdzDbColumnDescription;
  Col2 := FColumns[_Idx2] as IdzDbColumnDescription;

  Result := CompareBool(Col1.IsPrimaryKey, Col2.IsPrimaryKey);
  if Result <> 0 then
    exit;

  Result := CompareBool(Col1.IsForeignKey, Col2.IsForeignKey);
  if Result <> 0 then
    exit;

  Result := CompareBool(Col1.Name <> CHKSUM_FIELD, Col2.Name <> CHKSUM_FIELD);
  if Result <> 0 then
    exit;

  Result := AnsiCompareText(Col1.Name, Col2.Name);
end;

procedure TdzDbTableDescription.SwapColumns(_Idx1, _Idx2: integer);
begin
  FColumns.Exchange(_Idx1, _Idx2);
end;

procedure TdzDbTableDescription.SortColumns;
begin
  QuickSort(0, FColumns.Count - 1, self.CompareColumns, self.SwapColumns);
end;

function TdzDbTableDescription.GetData: pointer;
begin
  Result := FData;
end;

procedure TdzDbTableDescription.SetData(const _Data: pointer);
begin
  FData := _Data;
end;

function TdzDbTableDescription.AppendRow: IdzDbTableRow;
begin
  Result := TdzTableRow.Create(GetColumnCount);
  FRows.Add(Result);
end;

function TdzDbTableDescription.GetRows(_Idx: integer): IdzDbTableRow;
begin
  Result := FRows[_Idx] as IdzDbTableRow;
end;

function TdzDbTableDescription.GetRowCount: integer;
begin
  result := FRows.Count;
end;

procedure TdzDbTableDescription.DeleteIndex(_Idx: integer);
begin
  FIndices.Delete(_Idx);
end;

function TdzDbTableDescription.AppendIndex(
  const _Name: string; const _IsPrimaryKey, _IsUniq, _IsForeign: boolean): IdzDbIndexDescription;
begin
  if _IsPrimaryKey and HasPrimaryKey then
    raise EdzDbIndexAlreadyExisting.CreateFmt(
      _('Could not append index %s. Table %s already has a primary key.'),
      [_Name, FName]);

  if Assigned(IndexByName(_Name)) then
    raise EdzDbIndexAlreadyExisting.CreateFmt(
      _('Could not append index %s. Table %s already has a index with that name.'),
      [_Name, FName]);

  Result := TdzDbIndexDescription.Create(self, _Name, _IsPrimaryKey, _IsUniq, _IsForeign);
  FIndices.Add(Result);
end;

function TdzDbTableDescription.GenerateIndexName(_IndexType: TIndexType): string;
begin
  case _IndexType of
    itPrimaryKey:
      Result := Format('PK_%s_PRIMARY', [self.GetName]);
    itUnique:
      Result := Format('IX_%s_UNIQUE%d', [self.GetName, self.UniqueKeyCount]);
    itForeignKey:
      Result := Format('FK_%s_FOREIGN_%d', [self.GetName, self.ForeignKeyCount]);
  else
    Result := Format('IX_%s_%d', [self.GetName, Self.GetIndiceCount]);
  end;
end;

function TdzDbTableDescription.AppendIndex(_IndexType: TIndexType): IdzDbIndexDescription;
var
  IndexName: string;
begin
  IndexName := GenerateIndexName(_IndexType);
  Result := TdzDbIndexDescription.Create(self, IndexName, _IndexType);
  FIndices.Add(Result);
end;

function TdzDbTableDescription.AppendIndex(const _Index: IdzDbIndexDescription): integer;
begin
  Result := FIndices.Count;
  FIndices.Add(_Index);
end;

function TdzDbTableDescription.HasPrimaryKey: boolean;
var
  i: integer;
begin
  Result := false;

  for i := 0 to GetIndiceCount - 1 do
    if GetIndices(i).IsPrimaryKey then begin
      Result := true;
      break;
    end;
end;

function TdzDbTableDescription.ForeignKeyCount: integer;
var
  i: integer;
begin
  Result := 0;

  for i := 0 to GetIndiceCount - 1 do
    if GetIndices(i).IsForeignKey then
      Inc(Result);
end;

function TdzDbTableDescription.UniqueKeyCount: integer;
var
  i: integer;
begin
  Result := 0;

  for i := 0 to GetIndiceCount - 1 do
    if GetIndices(i).IsUniq then
      Inc(Result);
end;

function TdzDbTableDescription.GetIndices(_Idx: integer): IdzDbIndexDescription;
begin
  Result := FIndices[_Idx] as IdzDbIndexDescription;
end;

function TdzDbTableDescription.GetIndiceCount: integer;
begin
  Result := FIndices.Count;
end;

function TdzDbTableDescription.IndexByName(const _Name: string): IdzDbIndexDescription;
var
  i: integer;
begin
  for i := 0 to FIndices.Count - 1 do begin
    Result := GetIndices(i);
    if AnsiSameText(Result.Name, _Name) then
      exit;
  end;
  Result := nil;
end;

//{ TdzDbUserDescription }
//
//constructor TdzDbUserDescription.Create(const _Name, _Password: string);
//begin
//  inherited Create;
//  fName := _Name;
//  fPassword := _Password;
//end;
//
//function TdzDbUserDescription.GetName: string;
//begin
//  Result := fName;
//end;
//
//function TdzDbUserDescription.GetPassword: string;
//begin
//  Result := fPassword;
//end;

{ TdzDbDescription }

constructor TdzDbDescription.Create(const _Name, _Prefix: string);
begin
  inherited Create;
  FName := _Name;
  FPrefix := _Prefix;
  FTableDescClass := TdzDbTableDescription;
  //  fUserDescClass := TdzDbUserDescription;
  FColumnDescClass := TdzDbColumnDescription;

  fSqlStatements := TStringList.Create;
  FTables := TInterfaceList.Create;
  FUsers := TInterfaceList.Create;
  FDbTypes := TInterfaceList.Create;
end;

destructor TdzDbDescription.Destroy;
begin
  fSqlStatements.Free;
  FUsers.Free;
  FTables.Free;
  FDbTypes.Free;
  inherited;
end;

function TdzDbDescription.CreateTable(const _Name, _Comment: string): IdzDbTableDescription;
begin
  Result := TdzDbTableDescription.Create(_Name, _Comment);
  Result.ColumnDescClass := FColumnDescClass;
end;

function TdzDbDescription.AppendTable(const _Name, _Comment: string): IdzDbTableDescription;
begin
  Result := CreateTable(_Name, _Comment);
  FTables.Add(Result);
end;

function TdzDbDescription.GetTableCount: integer;
begin
  Result := FTables.Count;
end;

function TdzDbDescription.GetTables(_Idx: integer): IdzDbTableDescription;
begin
  Result := FTables[_Idx] as IdzDbTableDescription;
end;

function TdzDbDescription.TableByName(const _Name: string): IdzDbTableDescription;
var
  i: integer;
begin
  for i := 0 to FTables.Count - 1 do begin
    Result := FTables[i] as IdzDbTableDescription;
    if AnsiSameText(Result.Name, _Name) then
      exit;
  end;
  Result := nil;
end;

//function TdzDbDescription.AppendUser(const _Name, _Password: string): IdzDbUserDescription;
//begin
//  Result := fUserDescClass.Create(_Name, _Password);
//  fUsers.Add(Result);
//end;

function TdzDbDescription.GetUserCount: integer;
begin
  Result := FUsers.Count;
end;

//function TdzDbDescription.GetUsers(_Idx: integer): IezDbUserDescription;
//begin
//  Result := fUsers[_Idx] as IdzDbUserDescription;
//end;

function TdzDbDescription.GetColumnDescClass: TdzColumnDescriptionClass;
begin
  Result := FColumnDescClass;
end;

function TdzDbDescription.GetName: string;
begin
  Result := FName;
end;

procedure TdzDbDescription.SetName(_Name: string);
begin
  FName := _Name;
end;

function TdzDbDescription.GetPrefix: string;
begin
  Result := FPrefix;
end;

procedure TdzDbDescription.SetPrefix(_Prefix: string);
begin
  FPrefix := _Prefix;
end;

function TdzDbDescription.GetTableDescClass: TdzTableDescriptionClass;
begin
  Result := FTableDescClass;
end;

//function TdzDbDescription.GetUserDescClass: TdzDbUserDescriptionClass;
//begin
//  Result := fUserDescClass;
//end;

procedure TdzDbDescription.SetColumnDescClass(const _ColumnDescClass: TdzColumnDescriptionClass);
begin
  FColumnDescClass := _ColumnDescClass;
end;

procedure TdzDbDescription.SetTableDescClass(const _TableDescClass: TdzTableDescriptionClass);
begin
  FTableDescClass := _TableDescClass;
end;

//procedure TdzDbDescription.SetUserDescClass(const _UserDescClass: TdzDbUserDescriptionClass);
//begin
//  fUserDescClass := _UserDescClass;
//end;

function TdzDbDescription.GetSqlStatements: TStrings;
begin
  Result := fSqlStatements;
end;

procedure TdzDbDescription.SetProgramm(const _Identifier, _Name: string);
begin
  FProgIdentifier := _Identifier;
  FProgName := _Name;
end;

function TdzDbDescription.GetProgIdentifier: string;
begin
  Result := FProgIdentifier;
end;

function TdzDbDescription.GetProgName: string;
begin
  Result := FProgName;
end;

{ TTableRow }

constructor TdzTableRow.Create(_ColCount: integer);
var
  i: integer;
begin
  SetLength(FStrings, _ColCount);
  SetLength(FNull, _ColCount);
  for i := 0 to _ColCount - 1 do
    FNull[i] := true;
end;

function TdzTableRow.GetCount: integer;
begin
  Result := Length(FStrings);
end;

function TdzTableRow.GetValue(_Idx: integer): string;
begin
  if FNull[_Idx] then
    Result := ''
  else
    Result := FStrings[_Idx];
end;

function TdzTableRow.IsNull(_Idx: integer): boolean;
begin
  Result := FNull[_Idx];
end;

procedure TdzTableRow.SetValue(_Idx: integer; const _Value: string);
begin
  FStrings[_Idx] := _Value;
  FNull[_Idx] := false;
end;

function TdzDbDescription.GetTopologicalSortedTables(_Idx: integer): IdzDbTableDescription;

var
  TableCount: integer;
  Child, Parent, order, Idx: integer;
  Outdegree: array of integer;
  Pre: array of array of boolean;
  Table: IdzDbTableDescription;
  Index: IdzDbIndexDescription;
begin
  if 0 = _Idx then begin
    TableCount := GetTableCount;

    SetLength(FTopologicalTableOrder, TableCount);
    SetLength(Outdegree, TableCount);
    SetLength(Pre, TableCount);

    for Child := 0 to TableCount - 1 do begin
      FTopologicalTableOrder[Child] := Child;
      Outdegree[Child] := 0;
      SetLength(Pre[Child], TableCount);
      for Parent := 0 to TableCount - 1 do
        Pre[Child][Parent] := false;
    end;

      // We are interested in Child to Parent references.

    for Child := 0 to TableCount - 1 do begin
      Table := FTables[Child] as IdzDbTableDescription;
      for Idx := 0 to Table.IndiceCount - 1 do begin
        Index := Table.Indices[Idx];
        if Index.IsForeignKey then
          for Parent := 0 to TableCount - 1 do
            if (not Pre[Child][Parent]) and
              ((FTables[Parent] as IdzDbTableDescription).Name = Index.RefTable) then begin
              Inc(Outdegree[Child]);
              Pre[Child][Parent] := true;
              break;
            end;
      end;
    end;

      // Now the following is true:
      // Pre[Child][Parent]      iff  Parent is referenced by Child
      // Outdegree[Child]         =   The amount of parents the child references
    for order := 0 to Tablecount - 1 do begin
      Parent := -1;
      for Idx := 0 to TableCount - 1 do
        if 0 = Outdegree[Idx] then begin
          Parent := idx;
          break;
        end;

      if Parent = -1 then begin
        LogError('Cyclic table references detected');
        raise EdzDbCyclicTableReferences.Create(_('Cyclic table references detected'));
      end;

      for Child := 0 to Tablecount - 1 do
        if Pre[Child][Parent] then
          Dec(Outdegree[Child]);

      Outdegree[Parent] := -1;
      FTopologicalTableOrder[order] := Parent;
    end;

    LogDebug('Default Order:');
    for Idx := 0 to TableCount - 1 do
      LogDebug(Format('Idx %d, Name %s', [Idx, (FTables[Idx] as IdzDbTableDescription).Name]));

    LogDebug('Topological Order:');
    for Idx := 0 to TableCount - 1 do
      LogDebug(Format('TopologicalIdx %d, DefaultIdx %d, Name %s', [Idx, FTopologicalTableOrder[Idx], (FTables[FTopologicalTableOrder[Idx]] as IdzDbTableDescription).Name]));
  end;

  Result := FTables[FTopologicalTableOrder[_Idx]] as IdzDbTableDescription;
end;

function TdzDbDescription.GetDbTypes(_Idx: integer): IdzDbTypeDescription;
begin
  Result := FDbTypes[_Idx] as IdzDbTypeDescription;
end;

function TdzDbDescription.GetDbTypesCount: integer;
begin
  Result := FDbTypes.Count;
end;

function TdzDbDescription.AppendDbType(
  const _Name, _English, _Deutsch: string): IdzDbTypeDescription;
begin
  Result := TdzDbTypeDescription.Create(_Name, _English, _Deutsch);
  FDbTypes.Add(Result);
end;

function TdzDbDescription.DbTypeByName(
  const _Name: string): IdzDbTypeDescription;
var
  i: integer;
begin
  for i := 0 to FDbTypes.Count - 1 do begin
    Result := FDbTypes[i] as IdzDbTypeDescription;
    if AnsiSameText(Result.Name, _Name) then
      exit;
  end;
  Result := nil;
end;

function TdzDbDescription.GetHasData: boolean;
var
  i: integer;
begin
  result := false;

  for i := 0 to FTables.Count - 1 do
    if GetTables(i).RowCount > 0 then begin
      result := true;
      break;
    end;
end;

function TdzDbDescription.GetHasTables: boolean;
begin
  result := FTables.Count > 0;
end;

{ TdzDbIndexDescription }

procedure TdzDbIndexDescription.AlterColumnSortOrder(_ColumnName: string;
  _SortOrder: TSortOrder);
var
  ci: integer;
  wrap: TdzDbColNSortorder;
  found: boolean;
begin
  found := false;
  for ci := 0 to FColumns.Count - 1 do begin
    wrap := TdzDbColNSortorder(FColumns[ci]);
    if _ColumnName = wrap.FColumn.Name then begin
      wrap.FSortOrder := _SortOrder;
      found := true;
      break;
    end;
  end;
  if not found then
    raise EdzDbNoSuchColumn.CreateFmt(_('Table has no column with name "%s"'), [_ColumnName]);
end;

procedure TdzDbIndexDescription.AppendColumn(_ColumnName: string; _SortOrder: TSortOrder = soAscending);
var
  Column: IdzDbColumnDescription;
begin
  Column := FTable.ColumnByName(_ColumnName);
  if not Assigned(Column) then
    raise EdzDbNoSuchColumn.CreateFmt(_('Table has no column with name "%s"'), [_ColumnName]);
  FColumns.Add(TdzDbColNSortorder.Create(Column, _SortOrder));
end;

procedure TdzDbIndexDescription.AppendColumn(_Column: IdzDbColumnDescription; _SortOrder: TSortOrder);
begin
  Assert(Assigned(_Column), 'Column must not be NIL');


  // workaround
  // Wenn die Spalte einem Index hinzugefügt wird
  // der einen Primary Key beschreibt, dann muss
  // die Spalte ebenfalls als PrimaryKey markiert werden
  if self.FIsPrimaryKey then
    _Column.SetIndexType(itPrimaryKey)
  else if self.FIsForeignKey and (not _Column.IsPrimaryKey) then
    _Column.SetIndexType(itForeignKey)
  else if self.FIsUniq and (not _Column.IsPrimaryKey) and (not _Column.IsUniqueIndex) then
    _Column.SetIndexType(itUnique);

  FColumns.Add(TdzDbColNSortorder.Create(_Column, _SortOrder));
end;

constructor TdzDbIndexDescription.Create(const _Table: IdzDbTableDescription;
  const _Name: string; const _IsPrimaryKey, _IsUniq, _IsForeign: boolean);
begin
  inherited Create;
  FColumns := TList.Create;

  FTable := _Table;
  FName := _Name;

  FIsPrimaryKey := _IsPrimaryKey;
  FIsUniq := _IsUniq;
  FIsForeignKey := _IsForeign;
end;

constructor TdzDbIndexDescription.Create(const _Table: IdzDbTableDescription;
  const _Name: string; _IndexType: TIndexType);
begin
  Create(_Table, _Name, itPrimaryKey = _IndexType, itUnique = _IndexType, itForeignKey = _IndexType);
end;

destructor TdzDbIndexDescription.Destroy;
begin
  FColumns.Free;
  inherited;
end;

function TdzDbIndexDescription.GetColumnCount: integer;
begin
  Result := FColumns.Count;
end;

function TdzDbIndexDescription.GetColumns(_Idx: integer): IdzDbColumnDescription;
begin
  Result := (TdzDbColNSortorder(FColumns[_Idx])).FColumn;
end;

function TdzDbIndexDescription.GetColumnsSortorder(
  _Idx: integer): TSortOrder;
begin
  Result := (TdzDbColNSortorder(FColumns[_Idx])).FSortOrder;
end;

function TdzDbIndexDescription.GetIndexType: TIndexType;
begin
  if FIsPrimaryKey then
    Result := itPrimaryKey
  else if FIsForeignKey then
    Result := itForeignKey
  else if FIsUniq then
    Result := itUnique
  else
    Result := itNotUnique;
end;

function TdzDbIndexDescription.GetIsForeignKey: boolean;
begin
  Result := FIsForeignKey;
end;

function TdzDbIndexDescription.GetIsPrimaryKey: boolean;
begin
  Result := FIsPrimaryKey;
end;

function TdzDbIndexDescription.GetIsUniq: boolean;
begin
  Result := FIsUniq or FIsPrimaryKey;
end;

function TdzDbIndexDescription.GetName: string;
begin
  Result := FName;
end;

procedure TdzDbIndexDescription.SetName(const _Name: string);
begin
  FName := _Name;
end;

function TdzDbIndexDescription.GetRefTable: string;
begin
  Result := FRefTable;
end;

procedure TdzDbIndexDescription.SetRefTable(const _RefTable: string);
begin
  FRefTable := _RefTable;
end;

{ TdzDbColNSortorder }

constructor TdzDbColNSortorder.Create(const _Column: IdzDbColumnDescription;
  const _SortOrder: TSortOrder);
begin
  inherited Create;
  FColumn := _Column;
  FSortOrder := _SortOrder;
end;

{ TdzDbVersionNTypeAncestor }

function TdzDbVersionNTypeAncestor.AppendDefault(
  _Name: string): IdzDbDefaultTypeDescription;
begin
  Result := TdzDbDefaultTypeDescription.Create(_Name);
  FDefaultTypes.Add(Result);
end;

function TdzDbVersionNTypeAncestor.AppendScript(const _Name, _Deutsch,
  _English: string; const _Active, _Mandatory: boolean): IdzDbScriptDescription;
begin
  Result := TdzDbScriptDescription.Create(_Name, _Deutsch,
    _English, _Active, _Mandatory);
  FScripts.Add(Result);
end;

function TdzDbVersionNTypeAncestor.AppendVariable(
  const _Name, _Value, _Deutsch, _English, _Tag, _ValType: string;
  const _Editable, _Advanced: boolean): IdzDbVariableDescription;
begin
  Result := TdzDbVariableDescription.Create(_Name, _Value, _Deutsch, _English, _Tag,
    _ValType, _Editable, _Advanced);
  FVariables.Add(Result);
  GetDefaults(0).AppendVariableDefault(_Name, _Value);
end;

procedure TdzDbVersionNTypeAncestor.ApplyDefault(_Default: IdzDbDefaultTypeDescription);

  procedure RealApplyDefault(_Default: IdzDbDefaultTypeDescription);
  var
    i: integer;
    variable: IdzDbVariableDescription;
    vardefault: IdzDbVariableDefaultDescription;
  begin
    for i := 0 to _Default.VariableDefaultsCount - 1 do begin
      vardefault := _Default.VariableDefaults[i];
      Variable := VariableByName(vardefault.Name);
      if not assigned(Variable) then
        raise EdzDbNoVariableWithThatName.CreateFmt(
          _('Can not apply default %s, no variable with that name.'), [vardefault.Name]);
      variable.Value := vardefault.Value;
    end;
  end;
begin
  RealApplyDefault(GetDefaults(0));
  RealApplyDefault(_Default);
end;

constructor TdzDbVersionNTypeAncestor.Create(const _DbTypeName, _English, _Deutsch: string);
begin
  inherited Create;
  FDbTypeName := _DbTypeName;
  FEnglish := _English;
  FDeutsch := _Deutsch;

  FDefaultTypes := TInterfaceList.Create;
  FVariables := TdzDbVariableDescriptionList.Create;
  FScripts := TInterfaceList.Create;
  AppendDefault('');
end;

function TdzDbVersionNTypeAncestor.DefaultByName(
  _Name: string): IdzDbDefaultTypeDescription;
var
  i: integer;
begin
  for i := 0 to FDefaultTypes.Count - 1 do begin
    Result := FDefaultTypes[i] as IdzDbDefaultTypeDescription;
    if AnsiSameText(Result.Name, _Name) then
      exit;
  end;
  Result := nil;
end;

destructor TdzDbVersionNTypeAncestor.Destroy;
begin
  FDefaultTypes.Free;
  FVariables.Free;
  inherited;
end;

function TdzDbVersionNTypeAncestor.GetDbTypeName: string;
begin
  Result := FDbTypeName;
end;

function TdzDbVersionNTypeAncestor.GetDefaults(
  _Idx: integer): IdzDbDefaultTypeDescription;
begin
  Result := FDefaultTypes[_Idx] as IdzDbDefaultTypeDescription;
end;

function TdzDbVersionNTypeAncestor.GetDefaultsCount: integer;
begin
  Result := FDefaultTypes.Count;
end;

function TdzDbVersionNTypeAncestor.GetDeutsch: string;
begin
  result := FDeutsch;
end;

function TdzDbVersionNTypeAncestor.GetEnglish: string;
begin
  result := FEnglish;
end;

function TdzDbVersionNTypeAncestor.GetName: string;
begin
  if '' = GetVersionName then
    Result := GetDbTypeName
  else
    Result := Format('%s %s', [GetDbTypeName, GetVersionName]);
end;

function TdzDbVersionNTypeAncestor.GetScripts(
  _Idx: integer): IdzDbScriptDescription;
begin
  Result := FScripts[_Idx] as IdzDbScriptDescription;
end;

function TdzDbVersionNTypeAncestor.GetScriptsCount: integer;
begin
  Result := FScripts.Count;
end;

function TdzDbVersionNTypeAncestor.GetVariables(
  _Idx: integer): IdzDbVariableDescription;
begin
  Result := FVariables[_Idx] as IdzDbVariableDescription;
end;

function TdzDbVersionNTypeAncestor.GetVariablesCount: integer;
begin
  Result := FVariables.Count;
end;

{ TdzDbDefaultTypeDescription }

function TdzDbVersionNTypeAncestor.GetVersionName: string;
begin
  Result := '';
end;

function TdzDbVersionNTypeAncestor.PrependScript(const _Name, _Deutsch,
  _English: string; const _Active,
  _Mandatory: boolean): IdzDbScriptDescription;
begin
  Result := TdzDbScriptDescription.Create(_Name, _Deutsch,
    _English, _Active, _Mandatory);
  FScripts.Insert(0, Result);
end;

function TdzDbVersionNTypeAncestor.ScriptByName(
  _Name: string): IdzDbScriptDescription;
var
  i: integer;
begin
  for i := 0 to FScripts.Count - 1 do begin
    Result := FScripts[i] as IdzDbScriptDescription;
    if AnsiSameText(Result.Name, _Name) then
      exit;
  end;
  Result := nil;
end;

function TdzDbVersionNTypeAncestor.VariableByName(_Name: string): IdzDbVariableDescription;
var
  idx: integer;
begin
  if FVariables.Find(_Name, idx) then
    Result := FVariables[idx]
  else
    Result := nil;
end;

{ TdzDbVariableDescription }

constructor TdzDbVariableDescription.Create(const _Name, _Value, _Deutsch,
  _English, _Tag, _ValType: string;
  const _Editable, _Advanced: boolean);
begin
  inherited Create;
  FName := _Name;
  FValue := _Value;
  FDeutsch := _Deutsch;
  FEnglish := _English;
  FTag := _Tag;
  FValType := _ValType;
  FEditable := _Editable;
  FAdvanced := _Advanced;
end;

function TdzDbVariableDescription.GetAdvanced: boolean;
begin
  Result := FAdvanced;
end;

function TdzDbVariableDescription.GetValType: string;
begin
  Result := FValType;
end;

function TdzDbVariableDescription.GetDeutsch: string;
begin
  Result := FDeutsch;
end;

function TdzDbVariableDescription.GetEditable: boolean;
begin
  Result := FEditable;
end;

function TdzDbVariableDescription.GetEnglish: string;
begin
  Result := FEnglish;
end;

function TdzDbVariableDescription.GetName: string;
begin
  Result := FName;
end;

function TdzDbVariableDescription.GetTag: string;
begin
  Result := FTag;
end;

function TdzDbVariableDescription.GetValue: string;
begin
  Result := FValue;
end;

procedure TdzDbVariableDescription.SetValue(const _Value: string);
begin
  FValue := _Value;
end;

{ TdzDbDefaultTypeDescription }

function TdzDbDefaultTypeDescription.AppendVariableDefault(const _Name,
  _Value: string): IdzDbVariableDefaultDescription;
begin
  Result := VariableDefaultByName(_Name);
  if assigned(Result) then
    FVariabeDefaults.Remove(Result);

  Result := TdzDbVariableDefaultDescription.Create(_Name, _Value);
  FVariabeDefaults.Add(Result);
end;

function TdzDbDefaultTypeDescription.Clone: IdzDbDefaultTypeDescription;
var
  clone: TdzDbDefaultTypeDescription;
  i: integer;
begin
  Clone := TdzDbDefaultTypeDescription.Create(FName);

  for i := 0 to GetVariableDefaultsCount - 1 do
    Clone.fVariabeDefaults.Add(GetVariableDefaults(i));

  Result := Clone;
end;

constructor TdzDbDefaultTypeDescription.Create(const _Name: string);
begin
  inherited Create;
  FName := _Name;
  FVariabeDefaults := TInterfaceList.Create;
end;

destructor TdzDbDefaultTypeDescription.Destroy;
begin
  FVariabeDefaults.Free;
  inherited;
end;

function TdzDbDefaultTypeDescription.GetName: string;
begin
  Result := FName;
end;

function TdzDbDefaultTypeDescription.GetVariableDefaults(
  _Idx: integer): IdzDbVariableDefaultDescription;
begin
  Result := FVariabeDefaults[_Idx] as IdzDbVariableDefaultDescription;
end;

function TdzDbDefaultTypeDescription.GetVariableDefaultsCount: integer;
begin
  Result := FVariabeDefaults.Count;
end;

function TdzDbDefaultTypeDescription.VariableDefaultByName(
  _Name: string): IdzDbVariableDefaultDescription;
var
  i: integer;
begin
  for i := 0 to FVariabeDefaults.Count - 1 do begin
    Result := FVariabeDefaults[i] as IdzDbVariableDefaultDescription;
    if AnsiSameText(Result.Name, _Name) then
      exit;
  end;
  Result := nil;
end;

{ TdzDbVariableDefaultDescription }

constructor TdzDbVariableDefaultDescription.Create(const _Name, _Value: string);
begin
  inherited Create;
  FName := _Name;
  FValue := _Value;
end;

function TdzDbVariableDefaultDescription.GetName: string;
begin
  Result := FName;
end;

function TdzDbVariableDefaultDescription.GetValue: string;
begin
  Result := FValue;
end;

{ TdzDbScriptDescription }

constructor TdzDbScriptDescription.Create(const _Name, _Deutsch,
  _English: string; const _Active, _Mandatory: boolean);
begin
  inherited Create;
  FName := _Name;
  FDeutsch := _Deutsch;
  FEnglish := _English;
  FMandatory := _Mandatory;
  FActive := _Active or _Mandatory;
  FStatements := TStringList.Create;
end;

function TdzDbScriptDescription.GetDeutsch: string;
begin
  Result := FDeutsch;
end;

function TdzDbScriptDescription.GetEnglish: string;
begin
  Result := FEnglish;
end;

function TdzDbScriptDescription.GetActive: boolean;
begin
  Result := FActive;
end;

function TdzDbScriptDescription.GetMandatory: boolean;
begin
  Result := FMandatory;
end;

function TdzDbScriptDescription.GetName: string;
begin
  Result := FName;
end;

procedure TdzDbScriptDescription.SetActive(_Active: boolean);
begin
  FActive := _Active;
end;

procedure TdzDbScriptDescription.GetStatements(_Statements: TStringList);
begin
  _Statements.AddStrings(FStatements);
end;

destructor TdzDbScriptDescription.Destroy;
begin
  FStatements.Free;
  inherited;
end;

procedure TdzDbScriptDescription.AppendStatement(const _Statement: string);
begin
  FStatements.Append(_Statement);
end;

{ TdzDbTypeDescription }

function TdzDbTypeDescription.AppendVersion(
  const _Name, _English, _Deutsch: string): IdzDbVersionDescription;
begin
  Result := TdzDbVersionDescription.Create(_Name, _English, _Deutsch, self);
  FVersions.Add(Result);
end;

constructor TdzDbTypeDescription.Create(const _Name, _English, _Deutsch: string);
begin
  inherited;
  FVersions := TInterfaceList.Create;
end;

destructor TdzDbTypeDescription.Destroy;
begin
  FVersions.Free;
  inherited;
end;

function TdzDbTypeDescription.GetVersions(
  _Idx: integer): IdzDbVersionDescription;
begin
  Result := FVersions[_Idx] as IdzDbVersionDescription;
end;

function TdzDbTypeDescription.GetVersionsCount: integer;
begin
  Result := FVersions.Count;
end;

{ TdzDbVersionDescription }

function TdzDbVersionDescription.AppendDefault(
  _Name: string): IdzDbDefaultTypeDescription;
begin
  Result := DefaultByName(_Name);
  if not assigned(Result) then
    Result := inherited AppendDefault(_Name);
end;

function TdzDbVersionDescription.AppendScript(const _Name, _Deutsch, _English:
  string; const _IsDefault,
  _Mandatory: boolean): IdzDbScriptDescription;
var
  oldIdx, newIdx: integer;
  old: IdzDbScriptDescription;
begin

  old := ScriptByName(_Name);

  if not assigned(old) then
    raise EdzDbScriptDoesNotExist.CreateFmt(_('There is no script named %s in this db type'), [_Name]);
  ;

  oldIdx := FScripts.IndexOf(old);

  Result := TdzDbScriptDescription.Create(_Name, _Deutsch, _English, _IsDefault, _Mandatory);

  newIdx := FScripts.Add(Result);
  FScripts.Exchange(oldIdx, newIdx);

  FScripts.Remove(old);
end;

function TdzDbVersionDescription.AppendVariable(const _Name, _Value,
  _Deutsch, _English, _Tag, _ValType: string; const _Editable,
  _Advanced: boolean): IdzDbVariableDescription;
begin
  Result := VariableByName(_Name);
  if assigned(Result) then
    FVariables.Extract(FVariables.IndexOf(Result));

  Result := inherited AppendVariable(_Name, _Value, _Deutsch, _English, _Tag,
    _ValType, _Editable, _Advanced);
end;

constructor TdzDbVersionDescription.Create(const _VersionName, _English, _Deutsch: string;
  const _Parent: IdzDbVersionNTypeAncestor);
var
  i: integer;
begin
  inherited Create(_Parent.Name, _English, _Deutsch);
  FVersionName := _VersionName;

  FDefaultTypes.Clear;
  for i := 0 to _Parent.DefaultsCount - 1 do
    FDefaultTypes.Add(_Parent.Defaults[i].Clone);

  for i := 0 to _Parent.VariablesCount - 1 do
    FVariables.Add(_Parent.Variables[i]);

  for i := 0 to _Parent.ScriptsCount - 1 do
    FScripts.Add(_Parent.Scripts[i]);
end;

function TdzDbVersionDescription.GetVersionName: string;
begin
  Result := FVersionName;
end;

end.

