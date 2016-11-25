object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'ViaThinkSoft FastPHP'
  ClientHeight = 661
  ClientWidth = 1120
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 385
    Width = 1120
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 262
    ExplicitWidth = 399
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 388
    Width = 1120
    Height = 273
    ActivePage = HtmlTabSheet
    Align = alBottom
    TabOrder = 0
    object PlaintextTabSheet: TTabSheet
      Caption = 'Plaintext'
      object Memo2: TMemo
        Left = 0
        Top = 0
        Width = 1112
        Height = 245
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object HtmlTabSheet: TTabSheet
      Caption = 'HTML'
      ImageIndex = 1
      object WebBrowser1: TWebBrowser
        Left = 0
        Top = 0
        Width = 1112
        Height = 245
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 348
        ExplicitHeight = 150
        ControlData = {
          4C000000EE720000521900000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
  end
  object PageControl2: TPageControl
    Left = 0
    Top = 0
    Width = 1120
    Height = 385
    ActivePage = TabSheet3
    Align = alClient
    TabOrder = 1
    OnChanging = PageControl2Changing
    object TabSheet3: TTabSheet
      Caption = 'Scrap'
      object SynEdit1: TSynEdit
        Left = 0
        Top = 0
        Width = 1112
        Height = 357
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        TabOrder = 0
        OnKeyDown = Memo1KeyDown
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.ShowLineNumbers = True
        Highlighter = SynPHPSyn1
        Lines.Strings = (
          'SynEdit1')
        Options = [eoAutoIndent, eoDragDropEditing, eoEnhanceEndKey, eoGroupUndo, eoHideShowScrollbars, eoScrollByOneLess, eoShowScrollHint, eoSmartTabDelete, eoSmartTabs, eoTabIndent, eoTabsToSpaces, eoTrimTrailingSpaces]
        WantTabs = True
        FontSmoothing = fsmNone
      end
    end
    object HelpTabsheet: TTabSheet
      Caption = 'Help'
      ImageIndex = 1
      object WebBrowser2: TWebBrowser
        Left = 0
        Top = 0
        Width = 1112
        Height = 357
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 300
        ExplicitHeight = 150
        ControlData = {
          4C000000EE720000E62400000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
  end
  object Panel1: TPanel
    Left = 544
    Top = 112
    Width = 185
    Height = 41
    Caption = 'Generating help. Please wait...'
    TabOrder = 2
    Visible = False
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.chm'
    FileName = 'php_manual_en.chm'
    Filter = 'Help files (*.chm)|*.chm'
    Options = [ofReadOnly, ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Please select your PHP Help file (CHM format)'
    Left = 504
    Top = 248
  end
  object OpenDialog2: TOpenDialog
    DefaultExt = '.exe'
    FileName = 'php.exe'
    Filter = 'Executable file (*.exe)|*.exe'
    Options = [ofReadOnly, ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Please chose your PHP interpreter (php.exe)'
    Left = 552
    Top = 248
  end
  object OpenDialog3: TOpenDialog
    DefaultExt = '.php'
    FileName = 'scap.php'
    Filter = 'PHP file (*.php)|*.php|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Where should the scrap file be saved?'
    Left = 608
    Top = 248
  end
  object SynPHPSyn1: TSynPHPSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    CommentAttri.Foreground = 33023
    IdentifierAttri.Foreground = clOlive
    KeyAttri.Foreground = 4227072
    NumberAttri.Foreground = 213
    StringAttri.Foreground = 16744576
    SymbolAttri.Foreground = 4227072
    VariableAttri.Foreground = 213
    Left = 72
    Top = 80
  end
end
