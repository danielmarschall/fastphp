unit Unit1;

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

// TODO: strg+f / h
// TODO: font bigger
// TODO: code in bildschirmmitte?
// TODO: regelm‰ﬂig scrap zwischenspeichern, oder bei strg+s

// Future ideas
// - ToDo list
// - Open/Save real files
// - multiple scraps?
// - verschiedene php versionen?
// - webbrowser1 nur laden, wenn man den tab anw‰hlt?
// - doppelklick auf tab soll diesen schlieﬂen
// - Strg+S
// - Onlinehelp (www) aufrufen

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, ComCtrls, ExtCtrls, ToolWin, IniFiles,
  SynEditHighlighter, SynHighlighterPHP, SynEdit, SHDocVw_TLB;

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    PlaintextTabSheet: TTabSheet;
    HtmlTabSheet: TTabSheet;
    Memo2: TMemo;
    WebBrowser1: TWebBrowser;
    Splitter1: TSplitter;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    HelpTabsheet: TTabSheet;
    WebBrowser2: TWebBrowser;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    OpenDialog2: TOpenDialog;
    OpenDialog3: TOpenDialog;
    SynEdit1: TSynEdit;
    SynPHPSyn1: TSynPHPSyn;
    Panel2: TPanel;
    SynEditFocusTimer: TTimer;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
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
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    CurSearchTerm: string;
    HlpPrevPageIndex: integer;
    procedure Help;
    procedure ApplicationOnMessage(var Msg: tagMSG; var Handled: Boolean);
    function MarkUpLineReference(cont: string): string;
  protected
    FastPHPConfig: TMemIniFile;
    ChmIndex: TMemIniFile;
    procedure GotoLineNo(LineNo:integer);
    function GetScrapFile: string;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Functions, StrUtils;

procedure TForm1.ApplicationOnMessage(var Msg: tagMSG; var Handled: Boolean);
var
  val: string;
  lineno: integer;
begin
  case Msg.message of
    WM_KEYUP:
    begin
      case Msg.wParam of
        {$REGION 'Esc'}
        VK_ESCAPE:
        begin
          Handled := true;
          // It is necessary to use Application.OnMessage, because Form1.KeyPreview does not work when TWebBrowser has the focus
          if (HlpPrevPageIndex <> -1) and (PageControl2.ActivePage = HelpTabSheet) and
             (HelpTabsheet.TabVisible) then
          begin
            PageControl2.ActivePageIndex := HlpPrevPageIndex;
            HelpTabsheet.TabVisible := false;
          end;
        end;
        {$ENDREGION}

        {$REGION 'Ctrl+G : Go to line'}
        ord('G'):
        begin
          // TODO: VK_LMENU does not work! only works with AltGr but not Alt
          // http://stackoverflow.com/questions/16828250/delphi-xe2-how-to-prevent-the-alt-key-stealing-focus ?
          if (GetKeyState(VK_CONTROL) < 0) then
          begin
            Handled := true;
            InputQuery('Go to', 'Line number:', val);
            if not TryStrToInt(val, lineno) then exit;
            GotoLineNo(lineno);
          end;
        end;
        {$ENDREGION}

        VK_F1:
        begin
          if SynEdit1.Focused then
          begin
            Handled := true;
            Help;
          end;
        end;

        VK_F5:
        begin
          Run(Self);
        end;

        VK_F9:
        begin
          Run(Self);
        end;
      end;
    end;
  end;
end;

procedure TForm1.Run(Sender: TObject);
var
  phpExe: string;
begin
  memo2.Lines.Text := '';
  BrowseContent(Webbrowser1, memo2.Lines.Text);
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;

  try
    if not FileExists(phpExe) then
    begin
      phpExe := FastPHPConfig.ReadString('Paths', 'PHPInterpreter', '');
      if not FileExists(phpExe) then
      begin
        if not OpenDialog2.Execute then exit;
        if not FileExists(OpenDialog2.FileName) then exit;
        phpExe := OpenDialog2.FileName;

        if not IsValidPHPExe(phpExe) then
        begin
          ShowMessage('This is not a valid PHP executable.');
          exit;
        end;

        FastPHPConfig.WriteString('Paths', 'PHPInterpreter', phpExe);
        FastPHPConfig.UpdateFile;
      end;
    end;

    SynEdit1.Lines.SaveToFile(GetScrapFile);

    memo2.Lines.Text := GetDosOutput('"'+phpExe+'" "'+GetScrapFile+'"', ExtractFileDir(Application.ExeName));

    BrowseContent(Webbrowser1, MarkUpLineReference(memo2.Lines.Text));

    if IsTextHTML(memo2.lines.text) then
      PageControl1.ActivePage := HtmlTabSheet
    else
      PageControl1.ActivePage := PlaintextTabSheet;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TForm1.SynEditFocusTimerTimer(Sender: TObject);
begin
  SynEditFocusTimer.Enabled := false;
  Button1.SetFocus; // Workaround for weird bug... This (and the timer) is necessary to get the focus to SynEdit1
  SynEdit1.SetFocus;
end;

procedure TForm1.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
const
  MAG_BEGIN = 'fastphp://gotoline/';
var
  s: string;
  lineno: integer;
begin
  if Copy(URL, 1, length(MAG_BEGIN)) = MAG_BEGIN then
  begin
    try
      s := copy(URL, length(MAG_BEGIN)+1, 99);
      if not TryStrToInt(s, lineno) then exit;
      GotoLineNo(lineno);
      SynEditFocusTimer.Enabled := true;
    finally
      Cancel := true;
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Run(Sender);
  SynEdit1.SetFocus;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Help;
  if PageControl2.ActivePage = HelpTabsheet then
    WebBrowser2.SetFocus
  else if PageControl2.ActivePage = TabSheet3{Scrap} then
    SynEdit1.SetFocus;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  val: string;
  lineno: integer;
begin
  InputQuery('Go to', 'Line number:', val);
  if not TryStrToInt(val, lineno) then
  begin
    if SynEdit1.CanFocus then SynEdit1.SetFocus;
    exit;
  end;
  GotoLineNo(lineno);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SynEdit1.Lines.SaveToFile(GetScrapFile);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  HlpPrevPageIndex := -1;
  CurSearchTerm := '';
  Application.OnMessage := ApplicationOnMessage;

  FastPHPConfig := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(ChmIndex) then
  begin
    FreeAndNil(ChmIndex);
  end;

  FastPHPConfig.UpdateFile;
  FreeAndNil(FastPHPConfig);
end;

procedure TForm1.FormShow(Sender: TObject);
var
  ScrapFile: string;
begin
  ScrapFile := GetScrapFile;
  if ScrapFile = '' then
  begin
    Close;
    exit;
  end;
  SynEdit1.Lines.LoadFromFile(ScrapFile);

  PageControl1.ActivePage := PlaintextTabSheet;

  PageControl2.ActivePageIndex := 0; // Scraps
  HelpTabsheet.TabVisible := false;

  SynEdit1.SetFocus;
end;

function TForm1.GetScrapFile: string;
begin
  result := FastPHPConfig.ReadString('Paths', 'ScrapFile', '');
  if not FileExists(result) then
  begin
    if not OpenDialog3.Execute then
    begin
      result := '';
      exit;
    end;

    result := OpenDialog3.FileName;

    if not DirectoryExists(ExtractFilePath(result)) then
    begin
      ShowMessage('Path does not exist!');
      result := '';
      exit;
    end;

    SynEdit1.Lines.Clear;
    SynEdit1.Lines.SaveToFile(result);

    FastPHPConfig.WriteString('Paths', 'ScrapFile', result);
  end;
end;

procedure TForm1.Help;
var
  IndexFile, chmFile, w, url: string;
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
  if w[1] in ['0'..'9'] then exit;  
  w := StringReplace(w, '_', '-', [rfReplaceAll]);
  w := LowerCase(w);
  CurSearchTerm := w;

  internalHtmlFile := ChmIndex.ReadString('_HelpWords_', CurSearchTerm, '');
  if internalHtmlFile = '' then
  begin
    HelpTabsheet.TabVisible := false;
    HlpPrevPageIndex := -1;
    ShowMessage('No help for "'+CurSearchTerm+'" available');
    Exit;
  end;

  url := 'mk:@MSITStore:'+ChmFile+'::'+internalHtmlFile;

  HlpPrevPageIndex := PageControl2.ActivePageIndex; // Return by pressing ESC
  HelpTabsheet.TabVisible := true;
  PageControl2.ActivePage := HelpTabsheet;
  BrowseURL(WebBrowser2, url);
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
    if not (line[i] in [' ', #9]) then
    begin
      SynEdit1.CaretX := i-1;
      break;
    end;
  end;

  PageControl2.ActivePage := TabSheet3{Scrap};
  if SynEdit1.CanFocus then SynEdit1.SetFocus;
end;

procedure TForm1.Memo2DblClick(Sender: TObject);
var
  line: string;
  p, lineno: integer;
begin
  line := memo2.Lines.Strings[Memo2.CaretPos.Y];
  p := Pos(' on line ', line);
  if p = 0 then exit;
  line := copy(line, p+length(' on line '), 99);
  if not TryStrToInt(line, lineno) then exit;
  GotoLineNo(lineno);
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

function TForm1.MarkUpLineReference(cont: string): string;
var
  p, a, b: integer;
  num: integer;
  insert_a, insert_b: string;
begin
  // TODO: make it more specific to PHP error messages. "on line" is too broad.
  p := Pos(' on line ', cont);
  while p >= 1 do
  begin
    a := p+1;
    b := p+length(' on line ');
    num := 0;
    while cont[b] in ['0'..'9'] do
    begin
      num := num*10 + StrToInt(cont[b]);
      inc(b);
    end;

    insert_b := '</a>';
    insert_a := '<a href="fastphp://gotoline/'+IntToStr(num)+'">';

    insert(insert_b, cont, b);
    insert(insert_a, cont, a);

    p := b + Length(insert_a) + Length(insert_b);

    p := PosEx(' on line ', cont, p+1);
  end;

  result := cont;
end;

end.
