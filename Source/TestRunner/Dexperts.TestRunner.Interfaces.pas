unit Dexperts.TestRunner.Interfaces;

interface

uses
  System.Classes;

type
  ICompiler = interface
    ['{03CE5D87-24C1-4789-93A4-B913D46AA579}']
    function Compile(const ProjectFileName, RsVarsPath, Args: string): Boolean;
  end;

  IDirectoryWatcher = interface
    ['{788C8365-BB79-472B-A84A-E3EF34FC9748}']
    function GetOnChange: TNotifyEvent;
    procedure SetOnChange(const Value: TNotifyEvent);

    procedure Watch(const Dirs: TArray<string>);
    procedure Terminate;

    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
  end;

  ITestRunner = interface
    ['{A5E0E2DF-5105-46D5-A2C3-B163941CBBCB}']
    function Run(const ExeFile: string): TArray<string>;
  end;

  TTestingState = (ConfigMissing, Waiting, Missing, Compiling, CompileFailed, Testing, TestsPassed,
    TestsFailed);

  IStatus = interface
    ['{F728D422-E65C-4635-9F57-D247BE6939AB}']
    function GetName: string;
    function GetState: TTestingState;
    function GetOnChanged: TNotifyEvent;
    procedure SetOnChanged(const Value: TNotifyEvent);
    function GetFailedTests: TArray<string>;

    procedure MissingTestProject;
    procedure Compile;
    procedure CompileSucceeded;
    procedure CompileFailed;
    procedure TestsSucceeded;
    procedure TestsFailed(const FailedTests: TArray<string>);

    property Name: string read GetName;
    property State: TTestingState read GetState;
    property FailedTests: TArray<string> read GetFailedTests;

    property OnChanged: TNotifyEvent read GetOnChanged write SetOnChanged;
  end;

implementation

end.
