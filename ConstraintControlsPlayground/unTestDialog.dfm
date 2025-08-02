object fmTestDialog: TfmTestDialog
  Left = 0
  Top = 0
  Caption = 'fmTestDialog'
  ClientHeight = 370
  ClientWidth = 391
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object btCorfirm: TButton
    Left = 24
    Top = 328
    Width = 75
    Height = 25
    Caption = 'btCorfirm'
    ModalResult = 1
    TabOrder = 0
  end
  object btCancel: TButton
    Left = 296
    Top = 328
    Width = 75
    Height = 25
    Caption = 'btCancel'
    ModalResult = 2
    TabOrder = 1
  end
  object DateEdit1: TDateEdit
    Left = 128
    Top = 104
    Width = 121
    Height = 23
    TabOrder = 2
  end
end
