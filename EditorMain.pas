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
// TODO: Wieso dauert webbrowser1 erste kompilierung so lange???
// TODO: wieso kommt syntax fehler zweimal? einmal stderr einmal stdout?
// TODO: Browser titlebar (link preview)
// TODO: "jump to next/prev todo" buttons/shortcuts
// TODO: "increase/decrease indent" buttons/shortcuts

// Future ideas
// - code insight
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
  ActnList, SynEditMiscClasses, SynEditSearch, RunPHP, ImgList, SynUnicode,
  System.ImageList, System.Actions, Vcl.Menus, SHDocVw;

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
    btnLint: TButton;
    ActionLint: TAction;
    ImageList1: TImageList;
    RunPopup: TPopupMenu;
    OpeninIDE1: TMenuItem;
    ActionRunConsole: TAction;
    Runinconsole1: TMenuItem;
    SavePopup: TPopupMenu;
    Saveas1: TMenuItem;
    Save1: TMenuItem;
    SaveDialog1: TSaveDialog;
    BtnSpecialChars: TImage;
    BtnSpecialCharsOff: TImage;
    BtnSpecialCharsOn: TImage;
    procedure Run(Sender: TObject);
    procedure RunConsole(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PageControl2Changing(Sender: TObject; var AllowChange: Boolean);
    procedure Memo2DblClick(Sender: TObject);
    (*
    {$IFDEF USE_SHDOCVW_TLB}
    *)
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    (*
    {$ELSE}
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    {$ENDIF}
    *)
    procedure BeforeNavigate(const URL: OleVariant; var Cancel: WordBool);
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
    procedure SynEdit1PaintTransient(Sender: TObject; Canvas: TCanvas;
      TransientType: TTransientType);
    procedure ActionLintExecute(Sender: TObject);
    procedure ActionRunConsoleExecute(Sender: TObject);
    procedure SynEdit1Change(Sender: TObject);
    procedure Saveas1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure BtnSpecialCharsClick(Sender: TObject);
    procedure WebBrowser1WindowClosing(ASender: TObject;
      IsChildWindow: WordBool; var Cancel: WordBool);
  private
    CurSearchTerm: string;
    HlpPrevPageIndex: integer;
    SrcRep: TSynEditFindReplace;
    {$IFDEF OnlineHelp}
    gOnlineHelpWord: string;
    {$ENDIF}
    procedure Help;
    function MarkUpLineReference(cont: string): string;
    function InputRequestCallback(var data: AnsiString): boolean;
    function OutputNotifyCallback(const data: AnsiString): boolean;
  protected
    ChmIndex: TMemIniFile;
    FScrapFile: string;
    FSaveAsFilename: string;
    codeExplorer: TRunCodeExplorer;
    procedure GotoLineNo(LineNo: integer);
    function GetScrapFile: string;
    procedure StartCodeExplorer;
    procedure RefreshModifySign;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{$R Cursors.res}

uses
  Functions, StrUtils, WebBrowserUtils, FastPHPUtils, Math, ShellAPI, RichEdit,
  FastPHPTreeView, ImageListEx, FastPHPConfig;

const
  crMouseGutter = 1;

procedure TForm1.RefreshModifySign;
var
  tmp: string;
begin
  tmp := Caption;

  tmp := StringReplace(tmp, '*', '', [rfReplaceAll]);
  if SynEdit1.Modified then tmp := tmp + '*';

  if Caption <> tmp then Caption := tmp;
end;

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

procedure TForm1.ActionLintExecute(Sender: TObject);
begin
  Run(Sender);
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

procedure TForm1.ActionRunConsoleExecute(Sender: TObject);
begin
  RunConsole(Sender);
  SynEdit1.SetFocus;
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
  RefreshModifySign;
end;

procedure TForm1.ActionSpaceToTabExecute(Sender: TObject);

    function SpacesAtBeginning(line: string): integer;
    begin
      result := 0;
      if Trim(line) = '' then exit;
      while line[result+1] = ' ' do
      begin
        inc(result);
      end;
    end;

    function GuessIndent(lines: {$IFDEF UNICODE}TStrings{$ELSE}TUnicodeStrings{$ENDIF}): integer;
      function _Check(indent: integer): boolean;
      var
        i: integer;
      begin
        result := true;
        for i := 0 to lines.Count-1 do
          if SpacesAtBeginning(lines.Strings[i]) mod indent <> 0 then
          begin
            // ShowMessageFmt('Zeile "%s" nicht durch %d teilbar!', [lines.strings[i], indent]);
            result := false;
            exit;
          end;
      end;
    var
      i: integer;
    begin
      for i := 8 downto 2 do
      begin
        if _Check(i) then
        begin
          result := i;
          exit;
        end;
      end;
      result := -1;
    end;

    procedure SpaceToTab(lines: {$IFDEF UNICODE}TStrings{$ELSE}TUnicodeStrings{$ENDIF}; indent: integer);
    var
      i, spaces: integer;
    begin
      for i := 0 to lines.Count-1 do
      begin
        spaces := SpacesAtBeginning(lines.Strings[i]);
        lines.Strings[i] := StringOfChar(#9, spaces div indent) + StringOfChar(' ', spaces mod indent) + Copy(lines.Strings[i], spaces+1, Length(lines.Strings[i])-spaces);
      end;
    end;

    function SpacesAvailable(lines: {$IFDEF UNICODE}TStrings{$ELSE}TUnicodeStrings{$ENDIF}): boolean;
    var
      i, spaces: integer;
    begin
      for i := 0 to lines.Count-1 do
      begin
        spaces := SpacesAtBeginning(lines.Strings[i]);
        if spaces > 0 then
        begin
          result := true;
          exit;
        end;
      end;
      result := false;
      exit;
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
    MessageDlg(SNoLinesAvailable, mtInformation, [mbOk], 0);
    exit;
  end;

  ind := GuessIndent(SynEdit1.Lines);
  if ind <> -1 then val := IntToStr(ind);

  InputQuery('Spaces to tabs', 'Indent:', val); // TODO: handle CANCEL correctly...
  if TryStrToInt(Trim(val), ind) then
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
    ActionSave.Execute; // TODO: if it is not the scrap file: do not save the file, since the user did not intended to save... better create a temporary file and run it instead.

    memo2.Lines.Text := RunPHPScript(GetScrapFile, Sender=ActionLint, False);

    Webbrowser1.LoadHTML(MarkUpLineReference(memo2.Lines.Text), GetScrapFile);

    if IsTextHTML(memo2.lines.text) then
      PageControl1.ActivePage := HtmlTabSheet
    else
      PageControl1.ActivePage := PlaintextTabSheet;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.RunConsole(Sender: TObject);
begin
  ActionSave.Execute; // TODO: if it is not the scrap file: do not save the file, since the user did not intended to save... better create a temporary file and run it instead.
  RunPHPScript(GetScrapFile, Sender=ActionLint, True);
end;

procedure TForm1.SynEdit1Change(Sender: TObject);
begin
  RefreshModifySign;
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

procedure TForm1.SynEdit1PaintTransient(Sender: TObject; Canvas: TCanvas; TransientType: TTransientType);
var
  Editor: TSynEdit;
  OpenChars: array of WideChar;//[0..2] of WideChar=();
  CloseChars: array of WideChar;//[0..2] of WideChar=();

  function IsCharBracket(AChar: WideChar): Boolean;
  begin
    case AChar of
      '{','[','(','<','}',']',')','>':
        Result := True;
      else
        Result := False;
    end;
  end;

  function CharToPixels(P: TBufferCoord): TPoint;
  begin
    Result := Editor.RowColumnToPixels(Editor.BufferToDisplayPos(P));
  end;

const
  COLOR_FG = clGreen;
  COLOR_BG = clLime;
var
  P: TBufferCoord;
  Pix: TPoint;
  D: TDisplayCoord;
  S: UnicodeString;
  I: Integer;
  Attri: TSynHighlighterAttributes;
  ArrayLength: Integer;
  start: Integer;
  TmpCharA, TmpCharB: WideChar;
begin       
  // Source: https://github.com/SynEdit/SynEdit/blob/master/Demos/OnPaintTransientDemo/Unit1.pas

  if TSynEdit(Sender).SelAvail then exit;
  Editor := TSynEdit(Sender);
  ArrayLength:= 3;

  (*
  if (Editor.Highlighter = shHTML) or (Editor.Highlighter = shXML) then
    inc(ArrayLength);
  *)

  SetLength(OpenChars, ArrayLength);
  SetLength(CloseChars, ArrayLength);
  for i := 0 to ArrayLength - 1 do
  begin
    case i of
      0: begin OpenChars[i] := '('; CloseChars[i] := ')'; end;
      1: begin OpenChars[i] := '{'; CloseChars[i] := '}'; end;
      2: begin OpenChars[i] := '['; CloseChars[i] := ']'; end;
      3: begin OpenChars[i] := '<'; CloseChars[i] := '>'; end;
    end;
  end;

  P := Editor.CaretXY;
  D := Editor.DisplayXY;

  Start := Editor.SelStart;

  if (Start > 0) and (Start <= length(Editor.Text)) then
    TmpCharA := Editor.Text[Start]
  else
    TmpCharA := #0;

  if (Start > 0){Added by VTS} and (Start < length(Editor.Text)) then
    TmpCharB := Editor.Text[Start + 1]
  else
    TmpCharB := #0;

  if not IsCharBracket(TmpCharA) and not IsCharBracket(TmpCharB) then exit;
  S := TmpCharB;
  if not IsCharBracket(TmpCharB) then
  begin
    P.Char := P.Char - 1;
    S := TmpCharA;
  end;
  Editor.GetHighlighterAttriAtRowCol(P, S, Attri);

  if (Editor.Highlighter.SymbolAttribute = Attri) then
  begin
    for i := low(OpenChars) to High(OpenChars) do
    begin
      if (S = OpenChars[i]) or (S = CloseChars[i]) then
      begin
        Pix := CharToPixels(P);

        Editor.Canvas.Brush.Style := bsSolid;//Clear;
        Editor.Canvas.Font.Assign(Editor.Font);
        Editor.Canvas.Font.Style := Attri.Style;

        if (TransientType = ttAfter) then
        begin
          Editor.Canvas.Font.Color := COLOR_FG;
          Editor.Canvas.Brush.Color := COLOR_BG;
        end
        else
        begin
          Editor.Canvas.Font.Color := Attri.Foreground;
          Editor.Canvas.Brush.Color := Attri.Background;
        end;
        if Editor.Canvas.Font.Color = clNone then
          Editor.Canvas.Font.Color := Editor.Font.Color;
        if Editor.Canvas.Brush.Color = clNone then
          Editor.Canvas.Brush.Color := Editor.Color;

        Editor.Canvas.TextOut(Pix.X, Pix.Y, S);
        P := Editor.GetMatchingBracketEx(P);

        if (P.Char > 0) and (P.Line > 0) then
        begin
          Pix := CharToPixels(P);
          if Pix.X > Editor.Gutter.Width then
          begin
            {$REGION 'Added by ViaThinkSoft'}
            if (TransientType = ttAfter) then
            begin
              Editor.Canvas.Font.Color := COLOR_FG;
              Editor.Canvas.Brush.Color := COLOR_BG;
            end
            else
            begin
              Editor.Canvas.Font.Color := Attri.Foreground;
              Editor.Canvas.Brush.Color := Attri.Background;
            end;
            if Editor.Canvas.Font.Color = clNone then
              Editor.Canvas.Font.Color := Editor.Font.Color;
            if Editor.Canvas.Brush.Color = clNone then
              Editor.Canvas.Brush.Color := Editor.Color;
            {$ENDREGION}
            if S = OpenChars[i] then
              Editor.Canvas.TextOut(Pix.X, Pix.Y, CloseChars[i])
            else Editor.Canvas.TextOut(Pix.X, Pix.Y, OpenChars[i]);
          end;
        end;
      end;
    end;
    Editor.Canvas.Brush.Style := bsSolid;
  end;
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
  lineNo: integer;
begin
  tn := TTreeView(Sender).Selected;
  if tn = nil then exit;
  lineNo := Integer(tn.Data);
  if lineNo > 0 then GotoLineNo(lineNo);
end;

(*
{$IFDEF USE_SHDOCVW_TLB}
*)
procedure TForm1.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
begin
  BeforeNavigate(URL, Cancel);
end;
procedure TForm1.WebBrowser1WindowClosing(ASender: TObject;
  IsChildWindow: WordBool; var Cancel: WordBool);
resourcestring
  LNG_CLOSE_REQUEST = 'A script has requested the window to be closed. The window of a standalone script would now close.';
begin
  ShowMessage(LNG_CLOSE_REQUEST);
  TWebBrowser(ASender).Clear;
  Cancel := true;
end;

(*
{$ELSE}
procedure TForm1.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
begin
  BeforeNavigate(URL, Cancel);
end;
{$ENDIF}
*)

procedure TForm1.BeforeNavigate(const URL: OleVariant; var Cancel: WordBool);
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

procedure TForm1.BtnSpecialCharsClick(Sender: TObject);
var
  opts: TSynEditorOptions;
begin
  opts := SynEdit1.Options;
  if eoShowSpecialChars in SynEdit1.Options then
  begin
    BtnSpecialChars.Picture.Assign(BtnSpecialCharsOff.Picture);
    Exclude(opts, eoShowSpecialChars);
    TFastPHPConfig.SpecialChars := false;
  end
  else
  begin
    BtnSpecialChars.Picture.Assign(BtnSpecialCharsOn.Picture);
    Include(opts, eoShowSpecialChars);
    TFastPHPConfig.SpecialChars := true;
  end;
  SynEdit1.Options := opts;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TFastPHPConfig.FontSize := SynEdit1.Font.Size;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  r: integer;
begin
  if SynEdit1.Modified then
  begin
    if (ParamStr(1) <> '') or (FSaveAsFilename <> '') then
    begin
      r := MessageDlg('Do you want to save?', mtConfirmation, mbYesNoCancel, 0);
      if r = mrCancel then
      begin
        CanClose := false;
        Exit;
      end
      else if r = mrYes then
      begin
        ActionSave.Execute;
        CanClose := true;
      end;
    end
    else
    begin
      ActionSave.Execute;
      CanClose := true;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  exeDir: string;
begin
  HlpPrevPageIndex := -1;
  CurSearchTerm := '';
  Caption := Caption + ' - ' + GetScrapFile;
  SrcRep := TSynEditFindReplace.Create(self);
  SrcRep.Editor := SynEdit1;
  SynEdit1.Gutter.Gradient := HighColorWindows;

  Screen.Cursors[crMouseGutter] := LoadCursor(hInstance, 'MOUSEGUTTER');
  SynEdit1.Gutter.Cursor := crMouseGutter;

  exeDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  if FileExists(exeDir + 'codeexplorer.bmp') then ImageList1.LoadAndSplitImages(exeDir + 'codeexplorer.bmp');
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
  tmpFontSize: integer;
  opts: TSynEditorOptions;
begin
  ScrapFile := GetScrapFile;
  if ScrapFile = '' then
  begin
    Application.Terminate; // Close;
    exit;
  end;

  opts := SynEdit1.Options;
  if TFastPHPConfig.SpecialChars then
  begin
    BtnSpecialChars.Picture.Assign(BtnSpecialCharsOn.Picture);
    Include(opts, eoShowSpecialChars);
  end
  else
  begin
    BtnSpecialChars.Picture.Assign(BtnSpecialCharsOff.Picture);
    Exclude(opts, eoShowSpecialChars);
  end;
  SynEdit1.Options := opts;

  if FileExists(ScrapFile) then
    SynEdit1.Lines.LoadFromFile(ScrapFile)
  else
    SynEdit1.Lines.Clear;

  PageControl1.ActivePage := PlaintextTabSheet;

  PageControl2.ActivePage := CodeTabsheet;
  HelpTabsheet.TabVisible := false;

  tmpFontSize := TFastPHPConfig.FontSize;
  if tmpFontSize <> -1 then SynEdit1.Font.Size := tmpFontSize;
  SynEdit1.SetFocus;

  DoubleBuffered := true;
  StartCodeExplorer;
end;

procedure TForm1.Save1Click(Sender: TObject);
begin
  Button7.Click;
end;

procedure TForm1.Saveas1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    FSaveAsFilename := SaveDialog1.FileName;
    Caption := Copy(Caption, 1, Pos(' - ', Caption)-1) + ' - ' + FSaveAsFilename;
    Button7.Click;
  end;
end;

procedure TForm1.StartCodeExplorer;
begin
  codeExplorer := TRunCodeExplorer.Create(true);
  codeExplorer.InputRequestCallback := InputRequestCallback;
  codeExplorer.OutputNotifyCallback := OutputNotifyCallback;
  codeExplorer.PhpExe := GetPHPExe;
  codeExplorer.PhpFile := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + 'codeexplorer.php'; // GetScrapFile;
  codeExplorer.WorkDir := ExtractFileDir(Application.ExeName);
  codeExplorer.Resume;
end;

function TForm1.GetScrapFile: string;
var
  tmpPath: string;
begin
  if FSaveAsFilename <> '' then
  begin
    result := FSaveAsFilename;
    exit;
  end;

  if FScrapFile <> '' then
  begin
    result := FScrapFile;
    exit;
  end;

  if ParamStr(1) <> '' then
  begin
    // Program was started with a filename

    result := ParamStr(1);

    if not FileExists(result) then
    begin
      case MessageDlg(Format('File %s does not exist. Create it?', [result]), mtConfirmation, mbYesNoCancel, 0) of
        mrYes:
          try
            SynEdit1.Lines.SaveToFile(result);
          except
            on E: Exception do
            begin
              MessageDlg(E.Message, mtError, [mbOk], 0);
              Application.Terminate;
              result := '';
              exit;
            end;
          end;
        mrNo:
          begin
            Application.Terminate;
            result := '';
            exit;
          end;
        mrCancel:
          begin
            Application.Terminate;
            result := '';
            exit;
          end;
      end;
    end;
  end
  else
  begin
    // Program is started without filename -> use scrap file

    result := TFastPHPConfig.ScrapFile;

    if not FileExists(result) then
    begin
      repeat
        {$REGION 'Determinate opendialog initial directory'}
        if result <> '' then
        begin
          tmpPath := ExtractFilePath(result);
          if DirectoryExists(tmpPath) then
          begin
            OpenDialog3.InitialDir := tmpPath;
            OpenDialog3.FileName := Result;
          end
          else
          begin
            OpenDialog3.InitialDir := GetMyDocumentsFolder;
          end;
        end
        else
        begin
          OpenDialog3.InitialDir := GetMyDocumentsFolder;
        end;
        {$ENDREGION}

        if not OpenDialog3.Execute then
        begin
          Application.Terminate;
          result := '';
          exit;
        end;

        if not DirectoryExists(ExtractFilePath(OpenDialog3.FileName)) then
        begin
          MessageDlg('Path does not exist! Please try again.', mtWarning, [mbOk], 0);
        end
        else
        begin
          result := OpenDialog3.FileName;
        end;
      until result <> '';

      if not FileExists(result) then
      begin
        try
          // Try saving the file; check if we have permissions
          //SynEdit1.Lines.Clear;
          SynEdit1.Lines.SaveToFile(result);
        except
          on E: Exception do
          begin
            MessageDlg(E.Message, mtError, [mbOk], 0);
            Application.Terminate;
            result := '';
            exit;
          end;
        end;
      end;

      TFastPHPConfig.ScrapFile := result;
      FScrapFile := result;
    end;
  end;
end;

procedure TForm1.Help;
var
  IndexFile, chmFile, w, OriginalWord, url: string;
  internalHtmlFile: string;
begin
  if not Assigned(ChmIndex) then
  begin
    IndexFile := TFastPHPConfig.HelpIndex;
    IndexFile := ChangeFileExt(IndexFile, '.ini'); // Just to be sure. Maybe someone wrote manually the ".chm" file in there
    if FileExists(IndexFile) then
    begin
      ChmIndex := TMemIniFile.Create(IndexFile);
    end;
  end;

  if Assigned(ChmIndex) then
  begin
    IndexFile := TFastPHPConfig.HelpIndex;
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
          MessageDlg('The CHM file is not a valid PHP documentation. Cannot use help.', mtError, [mbOk], 0);
          exit;
        end;
      finally
        Screen.Cursor := crDefault;
        Panel1.Visible := false;
      end;

      if not FileExists(IndexFile) then
      begin
        MessageDlg('Unknown error. Cannot use help.', mtError, [mbOk], 0);
        exit;
      end;
    end;

    TFastPHPConfig.HelpIndex := IndexFile;

    ChmIndex := TMemIniFile.Create(IndexFile);
  end;

  w := GetWordUnderCaret(SynEdit1);
  if w = '' then exit;
  {$IFDEF UNICODE}
  if CharInSet(w[1], ['0'..'9']) then exit;
  {$ELSE}
  if w[1] in ['0'..'9'] then exit;
  {$ENDIF}

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
    {$IFDEF UNICODE}
    if not CharInSet(line[i], [' ', #9]) then
    {$ELSE}
    if not (line[i] in [' ', #9]) then
    {$ENDIF}
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
      p := Pos(LowerCase(toFind), LowerCase(line));
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
      p := Pos(LowerCase(toFind), LowerCase(cont));
    while p >= 1 do
    begin
      a := p;
      b := p + length(toFind);
      num := 0;
      {$IFDEF UNICODE}
      while CharInSet(cont[b], ['0'..'9']) do
      {$ELSE}
      while cont[b] in ['0'..'9'] do
      {$ENDIF}
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

function TForm1.InputRequestCallback(var data: AnsiString): boolean;
begin
  data := UTF8Encode(SynEdit1.Text);
  result := true;
end;

function TForm1.OutputNotifyCallback(const data: AnsiString): boolean;
begin
  result := TreeView1.FillWithFastPHPData(data);
end;

end.
