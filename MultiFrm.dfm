object MultiForm: TMultiForm
  Left = 238
  Top = 108
  Width = 394
  Height = 350
  ActiveControl = btnBrowse
  BorderIcons = []
  Caption = 'MultiPack'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  ShowHint = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpSearch: TGroupBox
    Left = 0
    Top = 0
    Width = 378
    Height = 59
    Align = alTop
    Caption = 'Search Path:'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object lblDir: TLabel
      Left = 8
      Top = 17
      Width = 297
      Height = 17
      AutoSize = False
      Caption = 'N/A'
    end
    object btnBrowse: TButton
      Left = 310
      Top = 14
      Width = 65
      Height = 22
      Caption = '&Browse'
      TabOrder = 0
      OnClick = btnBrowseClick
    end
    object chkRecurse: TCheckBox
      Left = 192
      Top = 40
      Width = 185
      Height = 17
      Caption = '&Recurse subdirectories'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object cmbType: TComboBox
      Left = 11
      Top = 35
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 2
      Text = '*.exe (Executable)'
      Items.Strings = (
        '*.exe (Executable)'
        '*.dll (Dynamic Library)'
        '*.com (Command)'
        '*.sys (System)'
        '*.ocx (ActiveX)'
        '*.dpl (Delphi library)'
        '*.bpl (Delphi library)'
        '*.scr (Screen Saver)'
        '*.acm (ACM Codec)'
        '*.ax (ACM/AX Codec)'
        '*.*  (Any file)')
    end
  end
  object lvFiles: TListView
    Left = 0
    Top = 59
    Width = 378
    Height = 166
    Hint = 
      'Press '#39'Del'#39' or right-click an item to skip it from being process' +
      'ed'
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    Color = 14872561
    Columns = <
      item
        Caption = 'File Name'
        Width = 100
      end
      item
        Caption = 'Folder'
        Width = 100
      end
      item
        Caption = 'Size'
        Width = 55
      end
      item
        Caption = 'Packed'
        Width = 55
      end
      item
        Caption = 'Result'
      end>
    ColumnClick = False
    FlatScrollBars = True
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnKeyUp = lvFilesKeyUp
    OnMouseDown = lvFilesMouseDown
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 225
    Width = 378
    Height = 89
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object lblCurrent: TLabel
      Left = 0
      Top = 25
      Width = 118
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Current file:'
      ParentShowHint = False
      ShowHint = True
    end
    object lblOverall: TLabel
      Left = 0
      Top = 41
      Width = 118
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Overall progress:'
      ParentShowHint = False
      ShowHint = True
    end
    object lblTotalCap: TLabel
      Left = 43
      Top = 5
      Width = 48
      Height = 13
      Caption = 'Total files:'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      Visible = False
    end
    object lblSelectedCap: TLabel
      Left = 152
      Top = 5
      Width = 45
      Height = 13
      Caption = 'Selected:'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      Visible = False
    end
    object lblTimeCap: TLabel
      Left = 262
      Top = 5
      Width = 56
      Height = 13
      Caption = 'Time taken:'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      Visible = False
    end
    object lblTotal: TLabel
      Tag = -1
      Left = 97
      Top = 5
      Width = 6
      Height = 13
      Caption = '0'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      Visible = False
    end
    object lblSelected: TLabel
      Tag = -1
      Left = 203
      Top = 5
      Width = 6
      Height = 13
      Caption = '0'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      Visible = False
    end
    object lblTime: TLabel
      Tag = -1
      Left = 325
      Top = 5
      Width = 20
      Height = 13
      Caption = 'N/A'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      Visible = False
    end
    object btnPack: TButton
      Left = 155
      Top = 62
      Width = 75
      Height = 25
      Caption = '&Pack'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = btnPackClick
    end
    object btnExit: TButton
      Left = 275
      Top = 62
      Width = 75
      Height = 25
      Cancel = True
      Caption = '&Exit'
      ModalResult = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object btnScan: TButton
      Left = 35
      Top = 62
      Width = 75
      Height = 25
      Caption = '&Scan'
      Default = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = btnScanClick
    end
    object pnlCurrent: TPanel
      Left = 124
      Top = 24
      Width = 254
      Height = 16
      AutoSize = True
      BevelInner = bvLowered
      Caption = 'pnlCurrent'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      object pgbCurrent: TGauge
        Left = 2
        Top = 2
        Width = 250
        Height = 12
        BackColor = clBtnFace
        BorderStyle = bsNone
        ForeColor = 9981440
        ParentShowHint = False
        Progress = 0
        ShowHint = True
      end
      object sttRatio: TStaticText
        Left = 2
        Top = 2
        Width = 0
        Height = 12
        AutoSize = False
        BorderStyle = sbsSunken
        Color = 13680800
        ParentColor = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
    end
    object pnlOverall: TPanel
      Left = 124
      Top = 40
      Width = 254
      Height = 16
      AutoSize = True
      BevelInner = bvLowered
      Caption = 'ProgressPan'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      object pgbOverall: TGauge
        Left = 2
        Top = 2
        Width = 250
        Height = 12
        BackColor = clBtnFace
        BorderStyle = bsNone
        ForeColor = 9981440
        ParentShowHint = False
        Progress = 0
        ShowHint = True
      end
    end
  end
end
