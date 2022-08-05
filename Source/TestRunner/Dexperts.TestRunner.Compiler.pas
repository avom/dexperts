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

    function Compile(const ProjectFileName: string; const Commands: TArray<string>): Boolean;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils,
  Dexperts.TestRunner.ProcessRunner;

{ TCompiler }

function TCompiler.Compile(const ProjectFileName: string; const Commands: TArray<string>): Boolean;
begin
  Assert(ProjectFileName <> '', 'ProjectFileName cannot be empty');
  Assert(Commands <> nil, 'Commands must not be empty');

  var CmdLine := string.Join(' && ', Commands);
  CmdLine := CmdLine.Replace('<dproj>', ProjectFileName);
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
