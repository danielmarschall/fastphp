unit BrowserMain;

{$Include 'FastPHP.inc'}

interface

uses
  // TODO: "{$IFDEF USE_SHDOCVW_TLB}_TLB{$ENDIF}" does not work with Delphi 10.2
  //       so you have to change the reference SHDocVw / SHDocVw_TLB yourself
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, OleCtrls, SHDocVw, ExtCtrls, StrUtils,
  StdCtrls, activex, UrlMon;

type
  TForm2 = class(TForm)
    WebBrowser1: TWebBrowser;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    procedure WebBrowser1WindowClosing(ASender: TObject;
      IsChildWindow: WordBool; var Cancel: WordBool);
  strict private
    function EmbeddedWBQueryService(const rsid, iid: TGUID; out Obj{: IInterface}): HRESULT;
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
// TODO: kann man eventuell auch php dateien aus einer DLL rausziehen? das wäre TOLL!!!!
// TODO: headers... cookies...
// TODO: WebBrowser1BeforeNavigate2 mit einem DLL-callback, sodass entwickler ihre eigenen fastphp:// links machen können, z.B. um DLL-Funktionen aufzurufen! (auch in JavaScript ansteuerbar?)
// TODO: let the website decide if the window is maximized etc, as well as it's caption, size and icon
// TODO: Pass parameters (argv) to PHP

type
  TEmbeddedSecurityManager = class(TInterfacedObject, IInternetSecurityManager)
  public
    function GetSecuritySite(out ppSite: IInternetSecurityMgrSite): HResult; stdcall;
    function MapUrlToZone(pwszUrl: LPCWSTR; out dwZone: DWORD; dwFlags: DWORD): HResult; stdcall;
    function GetSecurityId(pwszUrl: LPCWSTR; pbSecurityId: Pointer; var cbSecurityId: DWORD; dwReserved: DWORD): HResult; stdcall;
    function ProcessUrlAction(pwszUrl: LPCWSTR; dwAction: DWORD; pPolicy: Pointer; cbPolicy: DWORD; pContext: Pointer; cbContext: DWORD; dwFlags, dwReserved: DWORD): HResult; stdcall;
    function QueryCustomPolicy(pwszUrl: LPCWSTR; const guidKey: TGUID; out pPolicy: Pointer; out cbPolicy: DWORD; pContext: Pointer; cbContext: DWORD; dwReserved: DWORD): HResult; stdcall;
    function SetZoneMapping(dwZone: DWORD; lpszPattern: PWideChar; dwFlags: DWORD): HResult; stdcall;
    function GetZoneMappings(dwZone: DWORD;out ppenumString: IEnumString; dwFlags: DWORD): HResult; stdcall;
    function SetSecuritySite(pSite: IInternetSecurityMgrSite): HResult; stdcall;
  end;

function TEmbeddedSecurityManager.SetSecuritySite(pSite: IInternetSecurityMgrSite): HResult; stdcall;
begin
  Result := INET_E_DEFAULT_ACTION;
end;
function TEmbeddedSecurityManager.GetSecuritySite(
  out ppSite: IInternetSecurityMgrSite): HResult; stdcall;
begin
  Result := INET_E_DEFAULT_ACTION;
end;
function TEmbeddedSecurityManager.GetSecurityId(pwszUrl: LPCWSTR; pbSecurityId: Pointer;
  var cbSecurityId: DWORD; dwReserved: DWORD): HResult; stdcall;
begin
  Result := INET_E_DEFAULT_ACTION;
end;
function TEmbeddedSecurityManager.ProcessUrlAction(pwszUrl: LPCWSTR; dwAction: DWORD;
  pPolicy: Pointer; cbPolicy: DWORD; pContext: Pointer; cbContext: DWORD;
  dwFlags, dwReserved: DWORD): HResult; stdcall;
begin
  // Result := INET_E_DEFAULT_ACTION;

  // TODO: Doesn't work... Cross-Domain is still not allowed.
  PDWORD(pPolicy)^ := URLPOLICY_ALLOW;
  Result := S_OK;
end;
function TEmbeddedSecurityManager.QueryCustomPolicy(pwszUrl: LPCWSTR; const guidKey: TGUID;
  out pPolicy: Pointer; out cbPolicy: DWORD; pContext: Pointer; cbContext: DWORD;
  dwReserved: DWORD): HResult; stdcall;
begin
  // Result := INET_E_DEFAULT_ACTION;

  // TODO: Doesn't work... Cross-Domain is still not allowed.
  PDWORD(pPolicy)^ := URLPOLICY_ALLOW;
  Result := S_OK;
end;
function TEmbeddedSecurityManager.SetZoneMapping(dwZone: DWORD; lpszPattern: PWideChar;
  dwFlags: DWORD): HResult; stdcall;
begin
  Result := INET_E_DEFAULT_ACTION;
end;
function TEmbeddedSecurityManager.GetZoneMappings(dwZone: DWORD;out ppenumString: IEnumString;
  dwFlags: DWORD): HResult; stdcall;
begin
  Result := INET_E_DEFAULT_ACTION;
end;
function TEmbeddedSecurityManager.MapUrlToZone(pwszUrl: LPCWSTR; out dwZone: DWORD; dwFlags: DWORD): HResult;
begin
  dwZone := URLZONE_TRUSTED;
  Result := S_OK;
end;

function TForm2.EmbeddedWBQueryService(const rsid, iid: TGUID; out Obj{: IInterface}): HRESULT;
var
    sam: IInternetSecurityManager;
begin
    Result := E_NOINTERFACE;

    //rsid ==> Service Identifier
    //iid ==> Interface identifier
    if IsEqualGUID(rsid, IInternetSecurityManager) and IsEqualGUID(iid, IInternetSecurityManager) then
    begin
        sam := TEmbeddedSecurityManager.Create;
        IInterface(Obj) := sam;
        Result := S_OK;
    end;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
var
  phpScript: string;
  sl: TStringList;
begin
  Timer1.Enabled := false;
  phpScript := ParamStr(1);

  // Remove Security
  WebBrowser1.ServiceQuery := EmbeddedWBQueryService;

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

  Application.ProcessMessages; // This is important, otherwise the metatags can't be read...

  sl := TStringList.Create;
  try
    WebBrowser1.ReadMetaTags(sl);
    // TODO: case insensitive
    if sl.Values['fastphp_title'] <> '' then Caption := sl.Values['fastphp_title'];
    if sl.Values['fastphp_width'] <> '' then ClientWidth := StrToInt(sl.Values['fastphp_width']);
    if sl.Values['fastphp_height'] <> '' then ClientHeight := StrToInt(sl.Values['fastphp_height']);
    // TODO: Add more attributes, like HTA applications had
    // TODO: Additionally implement "HTA:APPLICATION" element, see https://docs.microsoft.com/en-us/previous-versions//ms536495%28v%3dvs.85%29
  finally
    FreeAndNil(sl);
  end;
end;

procedure TForm2.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
  myURL, myUrl2, getData: string;
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

    myURL := StringReplace(myURL, 'http://wa.viathinksoft.de', '', []);

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

    // *.xphp is ViaThinkSoft's extension associated to FastPHPBrowser
    // This allows the "executable PHP scripts" to be executed via double click.--
    if FileExists(myURL) and (EndsText('.xphp', myURL) or EndsText('.php', myURL) or EndsText('.php3', myURL) or EndsText('.php4', myURL) or EndsText('.php5', myURL) or EndsText('.phps', myURL)) then
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

        myUrl2 := myUrl;
        myUrl2 := StringReplace(myUrl2, '\', '/', [rfReplaceAll]);
        // TODO: real myURL urlencode
        myUrl2 := StringReplace(myUrl2, '%', '%%', []);
        //myUrl2 := StringReplace(myUrl2, ' ', '%20', []);
        myUrl2 := StringReplace(myUrl2, ' ', '+', []);
        myUrl2 := 'http://wa.viathinksoft.de/' + myUrl2;

        // showmessage(myUrl2);
        WebBrowser1.LoadHTML(GetDosOutput('"'+GetPHPExe+'" -f "'+myURL+'" -- "'+ArgGet+'" "'+ArgPost+'" "'+ArgHeader+'"', ExtractFileDir(Application.ExeName)), myUrl2);
      end;
      Cancel := true;
    end;
  end;
  {$ENDREGION}
end;

procedure TForm2.WebBrowser1WindowClosing(ASender: TObject;
  IsChildWindow: WordBool; var Cancel: WordBool);
begin
  Close;
  Cancel := true;
end;

end.
