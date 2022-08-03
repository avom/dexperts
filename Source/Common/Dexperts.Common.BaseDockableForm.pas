unit Dexperts.Common.BaseDockableForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DockForm;

type
  TBaseDockableForm = class(TDockableForm)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TBaseDockableFormClass = class of TBaseDockableForm;

procedure ShowDockableForm(Form: TBaseDockableForm);
procedure CreateDockableForm(var FormVar: TBaseDockableForm; FormClass: TBaseDockableFormClass);
procedure FreeDockableForm(var FormVar: TBaseDockableForm);

implementation

{$R *.dfm}

uses
  DeskUtil;

procedure ShowDockableForm(Form: TBaseDockableForm);
begin
  if not Assigned(Form) then
    Exit;
  if not Form.Floating then
  begin
    Form.ForceShow;
    FocusWindow(Form);
  end
  else
    Form.Show;
end;

procedure RegisterDockableForm(FormClass: TBaseDockableFormClass;
  var FormVar; const FormName: string);
begin
  if @RegisterFieldAddress <> nil then
    RegisterFieldAddress(FormName, @FormVar);

  RegisterDesktopFormClass(FormClass, FormName, FormName);
end;

procedure UnRegisterDockableForm(var FormVar; const FormName: string);
begin
  if @UnregisterFieldAddress <> nil then
    UnregisterFieldAddress(@FormVar);
end;

procedure CreateDockableForm(var FormVar: TBaseDockableForm; FormClass: TBaseDockableFormClass);
begin
  TCustomForm(FormVar) := FormClass.Create(nil);
  RegisterDockableForm(FormClass, FormVar, TCustomForm(FormVar).Name);
end;

procedure FreeDockableForm(var FormVar: TBaseDockableForm);
begin
  if Assigned(FormVar) then
  begin
    UnRegisterDockableForm(FormVar, FormVar.Name);
    FreeAndNil(FormVar);
  end;
end;


{ TBaseDockableForm }

constructor TBaseDockableForm.Create(AOwner: TComponent);
begin
  inherited;
  DeskSection := Name;
  AutoSave := True;
  SaveStateNecessary := True;
end;

destructor TBaseDockableForm.Destroy;
begin
  SaveStateNecessary := True;
  inherited;
end;

end.
