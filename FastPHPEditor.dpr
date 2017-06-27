program FastPHPEditor;

uses
  Forms,
  EditorMain in 'EditorMain.pas' {Form1},
  Functions in 'Functions.pas',
  WebBrowserUtils in 'WebBrowserUtils.pas',
  FastPHPUtils in 'FastPHPUtils.pas',
  FindReplace in 'FindReplace.pas';

{$R *.res}

begin
  Application.Initialize;
  // Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
