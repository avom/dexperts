unit Dexperts.TestRunner.Status;

interface

uses
  System.Classes,
  Dexperts.TestRunner.Interfaces;

type
  TStatus = class(TInterfacedObject, IStatus)
  private const
    StateNames: array[TTestingState] of string = ('Configuration missing', 'Waiting',
      'Test project not defined','Compiling', 'Compile failed', 'Testing', 'Tests passed',
      'Tests failed');
  private
    FLock: TObject;
    FState: TTestingState;
    FFailedTests: TArray<string>;
    FOnChanged: TNotifyEvent;
    class var FInstance: TStatus;
    function GetName: string;
    class constructor CreateClass;
    class destructor DestroyClass;
    function GetState: TTestingState;
    function GetOnChanged: TNotifyEvent;
    procedure SetOnChanged(const Value: TNotifyEvent);
    procedure NotifyChanged;
    function GetFailedTests: TArray<string>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ConfigurationMissing;
    procedure Wait;
    procedure MissingTestProject;
    procedure Compile;
    procedure CompileSucceeded;
    procedure CompileFailed;
    procedure TestsSucceeded;
    procedure TestsFailed(const FailedTests: TArray<string>);

    property Name: string read GetName;
    property State: TTestingState read GetState;
    property FailedTests: TArray<string> read GetFailedTests;

    property OnChanged: TNotifyEvent read GetOnChanged write SetOnChanged;

    class property Instance: TStatus read FInstance;
  end;

implementation

{ TStatus }

procedure TStatus.Compile;
begin
  TMonitor.Enter(FLock);
  try
    FState := TTestingState.Compiling;
  finally
    TMonitor.Exit(FLock);
  end;
  NotifyChanged;
end;

procedure TStatus.CompileFailed;
begin
  TMonitor.Enter(FLock);
  try
    FState := TTestingState.CompileFailed;
  finally
    TMonitor.Exit(FLock);
  end;
  NotifyChanged;
end;

procedure TStatus.CompileSucceeded;
begin
  TMonitor.Enter(FLock);
  try
    FState := TTestingState.Testing;
  finally
    TMonitor.Exit(FLock);
  end;
  NotifyChanged;
end;

procedure TStatus.ConfigurationMissing;
begin
  TMonitor.Enter(FLock);
  try
    FState := TTestingState.ConfigMissing;
  finally
    TMonitor.Exit(FLock);
  end;
end;

constructor TStatus.Create;
begin
  FLock := TObject.Create;
  FState := TTestingState.Waiting;
end;

class constructor TStatus.CreateClass;
begin
  FInstance := TStatus.Create;
end;

destructor TStatus.Destroy;
begin
  FLock.Free;
  inherited;
end;

class destructor TStatus.DestroyClass;
begin
  FInstance.Free;
end;

function TStatus.GetFailedTests: TArray<string>;
begin
  TMonitor.Enter(FLock);
  try
    Result := Copy(FFailedTests);
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TStatus.GetName: string;
begin
  TMonitor.Enter(FLock);
  try
    Result := StateNames[FState];
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TStatus.GetOnChanged: TNotifyEvent;
begin
  TMonitor.Enter(FLock);
  try
    Result := FOnChanged;
  finally
    TMonitor.Exit(FLock);
  end;
end;

function TStatus.GetState: TTestingState;
begin
  TMonitor.Enter(FLock);
  try
    Result := FState;
  finally
    TMonitor.Exit(FLock);
  end;
end;

procedure TStatus.MissingTestProject;
begin
  TMonitor.Enter(FLock);
  try
    FState := TTestingState.Missing;
  finally
    TMonitor.Exit(FLock);
  end;
  NotifyChanged;
end;

procedure TStatus.NotifyChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TStatus.SetOnChanged(const Value: TNotifyEvent);
begin
  TMonitor.Enter(FLock);
  try
    FOnChanged := Value;
  finally
    TMonitor.Exit(FLock);
  end;
end;

procedure TStatus.TestsFailed(const FailedTests: TArray<string>);
begin
  TMonitor.Enter(FLock);
  try
    FState := TTestingState.TestsFailed;
    FFailedTests := Copy(FailedTests);
  finally
    TMonitor.Exit(FLock);
  end;
  NotifyChanged;
end;

procedure TStatus.TestsSucceeded;
begin
  TMonitor.Enter(FLock);
  try
    FState := TTestingState.TestsPassed;
  finally
    TMonitor.Exit(FLock);
  end;
  NotifyChanged;
end;

procedure TStatus.Wait;
begin
  TMonitor.Enter(FLock);
  try
    FState := TTestingState.Waiting;
  finally
    TMonitor.Exit(FLock);
  end;
  NotifyChanged;
end;

end.
