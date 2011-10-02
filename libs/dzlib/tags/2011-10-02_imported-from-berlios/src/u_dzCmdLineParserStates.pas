unit u_dzCmdLineParserStates;

interface

uses
  u_dzCmdLineParser;

type
  TEngineStateAbstract = class(TInterfacedObject)
  private
    function GetClassName: string;
  end;

type
  TEngineStateError = class(TEngineStateAbstract, IEngineState)
  private
    FError: string;
    function Execute(const _Context: IEngineContext): IEngineState;
  public
    constructor Create(const _Error: string);
  end;

type
  TEngineStateSpace = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

type
  TEngineStateDash = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

type
  TEngineStateDoubleDash = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

type
  TEngineStateLongOption = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

type
  TEngineStateShortOption = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

type
  TEngineStateShortSwitch = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

type
  TEngineStateShortParam = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

type
  TEngineStateQuotedShortParam = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

type
  TEngineStateLongParam = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

type
  TEngineStateQuotedLongParam = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

type
  TEngineStateParam = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

type
  TEngineStateQuotedParam = class(TEngineStateAbstract, IEngineState)
  private
    function Execute(const _Context: IEngineContext): IEngineState;
  public
  end;

implementation

uses
  SysUtils,
  u_dzStringUtils;

{ TEngineStateAbstract }

function TEngineStateAbstract.GetClassName: string;
begin
  Result := ClassName;
end;

{ TEngineStateError }

constructor TEngineStateError.Create(const _Error: string);
begin
  inherited Create;
  FError := _Error;
end;

function TEngineStateError.Execute(const _Context: IEngineContext): IEngineState;
begin
  raise EStateEngineError.Create(FError);
end;

{ TEngineStateSpace }

function TEngineStateSpace.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  case c of
    '-':
      Result := TEngineStateDash.Create;
    #0:
      Result := nil; // end state
    '"': begin
        _Context.AddToParameter(c);
        Result := TEngineStateQuotedParam.Create;
      end;
    ' ':
      Result := self;
  else
    _Context.AddToParameter(c);
    Result := TEngineStateParam.Create;
  end;
end;

{ TEngineStateParam }

function TEngineStateParam.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  case c of
    '"': begin
        _Context.AddToParameter(c);
        Result := TEngineStateQuotedParam.Create;
      end;
    #0, ' ': begin
        _Context.HandleCmdLinePart;
        Result := TEngineStateSpace.Create;
      end;
  else
    _Context.AddToParameter(c);
    Result := Self;
  end;
end;

{ TEngineStateQuotedParam }

function TEngineStateQuotedParam.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  case c of
    '"': begin
        _Context.AddToParameter(c);
        Result := TEngineStateParam.Create;
      end;
    #0:
      Result := TEngineStateError.Create(Format('Invalid character "%s".', [c]));
  else
    _Context.AddToParameter(c);
    Result := self;
  end;
end;

{ TEngineStateDash }

function TEngineStateDash.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  if CharInSet(c, ALPHANUMERIC_CHARS + ['?']) then begin
    _Context.AddToOption(c);
    Result := TEngineStateShortOption.Create;
  end else if c = '-' then
    Result := TEngineStateDoubleDash.Create
  else
    Result := TEngineStateError.Create(Format('Invalid character "%s".', [c]));
end;

{ TEngineStateDoubleDash }

function TEngineStateDoubleDash.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  if CharInSet(c, ALPHANUMERIC_CHARS) then begin
    _Context.AddToOption(c);
    Result := TEngineStateLongOption.Create;
  end else
    Result := TEngineStateError.Create(Format('Invalid character "%s".', [c]));
end;

{ TEngineStateShortOption }

function TEngineStateShortOption.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  case c of
    ' ': begin
        Result := TEngineStateShortParam.Create;
      end;
    '-', '+': begin
        _Context.AddToParameter(c);
        Result := TEngineStateShortSwitch.Create;
      end;
    #0: begin
        _Context.HandleCmdLinePart;
        Result := TEngineStateSpace.Create;
      end;
  else
    Result := TEngineStateError.Create(Format('Invalid character "%s".', [c]));
  end;
end;

{ TEngineStateShortSwitch }

function TEngineStateShortSwitch.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  case c of
    ' ', #0: begin
        _Context.HandleCmdLinePart;
        Result := TEngineStateSpace.Create;
      end else
    Result := TEngineStateError.Create(Format('Invalid character "%s".', [c]));
  end;
end;

{ TEngineStateShortParam }

function TEngineStateShortParam.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  case c of
    ' ', #0: begin
        _Context.HandleCmdLinePart;
        Result := TEngineStateSpace.Create;
      end;
    '"': begin
        _Context.AddToParameter(c);
        Result := TEngineStateQuotedShortParam.Create;
      end;
    '-': begin
        _Context.HandleCmdLinePart;
        Result := TEngineStateDash.Create;
      end;
  else
    _Context.AddToParameter(c);
    Result := self;
  end;
end;

{ TEngineStateQuotedShortParam }

function TEngineStateQuotedShortParam.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  case c of
    '"': begin
        _Context.AddToParameter(c);
        Result := TEngineStateShortParam.Create;
      end;
    #0:
      Result := TEngineStateError.Create(Format('Invalid character "%s".', [c]));
  else
    _Context.AddToParameter(c);
    Result := self;
  end;
end;

{ TEngineStateLongOption }

function TEngineStateLongOption.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  case c of
    '=':
      Result := TEngineStateLongParam.Create;
    ' ', #0: begin
        _Context.HandleCmdLinePart;
        Result := TEngineStateSpace.Create;
      end;
    '"', '''':
      Result := TEngineStateError.Create(Format('Invalid character "%s".', [c]));
  else
    _Context.AddToOption(c);
    Result := TEngineStateLongOption.Create;
  end;
end;

{ TEngineStateLongParam }

function TEngineStateLongParam.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  case c of
    '"': begin
        _Context.AddToParameter(c);
        Result := TEngineStateQuotedLongParam.Create;
      end;
    ' ', #0: begin
        _Context.HandleCmdLinePart;
        Result := TEngineStateSpace.Create;
      end;
  else
    _Context.AddToParameter(c);
    Result := TEngineStateLongParam.Create;
  end;
end;

{ TEngineStateQuotedLongParam }

function TEngineStateQuotedLongParam.Execute(const _Context: IEngineContext): IEngineState;
var
  c: char;
begin
  c := _Context.GetNextChar;
  case c of
    '"': begin
        _Context.AddToParameter(c);
        Result := TEngineStateLongParam.Create;
      end;
    #0:
      Result := TEngineStateError.Create(Format('Invalid character "%s".', [c]));
  else
    _Context.AddToParameter(c);
    Result := TEngineStateQuotedLongParam.Create;
  end;
end;

end.
