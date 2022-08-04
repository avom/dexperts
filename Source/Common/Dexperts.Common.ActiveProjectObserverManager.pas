unit Dexperts.Common.ActiveProjectObserverManager;

interface

uses
  System.Generics.Collections,
  Dexperts.Common.Interfaces;

type
  TActiveProjectObserverManager = class
  private
    FObservers: TList<IActiveProjectObserver>;
    class var FInstance: TActiveProjectObserverManager;
    class constructor CreateClass;
    class destructor DestroyClass;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Notify;

    procedure Subscribe(const Observer: IActiveProjectObserver);
    procedure Unsubscribe(const Observer: IActiveProjectObserver);

    class property Instance: TActiveProjectObserverManager read FInstance;
  end;

implementation

{ TActiveProjectObserver }

constructor TActiveProjectObserverManager.Create;
begin
  FObservers := TList<IActiveProjectObserver>.Create;
end;

class constructor TActiveProjectObserverManager.CreateClass;
begin
  FInstance := TActiveProjectObserverManager.Create;
end;

destructor TActiveProjectObserverManager.Destroy;
begin
  FObservers.Free;
  inherited;
end;

class destructor TActiveProjectObserverManager.DestroyClass;
begin
  FInstance.Free;
end;

procedure TActiveProjectObserverManager.Notify;
begin
  for var Observer in FObservers do
    Observer.OnActiveProjectChanged;
end;

procedure TActiveProjectObserverManager.Subscribe(const Observer: IActiveProjectObserver);
begin
  Assert(Observer <> nil, 'Observer must not be nil');
  FObservers.Add(Observer);
end;

procedure TActiveProjectObserverManager.Unsubscribe(const Observer: IActiveProjectObserver);
begin
  Assert(Observer <> nil, 'Observer must not be nil');
  FObservers.Remove(Observer);
end;

end.
