inherited MainForm: TMainForm
  Left = 368
  Height = 448
  Top = 368
  Width = 995
  BorderStyle = bsNone
  Caption = 'MainForm'
  ClientHeight = 448
  ClientWidth = 995
  Color = clWhite
  KeyPreview = True
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  Position = poScreenCenter
  WindowState = wsMaximized
  object PanelBottom: TPanel[0]
    Left = 0
    Height = 30
    Top = 418
    Width = 995
    Align = alBottom
    BevelOuter = bvNone
    Color = 3678006
    ParentColor = False
    TabOrder = 0
  end
  object PanelTop: TPanel[1]
    Left = 0
    Height = 52
    Top = 0
    Width = 995
    Align = alTop
    BevelOuter = bvNone
    Color = 12577023
    ParentColor = False
    TabOrder = 1
  end
  object PanelWork: TPanel[2]
    Left = 0
    Height = 362
    Top = 54
    Width = 995
    Align = alClient
    BorderSpacing.Top = 2
    BorderSpacing.Bottom = 2
    BevelOuter = bvNone
    ClientHeight = 362
    ClientWidth = 995
    TabOrder = 2
    object PanelRightHint: TPanel
      Left = 983
      Height = 362
      Top = 0
      Width = 12
      Align = alRight
      BorderSpacing.Left = 2
      BevelOuter = bvNone
      ParentColor = False
      TabOrder = 0
    end
    object PanelRight: TPanel
      Left = 817
      Height = 362
      Top = 0
      Width = 164
      Align = alRight
      BorderSpacing.Left = 2
      BevelOuter = bvNone
      ClientHeight = 362
      ClientWidth = 164
      ParentColor = False
      TabOrder = 1
      object Panel1: TPanel
        Left = 16
        Height = 40
        Top = 8
        Width = 60
        Caption = 'Panel1'
        TabOrder = 0
        OnClick = Panel1Click
      end
      object Panel2: TPanel
        Left = 88
        Height = 40
        Top = 8
        Width = 60
        Caption = 'Panel2'
        TabOrder = 1
        OnClick = Panel2Click
      end
      object Panel3: TPanel
        Left = 16
        Height = 40
        Top = 56
        Width = 60
        Caption = 'Panel3'
        TabOrder = 2
        OnClick = Panel3Click
      end
      object Panel4: TPanel
        Left = 88
        Height = 40
        Top = 56
        Width = 60
        Caption = 'Panel4'
        TabOrder = 3
        OnClick = Panel4Click
      end
      object Panel5: TPanel
        Left = 16
        Height = 50
        Top = 112
        Width = 98
        Caption = 'Panel5'
        TabOrder = 4
        OnClick = Panel5Click
      end
      object Panel6: TPanel
        Left = 8
        Height = 24
        Top = 216
        Width = 82
        Caption = 'Panel6'
        TabOrder = 5
        OnClick = Panel6Click
      end
      object Panel7: TPanel
        Left = 8
        Height = 26
        Top = 184
        Width = 82
        Caption = 'Panel7'
        TabOrder = 6
        OnClick = Panel7Click
      end
    end
    object PanelClient: TPanel
      Left = 0
      Height = 362
      Top = 0
      Width = 815
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
    end
  end
end