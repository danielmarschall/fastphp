unit FindReplace;

// FindReplace.pas
// Source: http://www.tek-tips.com/viewthread.cfm?qid=160357
//         18 Nov 2001 "bearsite4"
// Changes by Daniel Marschall, especially to make it compatible with TSynEdit

interface

uses
  Windows, Messages, SysUtils, Classes, Dialogs, SynEdit;

type
  FindReplaceCommunication = ( frcAlertUser, frcAlertReplace, frcEndReached );
  {allows the replace functions to use the find function avoiding alot
   of code duplication.  frcAlertuser means that when the find function
   has reached the end of the text while searching for a word it will pop
   up a message saying the word can't be found. frcAlertReplace
   tells the find function not to display a message to the user saying that
   the word can't be found but instead to set the state to frcEndReached to
   let the replace function know it's reached the end of the text}

  TReplaceFunc = function ( const S1, S2: string ): Integer;

  TFindReplace = class(TComponent)
  private
    fEditor: TSynEdit;  {the richedit or memo component to hook it up to}
    fReplaceDialog: TReplaceDialog;  {the replace dialog}
    fFindDialog: TFindDialog;  {the find dialog}

    FindActionOnEnd: FindReplaceCommunication;  {the action the find function
     should take when it reaches the end of the text while searching for the
     word}

    function TestWholeWord( Sender: TFindDialog; TestString: string ): boolean;
    {returns a true or false depending on whether the user chose the whole word
     only option and whether or not the word is a whole word.  Actually, it can
     test multiple words in a single string as well.}

  protected
    type
      TFindDirection = (sdDefault, sdForwards, sdBackwards);

    procedure FindForwards( Sender: TFindDialog; start, finish: integer );
    {search through the editor in a forwards direction}
    procedure FindBackwards( Sender: TFindDialog; start, finish: integer );
    {search through the editor in a backwards direction}

    {defined event handlers}
    procedure OnFind( Sender: TObject ); virtual;
    procedure OnReplace( Sender: TObject ); virtual;

    {the centralised find/replace functions}
    function TryAndMatch( Sender: TFindDialog; index, finish: integer ): boolean; virtual;
    function TryAndReplace(dialog: TReplaceDialog): boolean; virtual;

    procedure DoReplace(dialog: TReplaceDialog); virtual;
    {the replace function that coordinates all the work}
    procedure DoReplaceAll(dialog: TReplaceDialog); virtual;
    {the replace all function that coordinates all the work}

    procedure DoFind(dialog: TFindDialog; direction: TFindDirection);

  public
    constructor Create( AOwner: TComponent); override;

    property FindDialog: TFindDialog read fFindDialog;
    property ReplaceDialog: TReplaceDialog read fReplaceDialog;

    procedure CloseDialogs;

    procedure FindExecute;
    {opens the find dialog}
    procedure ReplaceExecute;
    {opens the replace dialog}

    procedure FindContinue;
    procedure FindNext;
    procedure FindPrev;

    procedure GoToLine( LineNumber: integer );

  published
    property Editor: TSynEdit read fEditor write fEditor;
  end;

(*
procedure Register;
*)

implementation

(*
{$R findrep.dcr}
*)

constructor TFindReplace.Create( AOwner: TComponent );
begin
  inherited;

  {create the find dialog}
  fFindDialog := TFindDialog.Create( Self );
  {set up the event handlers}
  fFindDialog.OnFind := OnFind;

  {create the replace dialog}
  fReplaceDialog := TReplaceDialog.Create( Self );
  {set up the event handlers}
  fReplaceDialog.OnReplace := OnReplace;
  fReplaceDialog.OnFind := OnFind;
  fReplaceDialog.Options := fReplaceDialog.Options + [frHideWholeWord]; // TODO: currently not supported (see below)

  {set find's default action on end of text to alert the user.
   If a replace function changes this it is it's responsibility
   to change it back}
  FindActionOnEnd := frcAlertUser;
end;

procedure TFindReplace.FindForwards( Sender: TFindDialog; start, finish: integer );
var
  i: integer;

begin

  {to find the word we go through the text on a character by character
   basis}
  for i := start to finish do
    if TryAndMatch( Sender, i, finish ) then
    {if we've got a match then stop}
      Exit;

end;

procedure TFindReplace.FindBackwards( Sender: TFindDialog; start, finish: Integer );
{since only find has a (search) up option and replace doesn't
 we don't have to worry about sender since only the onFind will
 be calling this function}

var
  i: integer;

begin
  {See comments for findforward}

  {to find the word we go through the text on a character by character
   basis but working backwards}
  for i := finish downto start do
    if TryAndMatch( Sender, i, start ) then
      Exit;

end;

function TFindReplace.TryAndMatch( Sender: TFindDialog; index, finish: integer ): boolean;
{returns true if there was a match and false otherwise}
var
  StringToTest: string;

  StringComparison: TReplaceFunc;
  {the function to use to compare 2 strings.  Should be assigned
   different values according to the search criteria}

   FindTextLength: integer;

resourcestring
  S_CANT_BE_FOUND = '%s could not be found';
begin
  FindTextLength := Length( Sender.FindText );

  {create a new string to test against}
  StringToTest := copy( fEditor.Text, index+1, FindTextLength );

  {assign a case sensitive or case insensitive string
   comparison function to StringComparison depending
   on the whether or not the user chose to match case.
   The functions assigned are normal VCL functions.}
  if frMatchCase in Sender.Options then
    StringComparison := CompareStr
  else
    StringComparison := CompareText;

  if (StringComparison( StringToTest, Sender.FindText ) = 0) and
     TestWholeWord( Sender, copy( fEditor.Text, index, FindTextLength+2 ) ) then
  {with TestWholeWord we pass the value index not index+1 so that it will also
   get the previous character.  We pass the value FindTextLenght+2 so it
   will copy the next character after the test string aswell}
  begin  {if all true then we've found the text}
    {highlight the word}
    fEditor.SetFocus;
    fEditor.SelStart := index;
    fEditor.SelLength := FindTextLength;

    {quit the function}
    Result := true;  {because we've found the word}
    Exit;
  end
  {if we've tried the last character and we can't find it then
   display a message saying so.}
  else if (index = finish) and (FindActionOnEnd = frcAlertUser) then
    ShowMessageFmt(S_CANT_BE_FOUND, [Sender.FindText])
  {otherwise if the replace function requested us to keep quiet
   about it then don't display the message to the user}
  else if (index = finish) and (FindActionOnEnd = frcAlertReplace) then
    FindActionOnEnd := frcEndReached;

  Result := false;  {didn't find it}
end;

procedure TFindReplace.DoFind(dialog: TFindDialog; direction: TFindDirection);
var
//  highlightedText: pChar;
  highlightedText: string;

begin
  if direction = sdDefault then
  begin
    if frDown in dialog.Options then
      direction := sdForwards
    else
      direction := sdBackwards;
  end;

  {check if there is already some highlighted text.  If there is and
   this text is the text to search for then it's probably been highlighted
   by the previous find operation.  In this case, move selStart to
   the position after the final character so the find operation won't find
   the same word again.  If the user chose to search up then move selStart
   to the character before the highlighted word}
  if fEditor.SelLength > 0 then
  begin
    (*
    GetMem( highlightedText, fEditor.SelLength + 1 );
    fEditor.GetSelTextBuf( highlightedText, fEditor.SelLength+1 );
    *)
    highlightedText := fEditor.SelText;

    {compare the two strings}
    if StrIComp( PChar(highlightedText), pChar( dialog.FindText ) ) = 0 then
    begin
      if direction = sdForwards then
        fEditor.selStart := fEditor.SelStart + fEditor.SelLength
      else
        fEditor.selStart := fEditor.SelStart - 1;
    end;

    (*
    FreeMem( highlightedText, fEditor.SelLength + 1 );
    *)
  end;

  {begin the search}
  if direction = sdForwards then  {the user choose to search down}
  begin
    {if the user has highlighted a block of text only search
     within that block}
    if fEditor.SelLength > 0 then
      FindForwards( dialog, fEditor.selStart, fEditor.selStart + fEditor.selLength )
    {otherwise search the whole of the text}
    else
      FindForwards( dialog, fEditor.selStart, fEditor.GetTextLen );
  end
  else  {the user chose to search up}
  begin
    {if the user has highlighted a block of text only search
     within that block}
    if fEditor.SelLength > 0 then
      FindBackwards( dialog, fEditor.selStart, fEditor.selStart + fEditor.selLength )
    {otherwise search the whole of the text}
    else
      FindBackwards( dialog, 0, fEditor.selStart );
  end;
end;

procedure TFindReplace.OnFind(Sender: TObject);
var
  FindDialog: TFindDialog;
begin
  FindDialog := Sender as TFindDialog;
  DoFind(FindDialog, sdDefault);
end;

procedure TFindReplace.OnReplace( Sender: TObject );
var
  ReplaceDialog: TReplaceDialog;
begin
  ReplaceDialog := Sender as TReplaceDialog;

  {set the action on end to alert the function not the user}
  FindActionOnEnd := frcAlertReplace;

  // TODO: UnDo does not work

  {now replace the word}
  if frReplace in ReplaceDialog.Options then
    DoReplace(ReplaceDialog)
  else
    DoReplaceAll(ReplaceDialog);

  {reset the action on end to alert the user}
  FindActionOnEnd := frcAlertUser;
end;

procedure TFindReplace.DoReplace(dialog: TReplaceDialog);
begin
  FindForwards( dialog, fEditor.selStart, fEditor.GetTextLen );
  TryAndReplace(dialog);
  FindForwards( dialog, fEditor.selStart, fEditor.GetTextLen ); // Jump to the next occurrence
end;

procedure TFindReplace.DoReplaceAll(dialog: TReplaceDialog);
begin
  {see comments for DoReplace}

  fEditor.BeginUpdate;
  fEditor.BeginUndoBlock;
  try
    {if the user has highlighted a block of text only replace
     within that block}
    if fEditor.SelLength > 0 then
    begin
      // TODO: test this functionality
      FindForwards( dialog, fEditor.selStart, fEditor.selStart + fEditor.selLength );
      {keep replacing until we reach the end of the text}
      while FindActionOnEnd <> frcEndReached do
      begin
        {we enclose the TryAndReplace in a loop because there might be more
         than one occurence of the word in the line}
        while TryAndReplace(dialog) do
          FindForwards( dialog, fEditor.selStart, fEditor.selStart + fEditor.selLength );

        FindForwards( dialog, fEditor.selStart, fEditor.selStart + fEditor.selLength );
      end;
    end
    else {otherwise replace within the whole of the text}
    begin
      FindForwards( dialog, fEditor.selStart, fEditor.GetTextLen );
      while FindActionOnEnd <> frcEndReached do
      begin
        while TryAndReplace(dialog) do
          FindForwards( dialog, fEditor.selStart, fEditor.GetTextLen );

        FindForwards( dialog, fEditor.selStart, fEditor.GetTextLen );
      end;
    end;
  finally
    fEditor.EndUpdate;
    fEditor.EndUndoBlock;
  end;
end;

function TFindReplace.TryAndReplace(dialog: TReplaceDialog): boolean;
{returns true if a replacement was made and false otherwise.  This is
 so a function can keep calling TryAndReplace until it returns false
 since there might be more than one occurence of the word to replace
 in the line}

var
  LineNumber, ColumnNumber: integer;

  OldSelStart: integer;  {the position of the cursor prior to the text being replaced}


begin
  {assume no replacement was made}
  Result := false;

  {check to see if the word was found otherwise we don't add the
   replaceText to the editor.  That is, only delete the selected text
   and insert the replacement text if the end was not reached}
  if not (FindActionOnEnd = frcEndReached) then
  begin
    {get the line number and column number of the cursor which
     is needed for string manipulations later.  We should do this
     before the call to clear selection}

    // TODO: only replace beginning at the selected section / caret, not from beginning of the line!!
    LineNumber := fEditor.CaretY-1;
    ColumnNumber := fEditor.CaretX-1;

    {get the position of the cursor prior to the replace operation
     so we cab restore it later}
    OldSelStart := fEditor.SelStart;

    // Note: "fEditor.ClearSelection" can be used to delete the selected text

    // TODO: only replace beginning at the selected section / caret, not from beginning of the line
    // TODO: support "whole word" ?
    if frMatchCase in dialog.Options then
      fEditor.Lines[LineNumber] := StringReplace(fEditor.Lines[LineNumber], dialog.FindText, dialog.ReplaceText, [])
    else
      fEditor.Lines[LineNumber] := StringReplace(fEditor.Lines[LineNumber], dialog.FindText, dialog.ReplaceText, [rfIgnoreCase]);

    {set the result to true since we have made a replacement}
    Result := true;

    {reposition the cursor to the character after the last chracter in
     the newly replacing text.  This is mainly so we can locate multiple
     occurences of the to-be-replaced text in the same line}
    fEditor.SelStart := oldSelStart + length( dialog.ReplaceText );
  end
end;

procedure TFindReplace.FindExecute;
begin
  fFindDialog.Execute;
end;

procedure TFindReplace.ReplaceExecute;
begin
  fReplaceDialog.Execute;
end;

function TFindReplace.TestWholeWord( Sender: TFindDialog; TestString: string ): boolean;
var
  FindTextLength: integer;
begin
  {assume it's not a whole word}
  Result := false;

  FindTextLength := Length( Sender.FindText );

  {if the user didn't choose whole words only then basically
   we don't care about it so return true}
  if not (frWholeWord in Sender.Options) then
  begin
    Result := true;
    Exit;
  end;

  {Test if the word is a whole word}
  {Basically there are 4 cases: ( _ denotes whitespace )
   1. _word_
   2. \nword_
   3. _word\n
   4.\nword\n}
  {case 1,  note: #9 tab, #$A newline}
  if (CharInSet(TestString[1], [' ', #9 ])) and (CharInSet(TestString[FindTextLength + 2], [' ', #9 ])) then
    Result := true
  {case 2}
  else if(TestString[1] = #$A) and (CharInSet(TestString[FindTextLength + 2], [' ', #9 ])) then
    Result := true
  {case 3,  note: #$D end of line}
  else if(CharInSet(TestString[1], [' ', #9 ])) and (TestString[FindTextLength + 2] = #$D) then
    Result := true
  else if (TestString[1] = #$A) and (TestString[FindTextLength + 2] = #$D) then
    Result := true

end;

procedure TFindReplace.FindContinue;
begin
  if fFindDialog.FindText = '' then
  begin
    fFindDialog.Options := fFindDialog.Options + [frDown]; // Default direction: down
    FindExecute;
  end
  else
    DoFind(fFindDialog, sdDefault);
end;

procedure TFindReplace.FindNext;
begin
  if fFindDialog.FindText = '' then
  begin
    fFindDialog.Options := fFindDialog.Options + [frDown];
    FindExecute;
  end
  else
    DoFind(fFindDialog, sdForwards);
end;

procedure TFindReplace.FindPrev;
begin
  if fFindDialog.FindText = '' then
  begin
    fFindDialog.Options := fFindDialog.Options - [frDown];
    FindExecute;
  end
  else
    DoFind(fFindDialog, sdBackwards);
end;

procedure TFindReplace.GoToLine( LineNumber: integer );
var
  currentLine: integer;
  i: integer;

begin
  {set the current line to 1}
  currentLine := 1;

  {go through the whole text looking for the line}
  for i := 1 to fEditor.GetTextLen do
  begin
    if currentLine = LineNumber then
    begin
      {goto the position corresponding to the line}
      fEditor.selStart := i;
      fEditor.SetFocus;
      {quit the function}
      Exit;
    end
    else if fEditor.Text = #$D then
      inc( currentLine );
  end;

end;

procedure TFindReplace.CloseDialogs;
begin
  fFindDialog.CloseDialog;
  fReplaceDialog.CloseDialog;
end;

(*
procedure Register;
begin
  RegisterComponents('Tek-tips', [TFindReplace]);
end;
*)

end.
