{.GXFormatter.config=twm}
///<summary> Implements functions which work on components but are not methods.
///          @author        twm </summary>
unit u_dzVclUtils;

{$INCLUDE jedi.inc}

interface

uses
  Classes,
  Windows,
  SysUtils,
  Graphics,
  Forms,
  Messages,
  Controls,
  ComCtrls,
  ExtCtrls,
  CheckLst,
  StdCtrls,
  Grids,
  DbGrids,
  Buttons,
  ActnList,
  u_dzTranslator;

type
  ///<summary> Ancestor to all exceptions raised in this unit. </summary>
  EdzVclUtils = class(Exception);

  ///<summary> raised if the Combobox passed to SetOwnerDrawComboItemCount is not owner drawn. </summary>
  EdzComboBoxNotOwnerDraw = class(EdzVclUtils);

  ///<summary> raised if the Listbox passed to SetOwnerDrawListboxItemCount is not owner drawn. </summary>
  EdzListBoxNotOwnerDraw = class(EdzVclUtils);

  EdzComboBoxNoSelection = class(EdzVclUtils);
  EdzListBoxNoSelection = class(EdzVclUtils);

type
  ///<summary> This is a copy of the TFileFormatsList class from Graphics which
  ///          is unfortunately only declaread in the implementation section </summary>
  TFileFormatsList = class(TList)
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Ext, Desc: string; DescID: Integer; AClass: TGraphicClass);
    function FindExt(Ext: string): TGraphicClass;
    function FindClassName(const Classname: string): TGraphicClass;
    procedure Remove(AClass: TGraphicClass);
    ///<summary> returns a file select filter string for all descendants of the given TGraphicClass </summary>
    procedure BuildFilterStrings(GraphicClass: TGraphicClass; var Descriptions, Filters: string);
    function GetFilterString(GraphicClass: TGraphicClass = nil): string;
  end;

///<summary> returns the global file formats list </summary>
function GetFileFormats: TFileFormatsList;

///<summary> Assigns the TBitBtn's glyph from the hex string (e.g. copied from .dfm)
///          if ContainsLength is true, the first 4 bytes (8 characters) contain the length of the
///          data (as is the case with the strings stored in the .dfm file) </summary>
procedure TBitBtn_GlyphFromString(_btn: TBitBtn; const _GlyphStr: AnsiString; _ContainsLength: boolean = true);

///<summary> This is meant as a replacement to the LockWindowUpate function which shouldn't really be used
///          any more.
///          @param Ctrl is a TWinControl which should be locked
///          @returns an interface, if that interface is released, it will automatically unlock the control </summary>
function TWinControl_Lock(_Ctrl: TWinControl): IInterface;

///<summary> checks whether the integer array contains the given element
///          @param Element is the integer to check for
///          @param Arr is the array to check
///          @returns true, if Arr contains Element </summary>
function ArrayContains(_Element: integer; const _Arr: array of integer): boolean;

type
  ///<summary> used in ResizeStringGrid and ResizeDbGrid to specify additional options
  ///  <ul>
  ///    <li>roUseGridWidth -> make the columns take up the whole grid width</li>
  ///    <li>roIgnoreHeader -> do not use the column header to calculate the column
  ///                          width</li>
  ///    <li>roUseAllRows -> use all Grid rows to calculate the minimum width, not
  ///                        just the first 10</li>
  ///  </ul> </summary>
  TResizeOptions = (roUseGridWidth, roIgnoreHeader, roUseAllRows);
  TResizeOptionSet = set of TResizeOptions;

///<summary> Resizes the columns of a TCustomGrid to fit their contents
///          @param Grid is the TCustomGrid to work on
///          @param Options is a TResizeOptionSet specifying additional options,
///                         defaults to an empty set. </summary>
procedure TGrid_Resize(_Grid: TCustomGrid); overload;
procedure TGrid_Resize(_Grid: TCustomGrid; _Options: TResizeOptionSet); overload;
procedure TGrid_Resize(_Grid: TCustomGrid; _Options: TResizeOptionSet; _RowOffset: integer); overload;
procedure TGrid_Resize(_Grid: TCustomGrid; _Options: TResizeOptionSet; const _ConstantCols: array of integer); overload;
procedure TGrid_Resize(_Grid: TCustomGrid; _Options: TResizeOptionSet; const _ConstantCols: array of integer; _RowOffset: integer); overload;

///<summary> Resizes the columns of a TDbGrid to fit their contents
///          @param Grid is the TCustomDbGrid to work on
///          @param Options is a TResizeOptionSet specifying additional options,
///                         defaults to an empty set. </summary>
procedure TDbGrid_Resize(_Grid: TCustomDbGrid; _Options: TResizeOptionSet = []);

///<summary> Returns the content of a StringGrid as a string
///          @param Grid is the TCustomGrid to read from.
///          @param IncludeFixed determines whether the fixed rows/columns are also included
///          @returns a string containing the contents of the grid columns separated by TAB
///                   rows sepearated by CRLF. </summary>
function TGrid_GetText(_Grid: TCustomGrid; _IncludeFixed: boolean = false): string; overload;

///<summary> Returns the content of a StringGrid as a string
///          @param Grid is the TCustomGrid to read from.
///          @param Selection is a TGridRect that determinens the area of the grid to return
///          @returns a string containing the contents of the grid columns separated by TAB
///                   rows sepearated by CRLF. </summary>
function TGrid_GetText(_Grid: TCustomGrid; _Selection: TGridRect): string; overload;

///<summary> exports the contents of the string grid to a tab separated text file
///          @param Grid is the string grid to export
///          @param Filename is the name of the text file to create
///          @param IncludeFixed determines whether the fixed rows/columns are also exported </summary>
procedure TGrid_ExportToFile(_Grid: TCustomGrid; const _Filename: string; _IncludeFixed: boolean = false);

///<summary> exports the contents of the string grid as tab separated strings to a stream
///          @param Grid is the string grid to export
///          @param Stream is the stream to write to
///          @param IncludeFixed determines whether the fixed rows/columns are also exported </summary>
procedure TGrid_ExportToStream(_Grid: TCustomGrid; _Stream: TStream; _IncludeFixed: boolean = false);

///<summary> sets the row count, taking the fixed rows into account
///          @returns the new RowCount </summary>
function TGrid_SetRowCount(_Grid: TCustomGrid; _RowCount: integer): integer;

///<summary> sets the nonfixd row count
///          @returns the new RowCount </summary>
function TGrid_SetNonfixedRowCount(_Grid: TCustomGrid; _RowCount: integer): integer;

///<summary> sets the column count, taking the fixed columns into account
///          @returns the new ColCount </summary>
function TGrid_SetColCount(_Grid: TCustomGrid; _ColCount: integer): integer;

///<summary> sets the nonfixd column count
///          @returns the new ColCount </summary>
function TGrid_SetNonfixedColCount(_Grid: TCustomGrid; _ColCount: integer): integer;

///<summary> sets the grid's current row without triggering an OnClick event
procedure TGrid_SetRowNoClick(_Grid: TDrawGrid; _Row: integer);

///<summary> sets the row count to FixedRows + 1 and clears all non-fixed cells </summary>
procedure TStringGrid_Clear(_Grid: TStringGrid);

///<summary> adds a new column to the Grid
///          It first searches for an empty column (no caption) and uses that, if
///          found, otherwise the column count is incremented.
///          @param Grid is the grid to expand
///          @param Caption is the caption of the new column
///          @returns the index of the new column </summary>
function TStringGrid_AddColumn(_Grid: TStringGrid; const _Caption: string): integer;

///<summary> exports the contents of the string grid to a tab separated text file (deprecated, use TGrid_ExportTofile instead)
///          @param Grid is the string grid to export
///          @param Filename is the name of the text file to create </summary>
procedure TStringGrid_ExportToFile(_Grid: TCustomGrid; const _Filename: string); deprecated; inline; // use TGrid_ExportTofile instead

///<summary> scrolls up the lines of a string grid
///          @param Grid is the TStringGrid to scroll
///          @param Top is the topmost row to scroll, if passed as -1 defaults to the first non-fixed row
///          @param Bottom is the bottommost row to scroll, if passed as -1 defaults to RowCount-1 </summary>
procedure TStringGrid_ScrollUp(_Grid: TStringGrid; _Top: integer = -1; _Bottom: integer = -1);

///<summary> sets the row count, taking the fixed rows into account  (deprecated, use TGrid_SetRowCount instead) </summary>
procedure TStringGrid_SetRowCount(_Grid: TCustomGrid; _RowCount: integer); deprecated; inline; // use TGrid_SetRowCount instead

///<summary> sets the column count, taking the fixed columns into account </summary>
procedure TStringGrid_SetColCount(_Grid: TCustomGrid; _ColCount: integer); deprecated; inline; // use TGrid_SetColCount instead

///<summary> deletes the given row from the string grid and moves all rows below it up by one,
///   if there is only one non-fixed row left, this row is cleared but not deleted.
///   @param Grid is the StringGrid to change
///   @param Row is the index of the row to delete, or -1 to delete the current row
///   @returns true, if the row was deleted </summary>
function TStringGrid_DeleteRow(_Grid: TStringGrid; _Row: integer = -1): boolean;

///<summary> inserts a row at the given index into the string grid and moves all rows below it down by one.
///          @param Grid is the StringGrid to change
///          @param Row is the index of the row to insert, or -1 to insert at the current row
///          @returns the inserted row index or -1 if the row cannot be inserted </summary>
function TStringGrid_InsertRow(_Grid: TStringGrid; _Row: integer = -1): integer;

///<summary> Tries to convert the grid cell to a double, if an error occurs, it raises
///          an exception and optionally focuses the cell.
///          @param Grid is the grid containing the data
///          @param Col is the cell's column (zero based)
///          @param Row is the cell's row (zero based)
///          @param FocusCell is a boolean which determines whether to focus the grid and cell
///                           if it does not contain a valid value
///          @returns the cell's content as a double
///          @raises EConvertError if the cell's content could not be converted </summary>
function TStringGrid_CellToDouble(_grid: TStringGrid; _Col, _Row: integer; _FocusCell: boolean = true): double;

///<summary> Tries to convert the grid cell to an integer, if an error occurs, it raises
///          an exception and optionally focuses the cell.
///          @param Grid is the grid containing the data
///          @param Col is the cell's column (zero based)
///          @param Row is the cell's row (zero based)
///          @param FocusCell is a boolean which determines whether to focus the grid and cell
///                           if it does not contain a valid value
///          @returns the cell's content as an integer
///          @raises EConvertError if the cell's content could not be converted </summary>
function TStringGrid_CellToInt(_grid: TStringGrid; _Col, _Row: integer; _FocusCell: boolean = true): integer;

///<summary> Deletes the top lines of the memo so it only contains Retain lines
///          @param Memo is the memo to work on
///          @param Retain is the number of lines to retain </summary>
procedure TMemo_DeleteTopLines(_Memo: TMemo; _Retain: integer);

///<summary> Gets the cursor position (actually the start of the selection) of the memo </summary>
function TMemo_GetCursorPos(_Memo: TMemo): integer;
procedure TMemo_SetCursorPos(_Memo: TMemo; _CharIdx: integer);
procedure TMemo_ScrollToCursorPos(_Memo: TMemo);

///<summary> Scrolls the memo to the end </summary>
procedure TMemo_ScrollToEnd(_Memo: TMemo);

///<summary> sets the Text property of a TEdit without triggering an OnChange event </summary>
procedure TEdit_SetTextNoChange(_ed: TCustomEdit; const _Text: string);

///<summary> Tries to convert the edit control text to a double, if an error occurs, it raises
///          an exception and optionally focuses the control.
///          @param ed is the edit control
///          @param FocusControl is a boolean which determines whether to focus the control
///                              if it does not contain a valid value or not
///          @returns the controls content as a double
///          @raises EConvertError if the controls content could not be converted </summary>
function TEdit_TextToDouble(_ed: TEdit; _FocusControl: boolean = true): double;

///<summary> Tries to convert the edit control text to a double, if an error occurs, it changes it's
///          color to ErrColor and returns false, otherwise it changes the color to OkColor and
///          returns true. </summary>
function TEdit_TryTextToDouble(_ed: TEdit; _OkColor: TColor = clWindow; _ErrColor: TColor = clYellow): boolean; overload;
function TEdit_TryTextToDouble(_ed: TEdit; out _Value: double; _OkColor: TColor = clWindow; _ErrColor: TColor = clYellow): boolean; overload;

///<summary> Tries to convert the edit control text to an integer, if an error occurs, it raises
///          an exception and optionally focuses the control.
///          @param ed is the edit control
///          @param FocusControl is a boolean which determines whether to focus the control
///                              if it does not contain a valid value
///          @returns the controls content as an integer
///          @raises EConvertError if the controls content could not be converted </summary>
function TEdit_TextToInt(_ed: TEdit; _FocusControl: boolean = true): integer; overload;
function TEdit_TextToInt(_ed: TLabeledEdit; _FocusControl: boolean = true): integer; overload;

///<summary> returns the contents of the tree view as a string with indentations
///          @param Tree is the TTreeView to process
///          @param Indentation is the number of spaces for indentation
///          @param Marker is a marker character to use for each item, #0 for no marker </summary>
function TTreeView_GetAsText(_Tree: TTreeView; _Indentation: integer = 2; _Marker: char = #0): string;

///<summary> adds a new TTabSheet with the given Caption to the PageControl and returns it </summary>
function TPageControl_AddTabSheet(_PageControl: TPageControl; const _Caption: string): TTabSheet;

///<summary> Draws the tab text for a TPageControl as horizontal text, useful, if you
///          want to have the tabs on the left or right but don't want vertical text.
///         Set the TPageControl's OwnerDraw property to true, the TabHeight property
///         (which actually gives the width of the tabs if they are on the left or right
///         hand side) sufficiently large, the TabWidth (which is actually is the height)
///         to 18 and assign a OnDrawTab event. From this event call this function.
///         @param PageControl is the TPageControl to draw
///         @param TabIndex is the index of the tab to draw
///         @param Rect is a TRect giving the drawing area
///         @param Active is a boolean that is true if the Tab is currently active </summary>
procedure TPageControl_DrawTab(_PageControl: TPageControl; _TabIndex: integer;
  const _Rect: TRect; _Active: boolean);

///<summary> Draws the tab text for a TTabControl as horizontal text, useful, if you
///          want to have the tabs on the left or right but don't want vertical text.
///         Set the TTabControl's OwnerDraw property to true, the TabHeight property
///         (which actually gives the width of the tabs if they are on the left or right
///         hand side) sufficiently large, the TabWidth (which is actually is the height)
///         to 18 and assign a OnDrawTab event. From this event call this function.
///         @param PageControl is the TPageControl to draw
///         @param TabIndex is the index of the tab to draw
///         @param Rect is a TRect giving the drawing area
///         @param Active is a boolean that is true if the Tab is currently active </summary>
procedure TTabControl_DrawTab(_TabControl: TTabControl; _TabIndex: integer;
  const _Rect: TRect; _Active: boolean);

///<summary> Sets a TTabControl's tab width based on the text it displays, usefull
///          to display horizontal text in tabs on the left or right hand side </summary>
procedure TTabControl_AdjustTabWidth(_TabControl: TTabControl; _Form: TForm; _MinWidth: integer = 80);

///<summary> Enables longer SimpleText (longer than 127 characters)
///          Call once to enable. Works, by adding a single panel with owner drawing and
///          setting the StatusBar's OnDrawPanel to a custom drawing method.
///          To make it work, you must use TStatusBar_SetLongSimpleText to set
///          the text, or use TLongSimpleTextStatusBar as an interposer class. </summary>
procedure TStatusBar_EnableLongSimpleText(_StatusBar: TStatusBar);

///<summary> Set the SimpleText of the StatusBar and invalidate it to enforce a redraw </summary>
procedure TStatusBar_SetLongSimpleText(_StatusBar: TStatusBar; const _Text: string);

///<summary> call this function to determine which panel of a TStatusBar has been clicked
//           Note: This assumes, that the status bar actually was clicked, so only call it
//           from the status bar's OnClick, OnMouseDown or OnMouseUp event handlers
//           If the status bar does not have any panels (e.g. SimplePanel=true), this function
//           will return 0.
function TStatusBar_GetClickedPanel(_sb: TStatusBar): integer;

type
  ///<summary> Interposer class for TStatusBar to allow longer than 127 characters in SimpleText </summary>
  TLongSimpleTextStatusBar = class(TStatusBar)
  private
    function GetSimpleText: string;
    procedure SetSimpleText(const Value: string);
  published
  public
    property SimpleText: string read GetSimpleText write SetSimpleText;
  end;

{$IFDEF DELPHI2009_UP}
type
  TdzButtonedEdit = class(TButtonedEdit)
  protected
    procedure KeyDown(var _Key: Word; _Shift: TShiftState); override;
  public
    procedure Loaded; override;
  end;
{$ENDIF DELPHI2009_UP}

///<summary> sets the control and all its child controls Enabled property and changes their
///          caption to reflect this
///          @param Control is the TControl to change
///          @param Enabled is a boolean with the new value for the Enabled property. </summary>
procedure TControl_SetEnabled(_Control: TControl; _Enabled: boolean);
procedure SetControlEnabled(_Control: TControl; _Enabled: boolean); deprecated; // use TControl_SetEnabled instead

///<summary> sets the with of a ComboBox's dropdown  in pixels </summary>
procedure TComboBox_SetDropdownWidth(_cmb: TCustomCombobox; _Pixels: integer);

///<summary> Selects the entry in a combobox that has an object pointer matching Value
///          @param cmb is the TCustomCombobox (descendant) to select
///          @param Value is the desired object value
///          @returns true, if the value could be found, false otherwise </summary>
function TComboBox_SelectByObject(_cmb: TCustomCombobox; _Value: pointer): boolean;

///<summary> Gets the string of a combobox entry that has an object pointer matching Obj
///          @param cmb is the TCustomCombobox (descendant) to select
///          @param Obj is the desired object value
///          @param s is the string of the combobox entry, only valid if the function returns true
///          @returns true, if the object could be found, false otherwise </summary>
function TComboBox_GetObjectCaption(_cmb: TCustomCombobox; _Obj: pointer; out _s: string): boolean;

///<summary> Gets the object pointer of the selected combobox item
///          @param cmb is the TCustomCombobox (descendant) to read from
///          @param Idx is the combobox's ItemIndex, only valid if the function returns true
///          @param Obj is the value of the object pointer of the selected item, only valid
///                     if the function returns true
///          @param FocusControl is a boolean which determines whether to focus the control
///                              if it does not contain a valid value, default = false
///          @returns true, if these out parameters are valid </summary>
function TComboBox_GetSelectedObject(_cmb: TCustomCombobox; out _Obj: pointer; _FocusControl: boolean = false): boolean; overload; inline;
function TComboBox_GetSelectedObject(_cmb: TCustomCombobox; out _Idx: integer;
  out _Obj: pointer; _FocusControl: boolean = false): boolean; overload;

///<summary> Gets the caption of the selected combobox item
///          @param cmb is the TCustomCombobox (descendant) to read from
///          @param Item is the selected item, only valid if the function returns true
///          @param FocusControl is a boolean which determines whether to focus the control
///                              if it does not contain a valid value, default = false
///          @returns true, if an item was selected </summary>
function TComboBox_GetSelected(_cmb: TCustomComboBox; out _Item: string;
  _FocusControl: boolean = false): boolean; overload;
function TComboBox_GetSelected(_cmb: TCustomComboBox): string; overload;

///<summary> Selects the item if it is in the list and returns the new ItemIndex
///          @param cmb is the TCustomCombobox (descendant) to use
///          @param Item is the item to select
///          @param DefaultIdx is the ItemIndex to use if no item matches.
///          @returns the index of the newly selected item or -1 if it doesn't exist </summary>
function TComboBox_Select(_cmb: TCustomComboBox; const _Item: string; _DefaultIdx: integer = -1): integer;

///<summary> Selects an item (or no Item, if Idx = -1) without triggering an OnChange event </summary>
procedure TComboBox_SelectWithoutChangeEvent(_cmb: TComboBox; _Idx: integer);

///<summary> Sets the control to readonly by adding a TPanel as parent and disable it. Note that this does
///          not grey out the control as the Enabled property would.
///          This is meant for controls that do not have a readonly property like TComboBox or TCheckBox. </summary>
procedure TControl_SetReadonly(_ctrl: TControl; _ReadOnly: boolean);

///<summary> Gets the object pointer of the selected listbox item
///          @param lst is the TCustomListbox (descendant) to read from
///          @param Idx is the listbox's ItemIndex, only valid if the function returns true
///          @param Obj is the value of the object pointer of the selected item, only valid
///                     if the function returns true
///          @returns true, if out parameters are valid </summary>
function TListBox_GetSelectedObject(_lst: TCustomListbox; out _Idx: integer; out _Obj: pointer): boolean;

///<summary> Gets the caption of the selected listbox item
///          @param cmb is the TCustomListbox (descendant) to read from
///          @param Item is the selected item, only valid if the function returns true
///          @param FocusControl is a boolean which determines whether to focus the control
///                              if it does not contain a valid value, default = false
///          @returns true, if an item was selected </summary>
function TListBox_GetSelected(_lb: TCustomListBox; out _Item: string;
  _FocusControl: boolean = false): boolean; overload;
function TListBox_GetSelected(_lb: TCustomListBox): string; overload;

///<summary> @Returns the number of selected items in the ListBox
///          @param Selected will contain the selected items as well as the
///                          associated objects. May be passed as NIL if only the count
///                          is required. </summary>
function TListBox_GetSelected(_lb: TCustomListBox; _Selected: TStrings): integer; overload;

///<summary> Selects the item if it is in the list and returns the new ItemIndex
///          @param lb is the TCustomListbox (descendant) to use
///          @param Item is the item to select
///          @param DefaultIdx is the ItemIndex to use if no item matches.
///          @returns the index of the newly selected item or -1 if it doesn't exist </summary>
function TListBox_Select(_lb: TCustomListBox; const _Item: string; _DefaultIdx: integer = -1): integer;

///<summary> Deletes the selected listbox item
///          @param lst is the TCustomListbox (descendant) to read from
///          @param Idx is the listbox's ItemIndex, only valid if the function returns true
///   @returns true, if these values are valid </summary>
function TListBox_DeleteSelected(_lst: TCustomListbox; out _Idx: integer): boolean; overload;
function TListBox_DeleteSelected(_lst: TCustomListbox): boolean; overload;
function TListBox_DeleteSelected(_lst: TCustomListBox; out _s: string): boolean; overload;

procedure TListBox_UnselectAll(_lb: TCustomListbox);

///<summary> Frees all objects assigned to the list and then clears the list </summary>
procedure TListbox_ClearWithObjects(_lst: TCustomListBox);

///<summary> Returns the nunber of items that are checked </summary>
function TCheckListBox_GetCheckedCount(_clb: TCheckListBox): integer;
procedure TCheckListBox_DeleteDisabled(_clb: TCheckListBox);
procedure TCheckListBox_InvertCheckmarks(_clb: TCheckListBox; _IncludeDisabled: boolean = false);
procedure TCheckListBox_UncheckAll(_clb: TCheckListBox);
procedure TCheckListBox_CheckAll(_clb: TCheckListBox; _IncludeDisabled: boolean = false);
///<summary> Returns the checked items and the objects associated in them
///          @param clb is the TCheckListBox
///          @param Checked is a TStrings to which the selected items and objects are to be added
///          @param IncludeDisabled determines whether the disabled items should also be returned if they are checked
///          @returns the number of Items in Checked </summary>
function TCheckListBox_GetChecked(_clb: TCheckListBox; _Checked: TStrings; _IncludeDisabled: boolean = false): integer; overload;
function TCheckListBox_GetChecked(_clb: TCheckListbox; _IncludeDisabled: boolean = false): string; overload;
///<summary> Returns the objects associated with the checked items
///          @param clb is the TCheckListBox
///          @param Objects is a TList to which the selected objects are to be added
///          @param IncludeDisabled determines whether the disabled items should also be returned if they are checked
///          @returns the number of Items in Objects </summary>
function TCheckListBox_GetCheckedObjects(_clb: TCheckListBox; _Objects: TList; _IncludeDisabled: boolean = false): integer;
///<summary> Checks all items contained in the Checked string list
///          @param clb is the TCheckListBox to modify
///          @param Checked is a string list containing the items to be checked
///          @param UncheckOthers determines whether any items not in the list should
///                               be unchecked (defaults to true).
///          @param SuppressClick determines whether the automatic OnClickCkeck
///                               event should be suppressed.
///          @returns the number of items that have been checked. </summary>
function TCheckListBox_SetChecked(_clb: TCheckListBox; _Checked: TStrings;
  _UncheckOthers: boolean = true; _SuppressClick: boolean = false): integer;

///<summary> sets the checked property without triggering an OnClickCheck event </summary>
procedure TCheckListBox_SetCheckedNoClick(_clb: TCheckListBox; _Idx: integer; _Checked: boolean);

procedure TCheckListBox_CheckSelected(_clb: TCheckListBox; _IncludeDisabled: boolean = false);
procedure TCheckListBox_UncheckSelected(_clb: TCheckListBox; _IncludeDisabled: boolean = false);

///<summary> Makes the given TCheckListBox readonly by assigning a special
///          method to its OnClickCheck event or makes it ReadWrite again
///          by removing that method.
///          @param ReadOnly determines whether to assign or remove the event.
///          @param ChangeColor determines whether to change the background color
///                             to clWindow (ReadWrite) and clBtnFace (ReadOnly)
///                             respectively. Defaults to true </summary>
procedure TCheckListBox_Readonly(_clb: TCheckListBox; _ReadOnly: boolean; _ChangeColor: boolean = true);

///<summary> Gets the caption of the given or selected item in the RadioGroup
///          @param rg is the TCustomRadioGroup descendant to read
///          @param Caption returns a string with the requested caption with
///                         Ampersands ('&') stripped, only valid, if
///                         the function returns true
///          @param Idx is the item index to read, defaults to -1 meaning 'selected item'
///          @returns true, if the caption could be read </summary>
function TRadioGroup_GetItemCaption(_rg: TCustomRadioGroup;
  out _Caption: string; _Idx: integer = -1): boolean;

///<summary> Selects the item in the radio group with the given caption,
///          returns the item's index or -1 if no item matched.
///          Comparison is case insensitive </summary>
function TRadioGroup_Select(_rg: TCustomRadioGroup; const _Item: string; _DefaultIdx: integer = -1): integer;

///<summary> Gets the object pointer of the selected RadioGroup item
///          @param cmb is the TCustomListbox (descendant) to read from
///          @param Idx is the listbox's ItemIndex, only valid if the function returns true
///          @param Obj is the value of the object pointer of the selected item, only valid
///                     if the function returns true
///          @returns true, if the out parameters are valid </summary>
function TRadioGroup_GetSelectedObject(_rg: TCustomRadioGroup; out _Idx: integer; out _Obj: pointer): boolean;

///<summary> Writes a TPicture object to a String. The Format is
///          <pictureformat>#26<picturedata> </summary>
function TPicture_WriteToString(_Pic: TPicture): string;

///<summary> Reads a TPicture object from a String which was created using
///          Picture_WriteToString </summary>
procedure TPicture_ReadFromString(_Pic: TPicture; const _S: string);

///<summary> Writes a TRichEdit to a string including all formatting </summary>
function TRichEdit_WriteToString(_Re: TRichEdit): string;

///<summary> Reads a TRichEdit from a string including all formatting </summary>
procedure TRichEdit_ReadFromString(_Re: TRichEdit; const _S: string);

///<summary> Returns the characater offset of the first character of the given row
///          example: RicheEdit1.SelStart := RichEdit_GetRowCharIndex(RichEdit1, 5);
///          @param Re is a TRichEdit
///          @param Row is the row number (0 based)
///          @returns the character offset (0 based) of the first character of the row </summary>
function TRichEdit_RowToCharIndex(_Re: TRichEdit; _Row: integer): integer;

///<summary> Returns the row which contains the given character index </summary>
function TRichEdit_CharIndexToRow(_Re: TRichEdit; _Idx: integer): integer;

///<summary> Returns the current row number (0 based) of the RichEdit </summary>
function TRichEdit_GetCurrentRow(_Re: TRichEdit): integer;

///<summary> Scrolls the rich edit to the current caret position </summary>
procedure TRichEdit_ScrollToCaret(_Re: TRichEdit);

///<summary> Write a line to a RichEdit, optionally specifying color and font style </summary>
procedure TRichEdit_WriteLn(_Re: TRichEdit; const _s: string; _Color: TColor = clBlack; _Style: TFontStyles = []);

///<summary> Adds a control and a corresponding label, a line consists of 24 pixels
///          with 16 pixels distance from the upper and 8 pixels from the left border.
///          It is assumed that the control already has the correct x position, only
///          Top will be adjusted. </summary>
function AddLabeledControl(_Idx: integer; const _Caption: string; _ctrl: TControl): TLabel;

///<summary> Calculates the height for writing a Text on a control </summary>
function CalcTextHeight(_Ctrl: TWinControl; const _Text: string; _Width: integer = -1): integer; overload;
function CalcTextHeight(_Ctrl: TGraphicControl; const _Text: string; _Width: integer = -1): integer; overload;

///<summary> I don't quite remember what this is supposed to do and where it is used,
///          Please, if you find a call to this function somewhere, tell me. -- twm </summary>
function TStringGrid_IsScrollBarVisible(_Grid: TCustomGrid; _Code: integer): boolean;

///<summary> Returns the path to the application's executable including the trailing backslash </summary>
function GetApplicationPath: string; deprecated; // use TApplication_GetExePath instead

///<summary> Center the child on the parent </summary>
procedure TControl_Center(_Child: TControl; _Parent: TControl);

///<summary> sets the Checked property without firing an OnClick event </summary>
procedure TCheckBox_SetCheckedNoOnClick(_Chk: TCustomCheckBox; _Checked: boolean);

///<summary> centers a form on the given point, but makes sure the form is fully visible </summary>
procedure TForm_CenterOn(_frm: TForm; _Center: TPoint); overload;
///<summary> centers a form on the given component, but makes sure the form is fully visible </summary>
procedure TForm_CenterOn(_frm: TForm; _Center: TWinControl); overload;

///<summary> tries to focus the given control, returns false if that's not possible </summary>
function TWinControl_SetFocus(_Ctrl: TWinControl): boolean;

///<summary> returns the full path of the executable (without the filename but including
///          a backslash) </summary>
function TApplication_GetExePath: string;

///<summary> returns true, if the application's executable contains version information </summary>
function TApplication_HasVersionInfo: boolean;

///<summary> switches off "Windows Ghosting" in Win 2000 and XP
///          This is a workaround for the bug that modal forms sometimes aren't modal in W2K and XP.
///          Call in application startup. </summary>
procedure DisableProcessWindowsGhosting;

procedure MergeForm(AControl: TWinControl; AForm: TForm; Align: TAlign; Show: Boolean); deprecated; // use a frame instead
///<summary> Reverses a VclUtils.MergeForm (rxlib)
///          @param Form is the TForm to unmerge </summary>
procedure UnMergeForm(_Form: TCustomForm); deprecated; // use a frame instead

///<summary> free all lv.Items[n].Data objects and then clear the items </summary>
procedure TListView_ClearWithObjects(_lv: TListView);

///<summary> Unselect all items, if WithSelectEvents is false, OnSelectItem events will be temporarily
///          disabled. </summary>
procedure TListView_UnselectAll(_lv: TListView; _WithSelectEvents: boolean = true);

///<summary> Returns the number of selected items in the ListView </summary>
function TListView_GetSelectedCount(_lv: TListView): integer;

///<summary> Returns the first item in the radio group with the caption ItemText </summary>
function TRadioGroup_GetButton(_rg: TRadioGroup; _ItemText: string): TRadioButton; overload;
///<summary> Returns the ItemIdx'th item in the radio group </summary>
function TRadioGroup_GetButton(_rg: TRadioGroup; _ItemIdx: integer): TRadioButton; overload;

///<summary> Returns the Checked value of a TCheckbox or TRadioButton (which both descend from TButtonControl) </summary>
function TButtonControl_GetChecked(_bctrl: TButtonControl): boolean;

///<summary> Sets the Checked value of a TCheckbox or TRadioButton (which both descend from TButtonControl) </summary>
procedure TButtonControl_SetChecked(_bctrl: TButtonControl; _Value: boolean);

///<summary> Sets the Caption value of a TCheckbox or TRadioButton (which both descend from TButtonControl) </summary>
procedure TButtonControl_SetCaption(_bctrl: TButtonControl; _Value: string);

///<summary> sets Screen.Cursor to NewCursor and restores it automatically when the returned interface
///          goes out of scope </summary>
function TCursor_TemporaryChange(_NewCursor: TCursor = crHourGlass): IInterface;

//<summary> If the Checked property of the action = the Checked parameter nothing happens and
//          the function returns true. If they are different, it calls the action's Execute
//          method and returns its result.
//          @returns true, if Execute was called and returned true, false otherwise </summary>
function TAction_SetCheckedExecute(_act: TCustomAction; _Checked: boolean): boolean;

implementation

uses
  Menus, // for StripHotKey function
  Consts,
  JPEG,
  StrUtils,
{$IFDEF SUPPORTS_UNICODE_STRING}
  AnsiStrings,
{$ENDIF SUPPORTS_UNICODE_STRING}
{$IFDEF GIFByRx}
  RxGConst,
  rxGif,
{$ENDIF GIFByRx}
  u_dzConvertUtils,
  u_dzStringUtils,
  u_dzClassUtils;

function _(const _s: string): string; inline;
begin
  Result := dzDGetText(_s, 'dzlib');
end;

procedure TBitBtn_GlyphFromString(_btn: TBitBtn; const _GlyphStr: AnsiString; _ContainsLength: boolean = true);
var
  st: TMemoryStream;
  s: AnsiString;
  Buf: array of byte;
  res: Integer;
  Size: integer;
begin
  if _ContainsLength then
    s := LowerCase(Copy(_GlyphStr, 9))
  else
    s := LowerCase(_GlyphStr);
  Size := Length(s) div 2;
  SetLength(Buf, Size);
  res := HexToBin(PAnsiChar(s), @Buf[0], Size);
  if res <> Size then
    raise Exception.CreateFmt(_('Glyph string contained invalid character at position %d.'), [res]);
  st := TMemoryStream.Create;
  try
    st.Write(Buf[0], Size);
    st.Position := 0;
    _btn.Glyph.LoadFromStream(st);
  finally
    FreeAndNil(st);
  end;
end;

// we need this to access protected methods
type
  TGridHack = class(TCustomGrid);
  TDbGridHack = class(TCustomDbGrid);

function TGrid_GetText(_Grid: TCustomGrid; _IncludeFixed: boolean = false): string;
var
  Selection: TGridRect;
  Grid: TGridHack;
begin
  Grid := TGridHack(_Grid);
  if _IncludeFixed then begin
    Selection.Left := 0;
    Selection.Top := 0;
  end else begin
    Selection.Left := Grid.FixedCols;
    Selection.Top := Grid.FixedRows;
  end;
  Selection.Right := Grid.ColCount - 1;
  Selection.Bottom := Grid.RowCount - 1;
  Result := TGrid_GetText(_Grid, Selection);
end;

function TGrid_GetText(_Grid: TCustomGrid; _Selection: TGridRect): string;
var
  Grid: TGridHack;
  Line: TLineBuilder;
  Content: TLineBuilder;
  r: Integer;
  c: Integer;
begin
  Grid := TGridHack(_Grid);
  Result := '';
  Content := TLineBuilder.Create(#13#10);
  try
    Line := TLineBuilder.Create;
    try
      for r := _Selection.Top to _Selection.Bottom do begin
        Line.Clear;
        for c := _Selection.Left to _Selection.Right do begin
          Line.Add(Grid.GetEditText(c, r));
        end;
        Content.Add(Line.Content);
      end;
    finally
      FreeAndNil(Line);
    end;
    Result := Content.Content;
  finally
    FreeAndNil(Content);
  end;
end;

procedure TGrid_ExportToStream(_Grid: TCustomGrid; _Stream: TStream; _IncludeFixed: boolean = false);
var
  s: string;
begin
  s := TGrid_GetText(_Grid, _IncludeFixed);
  TStream_WriteStringLn(_Stream, s);
end;

procedure TGrid_ExportToFile(_Grid: TCustomGrid; const _Filename: string; _IncludeFixed: boolean = false);
var
  t: Text;
  s: string;
begin
  s := TGrid_GetText(_Grid, _IncludeFixed);
  AssignFile(t, _FileName);
  Rewrite(t);
  try
    Write(t, s);
  finally
    CloseFile(t);
  end;
end;

function TGrid_SetRowCount(_Grid: TCustomGrid; _RowCount: integer): integer;
var
  Grid: TGridHack;
begin
  Grid := TGridHack(_Grid);
  if Grid.FixedRows >= _RowCount then
    Result := Grid.FixedRows + 1
  else
    Result := _RowCount;
  Grid.RowCount := Result;
end;

function TGrid_SetColCount(_Grid: TCustomGrid; _ColCount: integer): integer;
var
  Grid: TGridHack;
begin
  Grid := TGridHack(_Grid);
  if Grid.FixedCols >= _ColCount then
    Result := Grid.FixedCols + 1
  else
    Result := _ColCount;
  Grid.ColCount := Result;
end;

function TGrid_SetNonfixedColCount(_Grid: TCustomGrid; _ColCount: integer): integer;
var
  Grid: TGridHack;
begin
  Grid := TGridHack(_Grid);
  Result := Grid.FixedCols + _ColCount;
  Grid.ColCount := Result;
end;

function TGrid_SetNonfixedRowCount(_Grid: TCustomGrid; _RowCount: integer): integer;
var
  Grid: TGridHack;
begin
  Grid := TGridHack(_Grid);
  Result := Grid.FixedRows + _RowCount;
  Grid.RowCount := Result;
end;

procedure TStringGrid_SetRowCount(_Grid: TCustomGrid; _RowCount: integer);
begin
  TGrid_SetRowCount(_Grid, _RowCount);
end;

procedure TStringGrid_SetColCount(_Grid: TCustomGrid; _ColCount: integer);
begin
  TGrid_SetColCount(_Grid, _ColCount);
end;

procedure TGrid_SetRowNoClick(_Grid: TDrawGrid; _Row: integer);
var
  Event: TNotifyEvent;
begin
  Event := _Grid.OnClick;
  try
    _Grid.OnClick := nil;
    _Grid.Row := _Row;
  finally
    _Grid.OnClick := Event;
  end;
end;

procedure TStringGrid_ExportToFile(_Grid: TCustomGrid; const _Filename: string);
begin
  TGrid_ExportToFile(_Grid, _Filename, true);
end;

procedure TStringGrid_Clear(_Grid: TStringGrid);
var
  c: integer;
begin
  _Grid.RowCount := _Grid.FixedRows + 1;
  for c := _Grid.FixedCols to _Grid.ColCount - 1 do
    _Grid.Cells[c, _Grid.FixedRows] := '';
end;

function TStringGrid_AddColumn(_Grid: TStringGrid; const _Caption: string): integer;
var
  i: Integer;
begin
  Result := _Grid.ColCount;
  for i := _Grid.ColCount - 1 downto 0 do begin
    if _Grid.Cells[i, 0] = '' then begin
      Result := i;
    end;
  end;

  if Result >= _Grid.ColCount then
    TGrid_SetColCount(_Grid, Result + 1);
  _Grid.Cells[Result, 0] := _Caption;
end;

procedure TStringGrid_ScrollUp(_Grid: TStringGrid; _Top: integer = -1; _Bottom: integer = -1);
var
  r: Integer;
  c: Integer;
begin
  if _Top = -1 then
    _Top := _Grid.FixedRows;
  if _Bottom = -1 then
    _Bottom := _Grid.RowCount - 1;
  for r := _Top to _Bottom - 1 do begin
    for c := _Grid.FixedCols to _Grid.ColCount - 1 do
      _Grid.Cells[c, r] := _Grid.Cells[c, r + 1];
  end;
  if _Bottom > _Top then
    for c := _Grid.FixedCols to _Grid.ColCount - 1 do
      _Grid.Cells[c, _Bottom] := '';
end;

function TStringGrid_DeleteRow(_Grid: TStringGrid; _Row: integer): boolean;
var
  r: integer;
  c: integer;
begin
  Assert(Assigned(_Grid));
  Assert(_Grid.FixedRows < _Grid.RowCount);

  if _Row = -1 then
    _Row := _Grid.Row;
  if (_Row < _Grid.FixedRows) or (_Row >= _Grid.RowCount) then begin
    Result := false;
    exit;
  end;
  if _Grid.RowCount <= _Grid.FixedRows + 1 then begin
    for c := 0 to _Grid.ColCount - 1 do
      _Grid.Cells[c, _Grid.FixedRows] := '';
    Result := true;
    exit;
  end;

  if _Grid.Row = _Grid.RowCount - 1 then
    _Grid.Row := _Grid.Row - 1;

  for r := _Row + 1 to _Grid.RowCount - 1 do begin
    for c := 0 to _Grid.ColCount - 1 do
      _Grid.Cells[c, r - 1] := _Grid.Cells[c, r];
  end;
  _Grid.RowCount := _Grid.RowCount - 1;
  Result := true;
end;

function TStringGrid_InsertRow(_Grid: TStringGrid; _Row: integer = -1): integer;
var
  r: Integer;
  c: Integer;
begin
  Assert(Assigned(_Grid));

  if _Row = -1 then
    _Row := _Grid.Row;
  if (_Row < _Grid.FixedRows) or (_Row >= _Grid.RowCount) then begin
    Result := -1;
    exit;
  end;

  _Grid.RowCount := _Grid.RowCount + 1;
  for r := _Grid.RowCount - 1 downto _Row + 1 do begin
    for c := 0 to _Grid.ColCount - 1 do
      _Grid.Cells[c, r] := _Grid.Cells[c, r - 1];
  end;
  for c := 0 to _Grid.ColCount - 1 do
    _Grid.Cells[c, _Row] := '';
  Result := _Row;
end;

function TStringGrid_CellToDouble(_grid: TStringGrid; _Col, _Row: integer; _FocusCell: boolean = true): double;
var
  s: string;
begin
  s := _grid.Cells[_Col, _Row];
  if not TryStr2Float(s, Result, #0) then begin
    if _FocusCell then begin
      _grid.Row := _Row;
      _grid.Col := _Col;
      _grid.SetFocus;
    end;
    raise EConvertError.CreateFmt(_('"%s" is not a valid floating point value.'), [s]);
  end;
end;

function TStringGrid_CellToInt(_grid: TStringGrid; _Col, _Row: integer; _FocusCell: boolean = true): integer;
var
  s: string;
begin
  s := _grid.Cells[_Col, _Row];
  if not TryStrToInt(s, Result) then begin
    if _FocusCell then begin
      _grid.Row := _Row;
      _grid.Col := _Col;
      _grid.SetFocus;
    end;
    raise EConvertError.CreateFmt(_('"%s" is not a valid integer value.'), [s]);
  end;
end;

type
  THackEdit = class(TCustomEdit)
  end;

procedure TEdit_SetTextNoChange(_ed: TCustomEdit; const _Text: string);
var
  Event: TNotifyEvent;
  ed: THackEdit;
begin
  ed := THackEdit(_ed);
  Event := ed.OnChange;
  ed.OnChange := nil;
  try
    ed.Text := _Text;
  finally
    ed.OnChange := Event;
  end;
end;

function TEdit_TextToDouble(_ed: TEdit; _FocusControl: boolean = true): double;
var
  s: string;
begin
  s := _ed.Text;
  if not TryStr2Float(s, Result, #0) then begin
    if _FocusControl then begin
      _ed.SetFocus;
    end;
    raise EConvertError.CreateFmt(_('"%s" is not a valid floating point value.'), [s]);
  end;
end;

function TEdit_TryTextToDouble(_ed: TEdit; out _Value: double; _OkColor: TColor = clWindow; _ErrColor: TColor = clYellow): boolean;
var
  s: string;
begin
  s := _ed.Text;
  Result := TryStr2Float(s, _Value, #0);
  if Result then
    _ed.Color := _OkColor
  else
    _ed.Color := _ErrColor;
end;

function TEdit_TryTextToDouble(_ed: TEdit; _OkColor: TColor = clWindow; _ErrColor: TColor = clYellow): boolean;
var
  Value: double;
begin
  Result := TEdit_TryTextToDouble(_ed, Value, _OkColor, _ErrColor);
end;

function TEdit_TextToInt(_ed: TEdit; _FocusControl: boolean = true): integer;
var
  s: string;
begin
  s := _ed.Text;
  if not TryStrToInt(s, Result) then begin
    if _FocusControl then begin
      _ed.SetFocus;
    end;
    raise EConvertError.CreateFmt(_('"%s" is not a valid integer value.'), [s]);
  end;
end;

function TEdit_TextToInt(_ed: TLabeledEdit; _FocusControl: boolean = true): integer;
var
  s: string;
begin
  s := _ed.Text;
  if not TryStrToInt(s, Result) then begin
    if _FocusControl then begin
      _ed.SetFocus;
    end;
    raise EConvertError.CreateFmt(_('"%s" is not a valid integer value.'), [s]);
  end;
end;

function TTreeView_GetAsText(_Tree: TTreeView; _Indentation: integer = 2; _Marker: char = #0): string;
var
  Level: integer;
  Marker: string;

  function GetSubnodes(_tn: TTreeNode): string;
  var
    Child: TTreeNode;
  begin
    if Assigned(_tn) then begin
      Result := StringOfChar(' ', Level * _Indentation) + Marker + _tn.Text + #13#10;
      Inc(Level);
      try
        Child := _tn.getFirstChild;
        while Assigned(Child) do begin
          Result := Result + GetSubNodes(Child);
          Child := Child.getNextSibling;
        end;
      finally
        Dec(Level);
      end;
    end else
      Result := '';
  end;

begin
  if _Marker = #0 then
    Marker := ''
  else
    Marker := _Marker;
  Result := GetSubnodes(_Tree.Items.GetFirstNode);
end;

function ArrayContains(_Element: integer; const _Arr: array of integer): boolean;
var
  i: integer;
begin
  Result := false;
  for i := low(_Arr) to High(_Arr) do begin
    Result := _Arr[i] = _Element;
    if Result then
      exit;
  end;
end;

procedure HandleRow(_Grid: TGridHack; _Col, _Row: integer; var _MinWidth: integer);
var
  ColWidth: integer;
  ColText: string;
begin
  ColText := _Grid.GetEditText(_Col, _Row);
  ColWidth := _Grid.Canvas.TextWidth(ColText);
  if ColWidth > _MinWidth then
    _MinWidth := ColWidth;
end;

procedure TGrid_Resize(_Grid: TCustomGrid);
begin
  TGrid_Resize(_Grid, [], [], -1);
end;

procedure TGrid_Resize(_Grid: TCustomGrid; _Options: TResizeOptionSet);
begin
  TGrid_Resize(_Grid, _Options, [], -1);
end;

procedure TGrid_Resize(_Grid: TCustomGrid; _Options: TResizeOptionSet; _RowOffset: integer);
begin
  TGrid_Resize(_Grid, _Options, [], _RowOffset);
end;

procedure TGrid_Resize(_Grid: TCustomGrid; _Options: TResizeOptionSet; const _ConstantCols: array of integer);
begin
  TGrid_Resize(_Grid, _Options, _ConstantCols, -1);
end;

procedure TGrid_Resize(_Grid: TCustomGrid; _Options: TResizeOptionSet; const _ConstantCols: array of integer; _RowOffset: integer);
var
  Col, Row: integer;
  Grid: TGridHack;
  MinWidth: integer;
  MinCol: integer;
  MaxCol: integer;
  MaxRow: integer;
  ColWidths: array of integer;
  FirstRow: integer;
  SumWidths: integer;
  Additional: integer;
begin
  Grid := TGridHack(_Grid);
  MaxCol := Grid.ColCount - 1;
  MinCol := 0;
  SetLength(ColWidths, MaxCol + 1);

  if _RowOffset = -1 then
    FirstRow := Grid.FixedRows
  else
    FirstRow := _RowOffset;

  MaxRow := FirstRow + 10;
  if (MaxRow >= Grid.RowCount) or (roUseAllRows in _Options) then
    MaxRow := Grid.RowCount - 1;
  SumWidths := MaxCol; // one spare pixel per column
  if goVertLine in Grid.Options then
    Inc(SumWidths, Grid.GridLineWidth);
  for Col := MinCol to MaxCol do begin
    if ArrayContains(Col, _ConstantCols) then
      MinWidth := Grid.ColWidths[Col]
    else begin
      MinWidth := 0;

      if not (roIgnoreHeader in _Options) then
        for Row := 0 to Grid.FixedRows - 1 do
          HandleRow(Grid, Col, Row, MinWidth);

      for Row := FirstRow to MaxRow do
        HandleRow(Grid, Col, Row, MinWidth);

      if goVertLine in Grid.Options then
        Inc(MinWidth, Grid.GridLineWidth);
      Inc(MinWidth, 4); // 2 Punkte rechts und links, wie in TStringGrid.DrawCell
      if MinWidth < Grid.DefaultColWidth then
        MinWidth := Grid.DefaultColWidth;
    end;
    ColWidths[Col] := MinWidth;
    Inc(SumWidths, MinWidth);
  end;
  if (SumWidths < Grid.ClientWidth) and (roUseGridWidth in _Options)
    and (Length(_ConstantCols) < MaxCol + 1) then begin
    Additional := (Grid.ClientWidth - SumWidths) div (MaxCol + 1 - Length(_ConstantCols));
    for Col := MinCol to MaxCol do begin
      if not ArrayContains(Col, _ConstantCols) then begin
        Inc(ColWidths[Col], Additional);
        Inc(SumWidths, Additional);
      end;
    end;
    if SumWidths < Grid.ClientWidth then begin
      Col := MaxCol;
      while ArrayContains(Col, _ConstantCols) do
        Dec(Col);
      Inc(ColWidths[Col], Grid.ClientWidth - SumWidths);
    end;
  end;
  for Col := MinCol to MaxCol do
    Grid.ColWidths[Col] := ColWidths[Col];
end;

procedure TDbGrid_Resize(_Grid: TCustomDbGrid; _Options: TResizeOptionSet = []);
var
  Col, Row: integer;
  Grid: TDbGridHack;
  MinWidth: integer;
  ColWidth: integer;
  ColText: string;
  MinCol: integer;
  MaxCol: integer;
  MaxRow: integer;
  ColWidths: array of integer;
  FirstRow: integer;
  SumWidths: integer;
  Additional: integer;
  DBColumn: TColumn;
begin
  Grid := TDbGridHack(_Grid);
  MaxCol := Grid.ColCount - 1 - Grid.IndicatorOffset;
  MinCol := 0;
  SetLength(ColWidths, MaxCol + 1);
  FirstRow := 0;
  MaxRow := 10;
  if (MaxRow >= Grid.RowCount) or (roUseAllRows in _Options) then
    MaxRow := Grid.RowCount - 1;
  SumWidths := 4; // for some reason this must be 4 and not 0
  if dgColLines in Grid.Options then
    // there is one more grid line than there are columns
    Inc(SumWidths, Grid.GridLineWidth);
  if dgIndicator in Grid.Options then
    Inc(SumWidths, 21); // ColWidht[0] does not work :-(
  for Col := MinCol to MaxCol do begin
    MinWidth := 21;
    if not (roIgnoreHeader in _Options) then begin
      DBColumn := Grid.Columns[Col];
      ColText := DBColumn.Title.Caption;
      ColWidth := Grid.Canvas.TextWidth(ColText);
      if ColWidth > MinWidth then
        MinWidth := ColWidth;
    end;
    for Row := FirstRow to MaxRow do begin
      ColText := Grid.GetEditText(Col + Grid.IndicatorOffset, Row);
      ColWidth := Grid.Canvas.TextWidth(ColText);
      if ColWidth > MinWidth then
        MinWidth := ColWidth;
    end;
    if dgColLines in Grid.Options then
      Inc(MinWidth, Grid.GridLineWidth);
    Inc(MinWidth, 4); // 2 Punkte rechts und links, wie in TStringGrid.DrawCell
    ColWidths[Col] := MinWidth;
    Inc(SumWidths, MinWidth);
  end;
  if (SumWidths < Grid.ClientWidth) and (roUseGridWidth in _Options) then begin
    Additional := (Grid.ClientWidth - SumWidths) div (MaxCol + 1);
    for Col := MinCol to MaxCol do begin
      Inc(ColWidths[Col], Additional);
      Inc(SumWidths, Additional);
    end;
    if SumWidths < Grid.ClientWidth then
      Inc(ColWidths[MaxCol], Grid.ClientWidth - SumWidths);
  end;
  for Col := MinCol to MaxCol do
    Grid.Columns[Col].Width := ColWidths[Col];
end;

function TPageControl_AddTabSheet(_PageControl: TPageControl; const _Caption: string): TTabSheet;
begin
  Result := TTabSheet.Create(_PageControl);
  Result.Parent := _PageControl;
  Result.PageControl := _PageControl;
  Result.Caption := _Caption;
end;

procedure DrawTab(_TabControl: TCustomTabControl; const _Caption: string;
  const _Rect: TRect; _Active: boolean);
var
  TopOffs: integer;
begin
  if _Active then
    TopOffs := 4
  else
    TopOffs := 0;
  _TabControl.Canvas.TextRect(_Rect, _Rect.Left + 4, _Rect.Top + TopOffs, _Caption);
end;

procedure TPageControl_DrawTab(_PageControl: TPageControl; _TabIndex: integer;
  const _Rect: TRect; _Active: boolean);
begin
  DrawTab(_PageControl, _PageControl.Pages[_TabIndex].Caption, _Rect, _Active);
end;

procedure TTabControl_DrawTab(_TabControl: TTabControl; _TabIndex: integer;
  const _Rect: TRect; _Active: boolean);
begin
  DrawTab(_TabControl, _TabControl.Tabs[_TabIndex], _Rect, _Active);
end;

procedure TTabControl_AdjustTabWidth(_TabControl: TTabControl; _Form: TForm; _MinWidth: integer = 80);
var
  i: integer;
  MinWidth: integer;
  w: integer;
begin
  MinWidth := _MinWidth;
  for i := 0 to _TabControl.Tabs.Count - 1 do begin
    w := _TabControl.Canvas.TextWidth(_TabControl.Tabs[i]) + 16;
    if w > MinWidth then
      MinWidth := w;
  end;
  w := _TabControl.TabHeight;
  if (w < MinWidth) or (w > _MinWidth) then begin
    w := MinWidth - w;
    if Assigned(_Form) then
      _Form.Width := _Form.Width + w;
    if not Assigned(_Form) or not (akRight in _TabControl.Anchors) then
      _TabControl.Width := _TabControl.Width + w;
    _TabControl.TabHeight := MinWidth;
  end;
end;

type
  // Note: This class is never instantiated, only the DrawPanel method will be used
  //       without ever referencing the self pointer (which is NIL), so it should work
  TStatusBarPainter = class
  public
    procedure DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
  end;

procedure TStatusBarPainter.DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
var
  cnv: TCanvas;
  s: string;
  h: Integer;
begin
  s := StatusBar.SimpleText;
  cnv := StatusBar.Canvas;
  h := cnv.TextHeight(s);
  cnv.TextRect(Rect, 2, (StatusBar.ClientHeight - h) div 2, StatusBar.SimpleText);
end;

procedure TStatusBar_EnableLongSimpleText(_StatusBar: TStatusBar);
var
  Painter: TStatusBarPainter;
  pnl: TStatusPanel;
begin
  _StatusBar.SimplePanel := false;
  _StatusBar.Panels.Clear;
  pnl := _StatusBar.Panels.Add;
  pnl.Style := psOwnerDraw;
  Painter := nil;
  _StatusBar.OnDrawPanel := Painter.DrawPanel;
end;

procedure TStatusBar_SetLongSimpleText(_StatusBar: TStatusBar; const _Text: string);
begin
  _StatusBar.SimpleText := _Text;
  _StatusBar.Invalidate;
end;

procedure SetControlEnabled(_Control: TControl; _Enabled: boolean);
begin
  TControl_SetEnabled(_Control, _Enabled);
end;

procedure TControl_SetEnabled(_Control: TControl; _Enabled: boolean);
var
  i: integer;
  Container: TWinControl;
  ctrl: TControl;
begin
  if _Control is TWinControl then begin
    Container := _Control as TWinControl;
    for i := 0 to Container.ControlCount - 1 do begin
      ctrl := Container.Controls[i];
      TControl_SetEnabled(Ctrl, _Enabled);
    end;
  end;
  _Control.Enabled := _Enabled;
end;

procedure TComboBox_SetDropdownWidth(_cmb: TCustomCombobox; _Pixels: integer);
begin
  _cmb.HandleNeeded;
  _cmb.Perform(CB_SETDROPPEDWIDTH, _Pixels, 0);
end;

function TComboBox_SelectByObject(_cmb: TCustomCombobox; _Value: pointer): boolean;
var
  i: integer;
begin
  for i := 0 to _cmb.Items.Count - 1 do begin
    Result := (_cmb.Items.Objects[i] = _Value);
    if Result then begin
      _cmb.ItemIndex := i;
      exit;
    end;
  end;
  Result := false;
end;

function TComboBox_GetObjectCaption(_cmb: TCustomCombobox; _Obj: pointer; out _s: string): boolean;
var
  i: integer;
begin
  for i := 0 to _cmb.Items.Count - 1 do begin
    Result := (_cmb.Items.Objects[i] = _Obj);
    if Result then begin
      _s := _cmb.Items[i];
      exit;
    end;
  end;
  Result := false;
end;

function TComboBox_GetSelectedObject(_cmb: TCustomCombobox; out _Obj: pointer; _FocusControl: boolean = false): boolean;
var
  Idx: integer;
begin
  Result := TComboBox_GetSelectedObject(_cmb, Idx, _Obj, _FocusControl);
end;

function TComboBox_GetSelectedObject(_cmb: TCustomCombobox; out _Idx: integer;
  out _Obj: pointer; _FocusControl: boolean = false): boolean;
begin
  _Idx := _cmb.ItemIndex;
  Result := _Idx <> -1;
  if Result then
    _Obj := _cmb.Items.Objects[_Idx]
  else if _FocusControl then
    _cmb.SetFocus;
end;

function TComboBox_GetSelected(_cmb: TCustomComboBox; out _Item: string;
  _FocusControl: boolean = false): boolean;
var
  Idx: integer;
begin
  Idx := _cmb.ItemIndex;
  Result := Idx <> -1;
  if Result then
    _Item := _cmb.Items[Idx]
  else if _FocusControl then
    _cmb.SetFocus;
end;

function TComboBox_GetSelected(_cmb: TCustomComboBox): string; overload;
begin
  if not TComboBox_GetSelected(_cmb, Result) then
    raise EdzComboBoxNoSelection.Create(_('No item selected in combobox'));
end;

function TListBox_GetSelected(_lb: TCustomListBox; out _Item: string;
  _FocusControl: boolean = false): boolean;
var
  Idx: integer;
begin
  Idx := _lb.ItemIndex;
  Result := Idx <> -1;
  if Result then
    _Item := _lb.Items[Idx]
  else if _FocusControl then
    _lb.SetFocus;
end;

function TListBox_GetSelected(_lb: TCustomListBox): string;
begin
  if not TListBox_GetSelected(_lb, Result) then
    raise EdzListBoxNoSelection(_('No item selected in listbox'));
end;

function TListBox_GetSelected(_lb: TCustomListBox; _Selected: TStrings): integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to _lb.Items.Count - 1 do begin
    if _lb.Selected[i] then begin
      Inc(Result);
      if Assigned(_Selected) then
        _Selected.AddObject(_lb.Items[i], _lb.Items.Objects[i]);
    end;
  end;
end;

function TListBox_GetSelectedObject(_lst: TCustomListbox; out _Idx: integer; out _Obj: pointer): boolean;
begin
  _Idx := _lst.ItemIndex;
  Result := _Idx <> -1;
  if Result then
    _Obj := _lst.Items.Objects[_Idx];
end;

function TListBox_DeleteSelected(_lst: TCustomListbox; out _Idx: integer): boolean;
begin
  _Idx := _lst.ItemIndex;
  Result := _Idx <> -1;
  if Result then
    _lst.Items.Delete(_Idx);
end;

function TListBox_DeleteSelected(_lst: TCustomListBox; out _s: string): boolean; overload;
var
  Idx: Integer;
begin
  Idx := _lst.ItemIndex;
  Result := Idx <> -1;
  if Result then begin
    _s := _lst.Items[Idx];
    _lst.Items.Delete(Idx);
  end;
end;

function TListBox_DeleteSelected(_lst: TCustomListbox): boolean;
var
  Idx: integer;
begin
  Result := TListBox_DeleteSelected(_lst, Idx);
end;

procedure TListBox_UnselectAll(_lb: TCustomListbox);
var
  i: Integer;
begin
  for i := 0 to _lb.Items.count - 1 do
    _lb.Selected[i] := false;
end;

procedure TListbox_ClearWithObjects(_lst: TCustomListBox);
begin
  TStrings_FreeAllObjects(_lst.Items);
  _lst.Items.Clear;
end;

function TCheckListBox_GetCheckedCount(_clb: TCheckListBox): integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to _clb.Items.Count - 1 do
    if _clb.Checked[i] then
      Inc(Result);
end;

procedure TCheckListBox_CheckAll(_clb: TCheckListBox; _IncludeDisabled: boolean = false);
var
  i: Integer;
begin
  for i := 0 to _clb.Items.Count - 1 do
    _clb.Checked[i] := _IncludeDisabled or _clb.ItemEnabled[i];
end;

procedure TCheckListBox_UncheckAll(_clb: TCheckListBox);
var
  i: Integer;
begin
  for i := 0 to _clb.Items.Count - 1 do
    _clb.Checked[i] := False;
end;

procedure TCheckListBox_InvertCheckmarks(_clb: TCheckListBox; _IncludeDisabled: boolean = false);
var
  i: Integer;
begin
  for i := 0 to _clb.Items.Count - 1 do
    _clb.Checked[i] := not _clb.Checked[i] and (_IncludeDisabled or _clb.ItemEnabled[i]);
end;

procedure TCheckListBox_CheckSelected(_clb: TCheckListBox; _IncludeDisabled: boolean = false);
var
  i: Integer;
begin
  for i := 0 to _clb.Items.Count - 1 do
    if _clb.Selected[i] and (_IncludeDisabled or _clb.ItemEnabled[i]) then
      _clb.Checked[i] := true;
end;

procedure TCheckListBox_UncheckSelected(_clb: TCheckListBox; _IncludeDisabled: boolean = false);
var
  i: Integer;
begin
  for i := 0 to _clb.Items.Count - 1 do
    if _clb.Selected[i] and (_IncludeDisabled or _clb.ItemEnabled[i]) then
      _clb.Checked[i] := false;
end;

procedure TCheckListBox_DeleteDisabled(_clb: TCheckListBox);
var
  i: integer;
begin
  for i := _clb.Items.Count - 1 downto 0 do
    if not _clb.ItemEnabled[i] then
      _clb.Items.Delete(i);
end;

procedure TCheckListBox_SetCheckedNoClick(_clb: TCheckListBox; _Idx: integer; _Checked: boolean);
var
  Event: TNotifyEvent;
begin
  Event := _clb.OnClickCheck;
  _clb.OnClickCheck := nil;
  try
    _clb.Checked[_Idx] := _Checked;
  finally
    _clb.OnClickCheck := Event;
  end;
end;

function TCheckListBox_SetChecked(_clb: TCheckListBox; _Checked: TStrings;
  _UncheckOthers: boolean = true; _SuppressClick: boolean = false): integer;
var
  i: integer;
  Idx: integer;
begin
  Result := 0;
  for i := 0 to _clb.Items.Count - 1 do begin
    Idx := _Checked.IndexOf(_clb.Items[i]);
    if Idx <> -1 then begin
      Inc(Result);
      if _SuppressClick then
        TCheckListBox_SetCheckedNoClick(_clb, i, True)
      else
        _clb.Checked[i] := True;
    end else if _UncheckOthers then begin
      if _SuppressClick then
        TCheckListBox_SetCheckedNoClick(_clb, i, False)
      else
        _clb.Checked[i] := False;
    end;
  end;
end;

function TCheckListBox_GetChecked(_clb: TCheckListBox; _Checked: TStrings; _IncludeDisabled: boolean = false): integer;
var
  i: Integer;
begin
  for i := 0 to _clb.Items.Count - 1 do
    if _clb.Checked[i] and (_IncludeDisabled or _clb.ItemEnabled[i]) then
      _Checked.AddObject(_clb.Items[i], _clb.Items.Objects[i]);
  Result := _Checked.Count;
end;

function TCheckListBox_GetChecked(_clb: TCheckListbox; _IncludeDisabled: boolean = false): string; overload;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    TCheckListBox_GetChecked(_clb, sl, _IncludeDisabled);
    Result := StringReplace(sl.Text, #13#10, ',', [rfReplaceAll]);
  finally
    FreeAndNil(sl);
  end;
end;

function TCheckListBox_GetCheckedObjects(_clb: TCheckListBox; _Objects: TList; _IncludeDisabled: boolean = false): integer;
var
  i: Integer;
begin
  Assert(Assigned(_clb));
  Assert(Assigned(_Objects));

  for i := 0 to _clb.Items.Count - 1 do
    if _clb.Checked[i] and (_IncludeDisabled or _clb.ItemEnabled[i]) then
      _Objects.Add(_clb.Items.Objects[i]);
  Result := _Objects.Count;
end;

function TComboBox_Select(_cmb: TCustomComboBox; const _Item: string; _DefaultIdx: integer = -1): integer;
begin
  Result := _Cmb.Items.IndexOf(_Item);
  if Result = -1 then
    Result := _DefaultIdx;
  _Cmb.ItemIndex := Result;
end;

procedure TComboBox_SelectWithoutChangeEvent(_cmb: TComboBox; _Idx: integer);
var
  Event: TNotifyEvent;
begin
  Event := _cmb.OnChange;
  try
    _cmb.OnChange := nil;
    _cmb.ItemIndex := _Idx;
  finally
    _cmb.OnChange := Event;
  end;
end;

procedure TControl_SetReadonly(_ctrl: TControl; _ReadOnly: boolean);
var
  Panel: TPanel;
  comp: TComponent;
  PanelName: string;
begin
  if _ctrl.Name = '' then
    raise Exception.Create('Combobox must have a name to be set readonly');
  PanelName := 'p_dzVclUtils' + _ctrl.Name;
  comp := _ctrl.Owner.FindComponent(PanelName);
  if Assigned(comp) then begin
    if not (comp is TPanel) then
      raise Exception.Create(PanelName + ' is not a TPanel');
    Panel := comp as TPanel;
    if _ReadOnly then
      exit; // assume it is already readonly
    _ctrl.Parent := Panel.Parent;
    _ctrl.Top := Panel.Top;
    _ctrl.Left := Panel.Left;
    FreeAndNil(Panel);
    exit;
  end;
  if not _ReadOnly then
    exit; // assume it is not readonly

  Panel := TPanel.Create(_ctrl.Owner);
  Panel.Name := PanelName;
  Panel.Parent := _ctrl.Parent;
  Panel.Top := _ctrl.Top;
  Panel.Left := _ctrl.Left;
  Panel.Height := _ctrl.Height;
  Panel.Width := _ctrl.Width;
  Panel.BevelOuter := bvNone;
  _ctrl.Top := 0;
  _ctrl.Left := 0;
  _ctrl.Parent := Panel;
  Panel.Enabled := false;
end;

function TListBox_Select(_lb: TCustomListBox; const _Item: string; _DefaultIdx: integer = -1): integer;
begin
  Result := _lb.Items.IndexOf(_Item);
  if Result = -1 then
    Result := _DefaultIdx;
  _lb.ItemIndex := Result;
end;

type
  TRadioGroupHack = class(TCustomRadioGroup);

function TRadioGroup_GetItemCaption(_rg: TCustomRadioGroup;
  out _Caption: string; _Idx: integer = -1): boolean;
var
  Hack: TRadioGroupHack;
begin
  Hack := TRadioGroupHack(_rg);
  if _Idx = -1 then
    _Idx := Hack.ItemIndex;
  Result := (_Idx <> -1) and (_Idx < Hack.Items.Count);
  if Result then
    _Caption := StripHotKey(Hack.Items[_Idx]);
end;

function TRadioGroup_Select(_rg: TCustomRadioGroup; const _Item: string; _DefaultIdx: integer = -1): integer;
var
  Hack: TRadioGroupHack;
  i: Integer;
begin
  Hack := TRadioGroupHack(_rg);
  for i := 0 to Hack.Items.Count - 1 do
    if AnsiSameText(Hack.Items[i], _Item) then begin
      Hack.ItemIndex := i;
      Result := Hack.ItemIndex;
      exit;
    end;
  Hack.ItemIndex := _DefaultIdx;
  Result := Hack.ItemIndex;
end;

function TRadioGroup_GetSelectedObject(_rg: TCustomRadioGroup; out _Idx: integer; out _Obj: pointer): boolean;
var
  Hack: TRadioGroupHack;
begin
  Hack := TRadioGroupHack(_rg);
  _Idx := Hack.ItemIndex;
  Result := _Idx <> -1;
  if Result then
    _Obj := Hack.Items.Objects[_Idx];
end;

function TRichEdit_WriteToString(_Re: TRichEdit): string;
var
  st: TMemoryStream;
begin
  st := TMemoryStream.Create;
  try
    _Re.Lines.SaveToStream(st);
    Result := PChar(st.Memory);
  finally
    FreeAndNil(st);
  end;
end;

procedure TRichEdit_ReadFromString(_Re: TRichEdit; const _S: string);
var
  st: TMemoryStream;
begin
  st := TMemoryStream.Create;
  try
    st.Write(_s[1], Length(_s));
    st.Position := 0;
    _Re.Lines.LoadFromStream(st);
  finally
    FreeAndNil(st);
  end;
end;

function TPicture_WriteToString(_Pic: TPicture): string;
var
  st: TStringStream;
begin
  Result := '';
  st := TStringStream.Create('');
  try
    if Assigned(_Pic.Graphic) then begin
      Result := _Pic.Graphic.ClassName;
      _Pic.Graphic.SaveToStream(st);
      Result := Result + #26 + st.DataString;
    end
  finally
    FreeAndNil(st);
  end;
end;

procedure TPicture_ReadFromString(_Pic: TPicture; const _S: string);
var
  st: TStringStream;
  Klasse: string;
  Data: string;
  p: integer;
  GraphicClass: TGraphicClass;
  GraphicObj: TGraphic;
begin
  if _s = '' then
    exit;
  p := Pos(#26, _s);
  if p = 0 then
    exit;
  Klasse := LeftStr(_s, p - 1);
  Data := TailStr(_s, p + 1);

  st := TStringStream.Create(Data);
  try
    GraphicClass := GetFileFormats.FindClassName(Klasse);
    if GraphicClass <> nil then begin
      GraphicObj := GraphicClass.Create;
      GraphicObj.LoadFromStream(st);
      _Pic.Graphic := GraphicObj;
    end;
  finally
    FreeAndNil(st);
  end;
end;

function AddLabeledControl(_Idx: integer; const _Caption: string; _ctrl: TControl): TLabel;
begin
  Result := TLabel.Create(_ctrl.Owner);
  Result.Parent := _ctrl.Parent;
  Result.Left := 8;
  Result.Caption := _Caption;
  _ctrl.Top := _Idx * 24 + 16;
  Result.Top := _ctrl.Top + (_ctrl.Height - Result.Height) div 2;
end;

function CalcTextHeight(_Ctrl: TWinControl; const _Text: string; _Width: integer = -1): integer;
var
  Rect: TRect;
begin
  _Ctrl.HandleNeeded;
  Rect := _Ctrl.BoundsRect;
  if _Width <> -1 then
    Rect.Right := Rect.Left + _Width - 1;
  Result := DrawText(_Ctrl.Handle, PChar(_Text), Length(_Text), Rect,
    DT_LEFT or DT_WORDBREAK or DT_CALCRECT);
end;

type
  TGraphicControlHack = class(TGraphicControl)
  end;

function CalcTextHeight(_Ctrl: TGraphicControl; const _Text: string; _Width: integer = -1): integer; overload;
var
  Rect: TRect;
begin
  Rect := _Ctrl.BoundsRect;
  if _Width <> -1 then
    Rect.Right := Rect.Left + _Width - 1;
  Result := DrawText(TGraphicControlHack(_Ctrl).Canvas.Handle, PChar(_Text),
    Length(_Text), Rect, DT_LEFT or DT_WORDBREAK or DT_CALCRECT);
end;

type
  THackGrid = class(TCustomGrid);

function TStringGrid_IsScrollBarVisible(_Grid: TCustomGrid; _Code: integer): boolean;
var
  Min, Max: integer;
  Grid: THackGrid;
begin
  Result := false;
  if not _Grid.HandleAllocated then
    exit;
  Grid := THackGrid(_Grid);
  if (Grid.Scrollbars = ssBoth) or
    ((_Code = SB_HORZ) and (Grid.Scrollbars = ssHorizontal)) or
    ((_Code = SB_VERT) and (Grid.Scrollbars = ssVertical)) then begin
    GetScrollRange(_Grid.Handle, _Code, Min, Max);
    Result := Min <> Max;
  end;
end;

function GetApplicationPath: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
end;

function TRichEdit_RowToCharIndex(_Re: TRichEdit; _Row: integer): integer;
begin
  Result := _Re.Perform(EM_LINEINDEX, _Row, 0);
end;

function TRichEdit_CharIndexToRow(_Re: TRichEdit; _Idx: integer): integer;
begin
  Result := _Re.Perform(EM_LINEFROMCHAR, _Idx, 0);
end;

function TRichEdit_GetCurrentRow(_Re: TRichEdit): integer;
begin
  Result := TRichEdit_CharIndexToRow(_Re, _Re.SelStart);
end;

procedure TRichEdit_ScrollToCaret(_Re: TRichEdit);
begin
  _Re.Perform(EM_SCROLLCARET, 0, 0);
end;

procedure TRichEdit_WriteLn(_Re: TRichEdit; const _s: string; _Color: TColor = clBlack; _Style: TFontStyles = []);
begin
  _Re.SelAttributes.Color := _Color;
  _Re.SelAttributes.Style := _Style;
  _Re.Lines.Add(_s);
  _Re.SelAttributes.Color := clBlack;
  _Re.SelAttributes.Style := [];
end;

procedure TControl_Center(_Child: TControl; _Parent: TControl);
begin
  _child.left := (_parent.width - _child.width) div 2;
  _child.top := (_parent.height - _child.height) div 2;
end;

type
  THackCheckBox = class(TCustomCheckBox)
  end;

procedure TCheckBox_SetCheckedNoOnClick(_Chk: TCustomCheckBox; _Checked: boolean);
var
  Chk: THackCheckBox;
begin
  Chk := THackCheckBox(_Chk);
  Chk.ClicksDisabled := true;
  try
    Chk.Checked := _Checked;
  finally
    Chk.ClicksDisabled := false;
  end;
end;

procedure TForm_CenterOn(_frm: TForm; _Center: TPoint);
var
  Monitor: TMonitor;
begin
  _frm.Position := poDesigned;
  _frm.DefaultMonitor := dmDesktop;
  _frm.Left := _Center.X - _frm.Width div 2;
  _frm.Top := _Center.Y - _frm.Height div 2;
  Monitor := Screen.MonitorFromPoint(_Center);
  _frm.MakeFullyVisible(Monitor);
end;

procedure TForm_CenterOn(_frm: TForm; _Center: TWinControl); overload;
begin
  if Assigned(_Center) then begin
    if Assigned(_Center.Parent) then
      TForm_CenterOn(_frm, _Center.ClientToScreen(Point(_Center.Width div 2, _Center.Height div 2)))
    else
      TForm_CenterOn(_frm, Point(_Center.Left + _Center.Width div 2, _Center.Top + _Center.Height div 2));
  end else begin
    TForm_CenterOn(_frm, Point(Screen.Width div 2, Screen.Height div 2));
  end;
end;

function TWinControl_SetFocus(_Ctrl: TWinControl): boolean;
begin
  Result := _Ctrl.CanFocus;
  if Result then
    try
      _Ctrl.SetFocus;
    except
      Result := False;
    end;
end;

procedure DisableProcessWindowsGhosting;
var
  DisableProcessWindowsGhostingProc: procedure;
begin
  DisableProcessWindowsGhostingProc := GetProcAddress(
    GetModuleHandle('user32.dll'),
    'DisableProcessWindowsGhosting');
  if Assigned(DisableProcessWindowsGhostingProc) then
    DisableProcessWindowsGhostingProc;
end;

type
  PFileFormat = ^TFileFormat;
  TFileFormat = record
    GraphicClass: TGraphicClass;
    Extension: string;
    Description: string;
    DescResID: Integer;
  end;

constructor TFileFormatsList.Create;
begin
  inherited Create;
  Add('wmf', SVMetafiles, 0, TMetafile);
  Add('emf', SVEnhMetafiles, 0, TMetafile);
  Add('ico', SVIcons, 0, TIcon);
  Add('bmp', SVBitmaps, 0, TBitmap);
{$IFDEF GIFByRx}
  Add('gif', LoadStr(SGIFImage), 0, TGIFImage);
{$ENDIF GIFByRx}
  Add('jpg', _('JPEG Files'), 0, TJPEGImage);
end;

destructor TFileFormatsList.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Dispose(PFileFormat(Items[I]));
  inherited Destroy;
end;

procedure TFileFormatsList.Add(const Ext, Desc: string; DescID: Integer;
  AClass: TGraphicClass);
var
  NewRec: PFileFormat;
begin
  New(NewRec);
  with NewRec^ do begin
    Extension := AnsiLowerCase(Ext);
    GraphicClass := AClass;
    Description := Desc;
    DescResID := DescID;
  end;
  inherited Add(NewRec);
end;

function TFileFormatsList.FindExt(Ext: string): TGraphicClass;
var
  I: Integer;
begin
  Ext := AnsiLowerCase(Ext);
  for I := Count - 1 downto 0 do
    with PFileFormat(Items[I])^ do
      if Extension = Ext then begin
        Result := GraphicClass;
        Exit;
      end;
  Result := nil;
end;

function TFileFormatsList.GetFilterString(GraphicClass: TGraphicClass = nil): string;
var
  s: string;
begin
  if GraphicClass = nil then
    GraphicClass := TGraphic;
  BuildFilterStrings(GraphicClass, Result, s);
end;

function TFileFormatsList.FindClassName(const ClassName: string): TGraphicClass;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do begin
    Result := PFileFormat(Items[I])^.GraphicClass;
    if Result.ClassName = Classname then
      Exit;
  end;
  Result := nil;
end;

procedure TFileFormatsList.Remove(AClass: TGraphicClass);
var
  I: Integer;
  P: PFileFormat;
begin
  for I := Count - 1 downto 0 do begin
    P := PFileFormat(Items[I]);
    if P^.GraphicClass.InheritsFrom(AClass) then begin
      Dispose(P);
      Delete(I);
    end;
  end;
end;

procedure TFileFormatsList.BuildFilterStrings(GraphicClass: TGraphicClass;
  var Descriptions, Filters: string);
var
  C, I: Integer;
  P: PFileFormat;
begin
  Descriptions := '';
  Filters := '';
  C := 0;
  for I := Count - 1 downto 0 do begin
    P := PFileFormat(Items[I]);
    if P^.GraphicClass.InheritsFrom(GraphicClass) and (P^.Extension <> '') then
      with P^ do begin
        if C <> 0 then begin
          Descriptions := Descriptions + '|';
          Filters := Filters + ';';
        end;
        if (Description = '') and (DescResID <> 0) then
          Description := LoadStr(DescResID);
        FmtStr(Descriptions, '%s%s (*.%s)|*.%2:s', [Descriptions, Description, Extension]); // do not translate
        FmtStr(Filters, '%s*.%s', [Filters, Extension]); // do not translate
        Inc(C);
      end;
  end;
  if C > 1 then
    FmtStr(Descriptions, '%s (%s)|%1:s|%s', [sAllFilter, Filters, Descriptions]); // do not translate
end;

var
  FileFormats: TFileFormatsList = nil;

function GetFileFormats: TFileFormatsList;
begin
  if FileFormats = nil then
    FileFormats := TFileFormatsList.Create;
  Result := FileFormats;
end;

procedure TMemo_DeleteTopLines(_Memo: TMemo; _Retain: integer);
const
  EmptyStr: PChar = '';
var
  Offset: Integer;
  cnt: Integer;
begin
  cnt := _Memo.Lines.Count;
  if cnt <= _Retain then
    Exit;
  Dec(cnt, _Retain);

  Offset := SendMessage(_Memo.Handle, EM_LINEINDEX, cnt - 1, 0);
  if (Offset < 0) or (cnt = 0) then
    Offset := SendMessage(_Memo.Handle, EM_LINELENGTH, 0, 0);
  SendMessage(_Memo.Handle, EM_SETSEL, 0, Offset);
  SendMessage(_Memo.Handle, EM_REPLACESEL, 0, Longint(EmptyStr));
end;

function TMemo_GetCursorPos(_Memo: TMemo): integer;
begin
  SendMessage(_Memo.Handle, EM_GETSEL, integer(@Result), 0);
end;

procedure TMemo_SetCursorPos(_Memo: TMemo; _CharIdx: integer);
begin
  SendMessage(_Memo.Handle, EM_SETSEL, _CharIdx, _CharIdx);
  TMemo_ScrollToCursorPos(_Memo);
end;

procedure TMemo_ScrollToCursorPos(_Memo: TMemo);
begin
  SendMessage(_Memo.Handle, EM_SCROLLCARET, 0, 0);
end;

procedure TMemo_ScrollToEnd(_Memo: TMemo);
var
  cnt: Integer;
begin
  cnt := SendMessage(_Memo.Handle, EM_GETLINECOUNT, 0, 0);
  SendMessage(_Memo.Handle, EM_LINESCROLL, 0, cnt);
end;

function TApplication_GetExePath: string;
begin
  Result := ExtractFilePath(Application.ExeName);
end;

function TApplication_HasVersionInfo: boolean;
var
  Handle: THandle;
  Size: DWORD;
begin
  Size := GetFileVersionInfoSize(PChar(Application.ExeName), Handle);
  Result := Size <> 0;
end;

type
  TControlHack = class(TCustomControl);

procedure MergeForm(AControl: TWinControl; AForm: TForm; Align: TAlign; Show: Boolean);
var
  R: TRect;
  AutoScroll: Boolean;
begin
  AutoScroll := AForm.AutoScroll;
  AForm.Hide;
  TControlHack(AForm).DestroyHandle;
  with AForm do begin
    BorderStyle := bsNone;
    BorderIcons := [];
    Parent := AControl;
  end;
  AControl.DisableAlign;
  try
    if Align <> alNone then
      AForm.Align := Align
    else begin
      R := AControl.ClientRect;
      AForm.SetBounds(R.Left + AForm.Left, R.Top + AForm.Top, AForm.Width,
        AForm.Height);
    end;
    AForm.AutoScroll := AutoScroll;
    AForm.Visible := Show;
  finally
    AControl.EnableAlign;
  end;
end;

procedure UnMergeForm(_Form: TCustomForm);
begin
  _Form.Hide;
  TControlHack(_Form).DestroyHandle;
  _Form.Parent := nil;
end;

procedure TListView_ClearWithObjects(_lv: TListView);
var
  i: Integer;
begin
  for i := 0 to _lv.Items.Count - 1 do begin
    TObject(_lv.Items[i].Data).Free;
    _lv.Items[i].Data := nil;
  end;
  _lv.Clear;
end;

function TRadioGroup_GetButton(_rg: TRadioGroup; _ItemIdx: integer): TRadioButton;
// taken from http://delphi.about.com/od/adptips2006/qt/radiogroupbtns.htm
begin
  if (_ItemIdx < 0) or (_ItemIdx >= _rg.Items.Count) then
    Result := nil
  else
    Result := _rg.Controls[_ItemIdx] as TRadioButton;
end;

function TRadioGroup_GetButton(_rg: TRadioGroup; _ItemText: string): TRadioButton;
// taken from http://delphi.about.com/od/adptips2006/qt/radiogroupbtns.htm
var
  cnt: integer;
  Idx: integer;
begin
  Idx := -1;
  for cnt := 0 to -1 + _rg.Items.Count do begin
    if _rg.Items[cnt] = _ItemText then begin
      Idx := cnt;
      break;
    end;
  end;
  Result := TRadioGroup_GetButton(_rg, Idx);
end;

type
  THackButtonControl = class(TButtonControl)
  end;

function TButtonControl_GetChecked(_bctrl: TButtonControl): boolean;
begin
  Result := THackButtonControl(_bctrl).Checked;
end;

procedure TButtonControl_SetChecked(_bctrl: TButtonControl; _Value: boolean);
begin
  THackButtonControl(_bctrl).Checked := _Value;
end;

procedure TButtonControl_SetCaption(_bctrl: TButtonControl; _Value: string);
begin
  THackButtonControl(_bctrl).Caption := _Value;
end;

procedure TListView_UnselectAll(_lv: TListView; _WithSelectEvents: boolean = true);
var
  i: Integer;
  Event: TLVSelectItemEvent;
begin
  Event := _lv.OnSelectItem;
  if not _WithSelectEvents then
    _lv.OnSelectItem := nil;
  try
    for i := 0 to _lv.Items.Count - 1 do
      _lv.Items[i].Selected := false;
  finally
    _lv.OnSelectItem := Event;
  end;
end;

function TListView_GetSelectedCount(_lv: TListView): integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to _lv.Items.Count - 1 do
    if _lv.Items[i].Selected then
      Inc(Result);
end;

function TAction_SetCheckedExecute(_act: TCustomAction; _Checked: boolean): boolean;
begin
  Result := _act.Checked <> _Checked;
  if Result then
    Result := _act.Execute;
end;

function TStatusBar_GetClickedPanel(_sb: TStatusBar): integer;
// call this to determine which panel of a TStatusBar has been clicked
// Note: This assumes, that the status bar actually was clicked, so only call it
//       from the status bar's OnClick, OnMouseDown or OnMouseUp event handlers
// If the status bar does not have any panels (e.g. SimplePanel=true), this function
// will return 0.
var
  mpt: TPoint;
  x: Integer;
  j: Integer;
  cnt: Integer;
begin
  cnt := _sb.Panels.Count;
  if _sb.SimplePanel then
    cnt := 0;

  mpt := _sb.ScreenToClient(Mouse.CursorPos);

  Result := -1;
  x := 0;
  for j := 0 to cnt - 1 do begin
    x := x + _sb.Panels[j].Width;
    if mpt.X < x then begin
      Result := j;
      Break;
    end;
  end;

  //clicked "after" the last panel -
  //fake it as if the last one was clicked
  if Result = -1 then
    Result := _sb.Panels.Count - 1;
end;

{ TLongSimpleTextStatusBar }

function TLongSimpleTextStatusBar.GetSimpleText: string;
begin
  Result := inherited SimpleText;
end;

procedure TLongSimpleTextStatusBar.SetSimpleText(const Value: string);
begin
  TStatusBar_SetLongSimpleText(Self, Value);
end;

type
  TCursorRestorer = class(TInterfacedObject, IInterface)
  private
    FOldCursor: TCursor;
    constructor Create(_NewCursor: TCursor);
    destructor Destroy; override;
  end;

{ TCursorRestorer }

constructor TCursorRestorer.Create(_NewCursor: TCursor);
begin
  inherited Create;
  FOldCursor := Screen.Cursor;
  Screen.Cursor := _NewCursor;
end;

destructor TCursorRestorer.Destroy;
begin
  Screen.Cursor := FOldCursor;
  inherited;
end;

function TCursor_TemporaryChange(_NewCursor: TCursor = crHourGlass): IInterface;
begin
  Result := TCursorRestorer.Create(_NewCursor);
end;

type
  TWinControlLocker = class(TInterfacedObject, IInterface)
  private
    FCtrl: TWinControl;
  public
    constructor Create(_Ctrl: TWinControl);
    destructor Destroy; override;
  end;

function TWinControl_Lock(_Ctrl: TWinControl): IInterface;
begin
  Result := TWinControlLocker.Create(_Ctrl);
end;

{ TWinControlLocker }

constructor TWinControlLocker.Create(_Ctrl: TWinControl);
begin
  inherited Create;
  FCtrl := _Ctrl;
  SendMessage(FCtrl.Handle, WM_SETREDRAW, integer(LongBool(false)), 0);
end;

destructor TWinControlLocker.Destroy;
begin
  SendMessage(FCtrl.Handle, WM_SETREDRAW, integer(LongBool(true)), 0);
  RedrawWindow(FCtrl.Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_ALLCHILDREN);
  inherited;
end;

type
  TCheckListBoxHelper = class
  private
    procedure HandleClickCheck(_Sender: TObject);
  end;

var
  gblCheckListBoxHelper: TCheckListBoxHelper = nil;

procedure TCheckListBox_Readonly(_clb: TCheckListBox; _ReadOnly: boolean; _ChangeColor: boolean = true);
begin
  if _ReadOnly then begin
    if not Assigned(gblCheckListBoxHelper) then
      gblCheckListBoxHelper := TCheckListBoxHelper.Create;
    _clb.OnClickCheck := gblCheckListBoxHelper.HandleClickCheck;
    if _ChangeColor then
      _clb.Color := clBtnFace;
  end else begin
    _clb.OnClickCheck := nil;
    if _ChangeColor then
      _clb.Color := clWindow;
  end;
end;

procedure TCheckListBoxHelper.HandleClickCheck(_Sender: TObject);
var
  clb: TCheckListBox;
  Idx: integer;
begin
  clb := _Sender as TCheckListBox;
  Idx := clb.ItemIndex;
  if Idx <> -1 then begin
    clb.Checked[Idx] := not clb.Checked[Idx];
  end;
end;

{$IFDEF DELPHI2009_UP}
{ TdzButtonedEdit }

procedure TdzButtonedEdit.KeyDown(var _Key: Word; _Shift: TShiftState);
begin
  inherited;
  if (_Key = VK_RETURN) and (ssCtrl in _Shift) then
    OnRightButtonClick(Self);
end;

procedure TdzButtonedEdit.Loaded;
begin
  inherited;
  if RightButton.Visible and (RightButton.Hint = '') then begin
    RightButton.Hint := _('Ctrl+Return to ''click'' right button.');
    ShowHint := true;
  end;
end;
{$ENDIF DELPHI2009_UP}

initialization
finalization
  FreeAndNil(gblCheckListBoxHelper);
end.

