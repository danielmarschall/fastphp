unit FastPHPTreeView;

interface

uses
  SysUtils, Classes, ComCtrls;

(*

<FastPHPData>    ::= <FastPHPData100> .

Version 1.00:
<FastPHPData100> ::= "FAST100!" (<Nodes> <Exit> | <Exit>) .
<Nodes>          ::= <Node> | <Nodes> <Node> .
<Node>           ::= <LeafNode> | <LeafNode> <IncreaseLevel> <Nodes> <DecreaseLevel> .
<LeafNode>       ::= "N" <Icon(8)> <LineNo(8)> <DescLen(4)> <Desc> .
<IncreaseLevel>  ::= "I" .
<DecreaseLevel>  ::= "D" .
<Exit>           ::= "X" .

*)

type
  TTreeViewFastPHP = class helper for TTreeView
  private
    //FPrevFastPHPData: string;
    class function Read(var ptr: PChar; len: integer): string; inline;
    procedure Rec100(tn: TTreeNode; var ptr: PChar);
  protected
    procedure DoFillWithFastPHPData(ptr: PChar);
  public
    procedure FillWithFastPHPData(data: string);
  end;

  EFastNodeException = class(Exception);

implementation

uses
  StrUtils;

const
  LEN_MAGIC   = 8;
  LEN_ICON    = 8;
  LEN_LINENO  = 8;
  LEN_DESCLEN = 4;

procedure TTreeViewFastPHP.DoFillWithFastPHPData(ptr: PChar);
var
  s: String;
  tn, tmp: TTreeNode;
  expanded: TStringList;
  selected, magic: string;
  i: integer;
begin
  selected := '';
  expanded := TStringList.Create;
  Self.Items.BeginUpdate;
  try
    {$REGION 'Remember our current state (selected and expanded flags)'}
    for i := 0 to Self.Items.Count-1 do
    begin
      tn := Self.Items.Item[i];
      s := tn.Text;
      tmp := tn.Parent;
      while tmp <> nil do
      begin
        s := tmp.Text + #0 + s;
        tmp := tmp.Parent;
      end;
      if tn.Selected then selected := s;
      if tn.Expanded and tn.HasChildren then expanded.Add(s);
    end;
    {$ENDREGION}

    {$REGION 'Update the treeview'}
    Self.Items.Clear;
    magic := Read(ptr, LEN_MAGIC);
    if magic = 'FAST100!' then
      Rec100(nil, ptr)
    else
      raise EFastNodeException.CreateFmt('FastNode version "%s" not supported.', [magic]);
    {$ENDREGION}

    {$REGION 'Recover the previous current state (selected and expanded flags)'}
    for i := 0 to Self.Items.Count-1 do
    begin
      tn := Self.Items.Item[i];
      s := tn.Text;
      tmp := tn.Parent;
      while tmp <> nil do
      begin
        s := tmp.Text + #0 + s;
        tmp := tmp.Parent;
      end;
      if selected = s then tn.Selected := true;
      if expanded.IndexOf(s) >= 0 then tn.Expand(false);
    end;
    {$ENDREGION}
  finally
    expanded.Free;
    Self.Items.EndUpdate;
  end;
end;

procedure TTreeViewFastPHP.FillWithFastPHPData(data: string);
begin
  //if FPrevFastPHPData = data then exit;
  //FPrevFastPHPData := data;

  data := Trim(data);
  if not EndsStr('X', data) then raise EFastNodeException.Create('FastNode string must end with "X"');

  DoFillWithFastPHPData(PChar(data));
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
        caption := Read(ptr, StrToInt(len));
        if tn = nil then
          lastTn := Self.Items.Add(nil, caption)
        else
          lastTn := Self.Items.AddChild(tn, caption);
        lastTn.Data := Pointer(StrToInt(lineno)); // TODO: is this good?
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
      exit
    else
      raise;
  end;
end;

end.
