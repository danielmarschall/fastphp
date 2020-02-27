program FastPHPEditor;

uses
  Forms,
  EditorMain in 'EditorMain.pas' {Form1},
  Functions in 'Functions.pas',
  WebBrowserUtils in 'WebBrowserUtils.pas',
  FastPHPUtils in 'FastPHPUtils.pas',
  FindReplace in 'FindReplace.pas',
  RunPHP in 'RunPHP.pas',
  FastPHPTreeView in 'FastPHPTreeView.pas',
  ImageListEx in 'ImageListEx.pas',
  FastPHPConfig in 'FastPHPConfig.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ELSE}
  ReportMemoryLeaksOnShutdown := False;
  {$ENDIF}
  Application.Initialize;
  // Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
