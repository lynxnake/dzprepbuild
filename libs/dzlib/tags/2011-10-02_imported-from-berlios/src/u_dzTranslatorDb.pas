{.GXFormatter.config=twm}
///<summary> Add this unit to ignore some database properties from translation </summary>
unit u_dzTranslatorDb;

interface

uses
  SysUtils,
  Classes;

implementation

uses
  DB,
  DBTables,
  DBCtrls,
  u_dzTranslator;

initialization

  // Ignore Database properties
  TP_GlobalIgnoreClassProperty(TField, 'DefaultExpression');
  TP_GlobalIgnoreClassProperty(TField, 'FieldName');
  TP_GlobalIgnoreClassProperty(TField, 'KeyFields');
  TP_GlobalIgnoreClassProperty(TField, 'DisplayName');
  TP_GlobalIgnoreClassProperty(TField, 'LookupKeyFields');
  TP_GlobalIgnoreClassProperty(TField, 'LookupResultField');
  TP_GlobalIgnoreClassProperty(TField, 'Origin');
  TP_TryGlobalIgnoreClass(TParam);

  // Database Controls
  TP_GlobalIgnoreClassProperty(TDBComboBox, 'DataField');
  TP_GlobalIgnoreClassProperty(TDBCheckBox, 'DataField');
  TP_GlobalIgnoreClassProperty(TDBEdit, 'DataField');
  TP_GlobalIgnoreClassProperty(TDBImage, 'DataField');
  TP_GlobalIgnoreClassProperty(TDBListBox, 'DataField');
  TP_GlobalIgnoreClassProperty(TDBLookupControl, 'DataField');
  TP_GlobalIgnoreClassProperty(TDBLookupControl, 'KeyField');
  TP_GlobalIgnoreClassProperty(TDBLookupControl, 'ListField');
  TP_GlobalIgnoreClassProperty(TDBMemo, 'DataField');
  TP_GlobalIgnoreClassProperty(TDBRadioGroup, 'DataField');
  TP_GlobalIgnoreClassProperty(TDBRichEdit, 'DataField');
  TP_GlobalIgnoreClassProperty(TDBText, 'DataField');

  // Borland Database Engine  (BDE)
  TP_TryGlobalIgnoreClass(TSession);
  TP_TryGlobalIgnoreClass(TDatabase);
end.

