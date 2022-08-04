unit Dexperts.TestRunner.DUnitXRunner;

interface

uses
  Dexperts.TestRunner.Interfaces;

type
  TDunitXRunner = class(TInterfacedObject, ITestRunner)
  private
    FProcessRunner: IProcessRunner;
  public
    constructor Create(const ProcessRunner: IProcessRunner);

    function Run(const ExeFile: string): TArray<string>;
  end;

implementation

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  Dexperts.TestRunner.ProcessRunner;

{ TDunitXRunner }

constructor TDunitXRunner.Create(const ProcessRunner: IProcessRunner);
begin
  Assert(ProcessRunner <> nil, 'ProcessRunner must not be nil');
  FProcessRunner := ProcessRunner;
end;

function TDunitXRunner.Run(const ExeFile: string): TArray<string>;
begin
  Result := nil;
  if (ExeFile = '') or not TFile.Exists(ExeFile) then
    Exit;

  var Output := '';
  FProcessRunner.ExecAndCapture(Exefile + ' --exit:Continue', Output);

  var Tests := TStringList.Create;
  try
    var CollectFailures := False;
    var Lines := Output.Split([#13, #10], TStringSplitOptions.ExcludeEmpty);
    for var Line in Lines do
    begin
      if CollectFailures then
      begin
        if (Line <> '') and (not Line.StartsWith('  Message:')) then
          Tests.Add(Line);
      end
      else if Line.StartsWith('Tests Errored : ') then
        CollectFailures := True;
    end;

    Result := Tests.ToStringArray;
  finally
    Tests.Free;
  end;
end;

end.
