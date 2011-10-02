{: If this unit is included in a multithreaded program, it will set the
   name for the main thread to 'Main' (also does this for single threaded
   programs but it doesn't make that much sense there).
   Also it declares a TNamedThread type that uses its class name for the thread
   name. Make sure to override this if there are multiple instances of this class.
   If you do not want to derive from TNamedThread, just call SetThreadName from
   your thread's execute procedure. }
unit u_dzNamedThread;

interface

uses
  Classes,
  Windows;

type
  {: This record must be filled to set the name of a thread }
  TThreadNameInfo = record
    FType: LongWord; // must be 0x1000
    FName: PChar; // pointer to name (in user address space)
    FThreadID: LongWord; // thread ID (-1 indicates caller thread)
    FFlags: LongWord; // reserved for future use, must be zero
  end;

{: Set the name for the current thread to
   @param Name is a string with the name to use }
procedure SetThreadName(const _Name: string);

type
  {: A TThread that sets its name to its class name. Make sure you call
     inherited Execute in descendants! }
  TNamedThread = class(TThread)
  protected
    FThreadName: string;
    {: Calls SetThreadName with the given name or the class name if empty
       @param Name is the name to use, if empty, the class name will be used }
    procedure SetName(const _Name: string = ''); virtual;
    {: Calls SetName }
    procedure Execute; override;
    function GetThreadName: string;
  end;

implementation

procedure SetThreadName(const _Name: string);
var
  ThreadNameInfo: TThreadNameInfo;
begin
  ThreadNameInfo.FType := $1000;
  ThreadNameInfo.FName := PChar(_Name);
  ThreadNameInfo.FThreadID := $FFFFFFFF;
  ThreadNameInfo.FFlags := 0;
  try
    RaiseException($406D1388, 0, SizeOf(ThreadNameInfo) div SizeOf(LongWord), @ThreadNameInfo);
  except
    // ignore
  end;
end;

{ TNamedThread }

procedure TNamedThread.Execute;
begin
  SetName();
end;

function TNamedThread.GetThreadName: string;
begin
  Result := FThreadName;
end;

procedure TNamedThread.SetName(const _Name: string = '');
begin
  if _Name = '' then
    FThreadName := ClassName
  else
    FThreadName := _Name;
  SetThreadName(FThreadName);
end;

initialization
  // set the name for the main thread to 'Main'
  SetThreadName('Main');
end.

