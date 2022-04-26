unit Dexperts.SpellCheckWizard;

interface

uses
  ToolsAPI,
  Dexperts.EditServicesNotifier;

type
  TSpellCheckWizard = class(TNotifierObject, IOTAWizard)
  private
    FEditServicesNotifier: TEditServicesNotifier;
    FEditorIndex: Integer;
    FIdeNotifierIndex: Integer;
    function GetIDString: string;
    function GetName: string;
    function GetState: TWizardState;
    procedure Execute;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils,
  Dexperts.IdeNotifier;

{ TSpellCheckWizard }


constructor TSpellCheckWizard.Create;
begin
  inherited;
  FEditServicesNotifier := TEditServicesNotifier.Create;
  FEditorIndex := (BorlandIDEServices as IOTAEditorServices).AddNotifier(FEditServicesNotifier);

  var Services: IOTAServices;
  if Supports(BorlandIDEServices, IOTAServices, Services) then
    FIDENotifierIndex := Services.AddNotifier(TIDENotifier.Create);
end;

destructor TSpellCheckWizard.Destroy;
begin
  if FEditorIndex >= 0 then
    (BorlandIDEServices As IOTAEditorServices).RemoveNotifier(FEditorIndex);
  var Services: IOTAServices;
  if Supports(BorlandIDEServices, IOTAServices, Services) then
    Services.RemoveNotifier(FIDENotifierIndex);
  inherited;
end;

procedure TSpellCheckWizard.Execute;
begin
  // This is not called
end;

function TSpellCheckWizard.GetIDString: string;
begin
  Result := 'Dexperts.SpellChecker';
end;

function TSpellCheckWizard.GetName: string;
begin
  Result := 'Dexperts.SpellChecker';
end;

function TSpellCheckWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

end.
