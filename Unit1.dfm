object DBCreate: TDBCreate
  Left = 238
  Top = 237
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Update DataBases Virus v1.0.0.1     -= StalkerSTS =-'
  ClientHeight = 582
  ClientWidth = 879
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btn2: TSpeedButton
    Left = 772
    Top = 11
    Width = 33
    Height = 23
    Caption = 'add'
    OnClick = btn2Click
  end
  object btn3: TSpeedButton
    Left = 809
    Top = 11
    Width = 29
    Height = 23
    Caption = 'del'
    OnClick = btn3Click
  end
  object btn4: TSpeedButton
    Left = 840
    Top = 11
    Width = 31
    Height = 23
    Caption = 'save'
    OnClick = btn4Click
  end
  object DBListView: TListView
    Left = -49
    Top = 42
    Width = 929
    Height = 435
    Columns = <
      item
        Caption = #1058#1080#1087
      end
      item
        Caption = #1048#1084#1103
        Width = 350
      end
      item
        Caption = #1057#1080#1075#1085#1072#1090#1091#1088#1072
        Width = 500
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnClick = DBListViewClick
  end
  object pb1: TProgressBar
    Left = 8
    Top = 11
    Width = 720
    Height = 22
    TabOrder = 1
  end
  object grp1: TGroupBox
    Left = 0
    Top = 477
    Width = 879
    Height = 105
    Align = alBottom
    Caption = 'Log'
    TabOrder = 2
    object mmo1: TMemo
      Left = 2
      Top = 15
      Width = 423
      Height = 88
      Align = alLeft
      ImeName = 'Russian'
      ScrollBars = ssBoth
      TabOrder = 0
    end
    object mmo2: TMemo
      Left = 432
      Top = 15
      Width = 445
      Height = 88
      Align = alRight
      ImeName = 'Russian'
      ScrollBars = ssBoth
      TabOrder = 1
    end
  end
  object UPD: TCheckBox
    Left = 731
    Top = 14
    Width = 39
    Height = 17
    Hint = #1054#1073#1103#1079#1072#1090#1077#1083#1100#1085#1086#1077' '#1076#1086#1073#1072#1074#1083#1077#1085#1080#1077' '#1074#1080#1088#1091#1089#1086#1074' '#1074' '#1073#1072#1079#1091' ...'
    Caption = 'UPD'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
end
