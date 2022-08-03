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
  TTestRunnerForm = class(TBaseDockableForm)
    FailedTestsListBox: TListBox;
    AutoRunCheckBox: TCheckBox;
    StatusLabel: TLabel;
    RunButton: TButton;
    ProjectCheckTimer: TTimer;
    procedure RunButtonClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ProjectCheckTimerTimer(Sender: TObject);
  private const
    StatusUnknownColor = clOlive;
    StatusFailedColor = clRed;
    StatusSuccessColor = clGreen;
  private
    FAutoTester: TAutoTester;
    FStatus: TStatus;
    FActiveProjectProvider: IActiveProjectProvider;
    FIsAutoTesterRunning: Boolean;
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
  Dexperts.Common.ActiveProjectProvider,
  Dexperts.Common.ProjectSettings,
  Dexperts.TestRunner.Compiler,
  Dexperts.TestRunner.DUnitXRunner,
  Dexperts.TestRunner.Interfaces;

{$R *.dfm}

{ TTestRunnerForm }

constructor TTestRunnerForm.Create(AOwner: TComponent);
begin
  inherited;
//  TStatus.Instance.OnChanged := OnStatusChanged;

  FActiveProjectProvider := TActiveProjectProvider.Create;
  FAutoTester := TAutoTester.Instance;
  FStatus := TStatus.Create;
  FStatus.OnChanged := OnStatusChanged;
end;

class procedure TTestRunnerForm.CreateForm;
begin
  if not Assigned(FInstance) then
    CreateDockableForm(FInstance, TTestRunnerForm);
end;

destructor TTestRunnerForm.Destroy;
begin
//  TStatus.Instance.OnChanged := nil;
  FAutoTester.Stop;
  FStatus.Free;
  inherited;
end;

procedure TTestRunnerForm.FormHide(Sender: TObject);
begin
  inherited;
  ProjectCheckTimer.Enabled := False;
  StopAutoTesterThread;
end;

procedure TTestRunnerForm.FormShow(Sender: TObject);
begin
  inherited;

  StartAutoTesterThread;
  ProjectCheckTimer.Enabled := True;
end;

procedure TTestRunnerForm.OnStatusChanged(Sender: TObject);
begin
//  if FStatus.State = TTestingState.Testing then
//  begin
//    TThread.CreateAnonymousThread(
//      procedure
//      begin
//        var Runner := TDunitXRunner.Create;
//        try
//          var FailMessages := Runner.Run(LoadTestProjectArgs.TestExe);
//          if FailMessages = nil then
//            FStatus.TestsSucceeded
//          else
//            FStatus.TestsFailed(FailMessages);
//        finally
//          Runner.Free;
//        end;
//      end).Start;
//  end;

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

procedure TTestRunnerForm.ProjectCheckTimerTimer(Sender: TObject);
begin
  inherited;
  //
end;

class procedure TTestRunnerForm.RemoveForm;
begin
  FreeDockableForm(FInstance);
end;

procedure TTestRunnerForm.RunButtonClick(Sender: TObject);
begin
//  CompileActiveProject;
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
