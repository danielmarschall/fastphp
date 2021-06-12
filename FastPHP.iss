; FastPHP Setup Script for InnoSetup
; by Daniel Marschall, ViaThinkSoft
; http://www.viathinksoft.com/

[Setup]
AppName=FastPHP
AppVerName=FastPHP 0.4
AppVersion=0.4
AppCopyright=© Copyright 2017 - 2021 ViaThinkSoft.
AppPublisher=ViaThinkSoft
AppPublisherURL=http://www.viathinksoft.de/
AppSupportURL=http://www.daniel-marschall.de/
AppUpdatesURL=http://www.viathinksoft.de/
DefaultDirName={commonpf}\FastPHP
DefaultGroupName=FastPHP
VersionInfoCompany=ViaThinkSoft
VersionInfoCopyright=© Copyright 2017 - 2021 ViaThinkSoft.
VersionInfoDescription=FastPHP Setup
VersionInfoTextVersion=1.0.0.0
VersionInfoVersion=0.4
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
Root: HKCR; Subkey: ".php";                                       ValueName: ""; ValueType: string; ValueData: "FastPHPScript";                       Flags: uninsdeletevalue; Components: editor;  Tasks: fileassocEditor
Root: HKCR; Subkey: ".phps";                                      ValueName: ""; ValueType: string; ValueData: "FastPHPScript";                       Flags: uninsdeletevalue; Components: editor;  Tasks: fileassocEditor
;Root: HKCR; Subkey: ".inc";                                      ValueName: ""; ValueType: string; ValueData: "FastPHPScript";                       Flags: uninsdeletevalue; Components: editor;  Tasks: fileassocEditor
;Root: HKCR; Subkey: ".phtml";                                    ValueName: ""; ValueType: string; ValueData: "FastPHPScript";                       Flags: uninsdeletevalue; Components: editor;  Tasks: fileassocEditor
;Root: HKCR; Subkey: ".php2";                                     ValueName: ""; ValueType: string; ValueData: "FastPHPScript";                       Flags: uninsdeletevalue; Components: editor;  Tasks: fileassocEditor
;Root: HKCR; Subkey: ".php3";                                     ValueName: ""; ValueType: string; ValueData: "FastPHPScript";                       Flags: uninsdeletevalue; Components: editor;  Tasks: fileassocEditor
;Root: HKCR; Subkey: ".php4";                                     ValueName: ""; ValueType: string; ValueData: "FastPHPScript";                       Flags: uninsdeletevalue; Components: editor;  Tasks: fileassocEditor
;Root: HKCR; Subkey: ".php5";                                     ValueName: ""; ValueType: string; ValueData: "FastPHPScript";                       Flags: uninsdeletevalue; Components: editor;  Tasks: fileassocEditor
Root: HKCR; Subkey: "FastPHPScript";                              ValueName: ""; ValueType: string; ValueData: "PHP script";                          Flags: uninsdeletekey;   Components: editor;  Tasks: fileassocEditor
Root: HKCR; Subkey: "FastPHPScript\DefaultIcon";                  ValueName: ""; ValueType: string; ValueData: "{app}\Icons.dll,0";                                            Components: editor;  Tasks: fileassocEditor
Root: HKCR; Subkey: "FastPHPScript\shell\open\command";           ValueName: ""; ValueType: string; ValueData: """{app}\FastPHPEditor.exe"" ""%1""";                           Components: editor;  Tasks: fileassocEditor
           
Root: HKCR; Subkey: ".php\ShellNew";                              ValueName: "ItemName"; ValueType: string; ValueData: "PHP script";                                           Components: editor;  Tasks: fileassocEditor
Root: HKCR; Subkey: ".php\ShellNew";                              ValueName: "NullFile"; ValueType: string; ValueData: "";                                                     Components: editor;  Tasks: fileassocEditor

; xphp = executable PHP (only for PHP browser)
Root: HKCR; Subkey: ".xphp";                                      ValueName: ""; ValueType: string; ValueData: "FastPHPExecutableScript";             Flags: uninsdeletevalue; Components: browser; Tasks: fileassocBrowser
Root: HKCR; Subkey: "FastPHPExecutableScript";                    ValueName: ""; ValueType: string; ValueData: "Executable PHP application";          Flags: uninsdeletekey;   Components: browser; Tasks: fileassocBrowser
Root: HKCR; Subkey: "FastPHPExecutableScript\DefaultIcon";        ValueName: ""; ValueType: string; ValueData: "{app}\Icons.dll,1";                                            Components: browser; Tasks: fileassocBrowser
Root: HKCR; Subkey: "FastPHPExecutableScript\shell\open\command"; ValueName: ""; ValueType: string; ValueData: """{app}\FastPHPBrowser.exe"" ""%1""";                          Components: browser; Tasks: fileassocBrowser
Root: HKCR; Subkey: "FastPHPExecutableScript\shell\edit\command"; ValueName: ""; ValueType: string; ValueData: """{app}\FastPHPEditor.exe"" ""%1""";                           Components: browser; Tasks: fileassocBrowser

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
