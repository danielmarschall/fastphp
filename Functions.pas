unit Functions;

interface

uses
  Windows, Messages, SysUtils, StrUtils, IniFiles, Classes, Forms, Variants, MsHTML,
  SHDocVw_TLB, StdCtrls, SynEdit, ActiveX;

function GetDosOutput(CommandLine: string; Work: string = ''): string;
function StrIPos(const SubStr, S: string): Integer;
function LoadFileToStr(const FileName: TFileName): AnsiString;
function LastPos(const SubStr, S: string): integer;
function IsTextHTML(s: string): boolean;
function GetWordUnderPos(AMemo: TSynEdit; Line, Column: integer): string;
function GetWordUnderCaret(AMemo: TSynEdit): string;
function MyVarToStr(v: Variant): string;
function FileSystemCaseSensitive: boolean;

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

function IsTextHTML(s: string): boolean;

  function _Tag(const tag: string): integer;
  begin
    result := 0;
    if (StrIPos('<'+tag+'>', s) > 0) then Inc(result);
    if (StrIPos('</'+tag+'>', s) > 0) then Inc(result);
    if (StrIPos('<'+tag+' />', s) > 0) then Inc(result);
    if (StrIPos('<'+tag+' ', s) > 0) then Inc(result);
  end;

  procedure _Check(const tag: string; pair: boolean);
  begin
    if (pair and (_Tag(tag) >= 2)) or (not pair and (_Tag(tag) >= 1)) then result := true;
  end;

begin
  result := false;
  _Check('html', true);
  _Check('body', true);
  _Check('p', false{end tag optional});
  _Check('a', true);
  _Check('b', true);
  _Check('i', true);
  _Check('u', true);
  _Check('li', false{end tag optional});
  _Check('ol', true);
  _Check('ul', true);
  _Check('img', false);
  _Check('div', false);
  _Check('hr', false);
  _Check('code', true);
  _Check('pre', true);
  _Check('blockquote', true);
  _Check('span', true);
  _Check('br', false);
end;

// Template: http://stackoverflow.com/questions/6339446/delphi-get-the-whole-word-where-the-caret-is-in-a-memo
function GetWordUnderPos(AMemo: TSynEdit; Line, Column: integer): string;

  function ValidChar(c: char): boolean;
  begin
    result := CharInSet(c, ['a'..'z', 'A'..'Z', '0'..'9', '_']);
  end;

var
   LineText: string;
   InitPos : Integer;
   EndPos  : Integer;
begin
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

function GetWordUnderCaret(AMemo: TSynEdit): string;
var
   Line    : Integer;
   Column  : Integer;
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

   result := GetWordUnderPos(AMemo, Line, Column);
end;

function MyVarToStr(v: Variant): string;
var
  _Lo, _Hi, i: integer;
begin
  if VarIsNull(v) then
  begin
    result := '';
  end
  else if VarIsArray(v) then
  begin
    _Lo := VarArrayLowBound(v, 1);
    _Hi := VarArrayHighBound(v, 1);
    result := '';
    for i := _Lo to _Hi do
    begin
      if v[i] = 0 then break;
      result := result + chr(integer(v[i]));
    end;
  end
  else
  begin
    // At least try it...
    result := VarToStr(v);
  end;
end;

function FileSystemCaseSensitive: boolean;
begin
  // TODO: This code is not very reliable. At MAC OSX, the file system HFS can be switched
  //       between case sensitivity and insensitivity.
  {$IFDEF LINUX}
  exit(true);
  {$ELSE}
  exit(false);
  {$ENDIF}
end;

end.
