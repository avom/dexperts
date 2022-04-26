unit Dexperts.EditServicesNotifier;

interface

uses
  System.Classes,
  DockForm,
  ToolsAPI,
  Vcl.ExtCtrls;

type
  TEditServicesNotifier = class(TNotifierObject, INTAEditServicesNotifier)
  private
    FUpdateTimer: TTimer;
    FLastCursorPos: TOTAEditPos;
    FLastMoveTickCount: Cardinal;
    FLastEditorFileName: string;
    procedure OnTimer(Sender: TObject);
  protected
    procedure WindowShow(const EditWindow: INTAEditWindow; Show, LoadedFromDesktop: Boolean);
    procedure WindowNotification(const EditWindow: INTAEditWindow; Operation: TOperation);
    procedure WindowActivated(const EditWindow: INTAEditWindow);
    procedure WindowCommand(const EditWindow: INTAEditWindow; Command, Param: Integer; var Handled: Boolean);
    procedure EditorViewActivated(const EditWindow: INTAEditWindow; const EditView: IOTAEditView);
    procedure EditorViewModified(const EditWindow: INTAEditWindow; const EditView: IOTAEditView);
    procedure DockFormVisibleChanged(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    procedure DockFormUpdated(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    procedure DockFormRefresh(const EditWindow: INTAEditWindow; DockForm: TDockableForm);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils,
  WinApi.Windows,
  Dexperts.ToolsApiUtils;

{ TEditServicesNotifier }

constructor TEditServicesNotifier.Create;
begin
  FUpdateTimer := TTimer.Create(nil);
  FUpdateTimer.Interval := 100;
end;

destructor TEditServicesNotifier.Destroy;
begin
  FUpdateTimer.Free;
  inherited;
end;

procedure TEditServicesNotifier.DockFormRefresh(const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);
begin

end;

procedure TEditServicesNotifier.DockFormUpdated(const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);
begin

end;

procedure TEditServicesNotifier.DockFormVisibleChanged(const EditWindow: INTAEditWindow;
  DockForm: TDockableForm);
begin

end;

procedure TEditServicesNotifier.EditorViewActivated(const EditWindow: INTAEditWindow;
  const EditView: IOTAEditView);
begin

end;

procedure TEditServicesNotifier.EditorViewModified(const EditWindow: INTAEditWindow;
  const EditView: IOTAEditView);
begin
end;

procedure TEditServicesNotifier.OnTimer(Sender: TObject);

  function CheckCursorMovement(const Editor: IOTASourceEditor): TOTAEditPos;
  begin
    Result := FLastCursorPos;
    if Editor = nil then
      Exit;

    if Editor.GetEditViewCount <= 0 then
      Exit;

    var Services: IOTAEditorServices;
    if not Supports(BorlandIDEServices, IOTAEditorServices, Services) then
      Exit;

    Result := Services.TopView.CursorPos;
    if (Result.Col = FLastCursorPos.Col) and (Result.Line = FLastCursorPos.Line) then
      Exit;

    FLastCursorPos := Result;
    FLastMoveTickCount := GetTickCount;
  end;

  procedure CheckFileName(const Editor: IOTASourceEditor);
  begin
    if Editor = nil then
      Exit;

    if Editor.FileName = FLastEditorFileName then
      Exit;

    FLastEditorFileName := Editor.FileName;
  end;

begin
  var Editor := TToolsApiUtils.GetActiveSourceEditor;
  var CursorPos := CheckCursorMovement(Editor);
  CheckFileName(Editor);

end;

procedure TEditServicesNotifier.WindowActivated(const EditWindow: INTAEditWindow);
begin

end;

procedure TEditServicesNotifier.WindowCommand(const EditWindow: INTAEditWindow; Command,
  Param: Integer; var Handled: Boolean);
begin

end;

procedure TEditServicesNotifier.WindowNotification(const EditWindow: INTAEditWindow;
  Operation: TOperation);
begin

end;

procedure TEditServicesNotifier.WindowShow(const EditWindow: INTAEditWindow; Show,
  LoadedFromDesktop: Boolean);
begin

end;

end.
