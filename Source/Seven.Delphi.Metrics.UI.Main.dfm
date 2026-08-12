object FormMainMetrics: TFormMainMetrics
  Left = 0
  Top = 0
  Caption = 'Seven Builder Metrics - An'#193'lise Est'#193'tica de C'#243'digo Delphi'
  ClientHeight = 750
  ClientWidth = 1020
  Color = 16316668
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 10000000
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 1020
    Height = 72
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object lblTitle: TLabel
      Left = 20
      Top = 14
      Width = 289
      Height = 28
      Caption = 'Seven Builder Metrics - Delphi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13075456
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitle: TLabel
      Left = 20
      Top = 42
      Width = 476
      Height = 17
      Caption = 
        'An'#225'lise Est'#225'tica de M'#233'tricas de C'#243'digo, Complexidade Ciclom'#225'tica' +
        ' e Evolu'#231#227'o Git'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 9145236
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlTarget: TPanel
    Left = 0
    Top = 72
    Width = 1020
    Height = 110
    Align = alTop
    BevelOuter = bvNone
    Color = 16316668
    ParentBackground = False
    TabOrder = 1
    object lblTargetPath: TLabel
      Left = 20
      Top = 72
      Width = 155
      Height = 15
      Caption = 'Caminho do Projeto (.dproj):'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 10000000
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object grpTargetType: TGroupBox
      Left = 16
      Top = 10
      Width = 988
      Height = 52
      Caption = ' Sele'#231#227'o de Alvo para An'#225'lise '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 10000000
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object rbProject: TRadioButton
        Left = 20
        Top = 22
        Width = 160
        Height = 20
        Caption = 'Projeto (.dproj)'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 10000000
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        TabStop = True
        OnClick = rbTargetTypeClick
      end
      object rbGroupProject: TRadioButton
        Left = 220
        Top = 22
        Width = 220
        Height = 20
        Caption = 'Grupo de Projetos (.groupproj)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 10000000
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = rbTargetTypeClick
      end
      object rbDirectory: TRadioButton
        Left = 470
        Top = 22
        Width = 200
        Height = 20
        Caption = 'Pasta / Diret'#243'rio completo'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 10000000
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnClick = rbTargetTypeClick
      end
    end
    object edtTargetPath: TEdit
      Left = 200
      Top = 69
      Width = 665
      Height = 25
      TabOrder = 1
    end
    object btnBrowseTarget: TButton
      Left = 872
      Top = 68
      Width = 40
      Height = 27
      Caption = '...'
      TabOrder = 2
      OnClick = btnBrowseTargetClick
    end
    object btnListFiles: TButton
      Left = 918
      Top = 68
      Width = 86
      Height = 27
      Caption = 'Listar'
      TabOrder = 3
      OnClick = btnListFilesClick
    end
  end
  object pgcOptions: TPageControl
    Left = 0
    Top = 182
    Width = 1020
    Height = 140
    ActivePage = tsProjects
    Align = alTop
    TabOrder = 2
    object tsProjects: TTabSheet
      Caption = 'Projetos (.dproj) / Presets'
      object lblProjectsHelp: TLabel
        Left = 16
        Top = 6
        Width = 245
        Height = 15
        Caption = 'Projetos (.dproj) a serem analisados no grupo:'
      end
      object clbProjects: TCheckListBox
        Left = 16
        Top = 24
        Width = 730
        Height = 82
        ItemHeight = 17
        TabOrder = 0
      end
      object btnSelectAllProjects: TButton
        Left = 756
        Top = 24
        Width = 110
        Height = 24
        Caption = 'Marcar Todos'
        TabOrder = 1
        OnClick = btnSelectAllProjectsClick
      end
      object btnUnselectAllProjects: TButton
        Left = 756
        Top = 52
        Width = 110
        Height = 24
        Caption = 'Desmarcar Todos'
        TabOrder = 2
        OnClick = btnUnselectAllProjectsClick
      end
      object btnAddDproj: TButton
        Left = 872
        Top = 24
        Width = 130
        Height = 24
        Caption = 'Adicionar .dproj...'
        TabOrder = 3
        OnClick = btnAddDprojClick
      end
      object btnRemoveDproj: TButton
        Left = 872
        Top = 52
        Width = 130
        Height = 24
        Caption = 'Remover Selecionado'
        TabOrder = 4
        OnClick = btnRemoveDprojClick
      end
      object btnSavePreset: TButton
        Left = 756
        Top = 80
        Width = 110
        Height = 25
        Caption = 'Salvar Preset...'
        TabOrder = 5
        OnClick = btnSavePresetClick
      end
      object btnLoadPreset: TButton
        Left = 872
        Top = 80
        Width = 130
        Height = 25
        Caption = 'Carregar Preset...'
        TabOrder = 6
        OnClick = btnLoadPresetClick
      end
    end
    object tsReports: TTabSheet
      Caption = 'Sa'#237'das & Dashboards'
      object chkExportJson: TCheckBox
        Left = 16
        Top = 18
        Width = 170
        Height = 20
        Caption = 'Exportar Relat'#243'rio JSON:'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object edtJsonPath: TEdit
        Left = 190
        Top = 17
        Width = 675
        Height = 23
        TabOrder = 1
      end
      object btnBrowseJson: TButton
        Left = 872
        Top = 16
        Width = 40
        Height = 25
        Caption = '...'
        TabOrder = 2
        OnClick = btnBrowseJsonClick
      end
      object chkGenerateHtml: TCheckBox
        Left = 16
        Top = 54
        Width = 170
        Height = 20
        Caption = 'Gerar Dashboard HTML:'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object edtHtmlPath: TEdit
        Left = 190
        Top = 53
        Width = 675
        Height = 23
        TabOrder = 4
      end
      object btnBrowseHtml: TButton
        Left = 872
        Top = 52
        Width = 40
        Height = 25
        Caption = '...'
        TabOrder = 5
        OnClick = btnBrowseHtmlClick
      end
      object btnOpenHtml: TButton
        Left = 918
        Top = 52
        Width = 86
        Height = 25
        Caption = 'Abrir HTML'
        TabOrder = 6
        OnClick = btnOpenHtmlClick
      end
    end
    object tsGit: TTabSheet
      Caption = 'Evolu'#231#227'o Temporal Git'
      ImageIndex = 1
      object lblGitRepo: TLabel
        Left = 16
        Top = 46
        Width = 120
        Height = 15
        Caption = 'Reposit'#243'rio Git (Pasta):'
      end
      object lblGitCommits: TLabel
        Left = 16
        Top = 78
        Width = 132
        Height = 15
        Caption = 'Qtd. Commits a Analisar:'
      end
      object chkEnableGit: TCheckBox
        Left = 16
        Top = 14
        Width = 280
        Height = 20
        Caption = 'Habilitar An'#225'lise de Evolu'#231#227'o Hist'#243'rica no Git'
        TabOrder = 0
      end
      object edtGitRepoPath: TEdit
        Left = 160
        Top = 43
        Width = 705
        Height = 23
        TabOrder = 1
      end
      object btnBrowseGitRepo: TButton
        Left = 872
        Top = 42
        Width = 40
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
        Width = 95
        Height = 15
        Caption = 'C'#243'digo da Vers'#227'o:'
      end
      object lblVersionDate: TLabel
        Left = 260
        Top = 46
        Width = 80
        Height = 15
        Caption = 'Data da Vers'#227'o:'
      end
      object lblIniConfig: TLabel
        Left = 16
        Top = 78
        Width = 155
        Height = 15
        Caption = 'Configura'#231#227'o (db_config.ini):'
      end
      object chkEnableDb: TCheckBox
        Left = 16
        Top = 14
        Width = 320
        Height = 20
        Caption = 'Salvar M'#233'tricas no Banco de Dados (PostgreSQL)'
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
        Time = 46246.000000000000000000
        TabOrder = 2
      end
      object edtIniConfigPath: TEdit
        Left = 160
        Top = 75
        Width = 705
        Height = 23
        TabOrder = 3
      end
      object btnBrowseIniConfig: TButton
        Left = 872
        Top = 74
        Width = 40
        Height = 25
        Caption = '...'
        TabOrder = 4
        OnClick = btnBrowseIniConfigClick
      end
    end
  end
  object pnlAction: TPanel
    Left = 0
    Top = 322
    Width = 1020
    Height = 58
    Align = alTop
    BevelOuter = bvNone
    Color = 16316668
    ParentBackground = False
    TabOrder = 3
    object btnExecute: TButton
      Left = 16
      Top = 10
      Width = 988
      Height = 40
      Caption = 'EXECUTAR AN'#193'LISE EST'#193'TICA DE C'#243'DIGO'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnExecuteClick
    end
  end
  object pbProgress: TProgressBar
    Left = 0
    Top = 380
    Width = 1020
    Height = 6
    Align = alTop
    TabOrder = 4
  end
  object pgcResults: TPageControl
    Left = 0
    Top = 386
    Width = 1020
    Height = 280
    ActivePage = tsFiles
    Align = alClient
    TabOrder = 5
    object tsFiles: TTabSheet
      Caption = 'Lista de Arquivos Fontes Analisados'
      object lsvFiles: TListView
        Left = 0
        Top = 0
        Width = 1012
        Height = 250
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
        Width = 1012
        Height = 250
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
    Top = 666
    Width = 1020
    Height = 84
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 6
    object pnlKpiLoc: TPanel
      Left = 16
      Top = 12
      Width = 185
      Height = 60
      BevelOuter = bvLowered
      Color = 16316668
      ParentBackground = False
      TabOrder = 0
      object lblKpiLocTitle: TLabel
        Left = 12
        Top = 8
        Width = 102
        Height = 13
        Caption = 'LINHAS DE C'#211'DIGO'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblKpiLocValue: TLabel
        Left = 12
        Top = 26
        Width = 11
        Height = 25
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13075456
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlKpiClasses: TPanel
      Left = 213
      Top = 12
      Width = 185
      Height = 60
      BevelOuter = bvLowered
      Color = 16316668
      ParentBackground = False
      TabOrder = 1
      object lblKpiClassesTitle: TLabel
        Left = 12
        Top = 8
        Width = 84
        Height = 13
        Caption = 'CLASSES TOTAIS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblKpiClassesValue: TLabel
        Left = 12
        Top = 26
        Width = 11
        Height = 25
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13075456
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlKpiMethods: TPanel
      Left = 410
      Top = 12
      Width = 185
      Height = 60
      BevelOuter = bvLowered
      Color = 16316668
      ParentBackground = False
      TabOrder = 2
      object lblKpiMethodsTitle: TLabel
        Left = 12
        Top = 8
        Width = 127
        Height = 13
        Caption = 'M'#201'TODOS IMPL. (BODY)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblKpiMethodsValue: TLabel
        Left = 12
        Top = 26
        Width = 11
        Height = 25
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13075456
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlKpiComplexity: TPanel
      Left = 607
      Top = 12
      Width = 185
      Height = 60
      BevelOuter = bvLowered
      Color = 16316668
      ParentBackground = False
      TabOrder = 3
      object lblKpiComplexityTitle: TLabel
        Left = 12
        Top = 8
        Width = 121
        Height = 13
        Caption = 'COMPLEXIDADE (MCC)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblKpiComplexityValue: TLabel
        Left = 12
        Top = 26
        Width = 11
        Height = 25
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13075456
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlKpiTime: TPanel
      Left = 804
      Top = 12
      Width = 200
      Height = 60
      BevelOuter = bvLowered
      Color = 16316668
      ParentBackground = False
      TabOrder = 4
      object lblKpiTimeTitle: TLabel
        Left = 12
        Top = 8
        Width = 115
        Height = 13
        Caption = 'TEMPO DE EXECU'#199#195'O'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579307
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblKpiTimeValue: TLabel
        Left = 12
        Top = 26
        Width = 41
        Height = 25
        Caption = '0 ms'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13075456
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
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
    Options = [fdoPickFolders]
    Left = 835
    Top = 85
  end
end
