object CommandsForm: TCommandsForm
  Left = 330
  Top = 242
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'UPX Commands'
  ClientHeight = 592
  ClientWidth = 611
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 13
  object pgcCommands: TPageControl
    Left = 0
    Top = 0
    Width = 611
    Height = 592
    Hint = 'cl'
    ActivePage = tbsUPX3
    Align = alClient
    TabOrder = 0
    object tbsUPX1: TTabSheet
      object mmoUPX1: TMemo
        Left = 0
        Top = 0
        Width = 603
        Height = 564
        Cursor = crArrow
        Align = alClient
        BorderStyle = bsNone
        Color = cl3DLight
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        WantReturns = False
      end
    end
    object tbsUPX2: TTabSheet
      ImageIndex = 1
      object mmoUPX2: TMemo
        Left = 0
        Top = 0
        Width = 603
        Height = 564
        Cursor = crArrow
        Align = alClient
        BorderStyle = bsNone
        Color = cl3DLight
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        WantReturns = False
      end
    end
    object tbsUPX3: TTabSheet
      ImageIndex = 2
      object mmoUPX3: TMemo
        Left = 0
        Top = 0
        Width = 603
        Height = 564
        Cursor = crArrow
        Align = alClient
        BorderStyle = bsNone
        Color = cl3DLight
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        WantReturns = False
      end
    end
  end
end
