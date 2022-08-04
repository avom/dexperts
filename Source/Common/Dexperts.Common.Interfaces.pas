unit Dexperts.Common.Interfaces;

interface

type
  IActiveProjectObserver = interface
    ['{80AE27F5-A618-4D46-9B6B-4BE32E3CE92A}']
    procedure OnActiveProjectChanged;
  end;

  IActiveProjectProvider = interface
    ['{FF7603A9-796F-4E56-AB2A-F9DDA6A6A4B9}']
    function GetProjectFilePath: string;
  end;

implementation

end.
