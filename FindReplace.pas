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
resourcestring
  SBofReached = 'Begin of document reached.';
  SEofReached = 'End of document reached.';
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
      // Jump left to selection
      fEditor.SelLength := 0;
    end;
  end;

  opt := [];
  if frMatchCase in dialog.Options then Include(opt, ssoMatchCase);
  if frWholeWord in dialog.Options then Include(opt, ssoWholeWord);
  //if frReplace in dialog.Options then Include(opt, ssoReplace);
  //if frReplaceAll in dialog.Options then Include(opt, ssoReplaceAll);
  if direction = sdBackwards then Include(opt, ssoBackwards);
  //Include(opt, ssoPrompt); // TODO: test. does not work?
  //if fEditor.SelAvail then Include(opt, ssoSelectedOnly);  // TODO: doesn't work because when you search it selects something and then doesn't go any further
  Exclude(opt, ssoEntireScope); // TODO: ok?

  found := fEditor.SearchReplace(dialog.FindText, '', opt) > 0;

  if not found then
  begin
    // TODO: If single replace was chosen, behave like Notepad and select the last replaced word
    if direction = sdForwards then
      MessageDlg(SEofReached, mtInformation, [mbOk], 0)
    else
      MessageDlg(SBofReached, mtInformation, [mbOk], 0);
  end;

  if fAutofocus and fEditor.CanFocus then fEditor.SetFocus;
end;

procedure TSynEditFindReplace.DoReplace(dialog: TReplaceDialog; direction: TFindDirection);
var
  opt: TSynSearchOptions;
  numReplacements: integer;
  bakSelLenght, bakSelStart, bakSizeOld: Integer;
resourcestring
  SReplaceAllDoneEntireScope = '%d replaced in entire scope.';
  SReplaceAllDoneSelectionOnly = '%d replaced in selection.';
begin
  try
    if direction = sdDefault then direction := GetDirection(dialog);

    opt := [];
    if frMatchCase in dialog.Options then Include(opt, ssoMatchCase);
    if frWholeWord in dialog.Options then Include(opt, ssoWholeWord);
    if frReplace in dialog.Options then Include(opt, ssoReplace);
    if frReplaceAll in dialog.Options then Include(opt, ssoReplaceAll);
    if direction = sdBackwards then Include(opt, ssoBackwards);
    Include(opt, ssoPrompt); // TODO: test. does not work?
    if fEditor.SelAvail then
    begin
      Include(opt, ssoSelectedOnly);
      Exclude(opt, ssoEntireScope);
    end
    else
    begin
      Include(opt, ssoEntireScope);
      Exclude(opt, ssoSelectedOnly);
    end;

    if not (ssoReplaceAll in opt) then
    begin
      if fEditor.SelLength = 0 then
      begin
        DoFind(dialog, sdForwards);
        exit;
      end;
    end;

    fEditor.BeginUpdate; // For "replace all": avoid that the user sees how the program scrolls through the document and do replacements
    fEditor.BeginUndoBlock; // For "replace all": avoid that every replacement gets their own undo step
    try
      // will be needed later
      bakSelLenght := fEditor.SelLength;
      bakSelStart := fEditor.SelStart;
      bakSizeOld := Length(fEditor.Text);

      if (ssoReplaceAll in opt) and (ssoEntireScope in opt) then
      begin
        // Remember the selection start (we don't backup fEditor.SelStart, since the replacement might change the location)! by adding this character to the current cursor position
        // We assume that character #1 will not be in a text file!
        fEditor.SelLength := 0;
        fEditor.SelText := chr(1);
      end;

      numReplacements := fEditor.SearchReplace(dialog.FindText, dialog.ReplaceText, opt);

      // Restore position and selection after replacement
      // TODO: The SelStart and SelLength were kept, but the scrollposition did not. What can we do?
      if ssoReplaceAll in opt then
      begin
        if ssoEntireScope in opt then
        begin
          // Remove the temporary marker chr(1) and jump to that spot
          fEditor.SelStart := AnsiPos(chr(1), fEditor.Text)-1;
          fEditor.SelLength := 1;
          fEditor.SelText := ''; // remove the chr(1) again
          // restore initial select length
          fEditor.SelLength := bakSelLenght;
        end
        else if (ssoSelectedOnly in opt) then
        begin
          // restore initial selection
          fEditor.SelStart := bakSelStart;
          fEditor.SelLength := bakSelLenght + (Length(fEditor.Text) - bakSizeOld); // length will be adjusted, depending if the replacement changed length
        end;
      end;
    finally
      fEditor.EndUndoBlock;
      fEditor.EndUpdate;
    end;

    if (ssoReplaceAll in opt) and (ssoEntireScope in opt) then
    begin
      ShowMessageFmt(SReplaceAllDoneEntireScope, [numReplacements]);
    end
    else if (ssoReplaceAll in opt) and (ssoSelectedOnly in opt) then
    begin
      ShowMessageFmt(SReplaceAllDoneSelectionOnly, [numReplacements]);
    end
    else
    begin
      DoFind(dialog, sdForwards);
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
