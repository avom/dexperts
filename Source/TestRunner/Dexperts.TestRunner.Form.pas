unit Dexperts.TestRunner.Form;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Variants,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Winapi.Messages,
  Winapi.Windows,
  Dexperts.Common.BaseDockableForm,
  Dexperts.Common.Interfaces,
  Dexperts.TestRunner.AutoTester,
  Dexperts.TestRunner.Status;

type
  TTestRunnerForm = class(TBaseDockableForm, IActiveProjectObserver)
    FailedTestsListBox: TListBox;
    AutoRunCheckBox: TCheckBox;
    StatusLabel: TLabel;
    RunButton: TButton;
    procedure RunButtonClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AutoRunCheckBoxClick(Sender: TObject);
  private const
    StatusUnknownColor = clOlive;
    StatusFailedColor = clRed;
    StatusSuccessColor = clGreen;
  private
    FAutoTester: TAutoTester;
    FStatus: TStatus;
    FActiveProjectProvider: IActiveProjectProvider;
    FIsAutoTesterRunning: Boolean;
    procedure OnActiveProjectChanged;
    procedure OnStatusChanged(Sender: TObject);
    procedure StartAutoTesterThread;
    procedure StopAutoTesterThread;
    class var FInstance: TBaseDockableForm;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class procedure RemoveForm;
    class procedure ShowForm;
    class procedure CreateForm;
  end;

implementation

uses
  System.IOUtils,
  ToolsAPI,
  Dexperts.Common.ActiveProjectObserverManager,
  Dexperts.Common.ActiveProjectProvider,
  Dexperts.Common.ProjectSettings,
  Dexperts.TestRunner.Compiler,
  Dexperts.TestRunner.DUnitXRunner,
  Dexperts.TestRunner.Interfaces;

{$R *.dfm}

{ TTestRunnerForm }

procedure TTestRunnerForm.AutoRunCheckBoxClick(Sender: TObject);
begin
  inherited;
  if AutoRunCheckBox.Checked then
    FAutoTester.Unpause
  else
    FAutoTester.Pause;
end;

constructor TTestRunnerForm.Create(AOwner: TComponent);
begin
  inherited;
  FActiveProjectProvider := TActiveProjectProvider.Create;
  FAutoTester := TAutoTester.Instance;
  FStatus := TStatus.Create;
  FStatus.OnChanged := OnStatusChanged;
  TActiveProjectObserverManager.Instance.Subscribe(Self);
end;

class procedure TTestRunnerForm.CreateForm;
begin
  if not Assigned(FInstance) then
    CreateDockableForm(FInstance, TTestRunnerForm);
end;

destructor TTestRunnerForm.Destroy;
begin
  TActiveProjectObserverManager.Instance.Unsubscribe(Self);
  FAutoTester.Stop;
  FStatus.Free;
  inherited;
end;

procedure TTestRunnerForm.FormHide(Sender: TObject);
begin
  inherited;
  StopAutoTesterThread;
end;

procedure TTestRunnerForm.FormShow(Sender: TObject);
begin
  inherited;

  StartAutoTesterThread;
end;

procedure TTestRunnerForm.OnActiveProjectChanged;
begin
  if FIsAutoTesterRunning then
  begin
    var Restarted := False;
    var ProjectFileName := FActiveProjectProvider.GetProjectFilePath;
    if ProjectFileName <> '' then
    begin
      var SettingsFileName := ChangeFileExt(ProjectFileName, '.dexperts');
      if TFile.Exists(SettingsFileName) then
      begin
        var Settings := TProjectSettings.LoadFromFile(SettingsFileName);
        FAutoTester.Restart(Settings, FStatus);
        Restarted := True;
      end;
    end;
    if Restarted then
      StopAutoTesterThread;
  end
  else
    StartAutoTesterThread;
end;

procedure TTestRunnerForm.OnStatusChanged(Sender: TObject);
begin
  TThread.Queue(nil,
    procedure
    begin
      StatusLabel.Caption := FStatus.Name;
      if FStatus.State = TTestingState.TestsPassed then
        StatusLabel.Color := StatusSuccessColor
      else if FStatus.State in [TTestingState.TestsPassed, TTestingState.CompileFailed] then
        StatusLabel.Color := StatusFailedColor
      else
        StatusLabel.Color := StatusUnknownColor;

      FailedTestsListBox.Items.BeginUpdate;
      try
        FailedTestsListBox.Items.Clear;
        FailedTestsListBox.Items.AddStrings(FStatus.FailedTests);
      finally
        FailedTestsListBox.Items.EndUpdate;
      end;
    end);
end;

class procedure TTestRunnerForm.RemoveForm;
begin
  FreeDockableForm(FInstance);
end;

procedure TTestRunnerForm.RunButtonClick(Sender: TObject);
begin
  FAutoTester.QueueTesting;
end;

class procedure TTestRunnerForm.ShowForm;
begin
  CreateForm;
  ShowDockableForm(FInstance);
end;

procedure TTestRunnerForm.StartAutoTesterThread;
begin
  if FIsAutoTesterRunning then
    Exit;

  var ProjectFileName := FActiveProjectProvider.GetProjectFilePath;
  if ProjectFileName = '' then
    Exit;

  var SettingsFileName := ChangeFileExt(ProjectFileName, '.dexperts');
  if not TFile.Exists(SettingsFileName) then
    Exit;

  var Settings := TProjectSettings.LoadFromFile(SettingsFileName);
  TThread.CreateAnonymousThread(
    procedure
    begin
      FAutoTester.Start(Settings, FStatus);
    end).Start;
  FIsAutoTesterRunning := True;
end;

procedure TTestRunnerForm.StopAutoTesterThread;
begin
  if FIsAutoTesterRunning then
    FAutoTester.Stop;
  FIsAutoTesterRunning := False;
end;

end.
