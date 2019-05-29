object FormProducts: TFormProducts
  Left = 0
  Top = 0
  Caption = 'FormProducts'
  ClientHeight = 387
  ClientWidth = 837
  Color = clWhite
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    837
    387)
  PixelsPerInch = 96
  TextHeight = 21
  object StringGrid1: TStringGrid
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 831
    Height = 351
    Align = alClient
    BorderStyle = bsNone
    ColCount = 4
    DefaultDrawing = False
    FixedColor = clBackground
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    GradientEndColor = clBlack
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    TabOrder = 0
    OnDrawCell = StringGrid1DrawCell
    OnSelectCell = StringGrid1SelectCell
    OnSetEditText = StringGrid1SetEditText
    ExplicitLeft = -237
    ExplicitTop = -104
    ExplicitWidth = 872
    ExplicitHeight = 404
    ColWidths = (
      64
      64
      64
      64)
    RowHeights = (
      24)
  end
  object PanelError: TPanel
    Left = 0
    Top = 357
    Width = 837
    Height = 30
    Align = alBottom
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Caption = #1054#1096#1080#1073#1082#1072
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 1
    Visible = False
    ExplicitLeft = -243
    ExplicitTop = 270
    ExplicitWidth = 878
  end
  object ComboBox1: TComboBox
    Left = 422
    Top = 87
    Width = 145
    Height = 24
    BevelInner = bvNone
    BevelOuter = bvNone
    Style = csOwnerDrawFixed
    Anchors = []
    Color = clGradientInactiveCaption
    ItemHeight = 18
    ItemIndex = 0
    TabOrder = 2
    Text = 'COM1'
    Visible = False
    OnCloseUp = ComboBox1CloseUp
    OnExit = ComboBox2Exit
    Items.Strings = (
      'COM1')
    ExplicitLeft = 303
    ExplicitTop = 65
  end
  object ComboBox2: TComboBox
    Left = 669
    Top = 65
    Width = 145
    Height = 24
    BevelInner = bvNone
    BevelOuter = bvNone
    Style = csOwnerDrawFixed
    Anchors = []
    Color = clGradientInactiveCaption
    ItemHeight = 18
    TabOrder = 3
    Visible = False
    OnCloseUp = ComboBox2CloseUp
    OnExit = ComboBox2Exit
    Items.Strings = (
      ''
      '2'
      '3')
    ExplicitLeft = 490
    ExplicitTop = 48
  end
end
