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

// TODO: "crHourGlass" does not work if F9 is pressed!
// TODO: if a scrapfile is already open, create a new scrap file (scrap2.php)
// TODO: localize
// TODO: wieso geht copy paste im twebbrowser nicht???
// TODO: Wieso dauert webbrowser1 erste kompilierung so lange???
// TODO: wieso kommt syntax fehler zweimal? einmal stderr einmal stdout?
// TODO: Browser titlebar (link preview)
// TODO: "jump to next/prev todo" buttons/shortcuts
// TODO: "increase/decrease indent" buttons/shortcuts
// TODO: Solve all compiler warnings, especially in regards Encoding

// Note in re Unicode:
// - In Embarcadero® Delphi 10.4 Version 27.0.40680.4203:
//   SynEdit correctly detects UTF-8 files without BOM as well as ANSI files with Umlauts.
//   (Previous versions could not detect UTF-8 files without BOM?!)
// - If BOM is existing, it will be removed. (which is good, because this is defined by PSR-1)

// Small things:
// - The scroll bars of SynEdit are not affected by the dark theme
// - dark theme full screen: doubleclick to desktop pixel "0,0" cannot be used to close the app

// Future ideas
// - code insight
// - verschiedene php versionen?
// - webbrowser1 nur laden, wenn man den tab anwaehlt?
// - doppelklick auf tab soll diesen schliessen
// - Onlinehelp (www) aufrufen oder CHM datei
// - Let all colors be adjustable
// - code in bildschirmmitte (horizontal)?
// - search in files of a directory
// - Files in multiple tabs?
// - Configurable tabulator display-width

interface

uses
  // TODO: "{$IFDEF USE_SHDOCVW_TLB}_TLB{$ENDIF}" does not work with Delphi 10.2
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, ComCtrls, ExtCtrls, ToolWin, IniFiles,
  SynEditHighlighter, SynHighlighterPHP, SynEdit, ShDocVw, FindReplace,
  ActnList, SynEditMiscClasses, SynEditSearch, RunPHP, ImgList, SynUnicode,
  System.ImageList, System.Actions, Vcl.Menus, Vcl.Themes, System.UITypes,
  SynEditCodeFolding, WebBrowserUtils;

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
    BtnLightOn: TImage;
    BtnLightOff: TImage;
    BtnLight: TImage;
    StartUpTimer: TTimer;
    FileModTimer: TTimer;
    GotoPHPdir1: TMenuItem;
    PHPShell1: TMenuItem;
    ActionSaveAs: TAction;
    ActionGoToPHPDir: TAction;
    ActionPHPInteractiveShell: TAction;
    FontSizeTimer: TTimer;
    ChooseanotherPHPinterpreter1: TMenuItem;
    ChooseanotherCHMhelpfile1: TMenuItem;
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
    procedure BtnSpecialCharsClick(Sender: TObject);
    procedure WebBrowser1WindowClosing(ASender: TObject;
      IsChildWindow: WordBool; var Cancel: WordBool);
    procedure BtnLightClick(Sender: TObject);
    procedure StartUpTimerTimer(Sender: TObject);
    procedure FileModTimerTimer(Sender: TObject);
    procedure SynEdit1DropFiles(Sender: TObject; X, Y: Integer;
      AFiles: TStrings);
    procedure ActionSaveAsExecute(Sender: TObject);
    procedure ActionGoToPHPDirExecute(Sender: TObject);
    procedure ActionPHPInteractiveShellExecute(Sender: TObject);
    procedure SynEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FontSizeTimerTimer(Sender: TObject);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure ChooseanotherPHPinterpreter1Click(Sender: TObject);
    procedure ChooseanotherCHMhelpfile1Click(Sender: TObject);
  private
    hMutex: THandle;
    CurSearchTerm: string;
    HlpPrevPageIndex: integer;
    SrcRep: TSynEditFindReplace;
    {$IFDEF OnlineHelp}
    gOnlineHelpWord: string;
    {$ENDIF}
    FileModLast: TDateTime;
    FormShowRanOnce: boolean;
    BrowserLoadedOnce: boolean;
    procedure Help(AForceSelectNewHelpFile: boolean=false);
    function InputRequestCallback(var data: AnsiString): boolean;
    function OutputNotifyCallback(const data: AnsiString): boolean;
    procedure RightTrimAll;
  protected
    ChmIndex: TMemIniFile;
    FScrapFile: string;
    FSaveAsFilename: string;
    codeExplorer: TRunCodeExplorer;
    procedure GotoLineNo(LineNo: integer);
    function GetScrapFile: string;
    procedure StartCodeExplorer;
    procedure RefreshModifySign;
    procedure Theme_Light;
    procedure Theme_Dark;
    function IsThemeDark: boolean;
    function MarkUpLineReference(cont: string): string;
    function ContainsUnicodeCharsInAnsiFile: boolean;
    procedure SaveToFile(filename: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{$R Cursors.res}

uses
  Functions, StrUtils, FastPHPUtils, Math, ShellAPI, RichEdit,
  FastPHPTreeView, ImageListEx, FastPHPConfig;

const
  crMouseGutter = 1;

procedure TForm1.RefreshModifySign;
var
  tmp: string;
begin
  if SynEdit1 = nil then exit;

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
resourcestring
  SGoTo = 'Go to';
  SLineNumber = 'Line number:';
begin
  // TODO: VK_LMENU does not work! only works with AltGr but not Alt
  // http://stackoverflow.com/questions/16828250/delphi-xe2-how-to-prevent-the-alt-key-stealing-focus ?

  if not InputQuery(SGoTo, SLineNumber, val) or
     not TryStrToInt(val, lineno) then
  begin
    if SynEdit1.CanFocus then SynEdit1.SetFocus;
    exit;
  end;
  GotoLineNo(lineno);
end;

procedure TForm1.ActionGoToPHPDirExecute(Sender: TObject);
var
  phpExe: string;
begin
  phpExe := GetPHPExe;
  if phpExe <> '' then
    ShellExecute(Handle, 'open', 'explorer.exe', PChar(ExtractFilePath(phpExe)), '', SW_NORMAL);
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
    ShellExecute(0, 'open', PChar(ParamStr(0)), PChar('"' + OpenDialog3.FileName + '"'), '', SW_NORMAL);
  end;
end;

procedure TForm1.ActionPHPInteractiveShellExecute(Sender: TObject);
var
  phpExe: string;
begin
  phpExe := GetPHPExe;
  if phpExe <> '' then
    ShellExecute(Handle, 'open', PChar(phpExe), '-a', PChar(ExtractFilePath(phpExe)), SW_NORMAL);
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

procedure TForm1.RightTrimAll;
var
  i: integer;
begin
  for i := 0 to SynEdit1.Lines.Count-1 do
  begin
    SynEdit1.Lines.Strings[i] := TrimRight(SynEdit1.Lines.Strings[i]);
  end;

  (*
  while (SynEdit1.Lines.Count > 0) and (SynEdit1.Lines.Strings[SynEdit1.Lines.Count-1] = '') do
  begin
    SynEdit1.Lines.Delete(SynEdit1.Lines.Count-1);
  end;
  if SynEdit1.SelStart > Length(SynEdit1.Text)-1 then
  begin
    // TODO: This code does not work...
    SynEdit1.SelStart := Length(SynEdit1.Text)-1;
    SynEdit1.SelEnd   := Length(SynEdit1.Text)-1;
  end;
  *)
end;

procedure TForm1.ActionSaveAsExecute(Sender: TObject);
var
  hMutexNew: THandle;
resourcestring
  SCannotSaveBecauseMutex = 'Cannot save because file "%s", because it is alrady open in another FastPHP window!';
begin
  if SaveDialog1.Execute then
  begin
    {$REGION 'Switch mutex'}
    hMutexNew := CreateMutex(nil, True, PChar('FastPHP'+md5(UpperCase(SaveDialog1.FileName))));
    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
      ShowMessageFmt(SCannotSaveBecauseMutex, [SaveDialog1.FileName]);
      Close;
    end;

    if hMutex <> 0 then CloseHandle(hMutex); // Note: ReleaseMutex does not work as expected!
    hMutex := hMutexNew;
    {$ENDREGION}

    FSaveAsFilename := SaveDialog1.FileName;
    Caption := Copy(Caption, 1, Pos(' - ', Caption)-1) + ' - ' + FSaveAsFilename;
    Application.Title := Format('%s - FastPHP', [ExtractFileName(FSaveAsFilename)]); // do not translate!
    Button7.Click;
  end;
end;

procedure TForm1.ActionSaveExecute(Sender: TObject);
begin
  RightTrimAll;
  SaveToFile(GetScrapFile);
  SynEdit1.Modified := false;
  RefreshModifySign;
  if SynEdit1.CanFocus then SynEdit1.SetFocus;
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
      newval: string;
      somethingchanged: boolean;
    begin
      somethingchanged := false;
      for i := 0 to lines.Count-1 do
      begin
        spaces := SpacesAtBeginning(lines.Strings[i]);
        newval := StringOfChar(#9, spaces div indent) + StringOfChar(' ', spaces mod indent) + Copy(lines.Strings[i], spaces+1, Length(lines.Strings[i])-spaces);
        if lines.Strings[i] <> newval then
        begin
          somethingchanged := true;
          lines.Strings[i] := newval;
        end;
      end;
      if somethingchanged then
      begin
        SynEdit1.Modified := true; // seems to be required by Delphi 10.x
        RefreshModifySign;
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
  SSpacesToLabs = 'Spaces to tabs';
  SIndent = 'Indent:';
begin
  // TODO: if something is selected, only process the selected part

  if not SpacesAvailable(SynEdit1.Lines) then
  begin
    MessageDlg(SNoLinesAvailable, mtInformation, [mbOk], 0);
    exit;
  end;

  ind := GuessIndent(SynEdit1.Lines);
  if ind <> -1 then val := IntToStr(ind);

  if not InputQuery(SSpacesToLabs, SIndent, val) or
     not TryStrToInt(Trim(val), ind) then
  begin
    if SynEdit1.CanFocus then SynEdit1.SetFocus;
    exit;
  end;

  if ind = 0 then exit;
  SpaceToTab(SynEdit1.Lines, ind);
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

procedure TForm1.Run(Sender: TObject);
var
  bakTS: TTabSheet;
  //ss: TStringStream;
  //bakPos: Int64;
begin
  memo2.Lines.Text := '';

  if not BrowserLoadedOnce then
  begin
    bakTS := PageControl1.ActivePage;
    try
      PageControl1.ActivePage := HtmlTabSheet; // Required for the first time, otherwise, WebBrowser1.Clear will hang
      Webbrowser1.Clear;
    finally
      PageControl1.ActivePage := bakTS;
    end;
    BrowserLoadedOnce := true;
  end
  else
    Webbrowser1.Clear;

  Screen.Cursor := crHourGlass; // TODO: Doesn't work with F9
  Application.ProcessMessages;

  try
    ActionSave.Execute; // TODO: if it is not the scrap file: do not save the file, since the user did not intended to save... better create a temporary file and run it instead.

    // TODO 70421 * <fastphp> implement flush() with ContentCallBack implementieren... For long running scripts I want to see status changes via javascript which are loaded step by step
    // TODO 70422 * <fastphp> when a script has an endless loop, i want to have a possibility to cancel it
    if SynEdit1.Lines.Encoding = TEncoding.UTF8 then
      memo2.Lines.Text := Utf8Decode(RunPHPScript(GetScrapFile, Sender=ActionLint, False)) // if we have a UTF-8 file, then the DOS output is double-UTF8 encoded
    else
      memo2.Lines.Text := RunPHPScript(GetScrapFile, Sender=ActionLint, False);

    {$REGION 'Show in Web Browser'}
    if SynEdit1.Lines.Encoding = TEncoding.UTF8 then
      Webbrowser1.LoadHTML(MarkUpLineReference('<meta charset="utf-8">'+memo2.Lines.Text), GetScrapFile)
    else
      Webbrowser1.LoadHTML(MarkUpLineReference(memo2.Lines.Text), GetScrapFile);

    // Alternatively:
    (*
    ss := TstringStream.Create;
    ss.WriteString(MarkUpLineReference(memo2.Lines.Text));
    ss.Position := 0;
    Webbrowser1.LoadStream(ss, GetScrapFile);
    Webbrowser1.Wait;
    ss.Free;
    *)
    {$ENDREGION}

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

procedure TForm1.SynEdit1DropFiles(Sender: TObject; X, Y: Integer;
  AFiles: TStrings);
var
  FileName: string;
const
  WARN_FILE_COUNT = 10;
resourcestring
  SAreYouSure = 'Are you sure you want to open %d files?';
begin
  if AFiles.Count > WARN_FILE_COUNT then
  begin
    if not MessageDlg(Format(SAreYouSure, [WARN_FILE_COUNT]), mtConfirmation, mbYesNoCancel, 0) <> mrYes then
      exit;
  end;

  for FileName in AFiles do
  begin
    ShellExecute(0, 'open', PChar(ParamStr(0)), PChar('"' + FileName + '"'), '', SW_NORMAL);
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

procedure TForm1.SynEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl, ssShift]) and (Key = ord('C')) then
  begin
    // Disable "Column Select Mode" (https://github.com/SynEdit/SynEdit/blob/master/Source/SynEditKeyCmds.pas#L879)
    // which can be enabled by pressing Ctrl+Shift+C
    // Reasons why we disable it:
    // 1. I think nobody needs this, and sometimes you accidentally press it
    // 2. Ctrl+Shift+L would the combination to disable column select mode,
    //    but you cannot use it, because it is already in use for linting
    Key := 0;
  end;
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

var
  COLOR_FG: TColor;
  COLOR_BG: TColor;
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

  if IsThemeDark then
  begin
    COLOR_FG := clLime;
    COLOR_BG := clGreen;
  end
  else
  begin
    COLOR_FG := clGreen;
    COLOR_BG := clLime;
  end;

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
          {$IF CompilerVersion >= 35.0} // Added by ViaThinkSoft (not sure about the exact version)
          if Pix.X > Editor.Gutter.RealGutterWidth then // Added by ViaThinkSoft (not sure about the exact version)
          {$ELSE}
          if Pix.X > Editor.Gutter.Width then
          {$IFEND}
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

procedure TForm1.SynEdit1StatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  if scModified in Changes then
    RefreshModifySign;
end;

procedure TForm1.SynEditFocusTimerTimer(Sender: TObject);
begin
  SynEditFocusTimer.Enabled := false;
  Button1.SetFocus; // Workaround for weird bug... This (and the timer) is necessary to get the focus to SynEdit1
  SynEdit1.SetFocus;
end;

procedure TForm1.Theme_Dark;
begin
  if IsThemeDark then exit;
  TStyleManager.TrySetStyle('Windows10 SlateGray'); // do not translate
  Color := 1316887;
  Font.Color := clCream;
  //Memo2.Font.Color := clCream;
  //Memo2.ParentColor := true;
  SynEdit1.ActiveLineColor := 2238502;
  SynEdit1.Color := 1316887;
  SynEdit1.Font.Color := clCream;
  SynEdit1.Gutter.Color := 1316887;
  SynEdit1.Gutter.Font.Color := clCream;
  SynEdit1.Gutter.GradientStartColor := 2238502;
  SynEdit1.Gutter.GradientEndColor := 1316887;
  SynPHPSyn1.CommentAttri.Foreground := $00837B82;
  SynPHPSyn1.IdentifierAttri.Foreground := 9627120;
  SynPHPSyn1.KeyAttri.Foreground := 4157595;
  SynPHPSyn1.NumberAttri.Foreground := 5008079;
  SynPHPSyn1.StringAttri.Foreground := 6987151;
  SynPHPSyn1.SymbolAttri.Foreground := 8769754;
  SynPHPSyn1.VariableAttri.Foreground := 6924493;
end;

procedure TForm1.Theme_Light;
begin
  if not IsThemeDark then exit;
  TStyleManager.TrySetStyle('Windows'); // do not translate
  Color := clBtnFace;
  Font.Color := clWindowText;
  //Memo2.Font.Color := clWindowText;
  SynEdit1.ActiveLineColor := 14680010;
  SynEdit1.Color := clCream;
  SynEdit1.Font.Color := clWindowText;
  SynEdit1.Gutter.Color := clBtnFace;
  SynEdit1.Gutter.Font.Color := clWindowText;
  SynEdit1.Gutter.GradientStartcolor := cl3dLight;
  SynEdit1.Gutter.GradientEndColor := clBtnFace;;
  SynPHPSyn1.CommentAttri.Foreground := 33023;
  SynPHPSyn1.IdentifierAttri.Foreground := 4194304;
  SynPHPSyn1.KeyAttri.Foreground := 4227072;
  SynPHPSyn1.NumberAttri.Foreground := 213;
  SynPHPSyn1.StringAttri.Foreground := 13762560;
  SynPHPSyn1.SymbolAttri.Foreground := 4227072;
  SynPHPSyn1.VariableAttri.Foreground := 213;
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

procedure TForm1.WebBrowser1WindowClosing(ASender: TObject;
  IsChildWindow: WordBool; var Cancel: WordBool);
resourcestring
  SCloseRequest = 'A script has requested the window to be closed. The window of a standalone script would now close.';
begin
  ShowMessage(SCloseRequest);
  TWebBrowser(ASender).Clear;
  Cancel := true;
end;

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

  {$REGION 'Intelligent browser (executes PHP scripts which are clicked in a hyperlink)'}
  if URL <> 'about:blank' then
  begin
    myUrl := URL;

    p := Pos('?', myUrl);
    if p >= 1 then myURL := copy(myURL, 1, p-1);

    // TODO: myURL urldecode
    // TODO: maybe we could even open that file in the editor!
    // TODO: ?parameter=....

    if FileExists(myURL) and (EndsText('.php', myURL) or EndsText('.php3', myURL) or EndsText('.php4', myURL) or EndsText('.php5', myURL) or EndsText('.phps', myURL)) then
    begin
      WebBrowser1.LoadHTML(RunPHPScript(myURL), myUrl);
      Cancel := true;
    end;
  end;
  {$ENDREGION}
end;

procedure TForm1.BtnLightClick(Sender: TObject);
var
  CanClose: boolean;
begin
  FormCloseQuery(Form1, CanClose);
  if not CanClose then exit;

  if IsThemeDark then
  begin
    BtnLight.Picture.Assign(BtnLightOn.Picture);
    Theme_Light;
    TFastPHPConfig.DarkTheme := false;
  end
  else
  begin
    BtnLight.Picture.Assign(BtnLightOff.Picture);
    Theme_Dark;
    TFastPHPConfig.DarkTheme := true;
  end;
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

procedure TForm1.FileModTimerTimer(Sender: TObject);
resourcestring
  SChangeConflict = 'The file was changed in a different application BUT IT WAS ALSO MODIFIED HERE! Reload file AND LOSE CHANGES HERE?';
  SChangeNotify = 'The file was changed in a different application! Reload file?';
begin
  FileModTimer.Enabled := false;
  if FileModLast <> FileAge(GetScrapFile) then
  begin
    FileModLast := FileAge(GetScrapFile);
    if SynEdit1.Modified then
    begin
      if MessageDlg(SChangeConflict, mtWarning, mbYesNoCancel, 0) = mrYes then
      begin
        SynEdit1.Lines.LoadFromFile(GetScrapFile);
      end;
    end
    else
    begin
      if MessageDlg(SChangeNotify, mtConfirmation, mbYesNoCancel, 0) = mrYes then
      begin
        SynEdit1.Lines.LoadFromFile(GetScrapFile);
      end;
    end;
  end;
  FileModTimer.Enabled := true;
end;

procedure TForm1.FontSizeTimerTimer(Sender: TObject);
begin
  if Memo2.Font.Size <> (SynEdit1.Font.Size-3) then
    Memo2.Font.Size := (SynEdit1.Font.Size-3);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DragAcceptFiles(Handle, False);
  TFastPHPConfig.FontSize := SynEdit1.Font.Size;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  r: integer;
resourcestring
  SWantToSave = 'Do you want to save?';
begin
  if SynEdit1.Modified then
  begin
    if (ParamStr(1) <> '') or (FSaveAsFilename <> '') then
    begin
      r := MessageDlg(SWantToSave, mtConfirmation, mbYesNoCancel, 0);
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
  end
  else
  begin
    CanClose := true;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  exeDir: string;
  sScrapFile: string;
begin
  HlpPrevPageIndex := -1;
  CurSearchTerm := '';
  sScrapFile := GetScrapFile;
  Caption := Caption + ' - ' + sScrapFile;
  Application.Title := Format('%s - FastPHP', [ExtractFileName(sScrapFile)]); // do not translate!
  SrcRep := TSynEditFindReplace.Create(self);
  SrcRep.Editor := SynEdit1;
  SynEdit1.Gutter.Gradient := HighColorWindows;

  Screen.Cursors[crMouseGutter] := LoadCursor(hInstance, 'MOUSEGUTTER');
  SynEdit1.Gutter.Cursor := crMouseGutter;

  exeDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  if FileExists(exeDir + 'codeexplorer.bmp') then ImageList1.LoadAndSplitImages(exeDir + 'codeexplorer.bmp');

  FileModLast := FileAge(sScrapFile);
  FileModTimer.Enabled := True;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(ChmIndex) then
  begin
    FreeAndNil(ChmIndex);
  end;
  FreeAndNil(SrcRep);

  if hMutex <> 0 then CloseHandle(hMutex); // Note: ReleaseMutex does not work as expected!

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
resourcestring
  SFileAlreadyOpen = 'File "%s" is alrady open!';
begin
  if FormShowRanOnce then exit; // If the theme is changed from normal to dark, OnShow will be called another time
  FormShowRanOnce := true;

  DoubleBuffered := true;

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

  PageControl1.ActivePage := PlaintextTabSheet;

  PageControl2.ActivePage := CodeTabsheet;
  HelpTabsheet.TabVisible := false;

  tmpFontSize := TFastPHPConfig.FontSize;
  if tmpFontSize <> -1 then SynEdit1.Font.Size := tmpFontSize;

  if FileExists(ScrapFile) then
  begin
    if hMutex = 0 then
    begin
      hMutex := CreateMutex(nil, True, PChar('FastPHP'+md5(UpperCase(ScrapFile)))); // do not translate
      if GetLastError = ERROR_ALREADY_EXISTS then
      begin
        // TODO: It would be great if the window of that FastPHP instance would switched to foreground
        ShowMessageFmt(SFileAlreadyOpen, [ScrapFile]);
        Application.Terminate; // Close;
        exit;
      end;

      SynEdit1.Lines.LoadFromFile(ScrapFile);
    end;
  end
  else
    SynEdit1.Lines.Clear;

  SynEdit1.Modified := false; // is required for Delphi 11

  SynEdit1.ClearUndo; // Avoid that Ctrl+Z deletes a freshly opened file

  SynEdit1.Modified := false; // we do need to do it BEFORE *and* AFTER ClearUndo ( https://github.com/danielmarschall/fastphp/issues/6 )

  SynEdit1.SetFocus;

  StartCodeExplorer;

  DragAcceptFiles(Handle, True);

  StartupTimer.Enabled := true;
end;

procedure TForm1.ChooseanotherCHMhelpfile1Click(Sender: TObject);
begin
  Help(true);
end;

procedure TForm1.ChooseanotherPHPinterpreter1Click(Sender: TObject);
begin
  GetPHPExe(true);
end;

function TForm1.ContainsUnicodeCharsInAnsiFile: boolean;
var
  lines: TStringList;
  ms: TMemoryStream;
begin
  if SynEdit1.Lines.Encoding = TEncoding.UTF8 then
  begin
    result := false;
    exit;
  end;

  lines := TStringList.Create;
  ms := TMemoryStream.Create;
  try
    SynEdit1.Lines.SaveToStream(ms);
    ms.Position := 0;
    lines.LoadFromStream(ms);
    result := Trim(lines.Text) <> Trim(synedit1.Lines.Text);
  finally
    FreeAndNil(ms);
    FreeAndNil(lines);
  end;
end;

procedure TForm1.SaveToFile(filename: string);
var
  ss: TStringStream;
  ms: TMemoryStream;
  fs: TFileStream;
  eolStyle: string;
  str: string;
  UpgradeEncodingToUnicode: boolean;
  DoReloadEncoding: boolean;
resourcestring
  LNG_UpgradeToUtf8 = 'Unicode characters have been inserted to this ANSI encoded file. Convert file to UTF-8? (If you choose "No", the Unicode characters will be replaced with "?")';
begin
  FileModTimer.Enabled := false;

  if ContainsUnicodeCharsInAnsiFile then
  begin
    DoReloadEncoding := true;
    case MessageBox(Handle, PChar(LNG_UpgradeToUtf8), PChar(Caption), MB_YESNOCANCEL) of
      ID_YES:
      begin
        UpgradeEncodingToUnicode := true;
      end;
      ID_NO:
      begin
        UpgradeEncodingToUnicode := false;
      end;
      ID_CANCEL:
      begin
        Abort;
      end;
    end;
  end
  else
  begin
    DoReloadEncoding := false;
    UpgradeEncodingToUnicode := false;
  end;

  ms := TMemoryStream.Create;
  ss := TStringStream.Create('');
  fs := TFileStream.Create(filename, fmCreate);
  try
    // Save everything in a memory stream and then to a string
    // in comparison to "str := SynEdit1.Lines.Text;",
    // This approach should preserve LF / CRLF line endings
    if UpgradeEncodingToUnicode then
      SynEdit1.Lines.SaveToStream(ms, TEncoding.UTF8) // upgrade an ANSI file to UTF-8 (e.g. if you include Japanese characters)
    else
      SynEdit1.Lines.SaveToStream(ms);
    if DoReloadEncoding then
    begin
      ms.Position := 0;
      SynEdit1.Lines.LoadFromStream(ms);
    end;
    ms.Position := 0;
    ss.CopyFrom(ms, ms.Size);
    ss.Position := 0;
    str := ss.ReadString(ss.Size);
    ss.Size := 0; // clear string-stream, because we need it later again

    // Detect current line-endings
    if Copy(str, 1, 2) = '#!' then
    begin
      // Shebang. Use ONLY Linux LF
      str := StringReplace(str, #13#10, #10, [rfReplaceAll]);
      eolStyle := #10 // Linux LF
    end
    else
    begin
      if Pos(#13#10, str) > 0 then
        eolStyle := #13#10 // Windows CRLF
      else if Pos(#10, str) > 0 then
        eolStyle := #10 // Linux LF
      else
      begin
        if DefaultTextLineBreakStyle = tlbsLF then
          eolStyle := #10 // Linux LF
        else if DefaultTextLineBreakStyle = tlbsCRLF then
          eolStyle := #13#10 // Windows CRLF
        //else if DefaultTextLineBreakStyle = tlbsCR then
        //  eolStyle := #13 // Old Mac CR
        else
          eolStyle := #13#10; // (Should not happen)
      end;
    end;

    // Unitfy line-endings
    str := StringReplace(str, #13, '', [rfReplaceAll]);
    str := StringReplace(str, #10, eolStyle, [rfReplaceAll]);

    // Replace all trailing linebreaks by a single line break
    // Note: Removing all line breaks is not good, since Linux's "nano" will
    //       re-add a linebreak at the end of the file
    str := TrimRight(str) + eolStyle;

    // Old versions of Delphi/SynEdit write an UTF-8 BOM, which makes problems
    // e.g. with AJAX handlers (because AJAX reponses must not have a BOM).
    // So we try to avoid that.
    // Note that the output is still UTF-8 encoded if the input file was UTF-8 encoded
    if Copy(str,1,3) = #$EF#$BB#$BF then Delete(str, 1, 3);

    // Now save to the file
    ss.WriteString(str);
    ss.Position := 0;
    fs.CopyFrom(ss, ss.Size-ss.Position);
  finally
    FreeAndNil(ms);
    FreeAndNil(ss);
    FreeAndNil(fs);
  end;

  FileModLast := FileAge(GetScrapFile);
  FileModTimer.Enabled := True;
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

procedure TForm1.StartUpTimerTimer(Sender: TObject);
begin
  StartupTimer.Enabled := false;

  // We need this timer because we cannot change the Theme during OnShow,
  // because the Delphi VCL Theme is buggy!

  if TFastPHPConfig.DarkTheme then
  begin
    BtnLight.Picture.Assign(BtnLightOff.Picture);
    Theme_Dark;
  end
  else
  begin
    BtnLight.Picture.Assign(BtnLightOn.Picture);
    Theme_Light;
  end;
end;

function TForm1.GetScrapFile: string;
var
  tmpPath: string;
resourcestring
  SFileDoesNotExistsCreate = 'File %s does not exist. Create it?';
  SPathDoesNotExistTryAgain = 'Path does not exist! Please try again.';
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
      case MessageDlg(Format(SFileDoesNotExistsCreate, [result]), mtConfirmation, mbYesNoCancel, 0) of
        mrYes:
          try
            SaveToFile(result);
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
          MessageDlg(SPathDoesNotExistTryAgain, mtWarning, [mbOk], 0);
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
          SaveToFile(result);
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

procedure TForm1.Help(AForceSelectNewHelpFile: boolean=false);
var
  IndexFile, chmFile, w, OriginalWord, url: string;
  internalHtmlFile: string;
resourcestring
  SChmFileNotAValidPHPDocumentation = 'The CHM file is not a valid PHP documentation. Cannot use help.';
  SUnknownErrorCannotUseHelp = 'Unknown error. Cannot use help.';
  SNoHelpAvailable = 'No help for "%s" available';
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
          MessageDlg(SChmFileNotAValidPHPDocumentation, mtError, [mbOk], 0);
          exit;
        end;
      finally
        Screen.Cursor := crDefault;
        Panel1.Visible := false;
      end;

      if not FileExists(IndexFile) then
      begin
        MessageDlg(SUnknownErrorCannotUseHelp, mtError, [mbOk], 0);
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

  internalHtmlFile := ChmIndex.ReadString('function', CurSearchTerm, ''); // do not translate
  if internalHtmlFile = '' then
    internalHtmlFile := ChmIndex.ReadString('_HelpWords_', CurSearchTerm, ''); // do not translate
  if internalHtmlFile = '' then
  begin
    HelpTabsheet.TabVisible := false;
    HlpPrevPageIndex := -1;
    ShowMessageFmt(SNoHelpAvailable, [Originalword]);
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
      line := copy(line, p+length(toFind), 99); // TODO: "(test.php:123)" does not work, because "123)" will be tried to convert to Integer
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
  _process(ExtractFileName(GetScrapFile) + ' on line '); // do not translate!
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
  _process(ExtractFileName(GetScrapFile) + ' on line '); // do not translate!
  {$ENDREGION}

  result := cont;
end;

function TForm1.InputRequestCallback(var data: AnsiString): boolean;
begin
  data := UTF8Encode(SynEdit1.Text);
  result := true;
end;

function TForm1.IsThemeDark: boolean;
begin
  result := Assigned(TStyleManager.ActiveStyle) and (TStyleManager.ActiveStyle.Name<>'Windows');
end;

function TForm1.OutputNotifyCallback(const data: AnsiString): boolean;
begin
  result := TreeView1.FillWithFastPHPData(string(data));
end;

end.
