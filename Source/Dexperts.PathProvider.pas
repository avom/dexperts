unit Dexperts.PathProvider;

interface

type
  TPathProvider = class
  private const
    AppDir = 'Dexperts';
  private
    class function GetAppDataDir: string; static;
    class function GetSettingsFilePath: string; static;
  public
    class property AppDataDir: string read GetAppDataDir;
    class property SettingsFilePath: string read GetSettingsFilePath;
  end;

implementation

uses
  System.IOUtils;

{ TPathProvider }

class function TPathProvider.GetAppDataDir: string;
begin
  Result := TPath.Combine(TPath.GetDownloadsPath, AppDir);
end;

class function TPathProvider.GetSettingsFilePath: string;
begin
  Result := TPath.Combine(AppDataDir, 'settings.json');
end;

end.
