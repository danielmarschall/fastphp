object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'ViaThinkSoft FastPHP Browser'
  ClientHeight = 662
  ClientWidth = 1008
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 0
    Width = 1008
    Height = 662
    Align = alClient
    TabOrder = 0
    OnBeforeNavigate2 = WebBrowser1BeforeNavigate2
    OnWindowClosing = WebBrowser1WindowClosing
    ControlData = {
      4C0000002E6800006B4400000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 288
    Top = 80
  end
  object OpenDialog3: TOpenDialog
    DefaultExt = 'php'
    FileName = 'scrap.php'
    Filter = 
      'All PHP files (*.php*;*.phtml;*.inc;*.xphp)|*.php*;*.phtml;*.inc' +
      ';*.xphp|PHP files (*.php*;*.phtml)|*.php*;*.phtml|Include files ' +
      '(*.inc)|*.inc|PHP source files (*.phps)|*.phps|Executable PHP fi' +
      'le (*.xphp)|*.xphp|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Please select (or create) a scrap file'
    Left = 352
    Top = 88
  end
end
