unit Seven.Delphi.Metrics.UI.Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,
  Winapi.ActiveX,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IOUtils,
  System.Math,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.CheckLst,
  Seven.Delphi.Metrics.CodeAnalyzer,
  Seven.Delphi.Metrics.ProjectParser,
  Seven.Delphi.Metrics.GitAnalyzer,
  Seven.Delphi.Metrics.HtmlReportGenerator,
  Seven.Delphi.Metrics.HtmlHelpGenerator,
  Seven.Delphi.Metrics.HistoryService,
  Seven.Delphi.Metrics.Engine,
  Seven.Delphi.Metrics.SaveService,
  Seven.Delphi.Metrics.PresetService;

type
  TTargetType = (ttProject, ttGroupProject, ttDirectory);

  TFormMainMetrics = class(TForm)
    pnlHeader: TPanel;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    pnlTarget: TPanel;
    grpTargetType: TGroupBox;
    rbProject: TRadioButton;
    rbGroupProject: TRadioButton;
    rbDirectory: TRadioButton;
    lblTargetPath: TLabel;
    edtTargetPath: TEdit;
    btnBrowseTarget: TButton;
    btnListFiles: TButton;
    pgcOptions: TPageControl;
    tsProjects: TTabSheet;
    lblProjectsHelp: TLabel;
    clbProjects: TCheckListBox;
    btnSelectAllProjects: TButton;
    btnUnselectAllProjects: TButton;
    btnAddDproj: TButton;
    btnRemoveDproj: TButton;
    btnSavePreset: TButton;
    btnLoadPreset: TButton;
    tsReports: TTabSheet;
    chkExportJson: TCheckBox;
    edtJsonPath: TEdit;
    btnBrowseJson: TButton;
    chkGenerateHtml: TCheckBox;
    edtHtmlPath: TEdit;
    btnBrowseHtml: TButton;
    btnOpenHtml: TButton;
    tsGit: TTabSheet;
    chkEnableGit: TCheckBox;
    lblGitRepo: TLabel;
    edtGitRepoPath: TEdit;
    btnBrowseGitRepo: TButton;
    lblGitCommits: TLabel;
    edtGitCommits: TEdit;
    tsDatabase: TTabSheet;
    chkEnableDb: TCheckBox;
    lblVersionCode: TLabel;
    edtVersionCode: TEdit;
    lblVersionDate: TLabel;
    dtpVersionDate: TDateTimePicker;
    lblIniConfig: TLabel;
    edtIniConfigPath: TEdit;
    btnBrowseIniConfig: TButton;
    pnlAction: TPanel;
    btnExecute: TButton;
    pbProgress: TProgressBar;
    pgcResults: TPageControl;
    tsFiles: TTabSheet;
    lsvFiles: TListView;
    tsHotspots: TTabSheet;
    lsvHotspots: TListView;
    pnlFooterKpi: TPanel;
    pnlKpiLoc: TPanel;
    lblKpiLocTitle: TLabel;
    lblKpiLocValue: TLabel;
    pnlKpiClasses: TPanel;
    lblKpiClassesTitle: TLabel;
    lblKpiClassesValue: TLabel;
    pnlKpiMethods: TPanel;
    lblKpiMethodsTitle: TLabel;
    lblKpiMethodsValue: TLabel;
    pnlKpiComplexity: TPanel;
    lblKpiComplexityTitle: TLabel;
    lblKpiComplexityValue: TLabel;
    pnlKpiTime: TPanel;
    lblKpiTimeTitle: TLabel;
    lblKpiTimeValue: TLabel;
    openDialogTarget: TOpenDialog;
    saveDialogReport: TSaveDialog;
    selectFolderDialog: TFileOpenDialog;

    procedure FormCreate(Sender: TObject);
    procedure rbTargetTypeClick(Sender: TObject);
    procedure btnBrowseTargetClick(Sender: TObject);
    procedure btnListFilesClick(Sender: TObject);
    procedure btnSelectAllProjectsClick(Sender: TObject);
    procedure btnUnselectAllProjectsClick(Sender: TObject);
    procedure btnAddDprojClick(Sender: TObject);
    procedure btnRemoveDprojClick(Sender: TObject);
    procedure btnSavePresetClick(Sender: TObject);
    procedure btnLoadPresetClick(Sender: TObject);
    procedure btnBrowseJsonClick(Sender: TObject);
    procedure btnBrowseHtmlClick(Sender: TObject);
    procedure btnOpenHtmlClick(Sender: TObject);
    procedure btnBrowseGitRepoClick(Sender: TObject);
    procedure btnBrowseIniConfigClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
  private
    FDiscoveredFiles: TArray<string>;
    function GetTargetType: TTargetType;
    procedure PopulateFilesListView(const Files: TArray<string>);
    procedure UpdateKpiCards(const CodeStats: TCodeStatistics);
    procedure PopulateHotspots(const CodeStats: TCodeStatistics);
    procedure RefreshDiscoveredFilesFromProjects;
  public
  end;

var
  FormMainMetrics: TFormMainMetrics;

implementation

{$R *.dfm}

procedure TFormMainMetrics.FormCreate(Sender: TObject);
begin
  dtpVersionDate.DateTime := Now;
  const ExeDir = ExtractFilePath(ParamStr(0));
  edtTargetPath.Text := TPath.GetFullPath(TPath.Combine(ExeDir, '..\..\Seven.Delphi.Metrics.dproj'));
  edtJsonPath.Text := TPath.Combine(ExeDir, 'MetricasOutput.json');
  edtHtmlPath.Text := TPath.Combine(ExeDir, 'DashboardOutput.html');
  edtGitRepoPath.Text := TPath.GetFullPath(TPath.Combine(ExeDir, '..\..\..\'));
  edtGitCommits.Text := '20';
  edtVersionCode.Text := '1.0.0';
  edtIniConfigPath.Text := TPath.Combine(ExeDir, 'db_config.ini');

  const AppVersion = '1.0.0';
  Caption := Format('Seven Delphi Metrics v%s - Análise Estática de Código Delphi', [AppVersion]);
  lblTitle.Caption := Format('Seven Delphi Metrics v%s', [AppVersion]);
  lblSubtitle.Caption := 'Análise Estática de Métricas de Código, Complexidade Ciclomática e Evolução Git';

  grpTargetType.Caption := ' Seleção de Alvo para Análise ';
  rbProject.Caption := 'Projeto (.dproj)';
  rbGroupProject.Caption := 'Grupo de Projetos (.groupproj)';
  rbDirectory.Caption := 'Pasta / Diretório completo';
  lblTargetPath.Caption := 'Caminho do Projeto (.dproj):';

  tsProjects.Caption := 'Projetos (.dproj) / Presets';
  lblProjectsHelp.Caption := 'Projetos (.dproj) a serem analisados no grupo:';
  btnSelectAllProjects.Caption := 'Marcar Todos';
  btnUnselectAllProjects.Caption := 'Desmarcar Todos';
  btnAddDproj.Caption := 'Adicionar .dproj...';
  btnRemoveDproj.Caption := 'Remover Selecionado';
  btnSavePreset.Caption := 'Salvar Preset...';
  btnLoadPreset.Caption := 'Carregar Preset...';

  tsReports.Caption := 'Saídas & Dashboards';
  chkExportJson.Caption := 'Exportar Relatório JSON:';
  chkGenerateHtml.Caption := 'Gerar Dashboard HTML:';

  tsGit.Caption := 'Evolução Temporal Git';
  chkEnableGit.Caption := 'Habilitar Análise de Evolução Histórica no Git';
  lblGitRepo.Caption := 'Repositório Git (Pasta):';
  lblGitCommits.Caption := 'Qtd. Commits a Analisar:';

  tsDatabase.Caption := 'Banco de Dados (PostgreSQL / Breeze)';
  chkEnableDb.Caption := 'Salvar Métricas no Banco de Dados (PostgreSQL)';
  lblVersionCode.Caption := 'Código da Versão:';
  lblVersionDate.Caption := 'Data da Versão:';
  lblIniConfig.Caption := 'Configuração (db_config.ini):';

  btnExecute.Caption := 'EXECUTAR ANÁLISE ESTÁTICA DE CÓDIGO';
  tsFiles.Caption := 'Lista de Arquivos Fontes Analisados';
  tsHotspots.Caption := 'Top 10 Hotspots (Arquivos Mais Complexos)';

  lblKpiLocTitle.Caption := 'LINHAS DE CÓDIGO';
  lblKpiClassesTitle.Caption := 'CLASSES TOTAIS';
  lblKpiMethodsTitle.Caption := 'MÉTODOS IMPL. (BODY)';
  lblKpiComplexityTitle.Caption := 'COMPLEXIDADE (MCC)';
  lblKpiTimeTitle.Caption := 'TEMPO DE EXECUÇÃO';

  lsvFiles.ViewStyle := vsReport;
  lsvFiles.Columns.Clear;
  lsvFiles.Columns.Add.Caption := 'Arquivo Fonte';
  lsvFiles.Columns[0].Width := 300;
  lsvFiles.Columns.Add.Caption := 'LOC';
  lsvFiles.Columns[1].Width := 70;
  lsvFiles.Columns.Add.Caption := 'Comentários';
  lsvFiles.Columns[2].Width := 80;
  lsvFiles.Columns.Add.Caption := 'Em Branco';
  lsvFiles.Columns[3].Width := 80;
  lsvFiles.Columns.Add.Caption := 'Classes';
  lsvFiles.Columns[4].Width := 60;
  lsvFiles.Columns.Add.Caption := 'Métodos';
  lsvFiles.Columns[5].Width := 70;
  lsvFiles.Columns.Add.Caption := 'MCC';
  lsvFiles.Columns[6].Width := 60;
  lsvFiles.Columns.Add.Caption := 'Status';
  lsvFiles.Columns[7].Width := 80;

  lsvHotspots.ViewStyle := vsReport;
  lsvHotspots.Columns.Clear;
  lsvHotspots.Columns.Add.Caption := 'Arquivo (Hotspot)';
  lsvHotspots.Columns[0].Width := 380;
  lsvHotspots.Columns.Add.Caption := 'MCC (Complexidade)';
  lsvHotspots.Columns[1].Width := 140;
  lsvHotspots.Columns.Add.Caption := 'Métodos';
  lsvHotspots.Columns[2].Width := 100;
  lsvHotspots.Columns.Add.Caption := 'LOC';
  lsvHotspots.Columns[3].Width := 100;
end;

function TFormMainMetrics.GetTargetType: TTargetType;
begin
  if rbGroupProject.Checked then
    Result := ttGroupProject
  else if rbDirectory.Checked then
    Result := ttDirectory
  else
    Result := ttProject;
end;

procedure TFormMainMetrics.rbTargetTypeClick(Sender: TObject);
begin
  case GetTargetType of
    ttProject:
      lblTargetPath.Caption := 'Caminho do Projeto (.dproj):';
    ttGroupProject:
      lblTargetPath.Caption := 'Caminho do Grupo de Projetos (.groupproj):';
    ttDirectory:
      lblTargetPath.Caption := 'Caminho da Pasta / Diretório:';
  end;
end;

procedure TFormMainMetrics.btnBrowseTargetClick(Sender: TObject);
begin
  if GetTargetType = ttDirectory then
  begin
    selectFolderDialog.Options := [fdoPickFolders];
    if selectFolderDialog.Execute then
      edtTargetPath.Text := selectFolderDialog.FileName;
  end
  else
  begin
    if GetTargetType = ttProject then
      openDialogTarget.Filter := 'Projetos Delphi (*.dproj)|*.dproj|Todos (*.*)|*.*'
    else
      openDialogTarget.Filter := 'Grupos de Projetos (*.groupproj)|*.groupproj|Todos (*.*)|*.*';

    if openDialogTarget.Execute then
      edtTargetPath.Text := openDialogTarget.FileName;
  end;
end;

procedure TFormMainMetrics.btnListFilesClick(Sender: TObject);
var
  Projects: TArray<string>;
begin
  const TargetPath = Trim(edtTargetPath.Text);
  if (TargetPath = '') or (not TFile.Exists(TargetPath) and not TDirectory.Exists(TargetPath)) then
  begin
    ShowMessage('Por favor, informe um caminho de projeto ou diretório válido.');
    Exit;
  end;

  clbProjects.Items.BeginUpdate;
  try
    clbProjects.Items.Clear;
    case GetTargetType of
      ttProject:
        begin
          if TFile.Exists(TargetPath) then
          begin
            const Index = clbProjects.Items.Add(TargetPath);
            clbProjects.Checked[Index] := True;
          end;
        end;
      ttGroupProject:
        begin
          Projects := TProjectParser.ExtractDprojFromGroupproj(TargetPath);
          for var P in Projects do
          begin
            const Index = clbProjects.Items.Add(P);
            clbProjects.Checked[Index] := True;
          end;
        end;
      ttDirectory:
        begin
          Projects := TDirectory.GetFiles(TargetPath, '*.dproj', TSearchOption.soAllDirectories);
          for var P in Projects do
          begin
            const Index = clbProjects.Items.Add(P);
            clbProjects.Checked[Index] := True;
          end;
        end;
  end;
  finally
    clbProjects.Items.EndUpdate;
  end;

  RefreshDiscoveredFilesFromProjects;

  PopulateFilesListView(FDiscoveredFiles);
  pgcOptions.ActivePage := tsProjects;
  ShowMessage(Format('%d projetos (.dproj) listados com checkbox. %d arquivos fontes (.pas) mapeados sem duplicatas.', [clbProjects.Items.Count, Length(FDiscoveredFiles)]));
end;

procedure TFormMainMetrics.btnSelectAllProjectsClick(Sender: TObject);
begin
  for var I := 0 to clbProjects.Items.Count - 1 do
    clbProjects.Checked[I] := True;
  RefreshDiscoveredFilesFromProjects;
  PopulateFilesListView(FDiscoveredFiles);
end;

procedure TFormMainMetrics.btnUnselectAllProjectsClick(Sender: TObject);
begin
  for var I := 0 to clbProjects.Items.Count - 1 do
    clbProjects.Checked[I] := False;
  RefreshDiscoveredFilesFromProjects;
  PopulateFilesListView(FDiscoveredFiles);
end;

procedure TFormMainMetrics.btnAddDprojClick(Sender: TObject);
begin
  openDialogTarget.Filter := 'Projetos Delphi (*.dproj)|*.dproj|Todos (*.*)|*.*';
  if openDialogTarget.Execute then
  begin
    const NewProj = openDialogTarget.FileName;
    if clbProjects.Items.IndexOf(NewProj) < 0 then
    begin
      const Idx = clbProjects.Items.Add(NewProj);
      clbProjects.Checked[Idx] := True;
      RefreshDiscoveredFilesFromProjects;
      PopulateFilesListView(FDiscoveredFiles);
    end;
  end;
end;

procedure TFormMainMetrics.btnRemoveDprojClick(Sender: TObject);
begin
  if clbProjects.ItemIndex >= 0 then
  begin
    clbProjects.Items.Delete(clbProjects.ItemIndex);
    RefreshDiscoveredFilesFromProjects;
    PopulateFilesListView(FDiscoveredFiles);
  end;
end;

procedure TFormMainMetrics.btnSavePresetClick(Sender: TObject);
var
  Preset: TPresetData;
  Items: TArray<TPresetProjectItem>;
begin
  saveDialogReport.Filter := 'Preset de Projetos (*.sdmpreset.json)|*.sdmpreset.json|JSON (*.json)|*.json';
  saveDialogReport.FileName := 'MeuProjetoPreset.sdmpreset.json';
  if saveDialogReport.Execute then
  begin
    Preset.PresetName := TPath.GetFileNameWithoutExtension(saveDialogReport.FileName);
    Preset.TargetPath := Trim(edtTargetPath.Text);
    SetLength(Items, clbProjects.Items.Count);
    for var I := 0 to clbProjects.Items.Count - 1 do
    begin
      Items[I].Path := clbProjects.Items[I];
      Items[I].Enabled := clbProjects.Checked[I];
    end;
    Preset.Projects := Items;

    TPresetService.SavePresetToFile(saveDialogReport.FileName, Preset);
    ShowMessage(Format('Preset salvo com sucesso com %d projetos!', [Length(Items)]));
  end;
end;

procedure TFormMainMetrics.btnLoadPresetClick(Sender: TObject);
var
  Preset: TPresetData;
begin
  openDialogTarget.Filter := 'Preset de Projetos (*.sdmpreset.json)|*.sdmpreset.json|JSON (*.json)|*.json';
  if openDialogTarget.Execute then
  begin
    if TPresetService.LoadPresetFromFile(openDialogTarget.FileName, Preset) then
    begin
      if Preset.TargetPath <> '' then
        edtTargetPath.Text := Preset.TargetPath;

      clbProjects.Items.BeginUpdate;
      try
        clbProjects.Items.Clear;
        for var Item in Preset.Projects do
        begin
          const Idx = clbProjects.Items.Add(Item.Path);
          clbProjects.Checked[Idx] := Item.Enabled;
        end;
      finally
        clbProjects.Items.EndUpdate;
      end;

      RefreshDiscoveredFilesFromProjects;
      PopulateFilesListView(FDiscoveredFiles);
      pgcOptions.ActivePage := tsProjects;
      ShowMessage(Format('Preset "%s" carregado com sucesso!', [Preset.PresetName]));
    end
    else
      ShowMessage('Não foi possível carregar o arquivo de preset selecionado.');
  end;
end;

procedure TFormMainMetrics.RefreshDiscoveredFilesFromProjects;
var
  SeenUnits: THashSet<string>;
  FilesList: TList<string>;
  ProjectFile: string;
  UnitsInProj: TArray<string>;
begin
  SeenUnits := THashSet<string>.Create;
  FilesList := TList<string>.Create;
  try
    if (clbProjects.Items.Count = 0) and (GetTargetType = ttDirectory) then
    begin
      const TargetPath = Trim(edtTargetPath.Text);
      if TDirectory.Exists(TargetPath) then
      begin
        const AllPas = TDirectory.GetFiles(TargetPath, '*.pas', TSearchOption.soAllDirectories);
        for var PasFile in AllPas do
        begin
          const NormPath = TPath.GetFullPath(PasFile).ToLower;
          if SeenUnits.Add(NormPath) then
            FilesList.Add(PasFile);
        end;
      end;
    end;

    for var I := 0 to clbProjects.Items.Count - 1 do
    begin
      if clbProjects.Checked[I] then
      begin
        ProjectFile := clbProjects.Items[I];
        if TFile.Exists(ProjectFile) then
        begin
          UnitsInProj := TProjectParser.ExtractProjectFiles(ProjectFile);
          for var UnitFile in UnitsInProj do
          begin
            const NormPath = TPath.GetFullPath(UnitFile).ToLower;
            if SeenUnits.Add(NormPath) then
              FilesList.Add(UnitFile);
          end;
        end;
      end;
    end;

    FDiscoveredFiles := FilesList.ToArray;
  finally
    SeenUnits.Free;
    FilesList.Free;
  end;
end;

procedure TFormMainMetrics.PopulateFilesListView(const Files: TArray<string>);
begin
  lsvFiles.Items.BeginUpdate;
  try
    lsvFiles.Items.Clear;
    for var F in Files do
    begin
      const Item = lsvFiles.Items.Add;
      Item.Caption := F;
      Item.SubItems.Add('-');
      Item.SubItems.Add('-');
      Item.SubItems.Add('-');
      Item.SubItems.Add('-');
      Item.SubItems.Add('-');
      Item.SubItems.Add('-');
      Item.SubItems.Add('Pendente');
    end;
  finally
    lsvFiles.Items.EndUpdate;
  end;
end;

procedure TFormMainMetrics.btnBrowseJsonClick(Sender: TObject);
begin
  saveDialogReport.Filter := 'Arquivos JSON (*.json)|*.json';
  saveDialogReport.FileName := edtJsonPath.Text;
  if saveDialogReport.Execute then
    edtJsonPath.Text := saveDialogReport.FileName;
end;

procedure TFormMainMetrics.btnBrowseHtmlClick(Sender: TObject);
begin
  saveDialogReport.Filter := 'Arquivos HTML (*.html)|*.html';
  saveDialogReport.FileName := edtHtmlPath.Text;
  if saveDialogReport.Execute then
    edtHtmlPath.Text := saveDialogReport.FileName;
end;

procedure TFormMainMetrics.btnOpenHtmlClick(Sender: TObject);
begin
  const HtmlPath = Trim(edtHtmlPath.Text);
  if not TFile.Exists(HtmlPath) then
  begin
    ShowMessage('O arquivo Dashboard HTML ainda não foi gerado. Execute a análise primeiro.');
    Exit;
  end;
  ShellExecute(0, 'open', PChar(HtmlPath), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormMainMetrics.btnBrowseGitRepoClick(Sender: TObject);
begin
  selectFolderDialog.Options := [fdoPickFolders];
  if selectFolderDialog.Execute then
    edtGitRepoPath.Text := selectFolderDialog.FileName;
end;

procedure TFormMainMetrics.btnBrowseIniConfigClick(Sender: TObject);
begin
  openDialogTarget.Filter := 'Arquivos INI (*.ini)|*.ini|Todos (*.*)|*.*';
  if openDialogTarget.Execute then
    edtIniConfigPath.Text := openDialogTarget.FileName;
end;

procedure TFormMainMetrics.btnExecuteClick(Sender: TObject);
var
  TargetPath: string;
  SaveService: ICodeAnalyzerSaveMetricsService;
  Analyzer: TCodeAnalyzer;
  CodeStats: TCodeStatistics;
begin
  TargetPath := Trim(edtTargetPath.Text);
  if (TargetPath = '') or (not TFile.Exists(TargetPath) and not TDirectory.Exists(TargetPath)) then
  begin
    ShowMessage('Selecione um projeto ou diretório válido antes de executar.');
    Exit;
  end;

  btnExecute.Enabled := False;
  pbProgress.Position := 0;
  pbProgress.Max := 100;
  try
    if chkEnableGit.Checked then
    begin
      const RepoPath = Trim(edtGitRepoPath.Text);
      const MaxCommits = StrToIntDef(Trim(edtGitCommits.Text), 20);
      const OutJson = Trim(edtJsonPath.Text);

      TGitAnalyzer.AnalyzeGitEvolution(RepoPath, TargetPath, OutJson, False, MaxCommits);

      if chkGenerateHtml.Checked then
        THtmlReportGenerator.GenerateGitEvolutionReport(OutJson, Trim(edtHtmlPath.Text));

      ShowMessage('Análise de evolução Git concluída com sucesso!');
      Exit;
    end;

    // Atualiza a lista de arquivos fontes com base nos dprojs marcados no CheckListBox (garantindo sem duplicatas)
    RefreshDiscoveredFilesFromProjects;

    Analyzer := TCodeAnalyzer.Create();
    try
      for var SourceFile in FDiscoveredFiles do
      begin
        Analyzer.AnalyzeFile(SourceFile);
      end;

      CodeStats := Analyzer.Results;
      CodeStats.FileName := TargetPath;

      // Exibir resultados na interface
      UpdateKpiCards(CodeStats);
      PopulateHotspots(CodeStats);

      // Atualizar lista de arquivos
      lsvFiles.Items.BeginUpdate;
      try
        lsvFiles.Items.Clear;
        for var FileStat in CodeStats do
        begin
          const Item = lsvFiles.Items.Add;
          Item.Caption := FileStat.FileName;
          Item.SubItems.Add(FileStat.LineCodeCount.ToString);
          Item.SubItems.Add(FileStat.CommentLineCount.ToString);
          Item.SubItems.Add(FileStat.BlankLineCount.ToString);
          Item.SubItems.Add(FileStat.ClassCount.ToString);
          Item.SubItems.Add(FileStat.ImplMethodCount.ToString);
          Item.SubItems.Add(FileStat.CyclomaticComplexity.ToString);
          if FileStat.ParseError <> '' then
            Item.SubItems.Add('Erro: ' + FileStat.ParseError)
          else
            Item.SubItems.Add('OK');
        end;
      finally
        lsvFiles.Items.EndUpdate;
      end;

      // Salvar JSON se marcado
      if chkExportJson.Checked then
      begin
        SaveService := TSaveServiceFileFactory.CreateFileJson(Trim(edtJsonPath.Text));
        SaveService.Save(CodeStats);
      end;

      // Salvar Banco de Dados se marcado
      if chkEnableDb.Checked then
      begin
        SaveService := TSaveServiceFileFactory.CreateDatabase(Trim(edtVersionCode.Text), dtpVersionDate.DateTime, Trim(edtIniConfigPath.Text));
        SaveService.Save(CodeStats);
      end;

      // Gerar Dashboard HTML se marcado
      if chkGenerateHtml.Checked then
      begin
        if not chkExportJson.Checked then
        begin
          SaveService := TSaveServiceFileFactory.CreateFileJson(Trim(edtJsonPath.Text));
          SaveService.Save(CodeStats);
        end;
        THtmlReportGenerator.GenerateProjectReport(Trim(edtJsonPath.Text), Trim(edtHtmlPath.Text));
      end;

      ShowMessage('Análise executada com sucesso!');
    finally
      Analyzer.Free;
    end;
  finally
    pbProgress.Position := 100;
    btnExecute.Enabled := True;
  end;
end;

procedure TFormMainMetrics.UpdateKpiCards(const CodeStats: TCodeStatistics);
begin
  lblKpiLocValue.Caption := Format('%.0n', [Extended(CodeStats.GetTotalLineCodeCount)]);
  lblKpiClassesValue.Caption := Format('%.0n', [Extended(CodeStats.GetTotalClassCount)]);
  lblKpiMethodsValue.Caption := Format('%.0n', [Extended(CodeStats.GetTotalImplMethodCount)]);
  lblKpiComplexityValue.Caption := Format('%.0n', [Extended(CodeStats.GetTotalCyclomaticComplexity)]);
  lblKpiTimeValue.Caption := Format('%.0f ms', [CodeStats.GetTotalAnalysisTimeMs]);
end;

procedure TFormMainMetrics.PopulateHotspots(const CodeStats: TCodeStatistics);
var
  List: TArray<TCodeFileStatistics>;
  I, J: Integer;
  Temp: TCodeFileStatistics;
begin
  SetLength(List, CodeStats.Count);
  for I := 0 to CodeStats.Count - 1 do
    List[I] := CodeStats[I];

  // Sort descending by CyclomaticComplexity
  for I := 0 to Length(List) - 2 do
    for J := I + 1 to Length(List) - 1 do
      if List[J].CyclomaticComplexity > List[I].CyclomaticComplexity then
      begin
        Temp := List[I];
        List[I] := List[J];
        List[J] := Temp;
      end;

  lsvHotspots.Items.BeginUpdate;
  try
    lsvHotspots.Items.Clear;
    const Limit = System.Math.Min(10, Length(List));
    for I := 0 to Limit - 1 do
    begin
      const Item = lsvHotspots.Items.Add;
      Item.Caption := List[I].FileName;
      Item.SubItems.Add(List[I].CyclomaticComplexity.ToString);
      Item.SubItems.Add(List[I].ImplMethodCount.ToString);
      Item.SubItems.Add(List[I].LineCodeCount.ToString);
    end;
  finally
    lsvHotspots.Items.EndUpdate;
  end;
end;

end.
