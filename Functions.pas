unit Functions;

interface

uses
  Windows, Messages, SysUtils, StrUtils, IniFiles, Classes, Forms, Variants, MsHTML,
  SHDocVw_TLB, StdCtrls, SynEdit;

function GetDosOutput(CommandLine: string; Work: string = ''): string;
function StrIPos(const SubStr, S: string): Integer;
procedure WaitForBrowser(WB: TWebbrowser);
function LoadFileToStr(const FileName: TFileName): AnsiString;
function LastPos(const SubStr, S: string): integer;
function ParseCHM(chmFile: string): boolean;
procedure BrowseURL(WebBrowser1: TWebBrowser; url: string);
procedure BrowseContent(WebBrowser1: TWebBrowser; html: string);
function IsTextHTML(s: string): boolean;
function GetWordUnderCaret(AMemo: TSynEdit): string;
function IsValidPHPExe(const exeFile: string): boolean;

implementation

function GetDosOutput(CommandLine: string; Work: string = ''): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  Handle: Boolean;
begin
  if Work = '' then Work := ExtractFilePath(ParamStr(0));

  Result := '';
  with SA do begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  try
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    WorkDir := Work;
    Handle := CreateProcess(nil, PChar('cmd.exe /C "' + CommandLine + '"'),
                            nil, nil, True, 0, nil,
                            PChar(WorkDir), SI, PI);
    CloseHandle(StdOutPipeWrite);
    if Handle then
      try
        repeat
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            Buffer[BytesRead] := #0;
            Result := Result + Buffer;
          end;
        until not WasOK or (BytesRead = 0);
        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
end;

function StrIPos(const SubStr, S: string): Integer;
begin
  Result := Pos(UpperCase(SubStr), UpperCase(S));
end;

procedure WaitForBrowser(WB: TWebbrowser);
begin
  while (WB.Busy)
    and not (Application.Terminated) do
  begin
    Application.ProcessMessages;
    Sleep(100);
  end;
end;

function LoadFileToStr(const FileName: TFileName): AnsiString;
var
  FileStream : TFileStream;

begin
  Result:= '';
  FileStream:= TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    if FileStream.Size>0 then begin
      SetLength(Result, FileStream.Size);
      FileStream.Read(Result[1], FileStream.Size);
    end;
  finally
    FileStream.Free;
  end;
end;

function LastPos(const SubStr, S: string): integer;
var
  I, J, K: integer;
begin
  Result := 0;
  I := Length(S);
  K := Length(SubStr);
  if (K = 0) or (K > I) then
    Exit;
  while (Result = 0) and (I >= K) do
  begin
    J := K;
    if S[I] = SubStr[J] then
    begin
      while (J > 1) and (S[I + J - K - 1] = SubStr[J - 1]) do
        Dec(J);
      if J = 1 then
        Result := I - K + 1;
    end;
    Dec(I);
  end;
end;

function ParseCHM(chmFile: string): boolean;
var
  test, candidate, candidate2: string;
  p, p2, q: integer;
  i: integer;
  good: Boolean;
  ini: TMemIniFile;
  domain: string;
  sl: TStringList;
  symbolCount: Integer;
  sl2: TStrings;
  outFile: string;
begin
  // TODO: problem:  mysqli::commit has /res/mysqli.commit.html -> keyword is NOT commit alone

  outFile := ChangeFileExt(chmFile, '.ini');
  DeleteFile(outFile);
  test := LoadFileToStr(chmFile);
  if Pos('/php_manual_', test) = -1 then
  begin
    result := false;
    exit;
  end;
  p := 0;
  ini := TMemIniFile.Create(outFile);
  try
    ini.WriteString('_Info_', 'Source', chmFile);
    ini.WriteString('_Info_', 'Generated', DateTimeToStr(Now));
    ini.WriteString('_Info_', 'GeneratorVer', '1.0');
    ini.WriteString('_Info_', 'Signature', '$ViaThinkSoft$');
    {$REGION 'Excludes'}
    // TODO: more excludes
    ini.WriteBool('_HelpExclude_', 'about', true);
    ini.WriteBool('_HelpExclude_', 'apache', true);
    {$ENDREGION}
    while true do
    begin
      Application.ProcessMessages;

      p := PosEx('/res/', Test, p+1);
      if p = 0 then break;
      p2 := PosEx('.html', Test, p);
      if p = 0 then break;
      candidate := copy(Test, p+5, p2-p-5);
      if candidate = '' then continue;
      if Length(candidate) > 50 then continue;
      good := true;
      for i := p+5 to p2-1 do
      begin
        if ord(test[i]) < 32 then
        begin
          good := false;
          break;
        end;
        if not (test[i] in ['a'..'z', 'A'..'Z', '.', '-', '_', '0'..'9']) then
        begin
          ini.WriteInteger('_Errors_', 'Contains unexpected character! ' + candidate, ini.ReadInteger('_Errors_', 'Contains unexpected character! ' + candidate, 0)+1);
          good := false;
          break;
        end;
      end;
      if good then
      begin
        candidate2 := LowerCase(StringReplace(candidate, '-', '_', [rfReplaceAll]));
        q := LastPos('.', candidate2);
        domain := copy(candidate2, 1, q-1);
        if domain = '' then continue;
        candidate2 := copy(candidate2, q+1, Length(candidate2)-q);
        ini.WriteInteger('_Category_', domain, ini.ReadInteger('_Category_', domain, 0)+1);
        ini.WriteString(domain, candidate2, '/res/'+candidate+'.html');
        if not ini.ReadBool('_HelpExclude_', domain, false)
           and (candidate2 <> 'configuration')
           and (candidate2 <> 'constants')
           and (candidate2 <> 'installation')
           and (candidate2 <> 'requirements')
           and (candidate2 <> 'resources')
           and (candidate2 <> 'setup') then
        begin
          if ini.ReadString('_HelpWords_', candidate2, '') <> '' then
          begin
            ini.WriteInteger('_Conflicts_', candidate2, ini.ReadInteger('_Conflicts_', candidate2, 0)+1);
          end;

          ini.WriteString('_HelpWords_', candidate2, '/res/'+candidate+'.html');
        end;
      end;
    end;

    sl := TStringList.Create;
    sl2 := TStringList.Create;
    try
      ini.ReadSections(sl);
      ini.WriteInteger('_Info_', 'TotalDomains', sl.Count);
      symbolCount := 0;
      for domain in sl do
      begin
        ini.ReadSection(domain, sl2);
        Inc(symbolCount, sl2.Count)
      end;
      ini.WriteInteger('_Info_', 'TotalSymbols', symbolCount);
    finally
      sl.Free;
      sl2.Free;
    end;

    ini.UpdateFile;
    result := true;
  finally
    ini.Free;
  end;
end;

procedure BrowseURL(WebBrowser1: TWebBrowser; url: string);
var
  BrowserFlags : olevariant;
  MyTargetFrameName : olevariant;
  MyPostaData : olevariant;
  MyHeaders : olevariant;
begin
{ Flags:
Constant            Value Meaning
NavOpenInNewWindow  $01  Open the resource or file in a new window.
NavNoHistory        $02  Do not add the resource or file to the history list. The new page replaces the current page in the list.
NavNoReadFromCache  $04  Do not read from the disk cache for this navigation.
NavNoWriteToCache   $08  Do not write the results of this navigation to the disk cache.
NavAllowAutosearch  $10  If the navigation fails, the Web browser attempts to navigate common root domains (.com, .org, and so on). If this still fails, the URL is passed to a search engine.
}
  BrowserFlags := $02;
  MyTargetFrameName := null;
  MyPostaData := null;
  MyHeaders := null;
  WebBrowser1.Silent := true; // no JavaScript errors
  Webbrowser1.Navigate(url, BrowserFlags,MyTargetFrameName,MyPostaData,MyHeaders);
  WaitForBrowser(WebBrowser1);
end;

procedure BrowseContent(WebBrowser1: TWebBrowser; html: string);
var
  BrowserFlags : olevariant;
  MyTargetFrameName : olevariant;
  MyPostaData : olevariant;
  MyHeaders : olevariant;
  Doc: Variant;
begin
{ Flags:
Constant            Value Meaning
NavOpenInNewWindow  $01  Open the resource or file in a new window.
NavNoHistory        $02  Do not add the resource or file to the history list. The new page replaces the current page in the list.
NavNoReadFromCache  $04  Do not read from the disk cache for this navigation.
NavNoWriteToCache   $08  Do not write the results of this navigation to the disk cache.
NavAllowAutosearch  $10  If the navigation fails, the Web browser attempts to navigate common root domains (.com, .org, and so on). If this still fails, the URL is passed to a search engine.
}
  if WebBrowser1.Document = nil then
  begin
    BrowserFlags := $02 + $04 + $08 + $10;
    MyTargetFrameName := null;
    MyPostaData := null;
    MyHeaders := null;
    Webbrowser1.Navigate('about:blank', BrowserFlags,MyTargetFrameName,MyPostaData,MyHeaders);
    WaitForBrowser(WebBrowser1);
  end;

  Doc := WebBrowser1.Document;
  Doc.Clear;
  Doc.Write(html);
  Doc.Close;
  WaitForBrowser(WebBrowser1);
end;

function IsTextHTML(s: string): boolean;

  function _Tag(const tag: string): integer;
  begin
    result := 0;
    if (StrIPos('<'+tag+'>', s) > 0) then Inc(result);
    if (StrIPos('</'+tag+'>', s) > 0) then Inc(result);
    if (StrIPos('<'+tag+' />', s) > 0) then Inc(result);
    if (StrIPos('<'+tag+' ', s) > 0) then Inc(result);
  end;

var
  score: integer;
begin
  score := _Tag('html') + _Tag('body') + _Tag('p') + _Tag('a') + _Tag('b') +
           _Tag('i') + _Tag('u') + _Tag('li') + _Tag('ol') + _Tag('ul') +
           _Tag('img') + _Tag('div') + _Tag('hr') + _Tag('code') +
           _Tag('pre') + _Tag('blockquote') + _Tag('span');
  result := score >= 2;
end;

// Template: http://stackoverflow.com/questions/6339446/delphi-get-the-whole-word-where-the-caret-is-in-a-memo
function GetWordUnderCaret(AMemo: TSynEdit): string;

  function ValidChar(c: char): boolean;
  begin
    result := c in ['a'..'z', 'A'..'Z', '0'..'9', '_'];
  end;

var
   Line    : Integer;
   Column  : Integer;
   LineText: string;
   InitPos : Integer;
   EndPos  : Integer;
begin
   //Get the caret position
   (*
   if AMemo is TMemo then
   begin
     Line   := AMemo.Perform(EM_LINEFROMCHAR,AMemo.SelStart, 0);
     Column := AMemo.SelStart - AMemo.Perform(EM_LINEINDEX, Line, 0);
   end;
   if AMemo is TSynEdit then
   begin
   *)
     Line := AMemo.CaretY-1;
     Column := AMemo.CaretX-1;
   (*
   end;
   *)

   //Validate the line number
   if AMemo.Lines.Count-1 < Line then Exit;

   //Get the text of the line
   LineText := AMemo.Lines[Line];

   if LineText = '' then exit('');

   // Column zeigt auf das Zeichen LINKS vom Cursor!

   InitPos := Column;
   if not ValidChar(LineText[InitPos]) then Inc(InitPos);
   while (InitPos-1 >= 1) and ValidChar(LineText[InitPos-1]) do Dec(InitPos);

   EndPos := Column;
   while (EndPos+1 <= Length(LineText)) and ValidChar(LineText[EndPos+1]) do Inc(EndPos);

   //Get the text
   Result := Copy(LineText, InitPos, EndPos - InitPos + 1);
end;

function IsValidPHPExe(const exeFile: string): boolean;
var
  cont: string;
begin
  cont := LoadFileToStr(exeFile);
  result := (Pos('php://stdout', cont) >= 0) or
            (Pos('PHP_SELF', cont) >= 0);
end;

end.
