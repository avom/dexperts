unit Dexperts.TestRunner.AutoTester;

interface

uses
  Dexperts.Common.ProjectSettings,
  Dexperts.TestRunner.Compiler,
  Dexperts.TestRunner.Interfaces,
  Dexperts.TestRunner.Status;

type
  TAutoTester = class
  private
    FCompiler: ICompiler;
    FDirectoryWatcher: IDirectoryWatcher;
    FSettings: TProjectSettings;
    FStatus: TStatus;
    FTestRunner: ITestRunner;
    FRunLock: TObject;
    FQueueLock: TObject;
    FStopped: Boolean;
    FIsTestingQueued: Boolean;
    FIsTestingPaused: Boolean;
    procedure SetIsTestingQueued(Value: Boolean);
    procedure BuildAndTest;
    procedure OnDirectoryChange(Sender: TObject);
    class var FInstance: TAutoTester;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  public
    constructor Create(
      const DirectoryWatcher: IDirectoryWatcher;
      const Compiler: ICompiler;
      const TestRunner: ITestRunner);
    destructor Destroy; override;

    procedure Start(Settings: TProjectSettings; Status: TStatus);
    procedure Stop;
    procedure Restart(Settings: TProjectSettings; Status: TStatus);

    procedure Pause;
    procedure Unpause;

    procedure QueueTesting;

    class property Instance: TAutoTester read FInstance;
  end;

implementation

uses
  System.Classes,
  Dexperts.TestRunner.DirectoryWatcher,
  Dexperts.TestRunner.DUnitXRunner,
  Dexperts.TestRunner.ProcessRunner;

{ TAutoTester }

procedure TAutoTester.BuildAndTest;
begin
  if not (FStatus.State in [TTestingState.Waiting, TTestingState.CompileFailed,
    TTestingState.TestsPassed, TTestingState.TestsFailed]) then
    Exit;

  FStatus.Compile;
  var Project := FSettings.AutoTest.TestProject;
  var CompileResult := FCompiler.Compile(Project.Dproj, Project.CompileCommands);
  if CompileResult then
  begin
    FStatus.CompileSucceeded;
    var Errors := FTestRunner.Run(FSettings.AutoTest.TestProject.Exe);
    if Errors = nil then
      FStatus.TestsSucceeded
    else
      FStatus.TestsFailed(Errors);
  end
  else
    FStatus.CompileFailed;
end;

class constructor TAutoTester.ClassCreate;
begin
  FInstance := TAutoTester.Create(
    TDirectoryWatcher.Create,
    TCompiler.Create(TProcessRunner.Create),
    TDUnitXRunner.Create(TProcessRunner.Create));
end;

class destructor TAutoTester.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TAutoTester.Create(
  const DirectoryWatcher: IDirectoryWatcher;
  const Compiler: ICompiler;
  const TestRunner: ITestRunner);
begin
  Assert(DirectoryWatcher <> nil, 'DirectoryWatcher');
  Assert(Compiler <> nil, 'Compiler');
  Assert(TestRunner <> nil, 'TestRunner');

  FDirectoryWatcher := DirectoryWatcher;
  FCompiler := Compiler;
  FTestRunner := TestRunner;

  FDirectoryWatcher.OnChange := OnDirectoryChange;

  FRunLock := TObject.Create;
  FQueueLock := TObject.Create;
end;

destructor TAutoTester.Destroy;
begin
  FDirectoryWatcher.OnChange := nil;
  Stop;
  TMonitor.Enter(FRunLock);
  TMonitor.Exit(FRunLock);
  FRunLock.Free;
  FQueueLock.Free;
  inherited;
end;

procedure TAutoTester.OnDirectoryChange(Sender: TObject);
begin
  QueueTesting;
end;

procedure TAutoTester.Pause;
begin
  FIsTestingPaused := True;
end;

procedure TAutoTester.QueueTesting;
begin
  SetIsTestingQueued(True);
end;

procedure TAutoTester.Restart(Settings: TProjectSettings; Status: TStatus);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      Stop;
      Start(Settings, FStatus);
    end);
end;

procedure TAutoTester.Stop;
begin
  FStopped := True;
  FDirectoryWatcher.Terminate;
end;

procedure TAutoTester.Unpause;
begin
  FIsTestingPaused := False;
end;

procedure TAutoTester.SetIsTestingQueued(Value: Boolean);
begin
  TMonitor.Enter(FQueueLock);
  try
    FIsTestingQueued := Value;
  finally
    TMonitor.Exit(FQueueLock);
  end;
end;

procedure TAutoTester.Start(Settings: TProjectSettings; Status: TStatus);
begin
  TMonitor.Enter(FRunLock);
  try
    FStopped := False;
    FSettings := Settings;
    FStatus := Status;
    FStatus.Wait;

    BuildAndTest;

    TThread.CreateAnonymousThread(
      procedure
      begin
        FDirectoryWatcher.Watch(FSettings.AutoTest.WatchPaths);
      end).Start;

    while not FStopped do
    begin
      if FIsTestingQueued and (not FIsTestingPaused) then
      begin
        BuildAndTest;
        SetIsTestingQueued(False);
      end;
      TThread.Sleep(Settings.AutoTest.TestQueuePeekIntervalMs);
    end;
  finally
    TMonitor.Exit(FRunLock);
  end;
end;

end.
