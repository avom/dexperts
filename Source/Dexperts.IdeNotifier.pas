unit Dexperts.IdeNotifier;

interface

uses
  System.Classes,
  System.Generics.Collections,
  ToolsAPI;

type
  TIdeNotifier = class(TNotifierObject, IOTAIDENotifier)
  private
    FEditorNotifiers: TDictionary<string, Integer>;
    procedure AddNotifier(const Module: IOTAModule; const FileName: string);
    procedure RemoveNotifier(const Module: IOTAModule; const FileName: string);

    procedure FileNotification(NotifyCode: TOTAFileNotification;
      const FileName: string; var Cancel: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean); overload;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils,
  Dexperts.EditorNotifier;

{ TIdeNotifier }

procedure TIdeNotifier.AddNotifier(const Module: IOTAModule; const FileName: string);
begin
  for var i := 0 to Module.GetModuleFileCount - 1 do
  begin
    var Editor := Module.GetModuleFileEditor(i);
    var SourceEditor: IOTASourceEditor;
    if not Supports(Editor, IOTASourceEditor, SourceEditor) then
      Continue;

    var EditorNotifier: IOTAEditorNotifier := TEditorNotifier.Create(SourceEditor);
    var Index := SourceEditor.AddNotifier(EditorNotifier);
    FEditorNotifiers.Add(FileName, Index);
  end;
end;

procedure TIdeNotifier.AfterCompile(Succeeded: Boolean);
begin

end;

procedure TIdeNotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin

end;

constructor TIdeNotifier.Create;
begin
  inherited;
  FEditorNotifiers := TDictionary<string, Integer>.Create;
end;

destructor TIdeNotifier.Destroy;
begin
  FEditorNotifiers.Free;
  inherited;
end;

procedure TIdeNotifier.FileNotification(NotifyCode: TOTAFileNotification; const FileName: string;
  var Cancel: Boolean);
begin
  var ModuleServices: IOTAModuleServices;
  if Cancel or not Supports(BorlandIDEServices, IOTAModuleServices, ModuleServices) then
    Exit;

  case NotifyCode of
    ofnFileOpening: ;
    ofnFileOpened:
      begin
        var Module := ModuleServices.OpenModule(FileName);
        AddNotifier(Module, FileName);
      end;
    ofnFileClosing:
      begin
        var Module := ModuleServices.OpenModule(FileName);
        RemoveNotifier(Module, FileName);
      end;
    ofnDefaultDesktopLoad: ;
    ofnDefaultDesktopSave: ;
    ofnProjectDesktopLoad: ;
    ofnProjectDesktopSave: ;
    ofnPackageInstalled: ;
    ofnPackageUninstalled: ;
    ofnActiveProjectChanged:
      begin
      end;
    ofnProjectOpenedFromTemplate: ;
    ofnBeginProjectGroupOpen: ;
    ofnEndProjectGroupOpen: ;
    ofnBeginProjectGroupClose: ;
    ofnEndProjectGroupClose: ;
  end;
end;

procedure TIdeNotifier.RemoveNotifier(const Module: IOTAModule; const FileName: string);
begin
  for var i := 0 to Module.GetModuleFileCount - 1 do
  begin
    var Editor := Module.GetModuleFileEditor(i);
    var SourceEditor: IOTASourceEditor;
    if not Supports(Editor, IOTASourceEditor, SourceEditor) then
      Exit;

    if FEditorNotifiers.ContainsKey(FileName) then
    begin
      var Index := FEditorNotifiers[FileName];
      SourceEditor.RemoveNotifier(Index);
      FEditorNotifiers.Remove(FileName);
    end;
  end;
end;

end.
