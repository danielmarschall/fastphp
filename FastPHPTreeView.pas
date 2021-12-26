unit FastPHPTreeView;

interface

uses
  SysUtils, Classes, ComCtrls;

(*

<FastPHPData>    ::= <FastPHPData100> .

Version 1.00 (signature "FAST100!"):

<FastPHPData100> ::= <Signature100> ( <Nodes> <Exit> | <Exit> ) .
<Signature100>   ::= "F" "A" "S" "T" "1" "0" "0" "!" .
<Nodes>          ::= <Node> | ( <Nodes> <Node> ) .
<Node>           ::= <LeafNode> | ( <LeafNode> <IncreaseLevel> <Nodes> <DecreaseLevel> ) .

<LeafNode>       ::= "N" <Icon> <LineNo> <DescLen> <Desc> .
<IncreaseLevel>  ::= "I" .
<DecreaseLevel>  ::= "D" .
<Exit>           ::= "X" .

<LineNo>         ::= <Int8> .
<DescLen>        ::= <Int4> .
<Desc>           ::= (Utf8-String) .
<Icon>           ::= <NoIcon> | <ImageIndex> .

<NoIcon>         ::= "_" "_" "_" "_" .
<ImageIndex>     ::= <Int4> .

<Int1>           ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" .
<Int2>           ::= <Int1> <Int1> .
<Int4>           ::= <Int2> <Int2> .
<Int8>           ::= <Int4> <Int4> .

*)

type
  TTreeViewFastPHP = class helper for TTreeView
  private
    class function Read(var ptr: PChar; len: integer): string; inline;
    procedure Rec100(tn: TTreeNode; var ptr: PChar);
  protected
    function DoFillWithFastPHPData(ptr: PChar): boolean;
  public
    function FillWithFastPHPData(data: string): boolean;
  end;

  EFastNodeException = class(Exception);

implementation

uses
  StrUtils, Windows;

const
  MAGIC_V100  = 'FAST100!';
  UTF8_BOM    = #$EF#$BB#$BF;
  LEN_ICON    = 4;
  LEN_LINENO  = 8;
  LEN_DESCLEN = 4;

{$EXTERNALSYM LockWindowUpdate}
function LockWindowUpdate(hWndLock: HWND): BOOL; stdcall; external user32 name 'LockWindowUpdate';

function HexToInt(HexNum: string): LongInt;
begin
  Result := StrToInt('$' + HexNum);
end;

function TTreeViewFastPHP.DoFillWithFastPHPData(ptr: PChar): boolean;

  function _NodeID(tn: TTreeNode): string;
  var
    tmp: TTreeNode;
  begin
    // Attention: This function requires that the tree node items are unique
    //            e.g. Class1->function1() is unique
    result := tn.Text;
    tmp := tn.Parent;
    while tmp <> nil do
    begin
      result := tmp.Text + #0 + result;
      tmp := tmp.Parent;
    end;
  end;

var
  s: String;
  tn: TTreeNode;
  expanded: TStringList;
  selected, magic: string;
  horPos, verPos: integer;
  i: integer;
begin
  // No update if the user is dragging the scrollbar
  // (otherwise the program will somehow lock up)
  result := GetCapture <> Handle;
  if not result then exit;

  selected := '';
  expanded := TStringList.Create;
  horPos := GetScrollPos(Handle, SB_HORZ);
  verPos := GetScrollPos(Handle, SB_VERT);
  LockWindowUpdate(Handle); // Parent is better choice for FastPHP... but for other applications it might be wrong?
  Self.Items.BeginUpdate;
  try
    {$REGION 'Remember our current state (selected and expanded flags)'}
    for i := 0 to Self.Items.Count-1 do
    begin
      tn := Self.Items.Item[i];
      s := _NodeID(tn);
      if tn.Selected then selected := s;
      if tn.Expanded and tn.HasChildren then expanded.Add(s);
    end;
    {$ENDREGION}

    {$REGION 'Update the treeview'}
    Self.Items.Clear;

    {$REGION 'Remove UTF8-BOMs'}
    repeat
      magic := Read(ptr, Length(UTF8_BOM));
    until magic <> UTF8_BOM;
    ptr := ptr - Length(UTF8_BOM);
    {$ENDREGION}

    magic := Read(ptr, length(MAGIC_V100));

    if magic = MAGIC_V100 then
    begin
      Rec100(nil, ptr)
    end
    else
    begin
      // Can happen if codeexplorer.php did output a warning
      raise EFastNodeException.CreateFmt('FastNode version "%s" not supported. More content: %s', [magic, Read(ptr,1000)]);
    end;
    {$ENDREGION}

    {$REGION 'Recover the previous current state (selected and expanded flags)'}
    for i := 0 to Self.Items.Count-1 do
    begin
      tn := Self.Items.Item[i];
      s := _NodeID(tn);
      if selected = s then tn.Selected := true;
      if expanded.IndexOf(s) >= 0 then tn.Expand(false);
    end;
    {$ENDREGION}
  finally
    Self.Items.EndUpdate;
    LockWindowUpdate(0);

    SetScrollPos(Handle, SB_HORZ, horPos, false);
    SetScrollPos(Handle, SB_VERT, verPos, false);

    expanded.Free;
  end;
end;

function TTreeViewFastPHP.FillWithFastPHPData(data: string): boolean;
var
  tn: TTreeNode;
begin
  result := false;
  try
    data := Trim(data);
    if not EndsStr('X', data) then raise EFastNodeException.Create('FastNode string must end with "X"');

    result := DoFillWithFastPHPData(PChar(data));
  except
    on E: Exception do
    begin
      Self.Items.Clear;
      tn := Self.Items.Add(nil, 'ERROR: ' + E.Message);
      tn.ImageIndex := -1;
      tn.SelectedIndex := -1;
    end;
  end;
end;

class function TTreeViewFastPHP.Read(var ptr: PChar; len: integer): string;
begin
  result := Copy(string(ptr), 1, len);
  inc(ptr, len);
end;

procedure TTreeViewFastPHP.Rec100(tn: TTreeNode; var ptr: PChar);
var
  typ, icon, lineno, len, caption: string;
  lastTn: TTreeNode;
begin
  try
    lastTn := nil;
    while true do
    begin
      repeat
        typ := Read(ptr, 1);
      until Trim(typ) <> '';
      if typ = 'N' then // new node
      begin
        icon   := Read(ptr, LEN_ICON);
        lineno := Read(ptr, LEN_LINENO);
        len    := Read(ptr, LEN_DESCLEN);
        caption := Utf8Decode(Read(ptr, StrToInt(len)));
        if tn = nil then
          lastTn := Self.Items.Add(nil, caption)
        else
          lastTn := Self.Items.AddChild(tn, caption);

        {$REGION 'Determinate icon'}
        if icon = '____' then
          lastTn.ImageIndex := -1
        else
          lastTn.ImageIndex := StrToInt(icon);
        lastTn.SelectedIndex := lastTn.ImageIndex;
        {$ENDREGION}

        lastTn.Data := Pointer(StrToInt(lineno)); // Hack...
      end
      else if typ = 'I' then // increase level
      begin
        if LastTn = nil then raise EFastNodeException.Create('Fast100: Increase command requires previous node');
        Rec100(lastTn, ptr);
      end
      else if typ = 'D' then Exit // decrease level
      else if typ = 'X' then Abort // exit
      else raise EFastNodeException.CreateFmt('Fast100: Command "%s" unknown', [typ]);
    end;
  except
    on E: EAbort do
      if tn = nil then
        exit
      else
        raise;
    else
      raise;
  end;
end;

end.
