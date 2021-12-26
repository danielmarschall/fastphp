unit FindReplace;

  (*
  TSynSearchOption = (ssoMatchCase, ssoWholeWord, ssoBackwards,
    ssoEntireScope, ssoSelectedOnly, ssoReplace, ssoReplaceAll, ssoPrompt);

  frDisableMatchCase
  Disables (grays) the Match Case check box in a find dialog.
  frDisableUpDown
  Disables (grays) the Up and Down buttons, which determine the direction of the search.
  frDisableWholeWord
  Disables (grays) the Match Whole Word check box of find dialog.
  frDown = not ssoBackwards
  Selects the Down button by default when the dialog opens. If the frDown flags is off, Up is selected when the dialog opens. (By default, frDown is on.)
  frFindNext
  This flag is turned on when the user clicks the Find Next button and turned off when the dialog closes.
  frHideMatchCase
  Removes the Match Case check box from the dialog.
  frHideWholeWord
  Removes the Match Whole Word check box from the dialog.
  frHideUpDown
  Removes the Up and Down buttons from the dialog.
  frMatchCase = ssoMatchCase
  This flag is turned on (off) when the user selects (deselects) the Match Case check box. To select the check box by default when the dialog opens, set frMatchCase at design time.
  frReplace = ssoReplace
  Applies to TReplaceDialog only. This flag is set by the system to indicate that the application should replace the current occurrence (and only the current occurrence) of the FindText string with the ReplaceText string. Not used in search routines.
  frReplaceAll = ssoReplaceAll
  Applies to TReplaceDialog only. This flag is set by the system to indicate that the application should replace all occurrences of the FindText string with the ReplaceText string.
  frShowHelp
  Displays a Help button in the dialog.
  frWholeWord = ssoWholeWord
  This flag is turned on (off) when the user selects (deselects) the Match Whole Word check box. To select the check box by default when the dialog opens, set frWholeWord at design time.
  *)

interface

uses
  Windows, Messages, SysUtils, Classes, Dialogs, SynEdit, System.UITypes;

type
  TSynEditFindReplace = class(TComponent)
  private
    fEditor: TSynEdit;
    fReplaceDialog: TReplaceDialog;
    fFindDialog: TFindDialog;
    fAutofocus: boolean;
  protected
    type
      TFindDirection = (sdDefault, sdForwards, sdBackwards);

    procedure OnFind(Sender: TObject); virtual;
    procedure OnReplace(Sender: TObject); virtual;

    procedure DoFind(dialog: TFindDialog; direction: TFindDirection); overload;
    procedure DoReplace(dialog: TReplaceDialog; direction: TFindDirection);

    function GetDirection(dialog: TFindDialog): TFindDirection;

  public
    constructor Create(AOwner: TComponent); override;

    property FindDialog: TFindDialog read fFindDialog;
    property ReplaceDialog: TReplaceDialog read fReplaceDialog;

    procedure CloseDialogs;

    procedure FindExecute;
    procedure ReplaceExecute;

    procedure FindContinue;
    procedure FindNext;
    procedure FindPrev;

    procedure GoToLine(LineNumber: integer);

  published
    property Editor: TSynEdit read fEditor write fEditor;
    property Autofocus: boolean read fAutofocus write fAutofocus;
  end;

implementation

uses
  SynEditTypes;

constructor TSynEditFindReplace.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fFindDialog := TFindDialog.Create(Self);
  fFindDialog.OnFind := OnFind;

  fReplaceDialog := TReplaceDialog.Create(Self);
  fReplaceDialog.OnReplace := OnReplace;
  fReplaceDialog.OnFind := OnFind;
  fReplaceDialog.Options := fReplaceDialog.Options + [frHideWholeWord]; // TODO: currently not supported (see below)
end;

function TSynEditFindReplace.GetDirection(dialog: TFindDialog): TFindDirection;
begin
  if frDown in dialog.Options then
    result := sdForwards
  else
    result := sdBackwards;
end;

procedure TSynEditFindReplace.DoFind(dialog: TFindDialog; direction: TFindDirection);
var
  opt: TSynSearchOptions;
  found: boolean;
begin
  if direction = sdDefault then direction := GetDirection(dialog);

  if fEditor.SelAvail then
  begin
    if direction = sdForwards then
    begin
      fEditor.SelStart := fEditor.SelStart + 1;
      fEditor.SelLength := 0;
    end
    else
    begin
      // Links von Selektion springen
      fEditor.SelLength := 0;
    end;
  end;

  opt := [];
  if frMatchCase in dialog.Options then Include(opt, ssoMatchCase);
  if frWholeWord in dialog.Options then Include(opt, ssoWholeWord);
  //if frReplace in dialog.Options then Include(opt, ssoReplace);
  //if frReplaceAll in dialog.Options then Include(opt, ssoReplaceAll);
  if direction = sdBackwards then Include(opt, ssoBackwards);
  //Include(opt, ssoPrompt); // TODO: test. geht nicht?
  //if fEditor.SelAvail then Include(opt, ssoSelectedOnly);  // TODO: geht nicht, weil er bei einer suche ja dann etwas selektirert und dann nicht weitergeht
  Exclude(opt, ssoEntireScope); // TODO: ok?

  found := fEditor.SearchReplace(dialog.FindText, '', opt) > 0;

  if not found then
  begin
    // TODO: If single replace was chosen, behave like Notepad and select the last replaced word
    if direction = sdForwards then
      MessageDlg('End of document reached.', mtInformation, [mbOk], 0)
    else
      MessageDlg('Begin of document reached.', mtInformation, [mbOk], 0);
  end;

  if fAutofocus and fEditor.CanFocus then fEditor.SetFocus;
end;

procedure TSynEditFindReplace.DoReplace(dialog: TReplaceDialog; direction: TFindDirection);
var
  opt: TSynSearchOptions;
  numReplacements: integer;
begin
  try
    if direction = sdDefault then direction := GetDirection(dialog);

    opt := [];
    if frMatchCase in dialog.Options then Include(opt, ssoMatchCase);
    if frWholeWord in dialog.Options then Include(opt, ssoWholeWord);
    if frReplace in dialog.Options then Include(opt, ssoReplace);
    if frReplaceAll in dialog.Options then Include(opt, ssoReplaceAll);
    if direction = sdBackwards then Include(opt, ssoBackwards);
    Include(opt, ssoPrompt); // TODO: test. geht nicht?
    if fEditor.SelAvail then Include(opt, ssoSelectedOnly);
    Exclude(opt, ssoEntireScope); // TODO: ok?

    if not (ssoReplaceAll in opt) then
    begin
      if fEditor.SelLength = 0 then
      begin
        DoFind(dialog, sdForwards);
        exit;
      end;
    end;

    fEditor.BeginUpdate; // TODO: geht nicht?
    //fEditor.BeginUndoBlock;
    try
      numReplacements := fEditor.SearchReplace(dialog.FindText, dialog.ReplaceText, opt);
    finally
      //fEditor.EndUndoBlock;
      fEditor.EndUpdate;
    end;

    if not (ssoReplaceAll in opt) then
    begin
      DoFind(dialog, sdForwards);
    end
    else
    begin
      ShowMessageFmt('%d replaced.', [numReplacements]);
    end;
  finally
    if fAutofocus and fEditor.CanFocus then fEditor.SetFocus;
  end;
end;

procedure TSynEditFindReplace.OnFind(Sender: TObject);
begin
  DoFind(Sender as TFindDialog, sdDefault);
end;

procedure TSynEditFindReplace.OnReplace(Sender: TObject);
begin
  DoReplace(Sender as TReplaceDialog, sdDefault);
end;

procedure TSynEditFindReplace.FindExecute;
begin
  fFindDialog.Execute;
end;

procedure TSynEditFindReplace.ReplaceExecute;
begin
  fReplaceDialog.Execute;
end;

procedure TSynEditFindReplace.FindContinue;
begin
  if fFindDialog.FindText = '' then
  begin
    fFindDialog.Options := fFindDialog.Options + [frDown]; // Default direction: down
    FindExecute;
  end
  else
    DoFind(fFindDialog, sdDefault);
end;

procedure TSynEditFindReplace.FindNext;
begin
  if fFindDialog.FindText = '' then
  begin
    fFindDialog.Options := fFindDialog.Options + [frDown];
    FindExecute;
  end
  else
    DoFind(fFindDialog, sdForwards);
end;

procedure TSynEditFindReplace.FindPrev;
begin
  if fFindDialog.FindText = '' then
  begin
    fFindDialog.Options := fFindDialog.Options - [frDown];
    FindExecute;
  end
  else
    DoFind(fFindDialog, sdBackwards);
end;

procedure TSynEditFindReplace.GoToLine(LineNumber: integer);
var
  currentLine: integer;
  i: integer;
begin
  currentLine := 1;

  for i := 1 to fEditor.GetTextLen do
  begin
    if currentLine = LineNumber then
    begin
      fEditor.selStart := i;
      fEditor.SetFocus;
      Exit;
    end
    else if fEditor.Text = #$D then
      inc(currentLine);
  end;
end;

procedure TSynEditFindReplace.CloseDialogs;
begin
  fFindDialog.CloseDialog;
  fReplaceDialog.CloseDialog;
end;

end.
