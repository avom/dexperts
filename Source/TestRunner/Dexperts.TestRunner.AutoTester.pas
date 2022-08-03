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
    class var FInstance: TAutoTester;
    procedure BuildAndTest;
    procedure OnDirectoryChange(Sender: TObject);
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

    class property Instance: TAutoTester read FInstance;
  end;

implementation

uses
  Dexperts.TestRunner.DirectoryWatcher,
  Dexperts.TestRunner.DUnitXRunner;

{ TAutoTester }

procedure TAutoTester.BuildAndTest;
begin
  if not (FStatus.State in [TTestingState.Waiting, TTestingState.CompileFailed,
    TTestingState.TestsPassed, TTestingState.TestsFailed]) then
    Exit;

  FStatus.Compile;
  var Project := FSettings.AutoTest.TestProject;
  var CompileResult := FCompiler.Compile(Project.Dproj, Project.RsVarsPath, Project.MsBuildArgs);
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
  FInstance := TAutoTester.Create(TDirectoryWatcher.Create, TCompiler.Create, TDUnitXRunner.Create);
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
end;

destructor TAutoTester.Destroy;
begin
  FDirectoryWatcher.OnChange := nil;
  inherited;
end;

procedure TAutoTester.OnDirectoryChange(Sender: TObject);
begin
  BuildAndTest;
end;

procedure TAutoTester.Stop;
begin
  FDirectoryWatcher.Terminate;
end;

procedure TAutoTester.Start(Settings: TProjectSettings; Status: TStatus);
begin
  FSettings := Settings;
  FStatus := Status;
  FStatus.Wait;
  BuildAndTest;
  FDirectoryWatcher.Watch(FSettings.AutoTest.WatchPaths);
end;

end.
