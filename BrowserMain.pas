unit BrowserMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw_TLB, Vcl.ExtCtrls, StrUtils,
  Vcl.StdCtrls, activex, UrlMon;

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
  WebBrowserUtils, FastPHPUtils, Functions, ShellAPI;

// TODO: Add a lot of nice stuff to let the PHP script communicate with this host application
//       For example, allow window resizing etc.  (See Microsoft HTA for inspiration)
// TODO: Ajax gives Access Denied error... Create own security manager?
// TODO: History doesn't work?
// (All these ToDos: Also fix in the Editor)
// TODO: kann man eventuell auch php dateien aus einer DLL rausziehen? das w�re TOLL!!!!
// TODO: headers... cookies...
// TODO: WebBrowser1BeforeNavigate2 mit einem DLL-callback, sodass entwickler ihre eigenen fastphp:// links machen k�nnen!

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
  myURL, getData: string;
  p: integer;
  background: boolean;
  ArgGet, ArgPost, ArgHeader: string;
begin
  background := Pos('background|', URL) >= 1;

  {$REGION 'Line number references (PHP errors and warnings)'}
  if Copy(URL, 1, length(FASTPHP_GOTO_URI_PREFIX)) = FASTPHP_GOTO_URI_PREFIX then
  begin
    // TODO: maybe we could even open that file in the editor!
    ShowMessage('This action only works in FastPHP editor.');
    Cancel := true;
    Exit;
  end;
  {$ENDREGION}

  {$REGION 'Intelligent browser (executes PHP scripts)'}
  if URL <> 'about:blank' then
  begin
    myUrl := URL;

    myurl := StringReplace(myurl, 'background|', '', []);

    p := Pos('?', myUrl);
    if p >= 1 then
    begin
      getData := copy(myURL, p+1, Length(myURL)-p);
      myURL := copy(myURL, 1, p-1);
    end
    else
    begin
      getData := '';
    end;

    myURL := StringReplace(myURL, 'file:///', '', []);
    myURL := StringReplace(myURL, '/', '\', [rfReplaceAll]);

    // TODO: real myURL urldecode
    myURL := StringReplace(myURL, '+', ' ', []);
    myURL := StringReplace(myURL, '%20', ' ', []);
    myURL := StringReplace(myURL, '%%', '%', []);

    ArgHeader := '';
    ArgHeader := MyVarToStr(Headers);
    ArgHeader := StringReplace(ArgHeader, #13, '|CR|', [rfReplaceAll]);
    ArgHeader := StringReplace(ArgHeader, #10, '|LF|', [rfReplaceAll]);

    if FileExists(myURL) and (EndsText('.php', myURL) or EndsText('.php3', myURL) or EndsText('.php4', myURL) or EndsText('.php5', myURL) or EndsText('.phps', myURL)) then
    begin
      if background then
      begin
        // TODO: how to detach the process?
        ShellExecute(0, 'open', PChar(GetPHPExe), PChar('"'+myURL+'" "'+ArgGet+'" "'+ArgPost+'" "'+ArgHeader+'"'), PChar(ExtractFileDir(Application.ExeName)), SW_HIDE);
      end
      else
      begin
        // TODO: somehow prepend fastphp_server.inc.php (populates the $_GET and $_POST arrays)
        // TODO: is there a maximal length for the command line?
        ArgGet := MyVarToStr(getData);
        ArgPost := MyVarToStr(PostData);
        WebBrowser1.LoadHTML(GetDosOutput('"'+GetPHPExe+'" "'+myURL+'" "'+ArgGet+'" "'+ArgPost+'" "'+ArgHeader+'"', ExtractFileDir(Application.ExeName)), myUrl);
      end;
      Cancel := true;
    end;
  end;
  {$ENDREGION}
end;

end.
