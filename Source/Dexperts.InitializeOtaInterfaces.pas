unit Dexperts.InitializeOtaInterfaces;

interface

uses
  ToolsAPI;

function InitWizard(const BorlandIDEServiices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc; var Terminate: TWizardTerminateProc): Boolean; stdcall;

exports
  InitWizard Name WizardEntryPoint;

implementation

uses
  Dexperts.SpellCheckWizard,
  Dexperts.TestRunner.Wizard;

function InitWizard(const BorlandIDEServiices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc; var Terminate: TWizardTerminateProc): Boolean; stdcall;
begin
  Result := Assigned(BorlandIDEServices);
  if not Result then
    Exit;

  RegisterProc(TSpellCheckWizard.Create);
  RegisterProc(TTestRunnerWizard.Create);
end;

end.
