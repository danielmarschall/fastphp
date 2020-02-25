unit WebBrowserUtils;

{$Include 'FastPHP.inc'}

interface

uses
  // TODO: "{$IFDEF USE_SHDOCVW_TLB}ShDocVw_TLB{$ELSE}ShDocVw{$ENDIF}" does not work with Delphi 10.2
  Windows, ShDocVw, SysUtils, Forms, Classes;

procedure WaitForBrowser(AWebBrowser: TWebbrowser);

function WebBrowserLoadHTML(AWebBrowser: TWebBrowser; const AHTML: string;
                            const AFakeURL: string=''): boolean;
function WebBrowserLoadStream(AWebBrowser: TWebBrowser; const AStream: TStream;
                            const AFakeURL: string=''): boolean;

type
  TWebBrowserEx = class helper for TWebBrowser
  public
    procedure Clear;
    procedure Wait;
    function LoadHTML(const HTML: string; const AFakeURL: string=''): boolean;
    function LoadStream(const Stream: TStream; const AFakeURL: string=''): boolean;
    procedure ReadMetaTags(outSL: TStringList);
  end;

implementation

uses
  ActiveX, urlmon;

type
  (*
  ILoadHTMLMoniker = interface(IMoniker)
    ['{DCAE3F41-9B38-40EB-B7D0-4AF0FBFBE5AB}']
    procedure InitLoader(sContent, sBaseUrl: string);
  end;
  *)
  TLoadHTMLMoniker = class (TInterfacedObject, IMoniker{, ILoadHTMLMoniker})
  private
    m_stream: IStream;
    m_sBaseName: string;
  public
    procedure InitLoader(sContent, sBaseUrl: string);
    procedure InitLoaderStream(sStream: TStream; sBaseUrl: string);
    {$REGION 'IMoniker members'}
    function BindToObject(const bc: IBindCtx; const mkToLeft: IMoniker;
      const iidResult: TIID; out vResult): HResult; stdcall;
    function BindToStorage(const bc: IBindCtx; const mkToLeft: IMoniker;
      const iid: TIID; out vObj): HResult; stdcall;
    function Reduce(const bc: IBindCtx; dwReduceHowFar: Longint;
      mkToLeft: PIMoniker; out mkReduced: IMoniker): HResult; stdcall;
    function ComposeWith(const mkRight: IMoniker; fOnlyIfNotGeneric: BOOL;
      out mkComposite: IMoniker): HResult; stdcall;
    function Enum(fForward: BOOL; out enumMoniker: IEnumMoniker): HResult;
      stdcall;
    function IsEqual(const mkOtherMoniker: IMoniker): HResult; stdcall;
    function Hash(out dwHash: Longint): HResult; stdcall;
    function IsRunning(const bc: IBindCtx; const mkToLeft: IMoniker;
      const mkNewlyRunning: IMoniker): HResult; stdcall;
    function GetTimeOfLastChange(const bc: IBindCtx; const mkToLeft: IMoniker;
      out filetime: TFileTime): HResult; stdcall;
    function Inverse(out mk: IMoniker): HResult; stdcall;
    function CommonPrefixWith(const mkOther: IMoniker;
      out mkPrefix: IMoniker): HResult; stdcall;
    function RelativePathTo(const mkOther: IMoniker;
      out mkRelPath: IMoniker): HResult; stdcall;
    function GetDisplayName(const bc: IBindCtx; const mkToLeft: IMoniker;
      out pszDisplayName: POleStr): HResult; stdcall;
    function ParseDisplayName(const bc: IBindCtx; const mkToLeft: IMoniker;
      pszDisplayName: POleStr; out chEaten: Longint;
      out mkOut: IMoniker): HResult; stdcall;
    function IsSystemMoniker(out dwMksys: Longint): HResult; stdcall;
    {$ENDREGION}

    {$REGION 'IPersistStream members'}
    function IsDirty: HResult; stdcall;
    function Load(const stm: IStream): HResult; stdcall;
    function Save(const stm: IStream; fClearDirty: BOOL): HResult; stdcall;
    function GetSizeMax(out cbSize: Largeint): HResult; stdcall;
    {$ENDREGION}

    {$REGION 'IPersist members'}
    function GetClassID(out classID: TCLSID): HResult; stdcall;
    {$ENDREGION}
  end;


// http://stackoverflow.com/questions/12605323/globalalloc-causes-my-delphi-app-hang
function StrToGlobalHandle(const aText: string): HGLOBAL;
var
  ptr: PChar;
begin
  Result := 0;
  if aText <> '' then
  begin
    Result := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT, (length(aText) + 1) * SizeOf(Char));
    if Result <> 0 then
    begin
      ptr := GlobalLock(Result);
      if Assigned(ptr) then
      begin
        StrCopy(ptr, PChar(aText));
        GlobalUnlock(Result);
      end
    end;
  end;
end;

procedure WaitForBrowser(AWebBrowser: TWebbrowser);
begin
  while (AWebBrowser.ReadyState <> READYSTATE_COMPLETE) and
        (not Assigned(Application) or not Application.Terminated) do
  begin
    if Assigned(Application) then Application.ProcessMessages;
    Sleep(50);
  end;
end;

function WebBrowserLoadHTML(AWebBrowser: TWebBrowser; const AHTML: string;
                            const AFakeURL: string=''): boolean;
var
  bindctx: IBindCtx;
  pPM: IPersistMoniker;
  loader: TLoadHTMLMoniker;
  url: string;
begin
  if AFakeURL <> '' then
    url := AFakeURL
  else if AWebBrowser.LocationURL <> '' then
    url := AWebBrowser.LocationURL
  else
    url := 'about:blank';

  if AWebBrowser.Document = nil then
  begin
    AWebBrowser.Navigate('about:blank');
    WaitForBrowser(AWebBrowser);
  end;

  pPM := AWebBrowser.Document as IPersistMoniker;
  if (pPM = nil) then
  begin
    result := false;
    exit;
  end;

  bindctx := nil;
  CreateBindCtx(0, bindctx);
  if (bindctx = nil) then
  begin
    result := false;
    exit;
  end;

  try
    // TODO: Delphi2007 and FastMM4 say that here we have a memory leak
    loader := TLoadHTMLMoniker.Create;
    loader.InitLoader(AHTML, url);
  except
    if Assigned(loader) then FreeAndNil(loader);
    result := false;
    exit;
  end;

  result := pPM.Load(true, loader, bindctx, STGM_READ) = S_OK;

  if not result and Assigned(loader) then FreeAndNil(loader);
end;

function WebBrowserLoadStream(AWebBrowser: TWebBrowser; const AStream: TStream;
                            const AFakeURL: string=''): boolean;
var
  bindctx: IBindCtx;
  pPM: IPersistMoniker;
  loader: TLoadHTMLMoniker;
  url: string;
begin
  if AFakeURL <> '' then
    url := AFakeURL
  else if AWebBrowser.LocationURL <> '' then
    url := AWebBrowser.LocationURL
  else
    url := 'about:blank';

  if AWebBrowser.Document = nil then
  begin
    AWebBrowser.Navigate('about:blank');
    WaitForBrowser(AWebBrowser);
  end;

  pPM := AWebBrowser.Document as IPersistMoniker;
  if (pPM = nil) then
  begin
    result := false;
    exit;
  end;

  bindctx := nil;
  CreateBindCtx(0, bindctx);
  if (bindctx = nil) then
  begin
    result := false;
    exit;
  end;

  try
    // TODO: Delphi2007 and FastMM4 say that here we have a memory leak
    loader := TLoadHTMLMoniker.Create;
    loader.InitLoaderStream(AStream, url);
  except
    if Assigned(loader) then FreeAndNil(loader);
    result := false;
    exit;
  end;

  result := pPM.Load(true, loader, bindctx, STGM_READ) = S_OK;

  if not result and Assigned(loader) then FreeAndNil(loader);
end;

{ TLoadHTMLMoniker }

// TLoadHTMLMoniker. Translated from C# to Delphi by Daniel Marschall
// Resources:
// - http://stackoverflow.com/questions/40927080/relative-urls-in-a-twebbrowser-containing-custom-html-code
// - https://github.com/kuza55/csexwb2/blob/master/General_Classes/LoadHTMLMoniker.cs
// - https://github.com/kuza55/csexwb2/blob/master/cEXWB.cs#L1769

procedure TLoadHTMLMoniker.InitLoader(sContent, sBaseUrl: string);
resourcestring
  SCannotAllocMemory = 'Cannot create IStream.';
var
  hr: integer;
begin
  m_sBaseName := sBaseUrl;
  hr := CreateStreamOnHGlobal(StrToGlobalHandle(sContent), true, m_stream);
  if ((hr <> S_OK) or (m_stream = nil)) then raise Exception.Create(SCannotAllocMemory);
end;

procedure TLoadHTMLMoniker.InitLoaderStream(sStream: TStream; sBaseUrl: string);
resourcestring
  SCannotAllocMemory = 'Cannot create IStream.';
begin
  m_sBaseName := sBaseUrl;
  m_stream := TStreamAdapter.Create(sStream, soReference) as IStream;
  if (m_stream = nil) then raise Exception.Create(SCannotAllocMemory);
end;

function TLoadHTMLMoniker.GetDisplayName(const bc: IBindCtx;
  const mkToLeft: IMoniker; out pszDisplayName: POleStr): HResult;
var
  bufSize: integer;
  wTest: WideString;
begin
//  pszDisplayName := PWideChar(WideString(m_sBaseName));

  // I am not sure if that is correct......
  bufSize := (Length(m_sBaseName)+1) * SizeOf(WideChar);
  pszDisplayName := CoTaskMemAlloc(bufSize);
  wTest := m_sBaseName;
  CopyMemory(pszDisplayName, PWideChar(wTest), bufSize);

  result := S_OK;
end;

function TLoadHTMLMoniker.BindToStorage(const bc: IBindCtx;
  const mkToLeft: IMoniker; const iid: TIID; out vObj): HResult;
const
  IID_IStream: TGUID = '{0000000C-0000-0000-C000-000000000046}';
begin
  if IsEqualIID(iid, IID_IStream) then
  begin
    IStream(vObj) := m_stream;
    result := S_OK;
  end
  else
  begin
    IStream(vObj) := nil;
    result := E_NOINTERFACE;
  end;
end;

{$REGION 'Not implemented'}
function TLoadHTMLMoniker.BindToObject(const bc: IBindCtx;
  const mkToLeft: IMoniker; const iidResult: TIID; out vResult): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.CommonPrefixWith(const mkOther: IMoniker;
  out mkPrefix: IMoniker): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.ComposeWith(const mkRight: IMoniker;
  fOnlyIfNotGeneric: BOOL; out mkComposite: IMoniker): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.Enum(fForward: BOOL;
  out enumMoniker: IEnumMoniker): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.GetClassID(out classID: TCLSID): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.GetSizeMax(out cbSize: Largeint): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.GetTimeOfLastChange(const bc: IBindCtx;
  const mkToLeft: IMoniker; out filetime: TFileTime): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.Hash(out dwHash: Integer): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.Inverse(out mk: IMoniker): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.IsDirty: HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.IsEqual(const mkOtherMoniker: IMoniker): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.IsRunning(const bc: IBindCtx; const mkToLeft,
  mkNewlyRunning: IMoniker): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.IsSystemMoniker(out dwMksys: Integer): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.Load(const stm: IStream): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.ParseDisplayName(const bc: IBindCtx;
  const mkToLeft: IMoniker; pszDisplayName: POleStr; out chEaten: Integer;
  out mkOut: IMoniker): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.Reduce(const bc: IBindCtx; dwReduceHowFar: Integer;
  mkToLeft: PIMoniker; out mkReduced: IMoniker): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.RelativePathTo(const mkOther: IMoniker;
  out mkRelPath: IMoniker): HResult;
begin
  result := E_NOTIMPL;
end;

function TLoadHTMLMoniker.Save(const stm: IStream; fClearDirty: BOOL): HResult;
begin
  result := E_NOTIMPL;
end;
{$ENDREGION}

{ TWebBrowserEx }

procedure TWebBrowserEx.Wait;
begin
  WaitForBrowser(Self);
end;

function TWebBrowserEx.LoadHTML(const HTML: string; const AFakeURL: string=''): boolean;
begin
  result := WebBrowserLoadHTML(Self, HTML, AFakeURL);
  Self.Wait;
end;

function TWebBrowserEx.LoadStream(const Stream: TStream; const AFakeURL: string=''): boolean;
begin
  result := WebBrowserLoadStream(Self, Stream, AFakeURL);
  Self.Wait;
end;

procedure TWebBrowserEx.ReadMetaTags(outSL: TStringList);
var
  vDocument: OleVariant;
  vMetas: OleVariant;
  vMetaItem: OleVariant;
  i: Integer;
begin
  vDocument := Self.Document;
  vMetas := vDocument.GetElementsByTagName('meta');
  for i := 0 to vMetas.Length-1 do
  begin
    vMetaItem := vMetas.Item(i);
    if string(vMetaItem.httpequiv) = '' then
      outSL.Values[vMetaItem.Name] := vMetaItem.Content
    else
      outSL.Values[vMetaItem.httpequiv] := vMetaItem.Content;
  end;
end;

procedure TWebBrowserEx.Clear;
begin
  Self.LoadHTML('', 'about:blank');
end;

end.
