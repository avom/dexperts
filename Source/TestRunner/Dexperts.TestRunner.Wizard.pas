unit Dexperts.TestRunner.Wizard;

interface

uses
  ToolsAPI;

type
  TCompileNotifier = class(TNotifierObject, IOTACompileNotifier)
    procedure ProjectCompileStarted(const Project: IOTAProject; Mode: TOTACompileMode);
    procedure ProjectCompileFinished(const Project: IOTAProject; Result: TOTACompileResult);
    procedure ProjectGroupCompileStarted(Mode: TOTACompileMode);
    procedure ProjectGroupCompileFinished(Result: TOTACompileResult);
  end;

  TTestRunnerWizard = class(TNotifierObject, IOTANotifier, IOTAWizard, IOTAMenuWizard)
  private
    FNotifierIndex: Integer;
    FCompileNotifier: TCompileNotifier;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Execute;
    function GetIDString: string;
    function GetMenuText: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Destroyed;
  end;

implementation

uses
  Dexperts.TestRunner.Form;

{ TTestRunnerWizard }

constructor TTestRunnerWizard.Create;
begin
  FCompileNotifier := TCompileNotifier.Create;
  FNotifierIndex := (BorlandIDEServices as IOTACompileServices).AddNotifier(FCompileNotifier);
end;

destructor TTestRunnerWizard.Destroy;
begin
  if FNotifierIndex >= 0 then
    (BorlandIDEServices As IOTAEditorServices).RemoveNotifier(FNotifierIndex);
  inherited;
end;

procedure TTestRunnerWizard.Destroyed;
begin
  TTestRunnerForm.RemoveForm;
end;

procedure TTestRunnerWizard.Execute;
begin
  TTestRunnerForm.ShowForm;
end;

function TTestRunnerWizard.GetIDString: string;
begin
  Result := 'Dexperts.TestRunner';
end;

function TTestRunnerWizard.GetMenuText: string;
begin
  Result := 'Show Dexperts Test Runner';
end;

function TTestRunnerWizard.GetName: string;
begin
  Result := 'Dexperts Test Runner';
end;

function TTestRunnerWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

{ TCompileNotifier }

procedure TCompileNotifier.ProjectCompileFinished(const Project: IOTAProject;
  Result: TOTACompileResult);
begin

end;

procedure TCompileNotifier.ProjectCompileStarted(const Project: IOTAProject; Mode: TOTACompileMode);
begin

end;

procedure TCompileNotifier.ProjectGroupCompileFinished(Result: TOTACompileResult);
begin

end;

procedure TCompileNotifier.ProjectGroupCompileStarted(Mode: TOTACompileMode);
begin

end;

initialization

finalization
  TTestRunnerForm.RemoveForm;
end.
