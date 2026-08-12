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
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Seven.Delphi.Metrics.CodeAnalyzer,
  Seven.Delphi.Metrics.ProjectParser,
  Seven.Delphi.Metrics.GitAnalyzer,
  Seven.Delphi.Metrics.HtmlReportGenerator,
  Seven.Delphi.Metrics.HtmlHelpGenerator,
  Seven.Delphi.Metrics.HistoryService,
  Seven.Delphi.Metrics.Engine,
  Seven.Delphi.Metrics.SaveService;

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

  Caption := 'Seven Builder Metrics - An'#$E1'lise Est'#$E1'tica de C'#$F3'digo Delphi';
  lblTitle.Caption := 'Seven Builder Metrics - Delphi';
  lblSubtitle.Caption := 'An'#$E1'lise Est'#$E1'tica de M'#$E9'tricas de C'#$F3'digo, Complexidade Ciclom'#$E1'tica e Evolu'#$E7#$E3'o Git';

  grpTargetType.Caption := ' Sele'#$E7#$E3'o de Alvo para An'#$E1'lise ';
  rbProject.Caption := 'Projeto (.dproj)';
  rbGroupProject.Caption := 'Grupo de Projetos (.groupproj)';
  rbDirectory.Caption := 'Pasta / Diret'#$F3'rio completo';
  lblTargetPath.Caption := 'Caminho do Projeto (.dproj):';

  tsReports.Caption := 'Sa'#$ED'das & Dashboards';
  chkExportJson.Caption := 'Exportar Relat'#$F3'rio JSON:';
  chkGenerateHtml.Caption := 'Gerar Dashboard HTML:';

  tsGit.Caption := 'Evolu'#$E7#$E3'o Temporal Git';
  chkEnableGit.Caption := 'Habilitar An'#$E1'lise de Evolu'#$E7#$E3'o Hist'#$F3'rica no Git';
  lblGitRepo.Caption := 'Reposit'#$F3'rio Git (Pasta):';
  lblGitCommits.Caption := 'Qtd. Commits a Analisar:';

  tsDatabase.Caption := 'Banco de Dados (PostgreSQL / Breeze)';
  chkEnableDb.Caption := 'Salvar M'#$E9'tricas no Banco de Dados (PostgreSQL)';
  lblVersionCode.Caption := 'C'#$F3'digo da Vers'#$E3'o:';
  lblVersionDate.Caption := 'Data da Vers'#$E3'o:';
  lblIniConfig.Caption := 'Configura'#$E7#$E3'o (db_config.ini):';

  btnExecute.Caption := 'EXECUTAR AN'#$C1'LISE EST'#$C1'TICA DE C'#$D3'DIGO';
  tsFiles.Caption := 'Lista de Arquivos Fontes Analisados';
  tsHotspots.Caption := 'Top 10 Hotspots (Arquivos Mais Complexos)';

  lblKpiLocTitle.Caption := 'LINHAS DE C'#$D3'DIGO';
  lblKpiClassesTitle.Caption := 'CLASSES TOTAIS';
  lblKpiMethodsTitle.Caption := 'M'#$C9'TODOS IMPL. (BODY)';
  lblKpiComplexityTitle.Caption := 'COMPLEXIDADE (MCC)';
  lblKpiTimeTitle.Caption := 'TEMPO DE EXECU'#$C7#$C3'O';

  lsvFiles.ViewStyle := vsReport;
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
begin
  const TargetPath = Trim(edtTargetPath.Text);
  if (TargetPath = '') or (not TFile.Exists(TargetPath) and not TDirectory.Exists(TargetPath)) then
  begin
    ShowMessage('Por favor, informe um caminho de projeto ou diretório válido.');
    Exit;
  end;

  case GetTargetType of
    ttProject, ttGroupProject:
      FDiscoveredFiles := TProjectParser.ExtractProjectFiles(TargetPath);
    ttDirectory:
      FDiscoveredFiles := TDirectory.GetFiles(TargetPath, '*.pas', TSearchOption.soAllDirectories);
  end;

  PopulateFilesListView(FDiscoveredFiles);
  ShowMessage(Format('%d arquivos fontes encontrados.', [Length(FDiscoveredFiles)]));
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

    // Análise direta
    if (GetTargetType = ttProject) or (GetTargetType = ttGroupProject) then
    begin
      FDiscoveredFiles := TProjectParser.ExtractProjectFiles(TargetPath);
    end;

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
