unit Dexperts.Dictionary;

interface

uses
  System.Generics.Collections;

type
  TDexpertsDictionary = class
  private
    class var FDictionary: TDictionary<string, Boolean>;
    class constructor CreateClass;
    class destructor DestroyClass;
  public
    class function IsValid(const S: string): Boolean;
  end;

implementation

uses
  System.Classes,
  System.SysUtils,
  Dexperts.PathProvider;

{ TDexpertsDictionary }

class constructor TDexpertsDictionary.CreateClass;
begin
  FDictionary := TDictionary<string, Boolean>.Create;
  var Strings := TStringList.Create;
  try
    Strings.LoadFromFile(TPathProvider.DictionaryFilePath);
    for var S in Strings do
      FDictionary.AddOrSetValue(S.ToLower, True);
  finally
    Strings.Free;
  end;
end;

class destructor TDexpertsDictionary.DestroyClass;
begin
  FDictionary.Free;
end;

class function TDexpertsDictionary.IsValid(const S: string): Boolean;
begin
  Result := FDictionary.ContainsKey(S.ToLower);
end;

end.
