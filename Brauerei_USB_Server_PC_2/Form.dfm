object MainForm: TMainForm
  Left = 488
  Top = 137
  Width = 498
  Height = 246
  Caption = 'Brauerei Arduino USB Server'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefaultPosOnly
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 234
    Top = 184
    Width = 3
    Height = 13
  end
  object Label2: TLabel
    Left = 234
    Top = 168
    Width = 3
    Height = 13
  end
  object Label3: TLabel
    Left = 232
    Top = 72
    Width = 169
    Height = 13
    Caption = 'Speicherort der Temperaturlogdatei:'
  end
  object Label4: TLabel
    Left = 232
    Top = 120
    Width = 191
    Height = 13
    Caption = 'Speicherort der Displaxinformationsdatei:'
  end
  object Mem_Rcv: TMemo
    Left = 8
    Top = 8
    Width = 209
    Height = 193
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    OnChange = Mem_RcvChange
  end
  object ComboBox1: TComboBox
    Left = 232
    Top = 8
    Width = 105
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    Text = 'COM4'
    OnChange = ComboBox1Change
    Items.Strings = (
      'COM1'
      'COM2'
      'COM3'
      'COM4'
      'COM5'
      'COM6'
      'COM7'
      'COM8'
      'COM9'
      'COM10'
      'COM11'
      'COM12'
      'COM13'
      'COM14'
      'COM15'
      'COM16'
      'COM17'
      'COM18'
      'COM19'
      'COM20')
  end
  object ComboBox2: TComboBox
    Left = 232
    Top = 40
    Width = 105
    Height = 21
    ItemHeight = 13
    TabOrder = 2
    Text = 'NTC10000'
    Items.Strings = (
      'NTC10000'
      'DS18B20'
      'Display')
  end
  object Button1: TButton
    Left = 344
    Top = 8
    Width = 129
    Height = 49
    Caption = 'Settings speichern'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 232
    Top = 88
    Width = 241
    Height = 21
    TabOrder = 4
    Text = 'C:\Brauerei\Temperatur\log.txt'
  end
  object Edit2: TEdit
    Left = 232
    Top = 136
    Width = 241
    Height = 21
    TabOrder = 5
    Text = 'C:\Brauerei\Display\display.txt'
  end
  object CheckBox1: TCheckBox
    Left = 360
    Top = 184
    Width = 113
    Height = 17
    Caption = 'Log-'#220'berwachung'
    Checked = True
    State = cbChecked
    TabOrder = 6
    OnClick = CheckBox1Click
  end
  object Tmr_Rcv: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Tmr_RcvTimer
    Left = 56
    Top = 16
  end
  object Timer1: TTimer
    Interval = 60000
    OnTimer = Timer1Timer
    Left = 96
    Top = 16
  end
end
