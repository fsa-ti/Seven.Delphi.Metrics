program Seven.Builder.Metrics;

uses
  Vcl.Forms,
  System.SysUtils,
  System.IOUtils,
  Winapi.Windows,
  Winapi.ActiveX,
  Seven.Builder.Metrics.UI.Main in 'Source\Seven.Builder.Metrics.UI.Main.pas' {FormMainMetrics},
  Seven.Builder.AnalyticsAndMetrics.GitAnalyzer in 'Source\Seven.Builder.AnalyticsAndMetrics.GitAnalyzer.pas',
  Seven.Builder.AnalyticsAndMetrics.ProjectParser in 'Source\Seven.Builder.AnalyticsAndMetrics.ProjectParser.pas',
  Seven.Builder.AnalyticsAndMetrics.CodeAnalyzer in 'Source\Seven.Builder.AnalyticsAndMetrics.CodeAnalyzer.pas',
  Seven.Builder.AnalyticsAndMetrics.HtmlReportGenerator in 'Source\Seven.Builder.AnalyticsAndMetrics.HtmlReportGenerator.pas',
  Seven.Builder.AnalyticsAndMetrics in 'Source\Seven.Builder.AnalyticsAndMetrics.pas',
  Seven.Builder.AnalyticsAndMetrics.SaveService in 'Source\Seven.Builder.AnalyticsAndMetrics.SaveService.pas';

{$R *.res}

function HasCmdSwitch(const SwitchName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
  begin
    if SameText(ParamStr(I), '-' + SwitchName) or SameText(ParamStr(I), '--' + SwitchName) or SameText(ParamStr(I), '/' + SwitchName) then
      Exit(True);
  end;
end;

function GetCmdValue(const SwitchName: string; const DefaultVal: string = ''): string;
var
  I: Integer;
begin
  Result := DefaultVal;
  for I := 1 to ParamCount - 1 do
  begin
    if SameText(ParamStr(I), '-' + SwitchName) or SameText(ParamStr(I), '--' + SwitchName) or SameText(ParamStr(I), '/' + SwitchName) then
      Exit(ParamStr(I + 1));
  end;
end;

procedure PrintHelp;
begin
  Writeln('=== Seven Builder Metrics - CLI ===');
  Writeln('Uso: Seven.Builder.Metrics.exe [opcoes]');
  Writeln('');
  Writeln('Opcoes:');
  Writeln('  -project, -p <path>   Caminho para o arquivo .dproj ou .groupproj');
  Writeln('  -out, -o <path>       Caminho para salvar o relatorio em formato JSON');
  Writeln('  -html <path>          Caminho para gerar o Dashboard visual em HTML');
  Writeln('  -git <repoPath>       Executa a analise de evolucao historica no Git');
  Writeln('  -commits <N>          Quantidade de commits a analisar no Git (Padrao: 20)');
  Writeln('  -db                   Habilita salvar as metricas no Banco de Dados');
  Writeln('  -version <str>        Versao de referencia para salvar no Banco de Dados');
  Writeln('  -help                 Exibe esta mensagem de ajuda');
end;

begin
  // CASO PADRÃO: Se executado por duplo clique ou sem parametros de analise -> Abre a Interface Grafica VCL (GUI)
  if (ParamCount = 0) or HasCmdSwitch('gui') then
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TFormMainMetrics, FormMainMetrics);
    Application.Run;
    Exit;
  end;

  // CASO CLI: Se parametros de analise forem passados por terminal -> Ativa o console e executa o processamento CLI
  if not AttachConsole(ATTACH_PARENT_PROCESS) then
    AllocConsole;

  CoInitialize(nil);
  try
    if HasCmdSwitch('help') or HasCmdSwitch('h') or HasCmdSwitch('?') then
    begin
      PrintHelp;
      Exit;
    end;

    var ProjectFile := GetCmdValue('project');
    if ProjectFile = '' then ProjectFile := GetCmdValue('p');

    var OutJsonFile := GetCmdValue('out');
    if OutJsonFile = '' then OutJsonFile := GetCmdValue('o');
    if OutJsonFile = '' then OutJsonFile := TPath.Combine(ExtractFilePath(ParamStr(0)), 'MetricasOutput.json');

    var OutHtmlFile := GetCmdValue('html');
    var GitRepoPath := GetCmdValue('git');
    var MaxCommitsStr := GetCmdValue('commits', '20');
    var EnableDb := HasCmdSwitch('db');
    var VersionCode := GetCmdValue('version', '1.0.0');

    if GitRepoPath <> '' then
    begin
      Writeln('Iniciando analise de evolucao Git em: ', GitRepoPath);
      var MaxCommits := StrToIntDef(MaxCommitsStr, 20);
      TGitAnalyzer.AnalyzeGitEvolution(GitRepoPath, ProjectFile, OutJsonFile, False, MaxCommits);
      Writeln('Evolucao Git salva em: ', OutJsonFile);

      if OutHtmlFile <> '' then
      begin
        THtmlReportGenerator.GenerateGitEvolutionReport(OutJsonFile, OutHtmlFile);
        Writeln('Dashboard de evolucao HTML gerado em: ', OutHtmlFile);
      end;
    end;

    if (ProjectFile <> '') and (GitRepoPath = '') then
    begin
      Writeln('Analisando projeto: ', ProjectFile);
      var SaveService := TSaveServiceFileFactory.CreateFileJson(OutJsonFile);
      TSevenAnalyticsAndMetrics.ExecuteProjectAnalysis(SaveService, ProjectFile);
      Writeln('Resultado JSON salvo em: ', OutJsonFile);

      if EnableDb then
      begin
        Writeln('Salvando no banco de dados para a versao: ', VersionCode);
        var DbService := TSaveServiceFileFactory.CreateDatabase(VersionCode, Now());
        TSevenAnalyticsAndMetrics.ExecuteProjectAnalysis(DbService, ProjectFile);
        Writeln('Métricas salvas no Banco de Dados com sucesso!');
      end;

      if OutHtmlFile <> '' then
      begin
        THtmlReportGenerator.GenerateProjectReport(OutJsonFile, OutHtmlFile);
        Writeln('Dashboard visual HTML gerado em: ', OutHtmlFile);
      end;
    end;
  except
    on E: Exception do
    begin
      Writeln('Erro durante a execucao CLI: ', E.Message);
      ExitCode := 1;
    end;
  end;
  CoUninitialize();
end.
