unit u_dzBeep;

interface

uses
  Windows,
  SysUtils,
  SyncObjs,
  u_dzNamedThread;

type
  TBeepSequenceEntry = record
    Frequency: Cardinal;
    Duration: Cardinal;
    class function Create(_Frequency, _Duration: Cardinal): TBeepSequenceEntry; static;
    procedure Init(_Frequency, _Duration: Cardinal); // inline does not work!
  end;

  TBeepSequenceList = array of TBeepSequenceEntry;

  ///<summary> Windows.Beep is synchronous, so it does not return until
  ///          the beep's duration has passed. This is a problem if you
  ///          cannot afford to block the current thread that long.
  ///          This class creates a thread (singleton) that does the
  ///          call for other threads. Note that I have not put much
  ///          work into making it really threadsafe, I rely on
  ///          writes to DWords being atomic operations and just
  ///          use two fields to pass the parameters. It is quite
  ///          possible for other threads to change these parameters
  ///          before they ever reach the Beeper thread, but all that
  ///          would cause is some weird beeping, so I can't be bothered.
  TBeeper = class(TNamedThread)
  private
    FSequence: array of TBeepSequenceEntry;
    FEvent: TEvent;
    FMutex: TMutex;
    procedure Terminate;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Beep(_Frequency, _Duration: Cardinal); overload;
    procedure Beep(_Sequence: array of TBeepSequenceEntry); overload;
  end;

var
  Beeper: TBeeper = nil;

implementation

{ TBeeper }

procedure TBeeper.Beep(_Frequency, _Duration: Cardinal);
begin
  Beep([TBeepSequenceEntry.Create(_Frequency, _Duration)]);
end;

procedure TBeeper.Beep(_Sequence: array of TBeepSequenceEntry);
var
  i: Integer;
begin
  // only beep if no other beep is active
  // protect the beep sequence
  if FMutex.WaitFor(0) = wrSignaled then begin
    try
      SetLength(FSequence, Length(_Sequence));
      for i := Low(_Sequence) to High(_Sequence) do
        FSequence[i] := _Sequence[i];
      FEvent.SetEvent;
    finally
      FMutex.Release;
    end;
  end;
end;

constructor TBeeper.Create;
begin
  FMutex := TMutex.Create;
  FEvent := TEvent.Create;
  inherited Create(false);
end;

destructor TBeeper.Destroy;
begin
  Terminate;
  inherited;
  FreeAndNil(FEvent);
  FreeAndNil(FMutex);
end;

procedure TBeeper.Execute;
var
  wr: TWaitResult;
  i: integer;
begin
  inherited;
  while not Terminated do begin
    wr := FEvent.WaitFor(INFINITE);
    if Terminated or (wr <> wrSignaled) then
      Exit; // --->
    // protecte the sequence
    // If we can't get the mutex, we set a new sequence
    if FMutex.WaitFor(0) = wrSignaled then begin
      try
        for i := Low(FSequence) to High(FSequence) do begin
          if FSequence[i].Frequency = 0 then
            Sleep(FSequence[i].Duration)
          else if FSequence[i].Frequency < 37 then
            Windows.Beep(37, FSequence[i].Duration)
          else if FSequence[i].Frequency > 32767 then begin
            Windows.Beep(32767, FSequence[i].Duration);
          end else
            Windows.Beep(FSequence[i].Frequency, FSequence[i].Duration);
        end;
      finally
        FMutex.Release;
      end;
    end;
    FEvent.ResetEvent;
  end;
end;

procedure TBeeper.Terminate;
begin
  inherited Terminate;
  FEvent.SetEvent;
  WaitFor;
end;

{ TBeepSequenceEntry }

class function TBeepSequenceEntry.Create(_Frequency, _Duration: Cardinal): TBeepSequenceEntry;
begin
  Result.Init(_Frequency, _Duration);
end;

procedure TBeepSequenceEntry.Init(_Frequency, _Duration: Cardinal);
begin
  Frequency := _Frequency;
  Duration := _Duration;
end;

initialization
  Beeper := TBeeper.Create;

finalization
  if Assigned(Beeper) then begin
    Beeper.Terminate;
    FreeAndNil(Beeper);
  end;
end.

