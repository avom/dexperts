unit Dexperts.Common.ActiveProjectProvider;

interface

uses
  Dexperts.Common.Interfaces;

type
  TActiveProjectProvider = class(TInterfacedObject, IActiveProjectProvider)
  public
    function GetProjectFilePath: string;
  end;

implementation

uses
  ToolsApi;

{ TActiveProjectProvider }

function TActiveProjectProvider.GetProjectFilePath: string;
begin
  Result := '';
  var Project := GetActiveProject;
  if Project <> nil then
    Result := Project.FileName;
end;

end.
