object SetupForm: TSetupForm
  Left = 407
  Top = 234
  ActiveControl = chkCompression
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Advanced options'
  ClientHeight = 364
  ClientWidth = 271
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 1
    Top = 256
    Width = 268
    Height = 78
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    object lblCommands: TLabel
      Left = 12
      Top = 8
      Width = 128
      Height = 13
      Caption = 'Additional UPX commands:'
    end
    object chkCommands: TCheckBox
      Left = 8
      Top = 54
      Width = 177
      Height = 17
      Hint = 'Allways use the entered commands'
      Caption = 'Save commands'
      TabOrder = 2
    end
    object txtCommands: TEdit
      Left = 6
      Top = 28
      Width = 256
      Height = 21
      TabOrder = 1
      OnChange = txtCommandsChange
    end
    object btnCommands: TButton
      Left = 189
      Top = 52
      Width = 75
      Height = 21
      Caption = 'Commands'
      TabOrder = 0
      OnClick = btnCommandsClick
    end
  end
  object btnOk: TButton
    Left = 98
    Top = 337
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
  end
  object pnlTop: TPanel
    Left = 1
    Top = 2
    Width = 268
    Height = 48
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object chkScramble: TCheckBox
      Left = 7
      Top = 8
      Width = 178
      Height = 17
      Hint = 'Scramble files compressed with UPX'
      Caption = 'Use file Scrambler'
      TabOrder = 0
    end
    object btnScramble: TButton
      Left = 189
      Top = 3
      Width = 75
      Height = 21
      Hint = 'Scramble the selected file now'
      Caption = 'Scramble'
      TabOrder = 1
      OnClick = btnScrambleClick
    end
    object chkIntegrate: TCheckBox
      Left = 8
      Top = 24
      Width = 241
      Height = 17
      Hint = 'Add '#39'Compress with UPX'#39' option to Explorer left-click menu'
      Caption = 'Integrate into context menu'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = chkIntegrateClick
    end
  end
  object pnlMiddle: TPanel
    Left = 1
    Top = 53
    Width = 268
    Height = 128
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object lblAdvacedOpts: TLabel
      Left = 8
      Top = 8
      Width = 114
      Height = 13
      Caption = 'Advanced UPX options:'
      Transparent = True
    end
    object lblPriority: TLabel
      Left = 144
      Top = 14
      Width = 70
      Height = 13
      Caption = 'Packer priority:'
      Transparent = True
    end
    object lblIcons: TLabel
      Left = 144
      Top = 54
      Width = 29
      Height = 13
      Caption = 'Icons:'
    end
    object lblCompression: TLabel
      Tag = -1
      Left = 228
      Top = 98
      Width = 30
      Height = 13
      Alignment = taRightJustify
      Caption = '10000'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object bvlCompressor: TBevel
      Left = 0
      Top = 96
      Width = 268
      Height = 2
    end
    object chkForce: TCheckBox
      Left = 8
      Top = 78
      Width = 129
      Height = 17
      Hint = 'Force compression of suspicious files'
      Caption = 'Force compression'
      TabOrder = 3
    end
    object chkResources: TCheckBox
      Left = 8
      Top = 27
      Width = 129
      Height = 17
      Hint = 'Compress resources (better compression)'
      Caption = 'Compress resources'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkRelocs: TCheckBox
      Left = 8
      Top = 61
      Width = 129
      Height = 17
      Hint = 'Strip relocations'
      Caption = 'Strip relocations'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object cmbPriority: TComboBox
      Left = 140
      Top = 30
      Width = 125
      Height = 21
      Hint = 'Select packer process priority'
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 1
      TabOrder = 4
      Text = 'NORMAL (default)'
      Items.Strings = (
        'IDLE'
        'NORMAL (default)'
        'HIGH'
        'REALTIME')
    end
    object cmbIcons: TComboBox
      Left = 140
      Top = 70
      Width = 125
      Height = 21
      Hint = 'Select what to do with icons'
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 2
      TabOrder = 5
      Text = 'Don'#39't compress'
      Items.Strings = (
        'All but 1st directory'
        'All but 1st icon'
        'Don'#39't compress')
    end
    object chkExports: TCheckBox
      Left = 8
      Top = 44
      Width = 129
      Height = 17
      Hint = 'Compress exports'
      Caption = 'Compress exports'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object trbCompression: TTrackBar
      Left = 160
      Top = 109
      Width = 105
      Height = 15
      Hint = 
        'The higher the setting, the more memory required to *compress* t' +
        'he file'
      Enabled = False
      LineSize = 10000
      Max = 999999
      Min = 10000
      PageSize = 50000
      Frequency = 100000
      Position = 10000
      TabOrder = 7
      ThumbLength = 15
      TickStyle = tsNone
      OnChange = trbCompressionChange
    end
    object chkCompression: TCheckBox
      Left = 8
      Top = 104
      Width = 152
      Height = 17
      Hint = 
        'Improves compression ratio, but uses more memory while compressi' +
        'ng'
      Caption = 'Additional compression'
      TabOrder = 6
      OnClick = chkCompressionClick
    end
  end
  object pnlUpx2: TPanel
    Left = 1
    Top = 182
    Width = 268
    Height = 71
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object lblUpx2Only: TLabel
      Left = 8
      Top = 4
      Width = 65
      Height = 13
      Caption = 'UPX v2.0x:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblUpx3Only: TLabel
      Left = 136
      Top = 4
      Width = 94
      Height = 13
      Caption = 'UPX v3.0x Only:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object chkBrute: TCheckBox
      Left = 8
      Top = 18
      Width = 129
      Height = 17
      Hint = 
        'Brute is an abbrevation for the options --best, --all-methods, -' +
        '-all-filters and Additional compression=999999'
      Caption = 'Brute'
      TabOrder = 0
      OnClick = chkBruteClick
    end
    object chkMethods: TCheckBox
      Left = 8
      Top = 34
      Width = 129
      Height = 17
      Hint = 
        'Compress the program several times, using all available compress' +
        'ion methods.'#13#10'This may improve the compression ratio in some cas' +
        'es,'#13#10'but usually the default method gives the best results anywa' +
        'y.'
      Caption = 'All Methods'
      TabOrder = 1
    end
    object chkFilters: TCheckBox
      Left = 8
      Top = 50
      Width = 129
      Height = 17
      Hint = 
        'Compress the program several times, using all available compress' +
        'ion methods.'#13#10'This may improve the compression ratio in some cas' +
        'es,'#13#10'but usually the default method gives the best results anywa' +
        'y.'
      Caption = 'All Filters'
      TabOrder = 2
    end
    object chkLZMA: TCheckBox
      Left = 136
      Top = 18
      Width = 129
      Height = 17
      Hint = 'This uses the NEW LZMA feature'
      Caption = 'Use LZMA'
      TabOrder = 3
    end
    object chkUltraBrute: TCheckBox
      Left = 136
      Top = 34
      Width = 129
      Height = 17
      Hint = 
        'Ultra Brute is almoste the same as Brute, but it tries more vari' +
        'ants of compression.'
      Caption = 'Ultra Brute'
      TabOrder = 4
      OnClick = chkUltraBruteClick
    end
  end
end
