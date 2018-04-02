unit FastPHPConfig;

interface

type
  TFastPHPConfig = class(TObject)
  private
    class function GetFontSize: integer; static;
    class procedure SetFontSize(Value: integer); static;
    class function GetScrapFile: string; static;
    class procedure SetScrapFile(Value: string); static;
    class function GetHelpIndex: string; static;
    class procedure SetHelpIndex(const Value: string); static;
    class function GetPhpInterpreter: string; static;
    class procedure SetPhpInterpreter(const Value: string); static;
  public
    class property FontSize: integer read GetFontSize write SetFontSize;
    class property ScrapFile: string read GetScrapFile write SetScrapFile;
    class property HelpIndex: string read GetHelpIndex write SetHelpIndex;
    class property PhpInterpreter: string read GetPhpInterpreter write SetPhpInterpreter;
  end;

implementation

uses
  Windows, Registry;

class function TFastPHPConfig.GetHelpIndex: string;
var
  reg: TRegistry;
begin
  result := '';
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\ViaThinkSoft\FastPHP\Editor', false) then
    begin
      if reg.ValueExists('HelpIndex') then
        result := reg.ReadString('HelpIndex');
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

class function TFastPHPConfig.GetPhpInterpreter: string;
var
  reg: TRegistry;
begin
  result := '';
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\ViaThinkSoft\FastPHP\Common', false) then
    begin
      if reg.ValueExists('PhpInterpreter') then
        result := reg.ReadString('PhpInterpreter');
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

class function TFastPHPConfig.GetScrapFile: string;
var
  reg: TRegistry;
begin
  result := '';
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\ViaThinkSoft\FastPHP\Editor', false) then
    begin
      if reg.ValueExists('ScrapFile') then
        result := reg.ReadString('ScrapFile');
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

class function TFastPHPConfig.GetFontSize: integer;
var
  reg: TRegistry;
begin
  result := -1;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\ViaThinkSoft\FastPHP\Editor', false) then
    begin
      if reg.ValueExists('FontSize') then
        result := reg.ReadInteger('FontSize');
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

class procedure TFastPHPConfig.SetFontSize(Value: integer);
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\ViaThinkSoft\FastPHP\Editor', true) then
    begin
      reg.WriteInteger('FontSize', Value);
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;
class procedure TFastPHPConfig.SetHelpIndex(const Value: string);
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\ViaThinkSoft\FastPHP\Editor', true) then
    begin
      reg.WriteString('HelpIndex', Value);
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

class procedure TFastPHPConfig.SetPhpInterpreter(const Value: string);
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\ViaThinkSoft\FastPHP\Common', true) then
    begin
      reg.WriteString('PhpInterpreter', Value);
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

class procedure TFastPHPConfig.SetScrapFile(Value: string);
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\ViaThinkSoft\FastPHP\Editor', true) then
    begin
      reg.WriteString('ScrapFile', Value);
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

end.

