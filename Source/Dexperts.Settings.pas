unit Dexperts.Settings;

interface

uses
  System.UITypes,
  Vcl.Graphics;

type
  TUnderlineStyle = (usLine, usDashes, usDots, usSin);

  TSettings = class
  private
    FSpellingErrorColor: TColor;
    FSpellingErrorStyle: TUnderlineStyle;
    procedure Load;
    function ParseColorDef(const S: string; Def: TColor): TColor;
    function ParseUnderlineStyleDef(const S: string; Def: TUnderlineStyle): TUnderlineStyle;
    class var FInstance: TSettings;
    class constructor CreateClass;
    class destructor DestroyClass;
  public
    constructor Create;

    property SpellingErrorColor: TColor read FSpellingErrorColor;
    property SpellingErrorStyle: TUnderlineStyle read FSpellingErrorStyle;

    class property Instance: TSettings read FInstance;
  end;

implementation

uses
  System.Classes,
  System.IOUtils,
  System.JSON,
  System.SysUtils,
  Dexperts.PathProvider;

{ TSettings }

constructor TSettings.Create;
begin
  FSpellingErrorColor := TColorRec.Yellow;
  FSpellingErrorStyle := usLine;
end;

class constructor TSettings.CreateClass;
begin
  FInstance := TSettings.Create;
  FInstance.Load;
end;

class destructor TSettings.DestroyClass;
begin
  FInstance.Free;
end;

procedure TSettings.Load;
begin
  var FileName := TPathProvider.SettingsFilePath;
  if not TFile.Exists(FileName) then
    Exit;

  var Content := TFile.ReadAllText(FileName);
  var Json := TJSONObject.ParseJSONValue(Content);
  try
    var S := '';
    if Json.TryGetValue<string>('spelling_error.color', S) then
      FSpellingErrorColor := ParseColorDef(S, clYellow);
    if Json.TryGetValue<string>('spelling_error.style', S) then
      FSpellingErrorStyle := ParseUnderlineStyleDef(S, usLine);
  finally
    Json.Free;
  end;
end;

function TSettings.ParseColorDef(const S: string; Def: TColor): TColor;
begin
  Result := Def;
  if S = '' then
    Exit;

  try
    Result := StringToColor('cl' + S);
  except
    on EConvertError do
    else
      raise;
  end;
end;

function TSettings.ParseUnderlineStyleDef(const S: string; Def: TUnderlineStyle): TUnderlineStyle;
begin
  var SLower := S.ToLower;
  if SLower = 'line' then
    Result := usLine
  else if SLower = 'dashes' then
    Result := usDashes
  else if SLower = 'dots' then
    Result := usDots
  else if SLower = 'sin' then
    Result := usSin
  else
    Result := Def;
end;

end.
