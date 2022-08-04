unit Dexperts.TestRunner.Compiler;

interface

uses
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
  private
    FProcessRunner: IProcessRunner;
  public
    constructor Create(const ProcessRunner: IProcessRunner);

    function Compile(const ProjectFileName, RsVarsPath, Args: string): Boolean;
  end;

implementation

uses
  System.StrUtils,
  Dexperts.TestRunner.ProcessRunner;

{ TCompiler }

function TCompiler.Compile(const ProjectFileName, RsVarsPath, Args: string): Boolean;
begin
  Assert(ProjectFileName <> '', 'ProjectFileName cannot be empty');
  Assert(RsVarsPath <> '', 'RsVarsPath must not be empty');

  var CmdLine := '"' + RsVarsPath + '" && @MsBuild "' + ProjectFileName + '" ' + Args;
  var Output := '';
  var BytesRead := FProcessRunner.ExecAndCapture(CmdLine, Output);
  Result := (BytesRead > 0) and (not ContainsText(Output, 'Could not compile'));
end;

constructor TCompiler.Create(const ProcessRunner: IProcessRunner);
begin
  Assert(ProcessRunner <> nil, 'ProcessRunner must not be nil');
  FProcessRunner := ProcessRunner;
end;

end.
