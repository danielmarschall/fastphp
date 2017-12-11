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
  OnCloseQuery = FormCloseQuery
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
    ActivePage = PlaintextTabSheet
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
        OnDblClick = Memo2DblClick
        OnKeyDown = Memo2KeyDown
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
        OnBeforeNavigate2 = WebBrowser1BeforeNavigate2
        ExplicitWidth = 348
        ExplicitHeight = 150
        ControlData = {
          4C000000EE720000521900000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126200000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
  end
  object PageControl2: TPageControl
    Left = 0
    Top = 36
    Width = 1120
    Height = 349
    ActivePage = CodeTabsheet
    Align = alClient
    TabOrder = 1
    OnChanging = PageControl2Changing
    object CodeTabsheet: TTabSheet
      Caption = 'Code'
      object Splitter2: TSplitter
        Left = 273
        Top = 0
        Height = 321
        ExplicitLeft = 328
        ExplicitTop = 32
        ExplicitHeight = 100
      end
      object SynEdit1: TSynEdit
        Left = 276
        Top = 0
        Width = 836
        Height = 321
        Align = alClient
        ActiveLineColor = 14680010
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        TabOrder = 0
        OnMouseWheelDown = SynEdit1MouseWheelDown
        OnMouseWheelUp = SynEdit1MouseWheelUp
        Gutter.AutoSize = True
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.ShowLineNumbers = True
        Gutter.Gradient = True
        Gutter.GradientStartColor = cl3DLight
        Highlighter = SynPHPSyn1
        Options = [eoAutoIndent, eoDragDropEditing, eoEnhanceHomeKey, eoEnhanceEndKey, eoGroupUndo, eoHideShowScrollbars, eoScrollByOneLess, eoShowScrollHint, eoTabIndent, eoTrimTrailingSpaces]
        SearchEngine = SynEditSearch1
        WantTabs = True
        OnGutterClick = SynEdit1GutterClick
        OnMouseCursor = SynEdit1MouseCursor
        OnPaintTransient = SynEdit1PaintTransient
        FontSmoothing = fsmNone
      end
      object TreeView1: TTreeView
        Left = 0
        Top = 0
        Width = 273
        Height = 321
        Align = alLeft
        Indent = 19
        TabOrder = 1
        OnDblClick = TreeView1DblClick
      end
    end
    object HelpTabsheet: TTabSheet
      Caption = 'Help'
      ImageIndex = 1
      object WebBrowser2: TWebBrowser
        Left = 0
        Top = 0
        Width = 1112
        Height = 321
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 300
        ExplicitHeight = 150
        ControlData = {
          4C000000EE7200002D2100000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126200000000000000004C0000000114020000000000C000000000000046
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
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 1120
    Height = 36
    Align = alTop
    TabOrder = 3
    object Button1: TButton
      Left = 4
      Top = 0
      Width = 75
      Height = 35
      Action = ActionRun
      TabOrder = 0
    end
    object Button2: TButton
      Left = 247
      Top = 0
      Width = 75
      Height = 35
      Action = ActionHelp
      TabOrder = 3
    end
    object Button3: TButton
      Left = 328
      Top = 0
      Width = 75
      Height = 35
      Action = ActionGoto
      TabOrder = 4
    end
    object Button4: TButton
      Left = 409
      Top = 0
      Width = 75
      Height = 35
      Action = ActionFind
      TabOrder = 5
    end
    object Button5: TButton
      Left = 490
      Top = 0
      Width = 75
      Height = 35
      Action = ActionReplace
      TabOrder = 6
    end
    object Button6: TButton
      Left = 571
      Top = 0
      Width = 75
      Height = 35
      Action = ActionFindNext
      TabOrder = 7
    end
    object Button7: TButton
      Left = 166
      Top = 0
      Width = 75
      Height = 35
      Action = ActionSave
      TabOrder = 2
    end
    object Button8: TButton
      Left = 85
      Top = 0
      Width = 75
      Height = 35
      Action = ActionOpen
      TabOrder = 1
    end
    object Button9: TButton
      Left = 652
      Top = 0
      Width = 75
      Height = 35
      Action = ActionFindPrev
      TabOrder = 8
    end
    object Button11: TButton
      Left = 733
      Top = 0
      Width = 75
      Height = 35
      Action = ActionSpaceToTab
      TabOrder = 9
    end
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
  object OpenDialog3: TOpenDialog
    DefaultExt = '.php'
    FileName = 'scrap.php'
    Filter = 'PHP file (*.php;*.xphp)|*.php;*.xphp|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Please select (or create) a scrap file'
    Left = 608
    Top = 248
  end
  object SynPHPSyn1: TSynPHPSyn
    DefaultFilter = 
      'PHP Files (*.php;*.xphp;*.php3;*.phtml;*.inc)|*.php;*.xphp;*.php' +
      '3;*.phtml;*.inc'
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    CommentAttri.Foreground = 33023
    IdentifierAttri.Foreground = 4194304
    KeyAttri.Foreground = 4227072
    NumberAttri.Foreground = 213
    StringAttri.Foreground = 13762560
    SymbolAttri.Foreground = 4227072
    VariableAttri.Foreground = 213
    Left = 72
    Top = 80
  end
  object SynEditFocusTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = SynEditFocusTimerTimer
    Left = 668
    Top = 249
  end
  object ActionList: TActionList
    Left = 252
    Top = 276
    object ActionFind: TAction
      Caption = 'Find'
      ShortCut = 16454
      OnExecute = ActionFindExecute
    end
    object ActionReplace: TAction
      Caption = 'Replace'
      ShortCut = 16456
      OnExecute = ActionReplaceExecute
    end
    object ActionFindNext: TAction
      Caption = 'Find next'
      ShortCut = 114
      OnExecute = ActionFindNextExecute
    end
    object ActionFindPrev: TAction
      Caption = 'Find prev'
      ShortCut = 8306
      OnExecute = ActionFindPrevExecute
    end
    object ActionGoto: TAction
      Caption = 'Goto line'
      ShortCut = 16455
      OnExecute = ActionGotoExecute
    end
    object ActionSave: TAction
      Caption = 'Save'
      ShortCut = 16467
      OnExecute = ActionSaveExecute
    end
    object ActionHelp: TAction
      Caption = 'Help'
      ShortCut = 112
      OnExecute = ActionHelpExecute
    end
    object ActionRun: TAction
      Caption = 'Run'
      ShortCut = 120
      OnExecute = ActionRunExecute
    end
    object ActionESC: TAction
      Caption = 'Esc'
      ShortCut = 27
      OnExecute = ActionESCExecute
    end
    object ActionOpen: TAction
      Caption = 'Open'
      ShortCut = 16463
      OnExecute = ActionOpenExecute
    end
    object ActionSpaceToTab: TAction
      Caption = 'SpaceToTab'
      Hint = 'Converts leading spaces to tabs'
      OnExecute = ActionSpaceToTabExecute
    end
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 776
    Top = 8
  end
  object SynEditSearch1: TSynEditSearch
    Left = 780
    Top = 236
  end
end
