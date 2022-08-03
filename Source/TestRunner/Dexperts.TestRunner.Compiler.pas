unit Dexperts.TestRunner.Compiler;

interface

uses
  System.SysUtils,
  Dexperts.TestRunner.Interfaces;

type
  TTestProjectArgs = record
    FileName: string;
    MsBuildArgs: string;
    RsVarsPath: string;
    WatchPaths: TArray<string>;
    TestExe: string;
  end;

  TCompiler = class(TInterfacedObject, ICompiler)
  public
    function Compile(const ProjectFileName, RsVarsPath, Args: string): Boolean;
  end;

procedure CompileActiveProject;
function LoadTestProjectArgs: TTestProjectArgs;

implementation

uses
  System.Classes,
  System.IOUtils,
  System.StrUtils,
  ToolsAPI,
  Dexperts.TestRunner.ProcessRunner,
  Dexperts.TestRunner.Status;

function LoadTestProjectArgs: TTestProjectArgs;
begin
  Result.FileName := '';
  Result.MsBuildArgs := '';
  Result.RsVarsPath := '';
  Result.WatchPaths := nil;
  Result.TestExe := '';

  var Project := GetActiveProject;
  if Project = nil then
    Exit;

  var ProjectFileName := Project.FileName;
  if ProjectFileName = '' then
    Exit;

  var SettingsFileName := ChangeFileExt(ProjectFileName, '.dexperts');
  if not TFile.Exists(SettingsFileName) then
    Exit;

  var Settings := TStringList.Create;
  try
    Settings.LoadFromFile(SettingsFileName);
    Result.FileName := Settings.Values['test-project'];
    if Result.FileName = '' then
      Exit;

    var ProjectDir := TPath.GetDirectoryName(ProjectFileName);
    Result.FileName := TPath.Combine(ProjectDir, Result.FileName);
    Result.TestExe := Settings.Values['test-exe'];
    if Result.TestExe <> '' then
      Result.TestExe := TPath.Combine(ProjectDir, Result.TestExe);
    Result.MsBuildArgs := Settings.Values['msbuild-args'];
    Result.RsVarsPath := Settings.Values['rsvars-path'];
    Result.WatchPaths := Settings.Values['watch-paths'].Split([';']);
    for var i := 0 to High(Result.WatchPaths) do
      Result.WatchPaths[i] := TPath.Combine(ProjectDir, Result.WatchPaths[i]);
  finally
    Settings.Free;
  end;
end;

procedure MsBuildProject(const ProjectFileName, RsVarsPath, Args: string);
begin
  if ProjectFileName = '' then
  begin
    TStatus.Instance.MissingTestProject;
    Exit;
  end;

  TStatus.Instance.Compile;
  var CmdLine := '"' + RsVarsPath + '" && @MsBuild "' + ProjectFileName + '" ' + Args;
  var Output := '';
  var BytesRead := ExecAndCapture(CmdLine, Output);
  if BytesRead = 0 then
  begin
    TStatus.Instance.CompileFailed;
    Exit;
  end;

  if ContainsText(Output, 'Could not compile') then
    TStatus.Instance.CompileFailed
  else
    TStatus.Instance.CompileSucceeded;
end;

procedure CompileActiveProject;
begin
  var Args := LoadTestProjectArgs;
  if Args.FileName = '' then
  begin
    TStatus.Instance.MissingTestProject;
    Exit;
  end;

  TThread.CreateAnonymousThread(
    procedure
    begin
      MsBuildProject(Args.FileName, Args.RsVarsPath, Args.MsBuildArgs);
    end).Start;
end;

{ TCompiler }

function TCompiler.Compile(const ProjectFileName, RsVarsPath, Args: string): Boolean;
begin
  Assert(ProjectFileName <> '', 'ProjectFileName cannot be empty');
  Assert(RsVarsPath <> '', 'RsVarsPath must not be empty');

  var CmdLine := '"' + RsVarsPath + '" && @MsBuild "' + ProjectFileName + '" ' + Args;
  var Output := '';
  var BytesRead := ExecAndCapture(CmdLine, Output);
  Result := (BytesRead > 0) and (not ContainsText(Output, 'Could not compile'));
end;

end.
