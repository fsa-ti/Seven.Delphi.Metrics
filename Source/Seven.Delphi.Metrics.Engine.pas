unit Seven.Delphi.Metrics.Engine;

interface

uses
  Seven.Delphi.Metrics.CodeAnalyzer,
  Seven.Delphi.Metrics.ProjectParser;

type
  TSevenAnalyticsAndMetrics = class
  private
    class procedure ExecuteFileAnalysis(const CodeAnalyzer: TCodeAnalyzer; const FileName: string); overload; static;
  public
    class procedure ExecuteProjectAnalysis(const SaveService: ICodeAnalyzerSaveMetricsService; const ProjectFile: string); static;
    class procedure ExecuteFileAnalysis(const SaveService: ICodeAnalyzerSaveMetricsService; const FileName: string); overload; static;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils;

{ TSevenAnalyticsAndMetrics }

class procedure TSevenAnalyticsAndMetrics.ExecuteFileAnalysis(const SaveService: ICodeAnalyzerSaveMetricsService; const FileName: string);
begin
  const CodeAnalyzer = TCodeAnalyzer.Create();
  try
    CodeAnalyzer.SaveMetricsService := SaveService;
    CodeAnalyzer.Results.Reset();
    CodeAnalyzer.Results.FileName := FileName;

    ExecuteFileAnalysis(CodeAnalyzer, FileName);

    CodeAnalyzer.SaveResults();
  finally
    CodeAnalyzer.Free();
  end;
end;

class procedure TSevenAnalyticsAndMetrics.ExecuteFileAnalysis(const CodeAnalyzer: TCodeAnalyzer; const FileName: string);
begin
  const ExtensionFile = TPath.GetExtension(FileName).ToLower();

  if (ExtensionFile = '.pas') or (ExtensionFile = '.dpk') or (ExtensionFile = '.dpr') or (ExtensionFile = '.inc') then
  begin
    try
      if TFile.Exists(FileName) then
        CodeAnalyzer.AnalyzeFile(FileName);
    except on E: Exception do
      raise Exception.CreateFmt('Erro ao analisar o arquivo %s. Erro causado por: %s', [FileName, E.Message]);
    end;
  end;
end;

class procedure TSevenAnalyticsAndMetrics.ExecuteProjectAnalysis(const SaveService: ICodeAnalyzerSaveMetricsService; const ProjectFile: string);
begin
  if not TFile.Exists(ProjectFile) then
    raise Exception.CreateFmt('Arquivo "%s" não existe', [ProjectFile]);

  const CodeAnalyzer = TCodeAnalyzer.Create();
  try
    CodeAnalyzer.SaveMetricsService := SaveService;
    CodeAnalyzer.Results.Reset();
    CodeAnalyzer.Results.FileName := ProjectFile;

    const FilesToAnalyze = TProjectParser.ExtractProjectFiles(ProjectFile);

    for var FileName in FilesToAnalyze do
    begin
      ExecuteFileAnalysis(CodeAnalyzer, FileName);
    end;

    CodeAnalyzer.SaveResults();
  finally
    CodeAnalyzer.Free();
  end;
end;

end.
