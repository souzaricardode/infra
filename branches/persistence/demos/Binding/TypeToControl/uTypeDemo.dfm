object Form1: TForm1
  Left = 376
  Top = 163
  Width = 554
  Height = 282
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 8
    Top = 147
    Width = 64
    Height = 13
    Caption = 'Person.Name'
  end
  object Label1: TLabel
    Left = 8
    Top = 171
    Width = 72
    Height = 13
    Caption = 'Person.Country'
  end
  object Label3: TLabel
    Left = 216
    Top = 147
    Width = 32
    Height = 13
    Caption = 'Label3'
  end
  object Label4: TLabel
    Left = 216
    Top = 171
    Width = 32
    Height = 13
    Caption = 'Label4'
  end
  object Label5: TLabel
    Left = 112
    Top = 192
    Width = 32
    Height = 13
    Caption = 'Label5'
  end
  object Memo2: TMemo
    Left = 8
    Top = 8
    Width = 529
    Height = 125
    Ctl3D = False
    Lines.Strings = (
      'Simple example how to bind InfraType to Control'
      'DataContext =  Person'
      '1) Person.Name <-> Edit3.Text'
      '2) Person.Country <-> Edit1.Text'
      '3) Person.Name <-> Label3.Caption'
      '4) Person.Country <-> Label4.Caption '
      '5) Person.Active <-> CheckBox1.Checked '
      
        '6) Person.Active <-> CheckBox1.Caption  [TBooleanToTextConverter' +
        ']'
      '7) Person.Active <-> Label5.Caption [TBooleanToTextConverter]')
    ParentCtl3D = False
    TabOrder = 0
  end
  object Edit3: TEdit
    Left = 88
    Top = 144
    Width = 121
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
    Text = 'Edit3'
  end
  object Edit1: TEdit
    Left = 88
    Top = 168
    Width = 121
    Height = 19
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
    Text = 'Edit1'
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 190
    Width = 97
    Height = 17
    Caption = 'Person.Active'
    TabOrder = 3
  end
  object Button1: TButton
    Left = 8
    Top = 216
    Width = 172
    Height = 25
    Caption = 'Set Person.Name by Code'
    TabOrder = 4
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 186
    Top = 216
    Width = 172
    Height = 25
    Caption = 'Set Person.Country by Code'
    TabOrder = 5
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 365
    Top = 216
    Width = 172
    Height = 25
    Caption = 'Togle Person.Active by Code'
    TabOrder = 6
    OnClick = Button3Click
  end
end
