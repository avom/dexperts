unit DexpertsTests.TestRunner.AutoTesterTests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TAutoTesterTests = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

//    [Test]
//    procedure TestOnSourceChange_;

    [Test]
    procedure Test1;
    // Test with TestCase Attribute to supply parameters.
    [Test]
    [TestCase('TestA','1,2')]
    [TestCase('TestB','3,4')]
    procedure Test2(const AValue1 : Integer;const AValue2 : Integer);
  end;

implementation

uses
  System.Classes,
  Dexperts.TestRunner.Interfaces;

type
  TCompilerStub = class(TInterfacedObject, ICompiler)
  public
    function Compile(const ProjectFileName, RsVarsPath, Args: string): Boolean;
  end;

  TDirecoryWatcherStub = class(TInterfacedObject, IDirectoryWatcher)
  private
    FOnChange: TNotifyEvent;
    function GetOnChange: TNotifyEvent;
    procedure SetOnChange(const Value: TNotifyEvent);

    procedure Watch(const Dirs: TArray<string>);
    procedure Terminate;
  end;

{ TCompilerStub }

function TCompilerStub.Compile(const ProjectFileName, RsVarsPath, Args: string): Boolean;
begin

end;

{ TDirecoryWatcherStub }

function TDirecoryWatcherStub.GetOnChange: TNotifyEvent;
begin
  Result := FOnChange;
end;

procedure TDirecoryWatcherStub.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TDirecoryWatcherStub.Terminate;
begin

end;

procedure TDirecoryWatcherStub.Watch(const Dirs: TArray<string>);
begin

end;

{ TAutoTesterTests }

procedure TAutoTesterTests.Setup;
begin

end;

procedure TAutoTesterTests.TearDown;
begin

end;

procedure TAutoTesterTests.Test1;
begin

end;

procedure TAutoTesterTests.Test2(const AValue1, AValue2: Integer);
begin

end;

initialization
  TDUnitX.RegisterTestFixture(TAutoTesterTests);

end.
