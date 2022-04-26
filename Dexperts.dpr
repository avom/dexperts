library Dexperts;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{$E dll}

uses
  System.Classes,
  System.SysUtils,
  Dexperts.InitializeOtaInterfaces in 'Source\Dexperts.InitializeOtaInterfaces.pas',
  Dexperts.SpellCheckWizard in 'Source\Dexperts.SpellCheckWizard.pas',
  Dexperts.EditViewNotifier in 'Source\Dexperts.EditViewNotifier.pas',
  Dexperts.EditorNotifier in 'Source\Dexperts.EditorNotifier.pas',
  Dexperts.DebugLog in 'Source\Dexperts.DebugLog.pas',
  Dexperts.ToolsApiUtils in 'Source\Dexperts.ToolsApiUtils.pas',
  Dexperts.EditServicesNotifier in 'Source\Dexperts.EditServicesNotifier.pas',
  Dexperts.IdeNotifier in 'Source\Dexperts.IdeNotifier.pas',
  Dexperts.SourceEditorNotifier in 'Source\Dexperts.SourceEditorNotifier.pas',
  Dexperts.Dictionary in 'Source\Dexperts.Dictionary.pas',
  Dexperts.Settings in 'Source\Dexperts.Settings.pas',
  Dexperts.PathProvider in 'Source\Dexperts.PathProvider.pas';

{$R *.res}

begin
end.

