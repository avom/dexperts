unit Dexperts.ToolsApiUtils;

interface

uses
  ToolsApi;

type
  TToolsApiUtils = class sealed
  public
    class function GetActiveSourceEditor: IOTASourceEditor;
  end;

implementation

uses
  System.SysUtils;

{ TToolsApiUtils }

class function TToolsApiUtils.GetActiveSourceEditor: IOTASourceEditor;
begin
  Result := nil;
  var ES: IOTAEditorServices;
  if Supports(BorlandIDEServices, IOTAEditorServices, ES) then
    Result := ES.TopBuffer;
end;

end.
