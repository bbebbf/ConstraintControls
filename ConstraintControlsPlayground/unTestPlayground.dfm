object fmTestPlayground: TfmTestPlayground
  Left = 0
  Top = 0
  Caption = 'fmTestPlayground'
  ClientHeight = 288
  ClientWidth = 478
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object DateEdit1: TDateEdit
    Left = 144
    Top = 72
    Width = 121
    Height = 23
    TabOrder = 0
  end
  object cbOptionalYear: TCheckBox
    Left = 144
    Top = 152
    Width = 97
    Height = 17
    Caption = 'Optional Year'
    TabOrder = 1
    OnClick = cbOptionalYearClick
  end
end
