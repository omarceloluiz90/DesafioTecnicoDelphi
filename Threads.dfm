object fThreads: TfThreads
  Left = 0
  Top = 0
  Caption = 'Threads'
  ClientHeight = 201
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  DesignSize = (
    447
    201)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 15
    Top = 8
    Width = 94
    Height = 13
    Caption = 'N'#250'mero de Threads'
  end
  object Label2: TLabel
    Left = 156
    Top = 8
    Width = 129
    Height = 13
    Caption = 'Tempo de Espera (MiliSec.)'
  end
  object edtNroThreads: TEdit
    Left = 15
    Top = 27
    Width = 135
    Height = 21
    TabOrder = 0
  end
  object edtTempoEspera: TEdit
    Left = 156
    Top = 27
    Width = 135
    Height = 21
    TabOrder = 1
  end
  object ProgressBar: TProgressBar
    AlignWithMargins = True
    Left = 3
    Top = 181
    Width = 441
    Height = 17
    Align = alBottom
    TabOrder = 4
  end
  object mmTexto: TMemo
    Left = 15
    Top = 54
    Width = 418
    Height = 121
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object btnIniciar: TButton
    Left = 297
    Top = 23
    Width = 100
    Height = 25
    Caption = 'INICIAR'
    TabOrder = 2
    OnClick = btnIniciarClick
  end
end
