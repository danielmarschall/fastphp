object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'ViaThinkSoft FastPHP 0.12'
  ClientHeight = 661
  ClientWidth = 1120
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  WindowState = wsMaximized
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
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
        Color = clCream
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
        SelectedEngine = EdgeIfAvailable
        OnBeforeNavigate2 = WebBrowser1BeforeNavigate2
        OnWindowClosing = WebBrowser1WindowClosing
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
        Left = 329
        Top = 0
        Height = 321
        ExplicitLeft = 328
        ExplicitTop = 32
        ExplicitHeight = 100
      end
      object SynEdit1: TSynEdit
        Left = 332
        Top = 0
        Width = 780
        Height = 321
        Align = alClient
        Color = clCream
        ActiveLineColor = 14680010
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        Font.Quality = fqClearTypeNatural
        TabOrder = 0
        OnKeyDown = SynEdit1KeyDown
        OnMouseWheelDown = SynEdit1MouseWheelDown
        OnMouseWheelUp = SynEdit1MouseWheelUp
        CodeFolding.ShowCollapsedLine = True
        UseCodeFolding = False
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.Font.Quality = fqClearTypeNatural
        Gutter.ShowLineNumbers = True
        Gutter.Gradient = True
        Gutter.GradientStartColor = cl3DLight
        Gutter.Bands = <
          item
            Kind = gbkMarks
            Width = 13
          end
          item
            Kind = gbkLineNumbers
          end
          item
            Kind = gbkFold
          end
          item
            Kind = gbkTrackChanges
          end
          item
            Kind = gbkMargin
            Width = 3
          end>
        Highlighter = SynPHPSyn1
        Options = [eoAutoIndent, eoDragDropEditing, eoDropFiles, eoEnhanceHomeKey, eoEnhanceEndKey, eoGroupUndo, eoHideShowScrollbars, eoKeepCaretX, eoScrollByOneLess, eoShowScrollHint, eoTabIndent]
        SearchEngine = SynEditSearch1
        SelectedColor.Alpha = 0.400000005960464500
        TabWidth = 4
        WantTabs = True
        OnDropFiles = SynEdit1DropFiles
        OnGutterClick = SynEdit1GutterClick
        OnMouseCursor = SynEdit1MouseCursor
        OnStatusChange = SynEdit1StatusChange
        OnPaintTransient = SynEdit1PaintTransient
        RemovedKeystrokes = <
          item
            Command = ecUndo
            ShortCut = 32776
          end
          item
            Command = ecRedo
            ShortCut = 40968
          end
          item
            Command = ecDeleteWord
            ShortCut = 16468
          end
          item
            Command = ecDeleteLine
            ShortCut = 16473
          end
          item
            Command = ecRedo
            ShortCut = 24666
          end>
        AddedKeystrokes = <
          item
            Command = ecDeleteWord
            ShortCut = 16430
          end
          item
            Command = ecRedo
            ShortCut = 16473
          end>
      end
      object TreeView1: TTreeView
        Left = 0
        Top = 0
        Width = 329
        Height = 321
        Align = alLeft
        Color = clCream
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        Images = ImageList1
        Indent = 19
        ParentFont = False
        ReadOnly = True
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
    object BtnSpecialChars: TImage
      Left = 896
      Top = 8
      Width = 24
      Height = 22
      Cursor = crHandPoint
      Hint = 'Special characters On/Off'
      AutoSize = True
      ParentShowHint = False
      Picture.Data = {
        07544269746D617066060000424D660600000000000036000000280000001800
        000016000000010018000000000030060000C30E0000C30E0000000000000000
        0000FFFFFFDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
        DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD6D6D6D6D6D6D6D6D6DDDDDDDDDDDDDDDD
        DDDDDDDDDDDDDDFFFFFFD8D8D8FEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFEFEFED8D8D8D2D2D2FFFFFFFFFFFFFDFDFDFDFD
        FDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFD
        FDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFFFFFFD2D2D2CCCCCCFFFFFF
        F8F8F8F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
        F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F8F8F8FFFFFFCC
        CCCCC6C6C6FFFFFFF3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3
        F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3
        F3F3F3F3FFFFFFC6C6C6C0C0C0FFFFFFEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
        EEEEEEEEEEEEEEEEEEEEEE2E2E2EEEEEEEEEEEEE2E2E2EEEEEEEEEEEEEEEEEEE
        EEEEEEEEEEEEEEEEEEEEEEEEFFFFFFC0C0C0BABABAFFFFFFE9E9E9E8E8E8E8E8
        E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E82E2E2EE8E8E8E8E8E82E2E2EE8
        E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E9E9E9FFFFFFBABABAB6B6B6FFFFFF
        E3E3E3E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E22E2E2EE2E2
        E2E2E2E22E2E2EE2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E3E3E3FFFFFFB6
        B6B6B3B3B3FCFCFCDEDEDEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
        DDDDDD2E2E2EDDDDDDDDDDDD2E2E2EDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
        DDDEDEDEFCFCFCB3B3B3B0B0B0F9F9F9D9D9D9D8D8D8D8D8D8D8D8D8D8D8D8D8
        D8D8D8D8D8D8D8D8D8D8D82E2E2ED8D8D8D8D8D82E2E2ED8D8D8D8D8D8D8D8D8
        D8D8D8D8D8D8D8D8D8D9D9D9F9F9F9B0B0B0AFAFAFF7F7F7D5D5D5D4D4D4D4D4
        D4D4D4D4D4D4D4D4D4D49595955757573737372E2E2ED4D4D4D4D4D42E2E2ED4
        D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D5D5D5F7F7F7AFAFAFB0B0B0F5F5F5
        D2D2D2D2D2D2D2D2D2D2D2D2D2D2D29494942E2E2E2E2E2E2E2E2E2E2E2ED2D2
        D2D2D2D22E2E2ED2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2F5F5F5B0
        B0B0B2B2B2F5F5F5D2D2D2D1D1D1D1D1D1D1D1D1D1D1D15656562E2E2E2E2E2E
        2E2E2E2E2E2ED1D1D1D1D1D12E2E2ED1D1D1D1D1D1D1D1D1D1D1D1D1D1D1D1D1
        D1D2D2D2F5F5F5B2B2B2B6B6B6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF39
        39392E2E2E2E2E2E2E2E2E2E2E2EFFFFFFFFFFFF2E2E2EFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB6B6B6BBBBBBFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFF6262622E2E2E2E2E2E2E2E2E2E2E2EFFFFFFFFFFFF2E2E2EFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBBBBBBC0C0C0FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB6B6B62E2E2E2E2E2E2E2E2E2E2E2EA8A8
        A8FFFFFF2E2E2EA8A8A8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0
        C0C0C7C7C7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB9B9B9656565
        2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2EFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFC7C7C7CECECEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECED4D4D4FFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD4D4D4D9D9D9FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD9
        D9D9DEDEDEF5F5F5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFF5F5F5DEDEDEFFFFFFE2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2
        E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2DDDDDDDDDDDDDDDDDD
        E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2FFFFFF}
      ShowHint = True
      OnClick = BtnSpecialCharsClick
    end
    object BtnSpecialCharsOff: TImage
      Left = 976
      Top = 8
      Width = 24
      Height = 22
      AutoSize = True
      Picture.Data = {
        07544269746D617066060000424D660600000000000036000000280000001800
        000016000000010018000000000030060000C30E0000C30E0000000000000000
        0000FFFFFFDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
        DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD6D6D6D6D6D6D6D6D6DDDDDDDDDDDDDDDD
        DDDDDDDDDDDDDDFFFFFFD8D8D8FEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFEFEFED8D8D8D2D2D2FFFFFFFFFFFFFDFDFDFDFD
        FDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFD
        FDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFFFFFFD2D2D2CCCCCCFFFFFF
        F8F8F8F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
        F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F8F8F8FFFFFFCC
        CCCCC6C6C6FFFFFFF3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3
        F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3
        F3F3F3F3FFFFFFC6C6C6C0C0C0FFFFFFEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
        EEEEEEEEEEEEEEEEEEEEEE2E2E2EEEEEEEEEEEEE2E2E2EEEEEEEEEEEEEEEEEEE
        EEEEEEEEEEEEEEEEEEEEEEEEFFFFFFC0C0C0BABABAFFFFFFE9E9E9E8E8E8E8E8
        E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E82E2E2EE8E8E8E8E8E82E2E2EE8
        E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E9E9E9FFFFFFBABABAB6B6B6FFFFFF
        E3E3E3E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E22E2E2EE2E2
        E2E2E2E22E2E2EE2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E3E3E3FFFFFFB6
        B6B6B3B3B3FCFCFCDEDEDEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
        DDDDDD2E2E2EDDDDDDDDDDDD2E2E2EDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
        DDDEDEDEFCFCFCB3B3B3B0B0B0F9F9F9D9D9D9D8D8D8D8D8D8D8D8D8D8D8D8D8
        D8D8D8D8D8D8D8D8D8D8D82E2E2ED8D8D8D8D8D82E2E2ED8D8D8D8D8D8D8D8D8
        D8D8D8D8D8D8D8D8D8D9D9D9F9F9F9B0B0B0AFAFAFF7F7F7D5D5D5D4D4D4D4D4
        D4D4D4D4D4D4D4D4D4D49595955757573737372E2E2ED4D4D4D4D4D42E2E2ED4
        D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D5D5D5F7F7F7AFAFAFB0B0B0F5F5F5
        D2D2D2D2D2D2D2D2D2D2D2D2D2D2D29494942E2E2E2E2E2E2E2E2E2E2E2ED2D2
        D2D2D2D22E2E2ED2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2F5F5F5B0
        B0B0B2B2B2F5F5F5D2D2D2D1D1D1D1D1D1D1D1D1D1D1D15656562E2E2E2E2E2E
        2E2E2E2E2E2ED1D1D1D1D1D12E2E2ED1D1D1D1D1D1D1D1D1D1D1D1D1D1D1D1D1
        D1D2D2D2F5F5F5B2B2B2B6B6B6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF39
        39392E2E2E2E2E2E2E2E2E2E2E2EFFFFFFFFFFFF2E2E2EFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB6B6B6BBBBBBFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFF6262622E2E2E2E2E2E2E2E2E2E2E2EFFFFFFFFFFFF2E2E2EFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBBBBBBC0C0C0FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB6B6B62E2E2E2E2E2E2E2E2E2E2E2EA8A8
        A8FFFFFF2E2E2EA8A8A8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0
        C0C0C7C7C7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB9B9B9656565
        2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2EFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFC7C7C7CECECEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECED4D4D4FFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD4D4D4D9D9D9FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD9
        D9D9DEDEDEF5F5F5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFF5F5F5DEDEDEFFFFFFE2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2
        E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2DDDDDDDDDDDDDDDDDD
        E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2FFFFFF}
      Visible = False
    end
    object BtnSpecialCharsOn: TImage
      Left = 1006
      Top = 8
      Width = 24
      Height = 22
      AutoSize = True
      Picture.Data = {
        07544269746D617066060000424D660600000000000036000000280000001800
        000016000000010018000000000030060000C40E0000C40E0000000000000000
        0000F9E8DAD5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989
        D5A989D5A989D5A989D5A989D5A989D1A380D1A380D1A380D5A989D5A989D5A9
        89D5A989D5A989F9E8DAD1A583E8CDB9CCF9FFCCF9FFCCF9FFCCF9FFCCF9FFCC
        F9FFCCF9FFCCF9FFCCF9FFCCF9FFCCF9FFCCF9FFCCF9FFCCF9FFCCF9FFCCF9FF
        CCF9FFCCF9FFCCF9FFCCF9FFE8CDB9D1A583CBA07DC4EFFFC4EFFF9FE5FF9FE5
        FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FF9F
        E5FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FFC4EFFFCBA07DC69976BEEDFF
        95E1FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1
        FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1FF95E1FFBEEDFFC6
        9976C1936FB8EBFF8CDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF
        8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDF
        FF8CDFFFB8EBFFC1936FBD8C68B2EAFF82DCFF81DCFF81DCFF81DCFF81DCFF81
        DCFF81DCFF81DCFF81DCFF00000081DCFF81DCFF00000081DCFF81DCFF81DCFF
        81DCFF81DCFF81DCFF82DCFFB2EAFFBD8C68B68762ABE8FF77DAFF76DAFF76DA
        FF76DAFF76DAFF76DAFF76DAFF76DAFF76DAFF00000076DAFF76DAFF00000076
        DAFF76DAFF76DAFF76DAFF76DAFF76DAFF77DAFFABE8FFB68762B4835DA4E7FF
        6BD7FF6AD7FF6AD7FF6AD7FF6AD7FF6AD7FF6AD7FF6AD7FF6AD7FF0000006AD7
        FF6AD7FF0000006AD7FF6AD7FF6AD7FF6AD7FF6AD7FF6AD7FF6BD7FFA4E7FFB4
        835DB07F5A9EE5FF61D5FF60D5FF60D5FF60D5FF60D5FF60D5FF60D5FF60D5FF
        60D5FF00000060D5FF60D5FF00000060D5FF60D5FF60D5FF60D5FF60D5FF60D5
        FF61D5FF9EE5FFB07F5AAF7D5698E4FF57D3FF56D3FF56D3FF56D3FF56D3FF56
        D3FF56D3FF56D3FF56D3FF00000056D3FF56D3FF00000056D3FF56D3FF56D3FF
        56D3FF56D3FF56D3FF57D3FF98E4FFAF7D56AE7C5593E3FF4FD1FF4ED1FF4ED1
        FF4ED1FF4ED1FF4ED1FF30829F13333F040C0F0000004ED1FF4ED1FF0000004E
        D1FF4ED1FF4ED1FF4ED1FF4ED1FF4ED1FF4FD1FF93E3FFAE7C55AF7D5590E2FF
        4AD0FF49D0FF49D0FF49D0FF49D0FF2D819F00000000000000000000000049D0
        FF49D0FF00000049D0FF49D0FF49D0FF49D0FF49D0FF49D0FF4AD0FF90E2FFAF
        7D55B07F598FE2FF49D0FF48D0FF48D0FF48D0FF48D0FF11333F000000000000
        00000000000048D0FF48D0FF00000048D0FF48D0FF48D0FF48D0FF48D0FF48D0
        FF49D0FF8FE2FFB07F59B5835CCAEFFCA9E5FAA8E5FAA8E5FAA8E5FAA8E5FA09
        0D0E000000000000000000000000A8E5FAA8E5FA000000A8E5FAA8E5FAA8E5FA
        A8E5FAA8E5FAA8E5FAA9E5FACAEFFCB5835CB88762D0F1FCB3E8FAB2E8FAB2E8
        FAB2E8FAB2E8FA2B393D000000000000000000000000B2E8FAB2E8FA000000B2
        E8FAB2E8FAB2E8FAB2E8FAB2E8FAB2E8FAB3E8FAD0F1FCB88762BD8C68D5F3FD
        BCECFBBBECFBBBECFBBBECFBBBECFB74939C0000000000000000000000006884
        8CBBECFB00000068848CBBECFBBBECFBBBECFBBBECFBBBECFBBCECFBD5F3FDBD
        8C68C4936EDAF5FDC3EFFCC3EFFCC3EFFCC3EFFCC3EFFCC3EFFC79959D303B3E
        000000000000000000000000000000000000000000C3EFFCC3EFFCC3EFFCC3EF
        FCC3EFFCDAF5FDC4936ECA9A77DFF7FECAF2FDCAF2FDCAF2FDCAF2FDCAF2FDCA
        F2FDCAF2FDCAF2FDCAF2FDCAF2FDCAF2FDCAF2FDCAF2FDCAF2FDCAF2FDCAF2FD
        CAF2FDCAF2FDCAF2FDCAF2FDDFF7FECA9A77CFA07DE2F9FED0F5FED0F5FED0F5
        FED0F5FED0F5FED0F5FED0F5FED0F5FED0F5FED0F5FED0F5FED0F5FED0F5FED0
        F5FED0F5FED0F5FED0F5FED0F5FED0F5FED0F5FEE2F9FECFA07DD3A683E5FAFE
        E5FAFED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7
        FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FEE5FAFED3
        A683D9AA87E1C4AEE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFF
        E8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FB
        FFE8FBFFE1C4AED9AA87FCF0E6DDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDD
        AF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDAA784DAA784DAA784
        DDAF8CDDAF8CDDAF8CDDAF8CDDAF8CFCF0E6}
      Visible = False
    end
    object BtnLightOn: TImage
      Left = 1022
      Top = 8
      Width = 24
      Height = 22
      AutoSize = True
      Picture.Data = {
        07544269746D617066060000424D660600000000000036000000280000001800
        000016000000010018000000000030060000C30E0000C30E0000000000000000
        0000F9E8DAD5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989
        D5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A9
        89D5A989D5A989F9E8DAD1A583E8CDB9CCF9FFCCF9FFCCF9FFCCF9FFCCF9FFCC
        F9FFCCF9FFCCF9FFBAE4E9414F51728C8FCCF9FFCCF9FFCCF9FFCCF9FFCCF9FF
        CCF9FFCCF9FFCCF9FFCCF9FFE8CDB9D1A583CBA07DC4EFFFC4EFFF9FE5FF9FE5
        FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FF59808E141D2025363C81BACF9FE5FF9F
        E5FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FFC4EFFFCBA07DC69976BEEDFF
        95E1FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1FF35515C1521251925
        2A6294A895E1FF95E1FF95E1FF95E1FF95E1FF95E1FF95E1FF95E1FFBEEDFFC6
        9976C1936FB8EBFF8CDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF88DBFA
        273F480F181C101A1E5181938CDFFF8CDFFF8CDFFF8CDFFF8CDFFF8CDFFF8CDF
        FF8CDFFFB8EBFFC1936FBD8C68B2EAFF82DCFF81DCFF81DCFF81DCFF81DCFF81
        DCFF81DCFF69B3D0111D221F353E18293021384182DCFF82DCFF82DCFF82DCFF
        82DCFF82DCFF82DCFF82DCFFB2EAFFBD8C68B68762ABE8FF77DAFF76DAFF76DA
        FF76DAFF64B9D873D5F976DAFF4A89A00D191D60B1CF3F73870E1A1E77DAFF77
        DAFF69C0E16ECAEC77DAFF77DAFF77DAFF77DAFFABE8FFB68762B4835DA4E7FF
        6BD7FF6AD7FF6AD7FF6AD7FF3B788E30627468D2F9274E5D172F386AD7FF59B4
        D509131654A8C75BB8DA25495758B1D26BD7FF6BD7FF6BD7FF6BD7FFA4E7FFB4
        835DB07F5A9EE5FF61D5FF60D5FF60D5FF60D5FF3F8CA81A3A463A819B0B171C
        2F697E60D5FF5ECEF70E20260F2127306A7F1D3F4C56BEE361D5FF61D5FF61D5
        FF61D5FF9EE5FFB07F5AAF7D5698E4FF57D3FF56D3FF56D3FF56D3FF56D3FF2D
        6D840A181D0D21284DBDE456D3FF57D3FF31768F091519132F3943A3C557D3FF
        57D3FF57D3FF57D3FF57D3FF98E4FFAF7D56AE7C5593E3FF4FD1FF4ED1FF4ED1
        FF4ED1FF4ED1FF1E5062060F123690B04ED1FF4ED1FF4FD1FF4ECFFC27677E0A
        191F3EA5C94FD1FF4FD1FF4FD1FF4FD1FF4FD1FF93E3FFAE7C55AF7D5590E2FF
        4AD0FF49D0FF3EB0D8389FC340B7E00A1D2417425149D0FF49D0FF49D0FF4AD0
        FF4AD0FF4AD0FF0C222A215D723CAAD03AA4C94AD0FF4AD0FF4AD0FF90E2FFAF
        7D55B07F598FE2FF49D0FF48D0FF2975901E5669308AA908181D2B7D9948D0FF
        48D0FF48D0FF49D0FF49D0FF49D0FF133743184453256981215F7449D0FF49D0
        FF49D0FF8FE2FFB07F59B5835CCAEFFCA9E5FAA8E5FA7099A75A7B867EACBC1E
        282C222F33A8E5FAA8E5FAA8E5FAA9E5FAA9E5FAA3DDF1161E2054717C698E9B
        618490A9E5FAA9E5FAA9E5FACAEFFCB5835CB88762D0F1FCB3E8FAB2E8FAB2E8
        FAB2E8FAB2E8FA536C75090C0D6D8E99B2E8FAB2E8FAB3E8FAABDDEE475C6314
        191B9AC7D7B3E8FAB3E8FAB3E8FAB3E8FAB3E8FAD0F1FCB88762BD8C68D5F3FD
        BCECFBBBECFBBBECFBBBECFBBBECFB9EC7D41C2325222B2E475A5F6B8790647D
        853441451D2527425258B9E8F7BCECFBBCECFBBCECFBBCECFBBCECFBD5F3FDBD
        8C68C4936EDAF5FDC3EFFCC3EFFCC3EFFCC3EFFC9ABDC847575C8FAFB93A474B
        333F423E4C503C494D2E383B4A5B60748E965C7077BAE4F0C3EFFCC3EFFCC3EF
        FCC3EFFCDAF5FDC4936ECA9A77DFF7FECAF2FDCAF2FDCAF2FDCAF2FD6E848A43
        5053B5D9E3C8EFFA8BA6AE596A6F6E848AA6C6CFCAF2FD8FACB4414E51A6C7D0
        CAF2FDCAF2FDCAF2FDCAF2FDDFF7FECA9A77CFA07DE2F9FED0F5FED0F5FED0F5
        FED0F5FE8FA8AEAECDD4D0F5FED0F5FED0F5FE515F6396B1B7D0F5FED0F5FED0
        F5FE8CA5ABB3D3DBD0F5FED0F5FED0F5FED0F5FEE2F9FECFA07DD3A683E5FAFE
        E5FAFED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FE4651548DA4
        A8D5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FEE5FAFED3
        A683D9AA87E1C4AEE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFF
        E8FBFF9BA7AAC8D9DCE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FB
        FFE8FBFFE1C4AED9AA87FCF0E6DDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDD
        AF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8C
        DDAF8CDDAF8CDDAF8CDDAF8CDDAF8CFCF0E6}
      Visible = False
    end
    object BtnLightOff: TImage
      Left = 1012
      Top = 8
      Width = 24
      Height = 22
      AutoSize = True
      Picture.Data = {
        07544269746D617066060000424D660600000000000036000000280000001800
        000016000000010018000000000030060000C30E0000C30E0000000000000000
        0000FFFFFFDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
        DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD6D6D6D6D6D6D6D6D6DDDDDDDDDDDDDDDD
        DDDDDDDDDDDDDDFFFFFFD8D8D8FEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFE9E9E95151518F8F8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFEFEFED8D8D8D2D2D2FFFFFFFFFFFFFDFDFDFDFD
        FDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFD8D8D8D2020203C3C3CCDCDCDFDFDFDFD
        FDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFFFFFFD2D2D2CCCCCCFFFFFF
        F8F8F8F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F75959592424242929
        29A3A3A3F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F8F8F8FFFFFFCC
        CCCCC6C6C6FFFFFFF3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3EEEEEE
        4545451B1B1B1D1D1D8C8C8CF3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3F3
        F3F3F3F3FFFFFFC6C6C6C0C0C0FFFFFFEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
        EEEEEEEEEEC2C2C22020203A3A3A2D2D2D3D3D3DEEEEEEEEEEEEEEEEEEEEEEEE
        EEEEEEEEEEEEEEEEEEEEEEEEFFFFFFC0C0C0BABABAFFFFFFE9E9E9E8E8E8E8E8
        E8E8E8E8C5C5C5E3E3E3E8E8E89292921A1A1ABCBCBC7B7B7B1B1B1BE8E8E8E8
        E8E8CDCDCDD7D7D7E8E8E8E8E8E8E8E8E8E9E9E9FFFFFFBABABAB6B6B6FFFFFF
        E3E3E3E2E2E2E2E2E2E2E2E27E7E7E676767DDDDDD525252323232E2E2E2BDBD
        BD131313B0B0B0C1C1C14D4D4DBABABAE2E2E2E2E2E2E2E2E2E3E3E3FFFFFFB6
        B6B6B3B3B3FCFCFCDEDEDEDDDDDDDDDDDDDDDDDD9292923D3D3D868686181818
        6D6D6DDDDDDDD6D6D62121212222226E6E6E424242C5C5C5DDDDDDDDDDDDDDDD
        DDDEDEDEFCFCFCB3B3B3B0B0B0F9F9F9D9D9D9D8D8D8D8D8D8D8D8D8D8D8D870
        7070191919222222C1C1C1D8D8D8D8D8D8797979151515303030A7A7A7D8D8D8
        D8D8D8D8D8D8D8D8D8D9D9D9F9F9F9B0B0B0AFAFAFF7F7F7D5D5D5D4D4D4D4D4
        D4D4D4D4D4D4D45151510F0F0F929292D4D4D4D4D4D4D4D4D4D2D2D26969691A
        1A1AA7A7A7D4D4D4D4D4D4D4D4D4D4D4D4D5D5D5F7F7F7AFAFAFB0B0B0F5F5F5
        D2D2D2D2D2D2B2B2B2A1A1A1B8B8B81E1E1E434343D2D2D2D2D2D2D2D2D2D2D2
        D2D2D2D2D2D2D22323235E5E5EABABABA6A6A6D2D2D2D2D2D2D2D2D2F5F5F5B0
        B0B0B2B2B2F5F5F5D2D2D2D1D1D17676765656568B8B8B1818187D7D7DD1D1D1
        D1D1D1D1D1D1D1D1D1D1D1D1D1D1D13737374444446A6A6A5F5F5FD1D1D1D1D1
        D1D2D2D2F5F5F5B2B2B2B6B6B6FFFFFFFFFFFFFFFFFFAAAAAA898989C0C0C02D
        2D2D343434FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6F6F62121217E7E7E9E9E9E
        939393FFFFFFFFFFFFFFFFFFFFFFFFB6B6B6BBBBBBFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFF7777770D0D0D9C9C9CFFFFFFFFFFFFFFFFFFF3F3F36565651C
        1C1CDBDBDBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBBBBBBC0C0C0FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD7D7D72626262F2F2F6161619292928787
        87464646282828595959FBFBFBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0
        C0C0C7C7C7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCACACA5D5D5DBBBBBB4C4C4C
        4343435151514E4E4E3C3C3C616161989898787878F3F3F3FFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFC7C7C7CECECEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8B8B8B54
        5454E5E5E5FCFCFCAFAFAF7070708B8B8BD1D1D1FFFFFFB5B5B5525252D2D2D2
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCECECED4D4D4FFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFAFAFAFD5D5D5FFFFFFFFFFFFFFFFFF636363B8B8B8FFFFFFFFFFFFFF
        FFFFACACACDCDCDCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD4D4D4D9D9D9FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF545454A9A9
        A9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD9
        D9D9DEDEDEF5F5F5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFAAAAAADCDCDCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFF5F5F5DEDEDEFFFFFFE2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2
        E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2DDDDDDDDDDDDDDDDDD
        E2E2E2E2E2E2E2E2E2E2E2E2E2E2E2FFFFFF}
      Visible = False
    end
    object BtnLight: TImage
      Left = 926
      Top = 8
      Width = 24
      Height = 22
      Cursor = crHandPoint
      Hint = 'Dark Mode On/Off'
      AutoSize = True
      ParentShowHint = False
      Picture.Data = {
        07544269746D617066060000424D660600000000000036000000280000001800
        000016000000010018000000000030060000C30E0000C30E0000000000000000
        0000F9E8DAD5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989
        D5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A989D5A9
        89D5A989D5A989F9E8DAD1A583E8CDB9CCF9FFCCF9FFCCF9FFCCF9FFCCF9FFCC
        F9FFCCF9FFCCF9FFBAE4E9414F51728C8FCCF9FFCCF9FFCCF9FFCCF9FFCCF9FF
        CCF9FFCCF9FFCCF9FFCCF9FFE8CDB9D1A583CBA07DC4EFFFC4EFFF9FE5FF9FE5
        FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FF59808E141D2025363C81BACF9FE5FF9F
        E5FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FF9FE5FFC4EFFFCBA07DC69976BEEDFF
        95E1FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1FF94E1FF35515C1521251925
        2A6294A895E1FF95E1FF95E1FF95E1FF95E1FF95E1FF95E1FF95E1FFBEEDFFC6
        9976C1936FB8EBFF8CDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF8BDFFF88DBFA
        273F480F181C101A1E5181938CDFFF8CDFFF8CDFFF8CDFFF8CDFFF8CDFFF8CDF
        FF8CDFFFB8EBFFC1936FBD8C68B2EAFF82DCFF81DCFF81DCFF81DCFF81DCFF81
        DCFF81DCFF69B3D0111D221F353E18293021384182DCFF82DCFF82DCFF82DCFF
        82DCFF82DCFF82DCFF82DCFFB2EAFFBD8C68B68762ABE8FF77DAFF76DAFF76DA
        FF76DAFF64B9D873D5F976DAFF4A89A00D191D60B1CF3F73870E1A1E77DAFF77
        DAFF69C0E16ECAEC77DAFF77DAFF77DAFF77DAFFABE8FFB68762B4835DA4E7FF
        6BD7FF6AD7FF6AD7FF6AD7FF3B788E30627468D2F9274E5D172F386AD7FF59B4
        D509131654A8C75BB8DA25495758B1D26BD7FF6BD7FF6BD7FF6BD7FFA4E7FFB4
        835DB07F5A9EE5FF61D5FF60D5FF60D5FF60D5FF3F8CA81A3A463A819B0B171C
        2F697E60D5FF5ECEF70E20260F2127306A7F1D3F4C56BEE361D5FF61D5FF61D5
        FF61D5FF9EE5FFB07F5AAF7D5698E4FF57D3FF56D3FF56D3FF56D3FF56D3FF2D
        6D840A181D0D21284DBDE456D3FF57D3FF31768F091519132F3943A3C557D3FF
        57D3FF57D3FF57D3FF57D3FF98E4FFAF7D56AE7C5593E3FF4FD1FF4ED1FF4ED1
        FF4ED1FF4ED1FF1E5062060F123690B04ED1FF4ED1FF4FD1FF4ECFFC27677E0A
        191F3EA5C94FD1FF4FD1FF4FD1FF4FD1FF4FD1FF93E3FFAE7C55AF7D5590E2FF
        4AD0FF49D0FF3EB0D8389FC340B7E00A1D2417425149D0FF49D0FF49D0FF4AD0
        FF4AD0FF4AD0FF0C222A215D723CAAD03AA4C94AD0FF4AD0FF4AD0FF90E2FFAF
        7D55B07F598FE2FF49D0FF48D0FF2975901E5669308AA908181D2B7D9948D0FF
        48D0FF48D0FF49D0FF49D0FF49D0FF133743184453256981215F7449D0FF49D0
        FF49D0FF8FE2FFB07F59B5835CCAEFFCA9E5FAA8E5FA7099A75A7B867EACBC1E
        282C222F33A8E5FAA8E5FAA8E5FAA9E5FAA9E5FAA3DDF1161E2054717C698E9B
        618490A9E5FAA9E5FAA9E5FACAEFFCB5835CB88762D0F1FCB3E8FAB2E8FAB2E8
        FAB2E8FAB2E8FA536C75090C0D6D8E99B2E8FAB2E8FAB3E8FAABDDEE475C6314
        191B9AC7D7B3E8FAB3E8FAB3E8FAB3E8FAB3E8FAD0F1FCB88762BD8C68D5F3FD
        BCECFBBBECFBBBECFBBBECFBBBECFB9EC7D41C2325222B2E475A5F6B8790647D
        853441451D2527425258B9E8F7BCECFBBCECFBBCECFBBCECFBBCECFBD5F3FDBD
        8C68C4936EDAF5FDC3EFFCC3EFFCC3EFFCC3EFFC9ABDC847575C8FAFB93A474B
        333F423E4C503C494D2E383B4A5B60748E965C7077BAE4F0C3EFFCC3EFFCC3EF
        FCC3EFFCDAF5FDC4936ECA9A77DFF7FECAF2FDCAF2FDCAF2FDCAF2FD6E848A43
        5053B5D9E3C8EFFA8BA6AE596A6F6E848AA6C6CFCAF2FD8FACB4414E51A6C7D0
        CAF2FDCAF2FDCAF2FDCAF2FDDFF7FECA9A77CFA07DE2F9FED0F5FED0F5FED0F5
        FED0F5FE8FA8AEAECDD4D0F5FED0F5FED0F5FE515F6396B1B7D0F5FED0F5FED0
        F5FE8CA5ABB3D3DBD0F5FED0F5FED0F5FED0F5FEE2F9FECFA07DD3A683E5FAFE
        E5FAFED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FE4651548DA4
        A8D5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FED5F7FEE5FAFED3
        A683D9AA87E1C4AEE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFF
        E8FBFF9BA7AAC8D9DCE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FBFFE8FB
        FFE8FBFFE1C4AED9AA87FCF0E6DDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDD
        AF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8CDDAF8C
        DDAF8CDDAF8CDDAF8CDDAF8CDDAF8CFCF0E6}
      ShowHint = True
      OnClick = BtnLightClick
    end
    object Button1: TButton
      Left = 4
      Top = 0
      Width = 75
      Height = 35
      Action = ActionRun
      PopupMenu = RunPopup
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
      PopupMenu = SavePopup
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
      Height = 17
      Action = ActionSpaceToTab
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
    end
    object btnLint: TButton
      Left = 814
      Top = 0
      Width = 75
      Height = 35
      Action = ActionLint
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
    end
    object Button10: TButton
      Left = 733
      Top = 18
      Width = 75
      Height = 17
      Action = ActionTabToSpace
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'chm'
    FileName = 'php_manual_en.chm'
    Filter = 'Help files (*.chm)|*.chm'
    Options = [ofReadOnly, ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Please select your PHP Help file (CHM format)'
    Left = 504
    Top = 248
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
    Left = 608
    Top = 248
  end
  object SynPHPSyn1: TSynPHPSyn
    DefaultFilter = 
      'PHP Files (*.php;*.xphp;*.php3;*.phtml;*.inc)|*.php;*.xphp;*.php' +
      '3;*.phtml;*.inc'
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
    Left = 692
    Top = 249
  end
  object ActionList: TActionList
    Left = 132
    Top = 252
    object ActionFind: TAction
      Caption = 'Find...'
      ShortCut = 16454
      OnExecute = ActionFindExecute
    end
    object ActionReplace: TAction
      Caption = 'Replace...'
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
      Caption = 'Goto line...'
      ShortCut = 16455
      OnExecute = ActionGotoExecute
    end
    object ActionSave: TAction
      Caption = 'Save'
      ShortCut = 16467
      OnExecute = ActionSaveExecute
    end
    object ActionSaveAs: TAction
      Caption = 'Save as...'
      Hint = 'Save as a new file'
      ShortCut = 24659
      OnExecute = ActionSaveAsExecute
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
    object ActionRunConsole: TAction
      Caption = 'Run in console'
      ShortCut = 8312
      OnExecute = ActionRunConsoleExecute
    end
    object ActionGoToPHPDir: TAction
      Caption = 'Go to PHP dir'
      OnExecute = ActionGoToPHPDirExecute
    end
    object ActionPHPInteractiveShell: TAction
      Caption = 'PHP Interactive Shell'
      Hint = 'Opens the PHP Interactive Shell'
      OnExecute = ActionPHPInteractiveShellExecute
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
      ShortCut = 24660
      OnExecute = ActionSpaceToTabExecute
    end
    object ActionTabToSpace: TAction
      Caption = 'TabToSpace'
      Hint = 'Convert leading tabs to 4 spaces each'
      ShortCut = 57428
      OnExecute = ActionTabToSpaceExecute
    end
    object ActionLint: TAction
      Caption = 'Lint'
      Hint = 'Run PHP Lint (php -l) to check for syntax errors'
      ShortCut = 24652
      OnExecute = ActionLintExecute
    end
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 864
    Top = 88
  end
  object SynEditSearch1: TSynEditSearch
    Left = 788
    Top = 252
  end
  object ImageList1: TImageList
    Left = 92
    Top = 180
  end
  object RunPopup: TPopupMenu
    Left = 60
    Top = 4
    object OpeninIDE1: TMenuItem
      Action = ActionRun
      Default = True
    end
    object Runinconsole1: TMenuItem
      Action = ActionRunConsole
    end
    object GotoPHPdir1: TMenuItem
      Action = ActionGoToPHPDir
    end
    object PHPShell1: TMenuItem
      Action = ActionPHPInteractiveShell
    end
    object ChooseanotherPHPinterpreter1: TMenuItem
      Caption = 'Choose another PHP interpreter...'
      OnClick = ChooseanotherPHPinterpreter1Click
    end
    object ChooseanotherCHMhelpfile1: TMenuItem
      Caption = 'Choose another CHM help file...'
      OnClick = ChooseanotherCHMhelpfile1Click
    end
  end
  object SavePopup: TPopupMenu
    Left = 196
    Top = 28
    object Save1: TMenuItem
      Action = ActionSave
      Default = True
    end
    object Saveas1: TMenuItem
      Action = ActionSaveAs
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'php'
    FileName = 'scrap.php'
    Filter = 
      'All PHP files (*.php*;*.phtml;*.inc;*.xphp)|*.php*;*.phtml;*.inc' +
      ';*.xphp|PHP files (*.php*;*.phtml)|*.php*;*.phtml|Include files ' +
      '(*.inc)|*.inc|PHP source files (*.phps)|*.phps|Executable PHP fi' +
      'le (*.xphp)|*.xphp|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save as...'
    Left = 608
    Top = 320
  end
  object StartUpTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = StartUpTimerTimer
    Left = 712
    Top = 56
  end
  object FileModTimer: TTimer
    Enabled = False
    OnTimer = FileModTimerTimer
    Left = 356
    Top = 276
  end
  object FontSizeTimer: TTimer
    OnTimer = FontSizeTimerTimer
    Left = 60
    Top = 460
  end
end
