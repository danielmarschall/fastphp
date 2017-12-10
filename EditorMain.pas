unit EditorMain;

{$Include 'FastPHP.inc'}

(*
  This program requires
  - Microsoft Internet Controls (TWebBrowser)
    If you are using Delphi 10.1 Starter Edition, please import the ActiveX TLB
    "Microsoft Internet Controls"
  - SynEdit
    You can obtain SynEdit via Embarcadero GetIt
*)

// TODO: localize
// TODO: wieso geht copy paste im twebbrowser nicht???
// Wieso dauert webbrowser1 erste kompilierung so lange???
// TODO: wieso kommt syntax fehler zweimal? einmal stderr einmal stdout?
// TODO: Browser titlebar (link preview)
// TODO: todo liste

// Future ideas
// - code explorer / code insight
// - verschiedene php versionen?
// - webbrowser1 nur laden, wenn man den tab anw‰hlt?
// - doppelklick auf tab soll diesen schlieﬂen
// - Onlinehelp (www) aufrufen
// - Let all colors be adjustable
// - code in bildschirmmitte (horizontal)?

interface

uses
  // TODO: "{$IFDEF USE_SHDOCVW_TLB}_TLB{$ENDIF}" does not work with Delphi 10.2
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, ComCtrls, ExtCtrls, ToolWin, IniFiles,
  SynEditHighlighter, SynHighlighterPHP, SynEdit, ShDocVw_TLB, FindReplace,
  System.Actions, Vcl.ActnList, System.UITypes, SynEditMiscClasses,
  SynEditSearch, RunPHP;

{.$DEFINE OnlineHelp}

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    PlaintextTabSheet: TTabSheet;
    HtmlTabSheet: TTabSheet;
    Memo2: TMemo;
    WebBrowser1: TWebBrowser;
    Splitter1: TSplitter;
    PageControl2: TPageControl;
    CodeTabsheet: TTabSheet;
    HelpTabsheet: TTabSheet;
    WebBrowser2: TWebBrowser;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    OpenDialog3: TOpenDialog;
    SynEdit1: TSynEdit;
    SynPHPSyn1: TSynPHPSyn;
    Panel2: TPanel;
    SynEditFocusTimer: TTimer;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    ActionList: TActionList;
    ActionFind: TAction;
    ActionReplace: TAction;
    ActionFindNext: TAction;
    ActionGoto: TAction;
    ActionSave: TAction;
    ActionHelp: TAction;
    ActionRun: TAction;
    ActionESC: TAction;
    Button7: TButton;
    ActionOpen: TAction;
    Button8: TButton;
    Button9: TButton;
    ActionFindPrev: TAction;
    Timer1: TTimer;
    ActionSpaceToTab: TAction;
    Button11: TButton;
    SynEditSearch1: TSynEditSearch;
    TreeView1: TTreeView;
    Splitter2: TSplitter;
    procedure Run(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PageControl2Changing(Sender: TObject; var AllowChange: Boolean);
    procedure Memo2DblClick(Sender: TObject);
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    procedure SynEditFocusTimerTimer(Sender: TObject);
    procedure ActionFindExecute(Sender: TObject);
    procedure ActionReplaceExecute(Sender: TObject);
    procedure ActionFindNextExecute(Sender: TObject);
    procedure ActionGotoExecute(Sender: TObject);
    procedure ActionSaveExecute(Sender: TObject);
    procedure ActionHelpExecute(Sender: TObject);
    procedure ActionRunExecute(Sender: TObject);
    procedure ActionESCExecute(Sender: TObject);
    procedure SynEdit1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure SynEdit1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ActionOpenExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Memo2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionFindPrevExecute(Sender: TObject);
    procedure SynEdit1MouseCursor(Sender: TObject;
      const aLineCharPos: TBufferCoord; var aCursor: TCursor);
    procedure Timer1Timer(Sender: TObject);
    procedure ActionSpaceToTabExecute(Sender: TObject);
    procedure TreeView1DblClick(Sender: TObject);
    procedure SynEdit1GutterClick(Sender: TObject; Button: TMouseButton; X, Y,
      Line: Integer; Mark: TSynEditMark);
  private
    CurSearchTerm: string;
    HlpPrevPageIndex: integer;
    SrcRep: TSynEditFindReplace;
    {$IFDEF OnlineHelp}
    gOnlineHelpWord: string;
    {$ENDIF}
    procedure Help;
    function MarkUpLineReference(cont: string): string;
    function InputRequestCallback: string;
    procedure OutputNotifyCallback(const data: string);
  protected
    ChmIndex: TMemIniFile;
    FScrapFile: string;
    codeExplorer: TRunCodeExplorer;
    procedure GotoLineNo(LineNo: integer);
    function GetScrapFile: string;
    procedure StartCodeExplorer;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{$R Cursors.res}

uses
  Functions, StrUtils, WebBrowserUtils, FastPHPUtils, Math, ShellAPI, RichEdit,
  FastPHPTreeView;

const
  crMouseGutter = 1;

// TODO: FindPrev ?
procedure TForm1.ActionFindNextExecute(Sender: TObject);
begin
  SrcRep.FindNext;
end;

procedure TForm1.ActionFindPrevExecute(Sender: TObject);
begin
  SrcRep.FindPrev;
end;

procedure TForm1.ActionGotoExecute(Sender: TObject);
var
  val: string;
  lineno: integer;
begin
  // TODO: VK_LMENU does not work! only works with AltGr but not Alt
  // http://stackoverflow.com/questions/16828250/delphi-xe2-how-to-prevent-the-alt-key-stealing-focus ?

  InputQuery('Go to', 'Line number:', val);
  if not TryStrToInt(val, lineno) then
  begin
    if SynEdit1.CanFocus then SynEdit1.SetFocus;
    exit;
  end;
  GotoLineNo(lineno);
end;

procedure TForm1.ActionHelpExecute(Sender: TObject);
begin
  Help;
  if PageControl2.ActivePage = HelpTabsheet then
    WebBrowser2.SetFocus
  else if PageControl2.ActivePage = CodeTabsheet then
    SynEdit1.SetFocus;
end;

procedure TForm1.ActionOpenExecute(Sender: TObject);
begin
  If OpenDialog3.Execute then
  begin
    ShellExecute(0, 'open', PChar(ParamStr(0)), PChar(OpenDialog3.FileName), '', SW_NORMAL);
  end;
end;

procedure TForm1.ActionReplaceExecute(Sender: TObject);
begin
  SrcRep.ReplaceExecute;
end;

procedure TForm1.ActionRunExecute(Sender: TObject);
begin
  Run(Sender);
  SynEdit1.SetFocus;
end;

procedure TForm1.ActionSaveExecute(Sender: TObject);
begin
  SynEdit1.Lines.SaveToFile(GetScrapFile);
  SynEdit1.Modified := false;
end;

procedure TForm1.ActionSpaceToTabExecute(Sender: TObject);

    function SpacesAtBeginning(line: string): integer;
    begin
      if line.Trim = '' then exit(0);
      result := 0;
      while line[result+1] = ' ' do
      begin
        inc(result);
      end;
    end;

    function GuessIndent(lines: TStrings): integer;
      function _Check(indent: integer): boolean;
      var
        i: integer;
      begin
        result := true;
        for i := 0 to lines.Count-1 do
          if SpacesAtBeginning(lines.Strings[i]) mod indent <> 0 then
          begin
            // ShowMessageFmt('Zeile "%s" nicht durch %d teilbar!', [lines.strings[i], indent]);
            exit(false);
          end;
      end;
    var
      i: integer;
    begin
      for i := 8 downto 2 do
      begin
        if _Check(i) then exit(i);
      end;
      result := -1;
    end;

    procedure SpaceToTab(lines: TStrings; indent: integer);
    var
      i, spaces: integer;
    begin
      for i := 0 to lines.Count-1 do
      begin
        spaces := SpacesAtBeginning(lines.Strings[i]);
        lines.Strings[i] := StringOfChar(#9, spaces div indent) + StringOfChar(' ', spaces mod indent) + Copy(lines.Strings[i], spaces+1, Length(lines.Strings[i])-spaces);
      end;
    end;

    function SpacesAvailable(lines: TStrings): boolean;
    var
      i, spaces: integer;
    begin
      for i := 0 to lines.Count-1 do
      begin
        spaces := SpacesAtBeginning(lines.Strings[i]);
        if spaces > 0 then exit(true);
      end;
      exit(false);
    end;

var
  val: string;
  ind: integer;
resourcestring
  SNoLinesAvailable = 'No lines with spaces at the beginning available';
begin
  // TODO: if something is selected, only process the selected part

  if not SpacesAvailable(SynEdit1.Lines) then
  begin
    ShowMessage(SNoLinesAvailable);
    exit;
  end;

  ind := GuessIndent(SynEdit1.Lines);
  if ind <> -1 then val := IntToStr(ind);

  InputQuery('Spaces to tabs', 'Indent:', val); // TODO: handle CANCEL correctly...
  if TryStrToInt(val.Trim, ind) then
  begin
    if ind = 0 then exit;
    SpaceToTab(SynEdit1.Lines, ind);
  end;

  if SynEdit1.CanFocus then SynEdit1.SetFocus;
end;

procedure TForm1.ActionESCExecute(Sender: TObject);
begin
  if (HlpPrevPageIndex <> -1) and (PageControl2.ActivePage = HelpTabSheet) and
     (HelpTabsheet.TabVisible) then
  begin
    PageControl2.ActivePageIndex := HlpPrevPageIndex;
    HelpTabsheet.TabVisible := false;
  end;

  // Dirty hack...
  SrcRep.CloseDialogs;
end;

procedure TForm1.ActionFindExecute(Sender: TObject);
begin
  SrcRep.FindExecute;
end;

var
  firstTimeBrowserLoad: boolean = true;
procedure TForm1.Run(Sender: TObject);
var
  bakTS: TTabSheet;
begin
  memo2.Lines.Text := '';

  if firstTimeBrowserLoad then
  begin
    bakTS := PageControl1.ActivePage;
    try
      PageControl1.ActivePage := HtmlTabSheet; // Required for the first time, otherwise, WebBrowser1.Clear will hang
      Webbrowser1.Clear;
    finally
      PageControl1.ActivePage := bakTS;
    end;
    firstTimeBrowserLoad := false;
  end
  else
    Webbrowser1.Clear;

  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;

  try
    SynEdit1.Lines.SaveToFile(GetScrapFile);

    memo2.Lines.Text := RunPHPScript(GetScrapFile);

    Webbrowser1.LoadHTML(MarkUpLineReference(memo2.Lines.Text), GetScrapFile);

    if IsTextHTML(memo2.lines.text) then
      PageControl1.ActivePage := HtmlTabSheet
    else
      PageControl1.ActivePage := PlaintextTabSheet;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.SynEdit1GutterClick(Sender: TObject; Button: TMouseButton; X,
  Y, Line: Integer; Mark: TSynEditMark);
begin
  (*
  TSynEdit(Sender).CaretX := 1;
  TSynEdit(Sender).CaretY := Line;
  TSynEdit(Sender).SelLength := Length(TSynEdit(Sender).LineText);
  *)
end;

procedure TForm1.SynEdit1MouseCursor(Sender: TObject; const aLineCharPos: TBufferCoord; var aCursor: TCursor);
{$IFDEF OnlineHelp}
var
  Line: Integer;
  Column: Integer;
  word: string;
begin
  Line  := aLineCharPos.Line-1;
  Column := aLineCharPos.Char-1;
  word := GetWordUnderPos(TSynEdit(Sender), Line, Column);
  if word <> gOnlineHelpWord then
  begin
    gOnlineHelpWord := word;
    Timer1.Enabled := false;
    Timer1.Enabled := true;
  end;
{$ELSE}
begin
{$ENDIF}
end;

procedure TForm1.SynEdit1MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then
  begin
    SynEdit1.Font.Size := Max(SynEdit1.Font.Size - 1, 5);
    Handled := true;
  end
  else Handled := false;
end;

procedure TForm1.SynEdit1MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then
  begin
    SynEdit1.Font.Size := SynEdit1.Font.Size + 1;
    Handled := true;
  end
  else Handled := false;
end;

procedure TForm1.SynEditFocusTimerTimer(Sender: TObject);
begin
  SynEditFocusTimer.Enabled := false;
  Button1.SetFocus; // Workaround for weird bug... This (and the timer) is necessary to get the focus to SynEdit1
  SynEdit1.SetFocus;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  {$IFDEF OnlineHelp}
  Timer1.Enabled := false;

  // TODO: Insert a small online help hint
  //Caption := gOnlineHelpWord;
  {$ENDIF}
end;

procedure TForm1.TreeView1DblClick(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn := TTreeView(Sender).Selected;
  if tn = nil then exit;
  GotoLineNo(Integer(tn.Data));
end;

procedure TForm1.WebBrowser1BeforeNavigate2(ASender: TObject;
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
    try
      s := copy(URL, length(FASTPHP_GOTO_URI_PREFIX)+1, 99);
      if not TryStrToInt(s, lineno) then exit;
      GotoLineNo(lineno);
      SynEditFocusTimer.Enabled := true;
    finally
      Cancel := true;
    end;
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
      WebBrowser1.LoadHTML(RunPHPScript(myURL), myUrl);
      Cancel := true;
    end;
  end;
  {$ENDREGION}
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FastPHPConfig.WriteInteger('User', 'FontSize', SynEdit1.Font.Size);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  r: integer;
begin
  if SynEdit1.Modified then
  begin
    if ParamStr(1) <> '' then
    begin
      r := MessageDlg('Do you want to save?', mtConfirmation, mbYesNoCancel, 0);
      if r = mrCancel then
      begin
        CanClose := false;
        Exit;
      end
      else if r = mrYes then
      begin
        SynEdit1.Lines.SaveToFile(GetScrapFile);
        CanClose := true;
      end;
    end
    else
    begin
      SynEdit1.Lines.SaveToFile(GetScrapFile);
      CanClose := true;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  HlpPrevPageIndex := -1;
  CurSearchTerm := '';
  Caption := Caption + ' - ' + GetScrapFile;
  SrcRep := TSynEditFindReplace.Create(self);
  SrcRep.Editor := SynEdit1;
  SynEdit1.Gutter.Gradient := HighColorWindows;

  Screen.Cursors[crMouseGutter] := LoadCursor(hInstance, 'MOUSEGUTTER');
  SynEdit1.Gutter.Cursor := crMouseGutter;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(ChmIndex) then
  begin
    FreeAndNil(ChmIndex);
  end;
  FreeAndNil(SrcRep);

  if Assigned(codeExplorer) then
  begin
    codeExplorer.Terminate;
    codeExplorer.WaitFor;
    FreeAndNil(codeExplorer);
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  ScrapFile: string;
begin
  ScrapFile := GetScrapFile;
  if ScrapFile = '' then
  begin
    Application.Terminate; // Close;
    exit;
  end;
  if FileExists(ScrapFile) then
    SynEdit1.Lines.LoadFromFile(ScrapFile)
  else
    SynEdit1.Lines.Clear;

  PageControl1.ActivePage := PlaintextTabSheet;

  PageControl2.ActivePage := CodeTabsheet;
  HelpTabsheet.TabVisible := false;

  SynEdit1.Font.Size := FastPHPConfig.ReadInteger('User', 'FontSize', SynEdit1.Font.Size);
  SynEdit1.SetFocus;

  DoubleBuffered := true;
  StartCodeExplorer;
end;

procedure TForm1.StartCodeExplorer;
begin
  codeExplorer := TRunCodeExplorer.Create(true);
  codeExplorer.InputRequestCallback := InputRequestCallback;
  codeExplorer.OutputNotifyCallback := OutputNotifyCallback;
  codeExplorer.PhpExe := GetPHPExe;
  codeExplorer.PhpFile := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + 'codeexplorer.php'; // GetScrapFile;
  codeExplorer.WorkDir := ExtractFileDir(Application.ExeName);
  codeExplorer.Start;
end;

function TForm1.GetScrapFile: string;
begin
  if FScrapFile <> '' then exit(FScrapFile);

  if ParamStr(1) <> '' then
    result := ParamStr(1)
  else
    result := FastPHPConfig.ReadString('Paths', 'ScrapFile', '');
  if not FileExists(result) then
  begin
    repeat
      if not OpenDialog3.Execute then
      begin
        Application.Terminate;
        exit('');
      end;

      if not DirectoryExists(ExtractFilePath(OpenDialog3.FileName)) then
      begin
        ShowMessage('Path does not exist! Please try again.');
      end
      else
      begin
        result := OpenDialog3.FileName;
      end;
    until result <> '';

    SynEdit1.Lines.Clear;
    SynEdit1.Lines.SaveToFile(result);

    FastPHPConfig.WriteString('Paths', 'ScrapFile', result);
    FScrapFile := result;
  end;
end;

procedure TForm1.Help;
var
  IndexFile, chmFile, w, OriginalWord, url: string;
  internalHtmlFile: string;
begin
  if not Assigned(ChmIndex) then
  begin
    IndexFile := FastPHPConfig.ReadString('Paths', 'HelpIndex', '');
    IndexFile := ChangeFileExt(IndexFile, '.ini'); // Just to be sure. Maybe someone wrote manually the ".chm" file in there
    if FileExists(IndexFile) then
    begin
      ChmIndex := TMemIniFile.Create(IndexFile);
    end;
  end;

  if Assigned(ChmIndex) then
  begin
    IndexFile := FastPHPConfig.ReadString('Paths', 'HelpIndex', '');
    // We don't check if IndexFile still exists. It is not important since we have ChmIndex pre-loaded in memory

    chmFile := ChangeFileExt(IndexFile, '.chm');
    if not FileExists(chmFile) then
    begin
      FreeAndNil(ChmIndex);
    end;
  end;

  if not Assigned(ChmIndex) then
  begin
    if not OpenDialog1.Execute then exit;

    chmFile := OpenDialog1.FileName;
    if not FileExists(chmFile) then exit;

    IndexFile := ChangeFileExt(chmFile, '.ini');

    if not FileExists(IndexFile) then
    begin
      Panel1.Align := alClient;
      Panel1.Visible := true;
      Panel1.BringToFront;
      Screen.Cursor := crHourGlass;
      Application.ProcessMessages;
      try
        if not ParseCHM(chmFile) then
        begin
          ShowMessage('The CHM file is not a valid PHP documentation. Cannot use help.');
          exit;
        end;
      finally
        Screen.Cursor := crDefault;
        Panel1.Visible := false;
      end;

      if not FileExists(IndexFile) then
      begin
        ShowMessage('Unknown error. Cannot use help.');
        exit;
      end;
    end;

    FastPHPConfig.WriteString('Paths', 'HelpIndex', IndexFile);
    FastPHPConfig.UpdateFile;

    ChmIndex := TMemIniFile.Create(IndexFile);
  end;

  w := GetWordUnderCaret(SynEdit1);
  if w = '' then exit;
  if CharInSet(w[1], ['0'..'9']) then exit;

  Originalword := w;
//  w := StringReplace(w, '_', '-', [rfReplaceAll]);
  w := LowerCase(w);
  CurSearchTerm := w;

  internalHtmlFile := ChmIndex.ReadString('_HelpWords_', CurSearchTerm, '');
  if internalHtmlFile = '' then
  begin
    HelpTabsheet.TabVisible := false;
    HlpPrevPageIndex := -1;
    ShowMessageFmt('No help for "%s" available', [Originalword]);
    Exit;
  end;

  url := 'mk:@MSITStore:'+ChmFile+'::'+internalHtmlFile;

  HlpPrevPageIndex := PageControl2.ActivePageIndex; // Return by pressing ESC
  HelpTabsheet.TabVisible := true;
  PageControl2.ActivePage := HelpTabsheet;
  WebBrowser2.Navigate(url);
  WebBrowser2.Wait;
end;

procedure TForm1.GotoLineNo(LineNo:integer);
var
  line: string;
  i: integer;
begin
  SynEdit1.GotoLineAndCenter(LineNo);

  // Skip indent
  line := SynEdit1.Lines[SynEdit1.CaretY];
  for i := 1 to Length(line) do
  begin
    if not CharInSet(line[i], [' ', #9]) then
    begin
      SynEdit1.CaretX := i-1;
      break;
    end;
  end;

  PageControl2.ActivePage := CodeTabsheet;
  if SynEdit1.CanFocus then SynEdit1.SetFocus;
end;

procedure TForm1.PageControl2Changing(Sender: TObject;
  var AllowChange: Boolean);
begin
  if PageControl2.ActivePage = HelpTabsheet then
    HlpPrevPageIndex := -1
  else
    HlpPrevPageIndex := PageControl2.ActivePageIndex;

  AllowChange := true;
end;

procedure TForm1.Memo2DblClick(Sender: TObject);
var
  line: string;

  procedure _process(toFind: string);
  var
    p, lineno: integer;
  begin
    if FileSystemCaseSensitive then
      p := Pos(toFind, line)
    else
      p := Pos(toFind.ToLower, line.ToLower);
    if p <> 0 then
    begin
      line := copy(line, p+length(toFind), 99);
      if not TryStrToInt(line, lineno) then exit;
      GotoLineNo(lineno);
    end;
  end;

begin
  line := memo2.Lines.Strings[Memo2.CaretPos.Y];

  {$REGION 'Possibility 1: filename.php:lineno'}
  _process(ExtractFileName(GetScrapFile) + ':');
  {$ENDREGION}

  {$REGION 'Possibility 2: on line xx'}
  _process(ExtractFileName(GetScrapFile) + ' on line ');
  {$ENDREGION}
end;

procedure TForm1.Memo2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((ssCtrl in Shift) and (Key = 65)) then TMemo(Sender).SelectAll;
end;

function TForm1.MarkUpLineReference(cont: string): string;

  procedure _process(toFind: string);
  var
    p, a, b: integer;
    num: integer;
    insert_a, insert_b: string;
  begin
    if FileSystemCaseSensitive then
      p := Pos(toFind, cont)
    else
      p := Pos(toFind.ToLower, cont.ToLower);
    while p >= 1 do
    begin
      a := p;
      b := p + length(toFind);
      num := 0;
      while CharInSet(cont[b], ['0'..'9']) do
      begin
        num := num*10 + StrToInt(cont[b]);
        inc(b);
      end;

      insert_b := '</a>';
      insert_a := '<a href="' + FASTPHP_GOTO_URI_PREFIX + IntToStr(num) + '">';

      insert(insert_b, cont, b);
      insert(insert_a, cont, a);

      p := b + Length(insert_a) + Length(insert_b);

      p := PosEx(toFind, cont, p+1);
    end;
  end;

begin
  {$REGION 'Possibility 1: filename.php:lineno'}
  _process(ExtractFileName(GetScrapFile) + ':');
  {$ENDREGION}

  {$REGION 'Possibility 2: on line xx'}
  _process(ExtractFileName(GetScrapFile) + ' on line ');
  {$ENDREGION}

  result := cont;
end;

function TForm1.InputRequestCallback: string;
begin
  result := SynEdit1.Text;
end;

procedure TForm1.OutputNotifyCallback(const data: string);
begin
  TreeView1.FillWithFastPHPData(data);
end;

end.
