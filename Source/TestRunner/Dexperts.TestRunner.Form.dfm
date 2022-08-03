inherited TestRunnerForm: TTestRunnerForm
  Caption = 'Dexperts Test Runner'
  ClientWidth = 447
  OnHide = FormHide
  OnShow = FormShow
  ExplicitWidth = 463
  PixelsPerInch = 96
  TextHeight = 13
  object StatusLabel: TLabel
    Left = 8
    Top = 8
    Width = 354
    Height = 25
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Status'
    Color = clOlive
    ParentColor = False
    Transparent = False
    Layout = tlCenter
  end
  object FailedTestsListBox: TListBox
    Left = 8
    Top = 44
    Width = 431
    Height = 367
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 0
  end
  object AutoRunCheckBox: TCheckBox
    Left = 368
    Top = 12
    Width = 71
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Auto-run'
    Checked = True
    State = cbChecked
    TabOrder = 1
  end
  object RunButton: TButton
    Left = 287
    Top = 8
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Run'
    TabOrder = 2
    Visible = False
    OnClick = RunButtonClick
  end
  object ProjectCheckTimer: TTimer
    Enabled = False
    Interval = 60000
    OnTimer = ProjectCheckTimerTimer
    Left = 404
    Top = 372
  end
end
