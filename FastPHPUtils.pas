unit FastPHPUtils;

interface

uses
  Windows, SysUtils, StrUtils, Dialogs, IniFiles, Classes, Forms, ShellAPI, Functions,
  System.UITypes;

const
  FASTPHP_GOTO_URI_PREFIX = 'fastphp://editor/gotoline/';

function GetPHPExe(AForceSelectNewInterpreter: boolean=false): string;
function RunPHPScript(APHPFileName: string; lint: boolean=false; inConsole: boolean=False; ContentCallBack: TContentCallBack=nil): string;
function ParseCHM(const chmFile: TFileName): boolean;
function IsValidPHPExe(const exeFile: TFileName): boolean;

implementation

uses
  FastPHPConfig;

function GetPHPExe(AForceSelectNewInterpreter: boolean=false): string;
var
  od: TOpenDialog;
  tmpInitDir: string;
begin
  result := TFastPHPConfig.PhpInterpreter;
  if not FileExists(result) or AForceSelectNewInterpreter then
  begin
    od := TOpenDialog.Create(nil);
    try
      od.DefaultExt := 'exe';
      od.FileName := 'php.exe';
      od.Filter := 'Executable file (*.exe)|*.exe';
      od.Options := [ofReadOnly, ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
      od.Title := 'Please choose your PHP interpreter (php.exe)';

      tmpInitDir := result;
      if tmpInitDir <> '' then tmpInitDir := ExtractFilePath(tmpInitDir);
      if (tmpInitDir <> '') and DirectoryExists(tmpInitDir) then
        od.InitialDir := tmpInitDir;

      if not od.Execute then exit;
      if not FileExists(od.FileName) then exit;
      result := od.FileName;
    finally
      od.Free;
    end;

    if not IsValidPHPExe(result) then
    begin
      MessageDlg('This is not a valid PHP executable.', mtError, [mbOk], 0);
      exit;
    end;

    TFastPHPConfig.PhpInterpreter := result;
  end;
end;

function RunPHPScript(APHPFileName: string; lint: boolean=false; inConsole: boolean=False; ContentCallBack: TContentCallBack=nil): string;
var
  phpExe, args, batFile, workdir: string;
  slBat: TStringList;
begin
  phpExe := GetPHPExe;
  if phpExe = '' then Abort;

  if lint then
    args := '-l "'+APHPFileName+'"'
  else
    args := '-f "'+APHPFileName+'"';

  //workdir := ExtractFileDir(ParamStr(0));
  workdir := ExtractFileDir(APHPFileName);

  if inConsole then
  begin
    (*
    ShellExecute(0, 'open', PChar(phpExe), PChar(args), PChar(workdir), SW_NORMAL);
    *)
    batFile := IncludeTrailingPathDelimiter(GetTempDir) + 'RunFastPHP.bat';
    slBat := TStringList.Create;
    try
      slBat.Add('@echo off');
      slBat.Add('cd /d "'+workdir+'"');
      slBat.Add('"'+phpExe+'" ' + args);
      slBat.Add('pause.');
      slBat.SaveToFile(batFile);
      ShellExecute(0, 'open', PChar(batFile), '', '', SW_NORMAL);
    finally
      slBat.Free;
    end;

    result := '';
  end
  else
  begin
    result := GetDosOutput('"'+phpExe+'" ' + args, workdir, ContentCallBack);
  end;
end;

function ParseCHM(const chmFile: TFileName): boolean;
var
  test, candidate, candidate2: string;
  p, p2, q: integer;
  i: integer;
  good: Boolean;
  ini: TMemIniFile;
  domain: string;
  sl: TStringList;
  symbolCount: Integer;
  sl2: TStrings;
  outFile: string;
begin
  // TODO: problem:  mysqli::commit has /res/mysqli.commit.html -> keyword is NOT commit alone

  outFile := ChangeFileExt(chmFile, '.ini');
  DeleteFile(outFile);
  test := LoadFileToStr(chmFile); // TODO: RawByteString instead of AnsiString?
  if Pos('/php_manual_', test) = -1 then
  begin
    result := false;
    exit;
  end;
  p := 0;
  ini := TMemIniFile.Create(outFile);
  try
    ini.WriteString('_Info_', 'Source', chmFile);
    ini.WriteString('_Info_', 'Generated', DateTimeToStr(Now));
    ini.WriteString('_Info_', 'GeneratorVer', '1.0');
    ini.WriteString('_Info_', 'Signature', '$ViaThinkSoft$');
    {$REGION 'Excludes'}
    // TODO: more excludes
    ini.WriteBool('_HelpExclude_', 'about', true);
    ini.WriteBool('_HelpExclude_', 'apache', true);
    {$ENDREGION}
    while true do
    begin
      if Assigned(Application) then Application.ProcessMessages;

      p := PosEx('/res/', Test, p+1);
      if p = 0 then break;
      p2 := PosEx('.html', Test, p);
      if p = 0 then break;
      candidate := copy(Test, p+5, p2-p-5);
      if candidate = '' then continue;
      if Length(candidate) > 50 then continue;
      good := true;
      for i := p+5 to p2-1 do
      begin
        if ord(test[i]) < 32 then
        begin
          good := false;
          break;
        end;
        {$IFDEF UNICODE}
        if not CharInSet(test[i], ['a'..'z', 'A'..'Z', '.', '-', '_', '0'..'9']) then
        {$ELSE}
        if not (test[i] in ['a'..'z', 'A'..'Z', '.', '-', '_', '0'..'9']) then
        {$ENDIF}
        begin
          ini.WriteInteger('_Errors_', 'Contains unexpected character! ' + candidate, ini.ReadInteger('_Errors_', 'Contains unexpected character! ' + candidate, 0)+1);
          good := false;
          break;
        end;
      end;
      if good then
      begin
        candidate2 := LowerCase(StringReplace(candidate, '-', '_', [rfReplaceAll]));
        q := LastPos('.', candidate2);
        domain := copy(candidate2, 1, q-1);
        if domain = '' then continue;
        candidate2 := copy(candidate2, q+1, Length(candidate2)-q);
        ini.WriteInteger('_Category_', domain, ini.ReadInteger('_Category_', domain, 0)+1);
        ini.WriteString(domain, candidate2, '/res/'+candidate+'.html');
        if not ini.ReadBool('_HelpExclude_', domain, false)
           and (candidate2 <> 'configuration')
           and (candidate2 <> 'constants')
           and (candidate2 <> 'installation')
           and (candidate2 <> 'requirements')
           and (candidate2 <> 'resources')
           and (candidate2 <> 'setup') then
        begin
          if ini.ReadString('_HelpWords_', candidate2, '') <> '' then
          begin
            ini.WriteInteger('_Conflicts_', candidate2, ini.ReadInteger('_Conflicts_', candidate2, 0)+1);
          end;

          ini.WriteString('_HelpWords_', candidate2, '/res/'+candidate+'.html');
        end;
      end;
    end;

    sl := TStringList.Create;
    sl2 := TStringList.Create;
    try
      ini.ReadSections(sl);
      ini.WriteInteger('_Info_', 'TotalDomains', sl.Count);
      symbolCount := 0;
      for domain in sl do
      begin
        ini.ReadSection(domain, sl2);
        Inc(symbolCount, sl2.Count)
      end;
      ini.WriteInteger('_Info_', 'TotalSymbols', symbolCount);
    finally
      sl.Free;
      sl2.Free;
    end;

    ini.UpdateFile;
    result := true;
  finally
    ini.Free;
  end;
end;

function IsValidPHPExe(const exeFile: TFileName): boolean;
var
  cont: string;
begin
  cont := LoadFileToStr(exeFile); // TODO: RawByteString instead of AnsiString?
  result := (Pos('php://stdout', cont) >= 0) or
            (Pos('PHP_SELF', cont) >= 0);
end;

end.
