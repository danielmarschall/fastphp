unit FindReplace;

// Source: http://www.tek-tips.com/viewthread.cfm?qid=160357
// Some changed by Daniel Marschall, especially to make it compatible with TSynEdit

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

  TFindReplace = class(TComponent)
  private
    fEditor: TSynEdit;  {the richedit or memo component to hook it up to}
    fReplaceDialog: TReplaceDialog;  {the replace dialog}
    fFindDialog: TFindDialog;  {the find dialog}

    FindTextLength: integer;  {the length of the text we want to find}
    TextToFind: string;  {the text to find}

    FindActionOnEnd: FindReplaceCommunication;  {the action the find function
     should take when it reaches the end of the text while searching for the
     word}

    function TestWholeWord( Sender: TFindDialog; TestString: string ): boolean;
    {returns a true or false depending on whether the user chose the whole word
     only option and whether or not the word is a whole word.  Actually, it can
     test multiple words in a single string as well.}

  protected
    StringComparison: function ( const S1, S2: string ): Integer;
    {the function to use to compare 2 strings.  Should be assigned
     different values according to the search criteria}
    procedure ProcessCriteria( Sender: TFindDialog );
    {set some internals given the search criteria such as match case}
    procedure FindForwards( Sender: TFindDialog; start, finish: integer );
    {search through the editor in a forwards direction}
    procedure FindBackwards( start, finish: integer );
    {search through the editor in a backwards direction}

    {defined event handlers}
    procedure OnFind( Sender: TObject ); virtual;
    procedure OnReplace( Sender: TObject ); virtual;

    {the centralised find/replace functions}
    function TryAndMatch( Sender: TFindDialog; index, finish: integer ): boolean; virtual;
    function TryAndReplace: boolean; virtual;

    procedure DoReplace; virtual;
    {the replace function that coordinates all the work}
    procedure DoReplaceAll; virtual;
    {the replace all function that coordinates all the work}

  public
    constructor Create( AOwner: TComponent); override;

    property _FindDialog: TFindDialog read fFindDialog;
    property _ReplaceDialog: TReplaceDialog read fReplaceDialog;

    procedure FindExecute;
    {opens the find dialog}
    procedure ReplaceExecute;
    {opens the replace dialog}
    procedure FindNext; overload;
    {finds the next occurence of the character}
    procedure FindNext( errorMessage: string ); overload;
    {same as above except allows you to specify the message to display
     if the user hasn't picked a search word}

    procedure GoToLine( LineNumber: integer );
    procedure GetLineNumber( Position: Integer; var LineNumber, ColumnNumber: Integer );
    {returns the line and column number the cursor is on in the editor}

  published
    property Editor: TSynEdit
      read fEditor write fEditor;
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

  {set find's default action on end of text to alert the user.
   If a replace function changes this it is it's responsibility
   to change it back}
  FindActionOnEnd := frcAlertUser;
end;

procedure TFindReplace.ProcessCriteria( Sender: TFindDialog );
begin

  {assign a case sensitive or case insensitive string
   comparison function to StringComparison depending
   on the whether or not the user chose to match case.
   The functions assigned are normal VCL functions.}
  if frMatchCase in Sender.Options then
    StringComparison := CompareStr
  else StringComparison := CompareText;

end;

procedure TFindReplace.FindForwards( Sender: TFindDialog; start, finish: integer );
var
  i: integer;

begin

  {because we'll be using the length of the text to search for
   often, we should calculate it here to save time}
  FindTextLength := Length( TextToFind );

  {to find the word we go through the text on a character by character
   basis}
  for i := start to finish do
    if TryAndMatch( Sender, i, finish ) then
    {if we've got a match then stop}
      Exit;

end;

procedure TFindReplace.FindBackwards( start, finish: Integer );
{since only find has a (search) up option and replace doesn't
 we don't have to worry about sender since only the onFind will
 be calling thi function}

var
  i: integer;

begin
  {See comments for findforward}

  FindTextLength := Length( TextToFind );

  {to find the word we go through the text on a character by character
   basis but working backwards}
  for i := finish downto start do
    if TryAndMatch( fFindDialog, i, start ) then
      Exit;

end;

function TFindReplace.TryAndMatch( Sender: TFindDialog; index, finish: integer ): boolean;
{returns true if there was a match and false otherwise}
var
  StringToTest: string;

begin
  {create a new string to test against}
  StringToTest := copy( fEditor.Text, index+1, FindTextLength );

  if (StringComparison( StringToTest, TextToFind ) = 0) and
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
    ShowMessage( TextToFind + ' could not be found' )
  {otherwise if the replace function requested us to keep quiet
   about it then don't display the message to the user}
  else if (index = finish) and (FindActionOnEnd = frcAlertReplace) then
    FindActionOnEnd := frcEndReached;

  Result := false;  {didn't find it}
end;

procedure TFindReplace.OnFind( Sender: TObject );
var
//  highlightedText: pChar;
  highlightedText: string;

begin
  {handle all the user options}
  ProcessCriteria( Sender as TFindDialog );

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
    if StrIComp( PChar(highlightedText), pChar( fFindDialog.FindText ) ) = 0 then
    begin
      if frDown in (Sender as TFindDialog).Options then
        fEditor.selStart := fEditor.SelStart + fEditor.SelLength
      else fEditor.selStart := fEditor.SelStart - 1;
    end;

    (*
    FreeMem( highlightedText, fEditor.SelLength + 1 );
    *)
  end;

  {set the text to find to the findtext field of the find dialog}
  TextToFind := (Sender as TFindDialog).FindText;

  {begin the search}
  if frDown in (Sender as TFindDialog).Options then  {the user choose to search down}
  begin
    {if the user has highlighted a block of text only search
     within that block}
    if fEditor.SelLength > 0 then
      FindForwards( (Sender as TFindDialog), fEditor.selStart, fEditor.selStart + fEditor.selLength )
    {otherwise search the whole of the text}
    else FindForwards( (Sender as TFindDialog), fEditor.selStart, fEditor.GetTextLen );
  end
  else  {the user chose to search up}
  begin
    {if the user has highlighted a block of text only search
     within that block}
    if fEditor.SelLength > 0 then
      FindBackwards( fEditor.selStart, fEditor.selStart + fEditor.selLength )
    {otherwise search the whole of the text}
    else FindBackwards( 0, fEditor.selStart );
  end;

end;

procedure TFindReplace.OnReplace( Sender: TOBject );
begin
  ProcessCriteria( fReplaceDialog );

  {set the action on end to alert the function not the user}
  FindActionOnEnd := frcAlertReplace;

  {set the text to find to the findtext field of the replace dialog}
  TextToFind := fReplaceDialog.FindText;

  {now replace the word}
  if frReplace in fReplaceDialog.Options then
    DoReplace
  else DoReplaceAll;

  {reset the action on end to alert the user}
  FindActionOnEnd := frcAlertUser;
end;

procedure TFindReplace.DoReplace;
begin

  {if the user has highlighted a block of text only replace
   within that block}
  if fEditor.SelLength > 0 then
  begin
    FindForwards( fReplaceDialog, fEditor.selStart, fEditor.selStart + fEditor.selLength );
    TryAndReplace;
  end
  {otherwise replace within the whole of the text}
  else
  begin
    FindForwards( fReplaceDialog, fEditor.selStart, fEditor.GetTextLen );
    TryAndReplace;
  end;

end;

procedure TFindReplace.DoReplaceAll;
begin
  {see comments for DoReplace}

  if fEditor.SelLength > 0 then
  begin
    FindForwards( fReplaceDialog, fEditor.selStart, fEditor.selStart + fEditor.selLength );
    {keep replacing until we reach the end of the text}
    while FindActionOnEnd <> frcEndReached do
    begin
      {we enclose the TryAndReplace in a loop because there might be more
       than one occurence of the word in the line}
      while TryAndReplace do
        FindForwards( fReplaceDialog, fEditor.selStart, fEditor.selStart + fEditor.selLength );

      FindForwards( fReplaceDialog, fEditor.selStart, fEditor.selStart + fEditor.selLength );
    end;
  end
  else
  begin
    FindForwards( fReplaceDialog, fEditor.selStart, fEditor.GetTextLen );
    while FindActionOnEnd <> frcEndReached do
    begin
      while TryAndReplace do
        FindForwards( fReplaceDialog, fEditor.selStart, fEditor.GetTextLen );

      FindForwards( fReplaceDialog, fEditor.selStart, fEditor.GetTextLen );
    end;
  end;

end;

function TFindReplace.TryAndReplace: boolean;
{returns true if a replacement was made and false otherwise.  This is
 so a function can keep calling TryAndReplace until it returns false
 since there might be more than one occurence of the word to replace
 in the line}

var
  LineNumber, ColumnNumber: integer;
  ReplacementString: string;  {string used to replace the text}

  OldSelStart: integer;  {the position of the cursore prior to the text
   being replaced}


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
    GetLineNumber( fEditor.SelStart, LineNumber, ColumnNumber );
    {get the position of the cursor prior to the replace operation
     so we cab restore it later}
    OldSelStart := fEditor.SelStart;

    {delete the unwanted word}
    fEditor.ClearSelection;

    {Add the replacement text}
    {Since we can't directly manipulate the Lines field of the
     TCustomMemo component we'll extract the line, manipulate it
     then put it back}
    ReplacementString := fEditor.Lines[ LineNumber ];
    {truncate the newline (#$A#$D) at the end of tempstring}
    SetLength( ReplacementString, Length( ReplacementString )-2 );
    {add the replacement text into tempstring}
    Insert( fReplaceDialog.ReplaceText, ReplacementString, ColumnNumber+1 );
    {remove the old string and add the new string into the editor}
    fEditor.Lines.Delete( LineNumber );
    fEditor.Lines.Insert( LineNumber, ReplacementString );

    {set the result to true since we have made a replacement}
    Result := true;

    {reposition the cursor to the character after the last chracter in
     the newly replacing text.  This is mainly so we can locate multiple
     occurences of the to-be-replaced text in the same line}
    fEditor.SelStart := oldSelStart + length( fReplaceDialog.ReplaceText );
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
begin
  {assume it's not a whole word}
  Result := false;

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

procedure TFindReplace.FindNext;
begin
  FindNext( 'Please chose a search word' );
end;

procedure TFindReplace.FindNext( errorMessage: string );
begin

  if fFindDialog.FindText = '' then
  begin
    ShowMessage( errorMessage );
    Exit;
  end;

  {I'm not sure if I should pass fFindDialog as sender}
  OnFind( fFindDialog );
end;

procedure TFindReplace.GetLineNumber( Position: Integer; var LineNumber, ColumnNumber: integer );
var
  i: integer;

begin
  {initialise line number to 0}
  LineNumber := 0;

  {increment line number each time we encounter a newline (#$D) in the text}
  for i := 1 to Position do
    if fEditor.Text = #$D then
      inc( LineNumber );

  {set the column number to position first}
  ColumnNumber := Position;
  {get the columnNumber by subtracting the length of each previous line}
  for i := 0 to (LineNumber-1) do
    dec( ColumnNumber, (*Length( fEditor.Lines )*) fEditor.Lines.Strings[i].Length );

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

(*
procedure Register;
begin
  RegisterComponents('Tek-tips', [TFindReplace]);
end;
*)

end.
