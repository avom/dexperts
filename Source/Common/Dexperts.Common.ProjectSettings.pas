unit Dexperts.Common.ProjectSettings;

interface

uses
  System.SysUtils;

type
  TProjectSettings = record
  private
    type
      TTestProject = record
      private
        FDproj: string;
        FExe: string;
        FCompileCommands: TArray<string>;
      public
        property Dproj: string read FDproj;
        property Exe: string read FExe;
        property CompileCommands: TArray<string> read FCompileCommands;
      end;

      TAutoTest = record
      private
        FTestProject: TTestProject;
        FWatchPaths: TArray<string>;
      public
        const TestQueuePeekIntervalMs = 1000;

        property TestProject: TTestProject read FTestProject;
        property WatchPaths: TArray<string> read FWatchPaths;
      end;
  private
    FAutoTest: TAutoTest;
  public
    property AutoTest: TAutoTest read FAutoTest;

    class function LoadFromFile(const FileName: string): TProjectSettings; static;
  end;

implementation

uses
  System.JSON,
  System.IOUtils,
  Dexperts.Common.Exceptions;

{ TProjectSettings }

class function TProjectSettings.LoadFromFile(const FileName: string): TProjectSettings;

  function ParseTestProject(Json: TJSONValue): TTestProject;
  begin
    var ProjectDir := TPath.GetDirectoryName(FileName);
    Result.FDproj := Json.GetValue<string>('dproj');
    if Result.FDproj <> '' then
      Result.FDproj := TPath.Combine(ProjectDir, Result.FDproj);
    Result.FExe := Json.GetValue<string>('exe');
    if Result.FExe <> '' then
      Result.FExe := TPath.Combine(ProjectDir, Result.FExe);
    Result.FCompileCommands := Json.GetValue<TArray<string>>('compile_commands');
  end;

  function ParseAutoTest(Json: TJSONValue): TAutoTest;
  begin
    var ProjectDir := TPath.GetDirectoryName(FileName);
    Result.FTestProject := ParseTestProject(Json.P['test_project']);
    Result.FWatchPaths := Json.GetValue<string>('watch_paths').Split([';']);
    for var i := 0 to High(Result.FWatchPaths) do
    begin
//      if Result.FWatchPaths[i] <> '.' then
        Result.FWatchPaths[i] := TPath.Combine(ProjectDir, Result.FWatchPaths[i])
//      else
//        Result.FWatchPaths[i] := ProjectDir;
    end;
  end;

begin
  var Content := TFile.ReadAllText(FileName);
  var Json := TJSONObject.ParseJSONValue(Content);
  if Json = nil then
    raise EDexpertsException.Create('Failed to parse project Dexperts configuration');
  Result.FAutoTest := ParseAutoTest(Json.P['auto_test']);
end;

end.
