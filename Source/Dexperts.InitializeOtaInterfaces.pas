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
  Dexperts.SpellCheckWizard;

function InitWizard(const BorlandIDEServiices: IBorlandIDEServices;
  RegisterProc: TWizardRegisterProc; var Terminate: TWizardTerminateProc): Boolean; stdcall;
begin
  Result := Assigned(BorlandIDEServices);
  if Result then
    RegisterProc(TSpellCheckWizard.Create);
end;

end.
