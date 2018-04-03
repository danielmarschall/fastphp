; FastPHP Setup Script for InnoSetup
; by Daniel Marschall, ViaThinkSoft
; http://www.viathinksoft.de/

[Setup]
AppName=FastPHP
AppVerName=FastPHP 0.1
AppVersion=0.1
AppCopyright=© Copyright 2017 - 2018 ViaThinkSoft.
AppPublisher=ViaThinkSoft
AppPublisherURL=http://www.viathinksoft.de/
AppSupportURL=http://www.daniel-marschall.de/
AppUpdatesURL=http://www.viathinksoft.de/
DefaultDirName={pf}\FastPHP
DefaultGroupName=FastPHP
VersionInfoCompany=ViaThinkSoft
VersionInfoCopyright=© Copyright 2017 - 2018 ViaThinkSoft.
VersionInfoDescription=FastPHP Setup
VersionInfoTextVersion=1.0.0.0
VersionInfoVersion=0.1
Compression=zip/9
ChangesAssociations=yes
OutputBaseFilename=FastPHP

[CustomMessages]
Assoc=File associations:

[Languages]
;Name: de; MessagesFile: "compiler:Languages\German.isl"

[LangOptions]
LanguageName=English
LanguageID=$0409

[Components]
Name: "editor";  Description: "FastPHP Editor";  Types: full compact custom
Name: "browser"; Description: "FastPHP Browser"; Types: full

[Tasks]
; xphp = executable PHP (only for PHP browser)
Name: fileassocEditor;  Description: "{cm:AssocFileExtension,'FastPHP Editor','.php(s)'}"; GroupDescription: "{cm:Assoc}"; Components: editor
Name: fileassocBrowser; Description: "{cm:AssocFileExtension,'FastPHP Browser','.xphp'}";  GroupDescription: "{cm:Assoc}"; Components: browser

[Files]
Source: "Icons\Icons.dll";          DestDir: "{app}"; Flags: ignoreversion

Source: "FastPHPEditor.exe";        DestDir: "{app}"; Flags: ignoreversion; Components: editor
Source: "codeexplorer.bmp";         DestDir: "{app}"; Flags: ignoreversion; Components: editor
Source: "codeexplorer.php";         DestDir: "{app}"; Flags: ignoreversion; Components: editor
Source: "codeexplorer_api.inc.php"; DestDir: "{app}"; Flags: ignoreversion; Components: editor

Source: "FastPHPBrowser.exe";       DestDir: "{app}"; Flags: ignoreversion; Components: browser
Source: "fastphp_server.inc.php";   DestDir: "{app}"; Flags: ignoreversion; Components: browser

[Dirs]

[Icons]
Name: "{group}\FastPHP Editor";  Filename: "{app}\FastPHPEditor.exe";  Components: editor
Name: "{group}\FastPHP Browser"; Filename: "{app}\FastPHPBrowser.exe"; Components: browser

[Run]
Filename: "{app}\FastPHPEditor.exe";  Description: "Run FastPHP Editor";  Flags: nowait postinstall skipifsilent; Components: editor
Filename: "{app}\FastPHPBrowser.exe"; Description: "Run FastPHP Browser"; Flags: nowait postinstall skipifsilent unchecked; Components: browser

[Registry]
Root: HKCR; Subkey: ".php";                                       ValueData: "FastPHPScript";                       ValueType: string; ValueName: ""; Flags: uninsdeletevalue; Components: editor;  Tasks: fileassocEditor
Root: HKCR; Subkey: ".phps";                                      ValueData: "FastPHPScript";                       ValueType: string; ValueName: ""; Flags: uninsdeletevalue; Components: editor;  Tasks: fileassocEditor
Root: HKCR; Subkey: "FastPHPScript";                              ValueData: "PHP script";                          ValueType: string; ValueName: ""; Flags: uninsdeletekey;   Components: editor;  Tasks: fileassocEditor
Root: HKCR; Subkey: "FastPHPScript\DefaultIcon";                  ValueData: "{app}\Icons.dll,0";                   ValueType: string; ValueName: "";                          Components: editor;  Tasks: fileassocEditor
Root: HKCR; Subkey: "FastPHPScript\shell\open\command";           ValueData: """{app}\FastPHPEditor.exe"" ""%1""";  ValueType: string; ValueName: "";                          Components: editor;  Tasks: fileassocEditor
           
Root: HKCR; Subkey: ".php\ShellNew";                              ValueData: "PHP script";                          ValueType: string; ValueName: "ItemName";                  Components: editor;  Tasks: fileassocEditor
Root: HKCR; Subkey: ".php\ShellNew";                              ValueData: "";                                    ValueType: string; ValueName: "NullFile";                  Components: editor;  Tasks: fileassocEditor

Root: HKCR; Subkey: ".xphp";                                      ValueData: "FastPHPExecutableScript";             ValueType: string; ValueName: ""; Flags: uninsdeletevalue; Components: browser; Tasks: fileassocBrowser
Root: HKCR; Subkey: "FastPHPExecutableScript";                    ValueData: "Executable PHP application";          ValueType: string; ValueName: ""; Flags: uninsdeletekey;   Components: browser; Tasks: fileassocBrowser
Root: HKCR; Subkey: "FastPHPExecutableScript\DefaultIcon";        ValueData: "{app}\Icons.exe,1";                   ValueType: string; ValueName: "";                          Components: browser; Tasks: fileassocBrowser
Root: HKCR; Subkey: "FastPHPExecutableScript\shell\open\command"; ValueData: """{app}\FastPHPBrowser.exe"" ""%1"""; ValueType: string; ValueName: "";                          Components: browser; Tasks: fileassocBrowser
Root: HKCR; Subkey: "FastPHPExecutableScript\shell\edit\command"; ValueData: """{app}\FastPHPEditor.exe"" ""%1""";  ValueType: string; ValueName: "";                          Components: browser; Tasks: fileassocBrowser

[Code]
function InitializeSetup(): Boolean;
begin
  if CheckForMutexes('FastPHPSetup')=false then
  begin
    Createmutex('FastPHPSetup');
    Result := true;
  end
  else
  begin
    Result := False;
  end;
end;
function IsAnyComponentSelected: Boolean;
var
  I: Integer;
begin
  // Source: https://stackoverflow.com/questions/20691583/innosetup-if-no-components-are-selected-go-back-to-components-page
  Result := False;
  for I := 0 to WizardForm.ComponentsList.Items.Count - 1 do
    if WizardForm.ComponentsList.Checked[I] then
    begin
      Result := True;
      Exit;
    end;
end;
function NextButtonClick(PageID: Integer): Boolean;
begin
  Result:= True;
  if PageID = wpSelectComponents then
  begin
    if not IsAnyComponentSelected then
    begin
      MsgBox('No items selected, please select at least one item', mbError, MB_OK);
      Result := False;
    end;
  end;
end;
