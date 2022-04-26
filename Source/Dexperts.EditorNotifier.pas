unit Dexperts.EditorNotifier;

interface

uses
  System.Classes,
  ToolsAPI;

type
  TEditorNotifier = class(TNotifierObject, IOTAEditorNotifier)
  private
    FEditViewNotifierIndex: Integer;
    procedure InsertEditViewNotifier(const View: IOTAEditView);
    procedure RemoveEditViewNotifier(const View: IOTAEditView);
    procedure ViewNotification(const View: IOTAEditView; Operation: TOperation);
    procedure ViewActivated(const View: IOTAEditView);
  public
    constructor Create(const SourceEditor: IOTASourceEditor);
  end;

implementation

uses
  Dexperts.EditViewNotifier;

{ TEditorNotifier }

constructor TEditorNotifier.Create(const SourceEditor: IOTASourceEditor);
begin
  FEditViewNotifierIndex := -1;
  if SourceEditor.EditViewCount > 0 then
    ViewNotification(SourceEditor.EditViews[0], opInsert);
end;

procedure TEditorNotifier.InsertEditViewNotifier(const View: IOTAEditView);
begin
  if FEditViewNotifierIndex = -1 then
    FEditViewNotifierIndex := View.AddNotifier(TEditViewNotifier.Create);
end;

procedure TEditorNotifier.RemoveEditViewNotifier(const View: IOTAEditView);
begin
  if FEditViewNotifierIndex >= 0 then
  begin
    View.RemoveNotifier(FEditViewNotifierIndex);
    FEditViewNotifierIndex := -1;
  end;
end;

procedure TEditorNotifier.ViewActivated(const View: IOTAEditView);
begin

end;

procedure TEditorNotifier.ViewNotification(const View: IOTAEditView; Operation: TOperation);
begin
  if View = nil then
    Exit;

  case Operation of
    opInsert:
      InsertEditViewNotifier(View);
    opRemove:
      RemoveEditViewNotifier(View);
  end;

end;

end.
