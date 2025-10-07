object LocalizerForm: TLocalizerForm
  Left = 628
  Top = 127
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Localizer'
  ClientHeight = 160
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlControlName: TPanel
    Left = 0
    Top = 0
    Width = 340
    Height = 33
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = 'ComponentName'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object pnlOk: TPanel
    Left = 0
    Top = 126
    Width = 340
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOk: TButton
      Left = 133
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOkClick
    end
  end
  object scbProps: TScrollBox
    Left = 0
    Top = 33
    Width = 340
    Height = 93
    VertScrollBar.Smooth = True
    VertScrollBar.Tracking = True
    Align = alClient
    BevelEdges = []
    BevelInner = bvLowered
    BevelOuter = bvRaised
    BevelKind = bkSoft
    BevelWidth = 3
    TabOrder = 2
  end
end
