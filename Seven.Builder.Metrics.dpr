program Seven.Builder.Metrics;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.IOUtils,
  Winapi.ActiveX,
  Seven.Builder.AnalyticsAndMetrics.GitAnalyzer in 'Source\Seven.Builder.AnalyticsAndMetrics.GitAnalyzer.pas',
  Seven.Builder.AnalyticsAndMetrics.ProjectParser in 'Source\Seven.Builder.AnalyticsAndMetrics.ProjectParser.pas',
  Seven.Builder.AnalyticsAndMetrics.CodeAnalyzer in 'Source\Seven.Builder.AnalyticsAndMetrics.CodeAnalyzer.pas',
  Seven.Builder.AnalyticsAndMetrics in 'Source\Seven.Builder.AnalyticsAndMetrics.pas',
  Seven.Builder.AnalyticsAndMetrics.SaveService in 'Source\Seven.Builder.AnalyticsAndMetrics.SaveService.pas';

{$R *.res}

begin
  CoInitialize(nil);
  try
    const ExeDir = ExtractFilePath(ParamStr(0));
    const ProjectFile = TPath.GetFullPath(TPath.Combine(ExeDir, '..\..\Seven.Builder.Metrics.dproj'));
    const OutputJson = TPath.Combine(ExeDir, 'MetricasOutput.json');

    Writeln('=== Seven Builder Metrics ===');
    Writeln('Analisando projeto: ', ProjectFile);

    const SaveService = TSaveServiceFileFactory.CreateFileJson(OutputJson);
    TSevenAnalyticsAndMetrics.ExecuteProjectAnalysis(SaveService, ProjectFile);

    Writeln('Análise concluída com sucesso!');
    Writeln('Relatório salvo em: ', OutputJson);
  except
    on E: Exception do
    begin
      Writeln('Erro durante a execução: ', E.Message);
      ExitCode := 1;
    end;
  end;
  CoUninitialize();
end.
