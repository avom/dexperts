unit Dexperts.TestRunner.DirectoryWatcher;

interface

uses
  System.Classes,
  Dexperts.TestRunner.Interfaces;

type
  TDirectoryWatcher = class(TInterfacedObject, IDirectoryWatcher)
  private
    FOnChange: TNotifyEvent;
    FTerminated: Boolean;
    function GetOnChange: TNotifyEvent;
    procedure SetOnChange(const Value: TNotifyEvent);
  public
    procedure Watch(const Dirs: TArray<string>);
    procedure Terminate;

    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
  end;

implementation

uses
  Winapi.Windows;

{ TDirectoryWatcher }

function TDirectoryWatcher.GetOnChange: TNotifyEvent;
begin
  Result := FOnChange;
end;

procedure TDirectoryWatcher.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TDirectoryWatcher.Terminate;
begin
  FTerminated := True;
end;

procedure TDirectoryWatcher.Watch(const Dirs: TArray<string>);
begin
  if Dirs = nil then
    Assert(Dirs <> nil, 'Dirs must not be nil');

  FTerminated := False;
  var DirCount: Cardinal := Length(Dirs);
  var Handles: TArray<THandle>;
  SetLength(Handles, DirCount);
  for var i := 0 to High(Handles) do
  begin
    Handles[i] := FindFirstChangeNotification(PWideChar(Dirs[i]), True,
      FILE_NOTIFY_CHANGE_FILE_NAME or FILE_NOTIFY_CHANGE_DIR_NAME or FILE_NOTIFY_CHANGE_LAST_WRITE);
    if (Handles[i] = INVALID_HANDLE_VALUE) or (Handles[i] = 0) then
      Exit; // TODO: notify, so user could be made aware
  end;

  while not FTerminated do
  begin
    var Event := WaitForMultipleObjects(DirCount, @Handles[0], { WaitAll } False, 1000);
    if (Event >= WAIT_OBJECT_0) and (Event < WAIT_OBJECT_0 + DirCount) then
    begin
      var Handle := Handles[Event - WAIT_OBJECT_0];
      if not FindNextChangeNotification(Handle) then
        Exit; // TODO: notify, so user could be made aware

      if Assigned(OnChange) then
        OnChange(Self);
    end;
  end;
end;

end.
