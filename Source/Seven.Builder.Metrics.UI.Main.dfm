object FormMainMetrics: TFormMainMetrics
  Left = 0
  Top = 0
  Caption = 'Seven Builder Metrics - Análise Estática de Código Delphi'
  ClientHeight = 720
  ClientWidth = 980
  Color = 2825487
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 980
    Height = 70
    Align = alTop
    BevelOuter = bvNone
    Color = 3348752
    ParentBackground = False
    TabOrder = 0
    object lblTitle: TLabel
      Left = 20
      Top = 12
      Width = 330
      Height = 25
      Caption = 'Seven Builder Metrics - Delphi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16301816
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitle: TLabel
      Left = 20
      Top = 40
      Width = 460
      Height = 17
      Caption = 'Análise Estática de Métricas de Código, Complexidade Ciclomática e Evolução Git'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13420490
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlTarget: TPanel
    Left = 0
    Top = 70
    Width = 980
    Height = 100
    Align = alTop
    BevelOuter = bvNone
    Color = 2101786
    ParentBackground = False
    TabOrder = 1
    object lblTargetPath: TLabel
      Left = 20
      Top = 64
      Width = 144
      Height = 15
      Caption = 'Caminho do Projeto (.dproj):'
      Font.Color = clWhite
    end
    object grpTargetType: TGroupBox
      Left = 20
      Top = 8
      Width = 940
      Height = 48
      Caption = ' Seleção de Alvo para Análise '
      Font.Color = 16301816
      ParentFont = False
      TabOrder = 0
      object rbProject: TRadioButton
        Left = 16
        Top = 20
        Width = 160
        Height = 20
        Caption = 'Projeto (.dproj)'
        Checked = True
        Font.Color = clWhite
        ParentFont = False
        TabOrder = 0
        TabStop = True
        OnClick = rbTargetTypeClick
      end
      object rbGroupProject: TRadioButton
        Left = 200
        Top = 20
        Width = 200
        Height = 20
        Caption = 'Grupo de Projetos (.groupproj)'
        Font.Color = clWhite
        ParentFont = False
        TabOrder = 1
        OnClick = rbTargetTypeClick
      end
      object rbDirectory: TRadioButton
        Left = 430
        Top = 20
        Width = 180
        Height = 20
        Caption = 'Pasta / Diretório completo'
        Font.Color = clWhite
        ParentFont = False
        TabOrder = 2
        OnClick = rbTargetTypeClick
      end
    end
    object edtTargetPath: TEdit
      Left = 200
      Top = 61
      Width = 630
      Height = 23
      TabOrder = 1
    end
    object btnBrowseTarget: TButton
      Left = 836
      Top = 60
      Width = 35
      Height = 25
      Caption = '...'
      TabOrder = 2
      OnClick = btnBrowseTargetClick
    end
    object btnListFiles: TButton
      Left = 877
      Top = 60
      Width = 83
      Height = 25
      Caption = 'Listar'
      TabOrder = 3
      OnClick = btnListFilesClick
    end
  end
  object pgcOptions: TPageControl
    Left = 0
    Top = 170
    Width = 980
    Height = 145
    ActivePage = tsReports
    Align = alTop
    TabOrder = 2
    object tsReports: TTabSheet
      Caption = 'Saídas & Dashboards'
      object chkExportJson: TCheckBox
        Left = 16
        Top = 16
        Width = 160
        Height = 20
        Caption = 'Exportar Relatório JSON:'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object edtJsonPath: TEdit
        Left = 180
        Top = 15
        Width = 660
        Height = 23
        TabOrder = 1
      end
      object btnBrowseJson: TButton
        Left = 846
        Top = 14
        Width = 35
        Height = 25
        Caption = '...'
        TabOrder = 2
        OnClick = btnBrowseJsonClick
      end
      object chkGenerateHtml: TCheckBox
        Left = 16
        Top = 52
        Width = 160
        Height = 20
        Caption = 'Gerar Dashboard HTML:'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object edtHtmlPath: TEdit
        Left = 180
        Top = 51
        Width = 660
        Height = 23
        TabOrder = 4
      end
      object btnBrowseHtml: TButton
        Left = 846
        Top = 50
        Width = 35
        Height = 25
        Caption = '...'
        TabOrder = 5
        OnClick = btnBrowseHtmlClick
      end
      object btnOpenHtml: TButton
        Left = 887
        Top = 50
        Width = 73
        Height = 25
        Caption = 'Abrir HTML'
        TabOrder = 6
        OnClick = btnOpenHtmlClick
      end
    end
    object tsGit: TTabSheet
      Caption = 'Evolução Temporal Git'
      ImageIndex = 1
      object lblGitRepo: TLabel
        Left = 16
        Top = 46
        Width = 117
        Height = 15
        Caption = 'Repositório Git (Pasta):'
      end
      object lblGitCommits: TLabel
        Left = 16
        Top = 78
        Width = 138
        Height = 15
        Caption = 'Qtd. Commits a Analisar:'
      end
      object chkEnableGit: TCheckBox
        Left = 16
        Top = 14
        Width = 280
        Height = 20
        Caption = 'Habilitar Análise de Evolução Histórica no Git'
        TabOrder = 0
      end
      object edtGitRepoPath: TEdit
        Left = 160
        Top = 43
        Width = 680
        Height = 23
        TabOrder = 1
      end
      object btnBrowseGitRepo: TButton
        Left = 846
        Top = 42
        Width = 35
        Height = 25
        Caption = '...'
        TabOrder = 2
        OnClick = btnBrowseGitRepoClick
      end
      object edtGitCommits: TEdit
        Left = 160
        Top = 75
        Width = 80
        Height = 23
        TabOrder = 3
        Text = '20'
      end
    end
    object tsDatabase: TTabSheet
      Caption = 'Banco de Dados (PostgreSQL / Breeze)'
      ImageIndex = 2
      object lblVersionCode: TLabel
        Left = 16
        Top = 46
        Width = 92
        Height = 15
        Caption = 'Código da Versão:'
      end
      object lblVersionDate: TLabel
        Left = 260
        Top = 46
        Width = 80
        Height = 15
        Caption = 'Data da Versão:'
      end
      object lblIniConfig: TLabel
        Left = 16
        Top = 78
        Width = 132
        Height = 15
        Caption = 'Configuração (db_config.ini):'
      end
      object chkEnableDb: TCheckBox
        Left = 16
        Top = 14
        Width = 320
        Height = 20
        Caption = 'Salvar Métricas no Banco de Dados (PostgreSQL)'
        TabOrder = 0
      end
      object edtVersionCode: TEdit
        Left = 120
        Top = 43
        Width = 120
        Height = 23
        TabOrder = 1
        Text = '1.0.0'
      end
      object dtpVersionDate: TDateTimePicker
        Left = 350
        Top = 43
        Width = 120
        Height = 23
        Date = 46246.000000000000000000
        Time = 0.000000000000000000
        TabOrder = 2
      end
      object edtIniConfigPath: TEdit
        Left = 160
        Top = 75
        Width = 680
        Height = 23
        TabOrder = 3
      end
      object btnBrowseIniConfig: TButton
        Left = 846
        Top = 74
        Width = 35
        Height = 25
        Caption = '...'
        TabOrder = 4
        OnClick = btnBrowseIniConfigClick
      end
    end
  end
  object pnlAction: TPanel
    Left = 0
    Top = 315
    Width = 980
    Height = 55
    Align = alTop
    BevelOuter = bvNone
    Color = 2101786
    ParentBackground = False
    TabOrder = 3
    object btnExecute: TButton
      Left = 20
      Top = 10
      Width = 940
      Height = 35
      Caption = 'EXECUTAR ANÁLISE ESTÁTICA DE CÓDIGO'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnExecuteClick
    end
  end
  object pbProgress: TProgressBar
    Left = 0
    Top = 370
    Width = 980
    Height = 8
    Align = alTop
    TabOrder = 4
  end
  object pgcResults: TPageControl
    Left = 0
    Top = 378
    Width = 980
    Height = 262
    ActivePage = tsFiles
    Align = alClient
    TabOrder = 5
    object tsFiles: TTabSheet
      Caption = 'Lista de Arquivos Fontes Analisados'
      object lsvFiles: TListView
        Left = 0
        Top = 0
        Width = 972
        Height = 232
        Align = alClient
        Columns = <>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object tsHotspots: TTabSheet
      Caption = 'Top 10 Hotspots (Arquivos Mais Complexos)'
      ImageIndex = 1
      object lsvHotspots: TListView
        Left = 0
        Top = 0
        Width = 972
        Height = 232
        Align = alClient
        Columns = <>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
  end
  object pnlFooterKpi: TPanel
    Left = 0
    Top = 640
    Width = 980
    Height = 80
    Align = alBottom
    BevelOuter = bvNone
    Color = 3348752
    ParentBackground = False
    TabOrder = 6
    object pnlKpiLoc: TPanel
      Left = 16
      Top = 10
      Width = 175
      Height = 60
      BevelOuter = bvNone
      Color = 2101786
      ParentBackground = False
      TabOrder = 0
      object lblKpiLocTitle: TLabel
        Left = 12
        Top = 8
        Width = 103
        Height = 13
        Caption = 'LINHAS DE CÓDIGO'
        Font.Color = 13420490
        Font.Height = -11
        Font.Style = [fsBold]
      end
      object lblKpiLocValue: TLabel
        Left = 12
        Top = 26
        Width = 12
        Height = 25
        Caption = '0'
        Font.Color = 16301816
        Font.Height = -19
        Font.Style = [fsBold]
      end
    end
    object pnlKpiClasses: TPanel
      Left = 205
      Top = 10
      Width = 175
      Height = 60
      BevelOuter = bvNone
      Color = 2101786
      ParentBackground = False
      TabOrder = 1
      object lblKpiClassesTitle: TLabel
        Left = 12
        Top = 8
        Width = 86
        Height = 13
        Caption = 'CLASSES TOTAIS'
        Font.Color = 13420490
        Font.Height = -11
        Font.Style = [fsBold]
      end
      object lblKpiClassesValue: TLabel
        Left = 12
        Top = 26
        Width = 12
        Height = 25
        Caption = '0'
        Font.Color = 16301816
        Font.Height = -19
        Font.Style = [fsBold]
      end
    end
    object pnlKpiMethods: TPanel
      Left = 395
      Top = 10
      Width = 175
      Height = 60
      BevelOuter = bvNone
      Color = 2101786
      ParentBackground = False
      TabOrder = 2
      object lblKpiMethodsTitle: TLabel
        Left = 12
        Top = 8
        Width = 136
        Height = 13
        Caption = 'MÉTODOS IMPL. (BODY)'
        Font.Color = 13420490
        Font.Height = -11
        Font.Style = [fsBold]
      end
      object lblKpiMethodsValue: TLabel
        Left = 12
        Top = 26
        Width = 12
        Height = 25
        Caption = '0'
        Font.Color = 16301816
        Font.Height = -19
        Font.Style = [fsBold]
      end
    end
    object pnlKpiComplexity: TPanel
      Left = 585
      Top = 10
      Width = 175
      Height = 60
      BevelOuter = bvNone
      Color = 2101786
      ParentBackground = False
      TabOrder = 3
      object lblKpiComplexityTitle: TLabel
        Left = 12
        Top = 8
        Width = 111
        Height = 13
        Caption = 'COMPLEXIDADE (MCC)'
        Font.Color = 13420490
        Font.Height = -11
        Font.Style = [fsBold]
      end
      object lblKpiComplexityValue: TLabel
        Left = 12
        Top = 26
        Width = 12
        Height = 25
        Caption = '0'
        Font.Color = 16301816
        Font.Height = -19
        Font.Style = [fsBold]
      end
    end
    object pnlKpiTime: TPanel
      Left = 775
      Top = 10
      Width = 185
      Height = 60
      BevelOuter = bvNone
      Color = 2101786
      ParentBackground = False
      TabOrder = 4
      object lblKpiTimeTitle: TLabel
        Left = 12
        Top = 8
        Width = 105
        Height = 13
        Caption = 'TEMPO DE EXECUÇÃO'
        Font.Color = 13420490
        Font.Height = -11
        Font.Style = [fsBold]
      end
      object lblKpiTimeValue: TLabel
        Left = 12
        Top = 26
        Width = 42
        Height = 25
        Caption = '0 ms'
        Font.Color = 16301816
        Font.Height = -19
        Font.Style = [fsBold]
      end
    end
  end
  object openDialogTarget: TOpenDialog
    Left = 880
    Top = 85
  end
  object saveDialogReport: TSaveDialog
    Left = 925
    Top = 85
  end
  object selectFolderDialog: TFileOpenDialog
    FavoriteFolders = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Left = 835
    Top = 85
  end
end
