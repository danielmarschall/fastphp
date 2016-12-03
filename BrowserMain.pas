unit BrowserMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw_TLB, Vcl.ExtCtrls, StrUtils;

type
  TForm2 = class(TForm)
    WebBrowser1: TWebBrowser;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

uses
  WebBrowserUtils, FastPHPUtils, Functions;

// TODO: Add a lot of nice stuff to let the PHP script communicate with this host application
//       For example, allow window resizing etc.  (See Microsoft HTA for inspiration)
// TODO: Ajax gives Access Denied error... Create own security manager?
// TODO: History doesn't work?
// TODO: Pass HTTP parameters to php executable
// (All these ToDos: Also fix in the Editor)

procedure TForm2.Timer1Timer(Sender: TObject);
var
  phpScript: string;
begin
  Timer1.Enabled := false;
  phpScript := ParamStr(1);

  WebBrowser1.LoadHTML('<h1>FastPHP</h1>Running script... please wait...');

  // TODO: nice HTML error/intro pages (as resource?)
  if phpScript = '' then
  begin
    WebBrowser1.LoadHTML('<h1>FastPHP</h1>Please enter a PHP file to execute.');
    Abort;
  end;

  if not FileExists(phpScript) then
  begin
    WebBrowser1.LoadHTML(Format('<h1>FastPHP</h1>File %s does not exist.', [phpScript]));
    Abort;
  end;

  WebBrowser1.LoadHTML(RunPHPScript(phpScript), phpScript);
end;

procedure TForm2.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
  s, myURL: string;
  lineno: integer;
  p: integer;
begin
  {$REGION 'Line number references (PHP errors and warnings)'}
  if Copy(URL, 1, length(FASTPHP_GOTO_URI_PREFIX)) = FASTPHP_GOTO_URI_PREFIX then
  begin
    ShowMessage('This action only works in FastPHP editor.');
    Cancel := true;
    Exit;
  end;
  {$ENDREGION}

  {$REGION 'Intelligent browser (executes PHP scripts)'}
  if URL <> 'about:blank' then
  begin
    myUrl := URL;

    p := Pos('?', myUrl);
    if p >= 1 then myURL := copy(myURL, 1, p-1);

    // TODO: myURL urldecode
    // TODO: maybe we could even open that file in the editor!

    if FileExists(myURL) and (EndsText('.php', myURL) or EndsText('.php3', myURL) or EndsText('.php4', myURL) or EndsText('.php5', myURL) or EndsText('.phps', myURL)) then
    begin
      WebBrowser1.LoadHTML(GetDosOutput('"'+GetPHPExe+'" "'+myURL+'"', ExtractFileDir(Application.ExeName)), myUrl);
      Cancel := true;
    end;
  end;
  {$ENDREGION}
end;

end.
