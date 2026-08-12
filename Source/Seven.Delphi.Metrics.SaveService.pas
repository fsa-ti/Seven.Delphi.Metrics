unit Seven.Delphi.Metrics.SaveService;

interface

uses
  Seven.Delphi.Metrics.CodeAnalyzer;

type
  TSaveServiceFileFactory = record
  public
    class function CreateFileJson(const FileName: string): ICodeAnalyzerSaveMetricsService; static;
    class function CreateDatabase(const VersionCode: string; const VersionDate: TDateTime; const IniConfigFile: string = ''): ICodeAnalyzerSaveMetricsService; static;
  end;

implementation

uses
  System.JSON,
  System.IOUtils,
  System.SysUtils,
  Breeze.Redist.Database.Client;

type
  TCodeAnalyzerSaveMetricsServiceFileJson = class(TInterfacedObject, ICodeAnalyzerSaveMetricsService)
  private
    FFileName: string;
  public
    constructor Create(const FileName: string);
    procedure Save(const CodeStatistics: TCodeStatistics);
  end;

  TCodeAnalyzerSaveMetricsServiceDatabase = class(TInterfacedObject, ICodeAnalyzerSaveMetricsService)
  private
    FVersionCode: string;
    FVersionDate: TDateTime;
    FIniConfigFile: string;
  public
    constructor Create(const VersionCode: string; const VersionDate: TDateTime; const IniConfigFile: string = '');
    procedure Save(const CodeStatistics: TCodeStatistics);
  end;

{ TCodeAnalyzerSaveMetricsServiceFile }

constructor TCodeAnalyzerSaveMetricsServiceFileJson.Create(const FileName: string);
begin
  FFileName := FileName;
end;

procedure TCodeAnalyzerSaveMetricsServiceFileJson.Save(const CodeStatistics: TCodeStatistics);
begin
  const JSON = TJSONObject.Create();
  JSON.AddPair('fileName', CodeStatistics.FileName)
      .AddPair('totalBlankLineCount', CodeStatistics.GetTotalBlankLineCount())
      .AddPair('totalLineCodeCount', CodeStatistics.GetTotalLineCodeCount())
      .AddPair('totalCommentLineCount', CodeStatistics.GetTotalCommentLineCount())
      .AddPair('totalClassCount', CodeStatistics.GetTotalClassCount())
      .AddPair('totalClassPropertyCount', CodeStatistics.GetTotalClassPropertyCount())
      .AddPair('totalRecordPropertyCount', CodeStatistics.GetTotalRecordPropertyCount())
      .AddPair('totalInterfaceCount', CodeStatistics.GetTotalInterfaceCount())
      .AddPair('totalInterfacePropertyCount', CodeStatistics.GetTotalInterfacePropertyCount())
      .AddPair('totalRecordCount', CodeStatistics.GetTotalRecordCount())
      .AddPair('totalEnumCount', CodeStatistics.GetTotalEnumCount())
      .AddPair('totalPublicMethodCount', CodeStatistics.GetTotalPublicMethodCount())
      .AddPair('totalPrivateMethodCount', CodeStatistics.GetTotalPrivateMethodCount())
      .AddPair('totalProtectedMethodCount', CodeStatistics.GetTotalProtectedMethodCount())
      .AddPair('totalStaticMethodCount', CodeStatistics.GetTotalStaticMethodCount())
      .AddPair('totalImplMethodCount', CodeStatistics.GetTotalImplMethodCount())
      .AddPair('totalCyclomaticComplexity', CodeStatistics.GetTotalCyclomaticComplexity())
      .AddPair('totalGlobalFunctionCount', CodeStatistics.GetTotalGlobalFunctionCount())
      .AddPair('totalGlobalVariableCount', CodeStatistics.GetTotalGlobalVariableCount())
      .AddPair('totalGlobalConstantCount', CodeStatistics.GetTotalGlobalConstantCount())
      .AddPair('totalAnalysisTimeMs', CodeStatistics.GetTotalAnalysisTimeMs());

  const JSONFiles = TJSONArray.Create();

  for var FileStat in CodeStatistics do
  begin
    const Item = TJSONObject.Create();
    Item.AddPair('fileName', FileStat.FileName)
        .AddPair('lineCodeCount', FileStat.LineCodeCount)
        .AddPair('commentLineCount', FileStat.CommentLineCount)
        .AddPair('blankLineCount', FileStat.BlankLineCount)
        .AddPair('classCount', FileStat.ClassCount)
        .AddPair('interfaceCount', FileStat.InterfaceCount)
        .AddPair('recordCount', FileStat.RecordCount)
        .AddPair('enumCount', FileStat.EnumCount)
        .AddPair('publicMethodCount', FileStat.PublicMethodCount)
        .AddPair('privateMethodCount', FileStat.PrivateMethodCount)
        .AddPair('protectedMethodCount', FileStat.ProtectedMethodCount)
        .AddPair('staticMethodCount', FileStat.StaticMethodCount)
        .AddPair('implMethodCount', FileStat.ImplMethodCount)
        .AddPair('cyclomaticComplexity', FileStat.CyclomaticComplexity)
        .AddPair('classPropertyCount', FileStat.ClassPropertyCount)
        .AddPair('recordPropertyCount', FileStat.RecordPropertyCount)
        .AddPair('interfacePropertyCount', FileStat.InterfacePropertyCount)
        .AddPair('globalFunctionCount', FileStat.GlobalFunctionCount)
        .AddPair('globalVariableCount', FileStat.GlobalVariableCount)
        .AddPair('globalConstantCount', FileStat.GlobalConstantCount)
        .AddPair('analysisTimeMs', FileStat.AnalysisTimeMs);
    JSONFiles.Add(Item);
  end;

  JSON.AddPair('files', JSONFiles);

  const JsonStr = JSON.ToJSON();
  TFile.WriteAllText(FFileName, JsonStr, TEncoding.UTF8);
end;

{ TSaveServiceFileFactory }

class function TSaveServiceFileFactory.CreateDatabase(const VersionCode: string; const VersionDate: TDateTime; const IniConfigFile: string): ICodeAnalyzerSaveMetricsService;
begin
  Result := TCodeAnalyzerSaveMetricsServiceDatabase.Create(VersionCode, VersionDate, IniConfigFile);
end;

class function TSaveServiceFileFactory.CreateFileJson(const FileName: string): ICodeAnalyzerSaveMetricsService;
begin
  Result := TCodeAnalyzerSaveMetricsServiceFileJson.Create(FileName);
end;

{ TCodeAnalyzerSaveMetricsServiceDatabase }

constructor TCodeAnalyzerSaveMetricsServiceDatabase.Create(const VersionCode: string; const VersionDate: TDateTime; const IniConfigFile: string);
begin
  FVersionCode := VersionCode;
  FVersionDate := VersionDate;
  FIniConfigFile := IniConfigFile;
end;

procedure TCodeAnalyzerSaveMetricsServiceDatabase.Save(const CodeStatistics: TCodeStatistics);
begin
  const Connection = TBreezeDatabaseDll.CreateConnection();
  Connection.Config.Provider := TBreezeProviderDatabase.Postgres;
  Connection.Config.Database := 'Metricas';
  Connection.Config.Server := 'localhost';
  Connection.Config.Port := 5434;
  Connection.Config.User := 'postgres';
  Connection.Config.Password := '123456';
  Connection.Config.Description := 'Data7 Matriz';

  if not Connection.Open() then
    raise Exception.Create('Não foi possível estabelecer a conexão com o banco de dados.');

  Connection.ExecuteInTransaction(procedure
    begin
      const Insert = Connection.CreateInsert('Salvar métricas do banco de dados.');
      const TableName = 'MetricaCodigo';
      Insert.TableName := TableName;
      const CodeMetricaCodigo = Connection.MaxTable(TableName, 'CodMetricaCodigo') + 1;

      Insert.SetValue('CodMetricaCodigo', CodeMetricaCodigo);
      Insert.SetValue('Versao', FVersionCode);
      Insert.SetValue('DataVersao', FVersionDate);
      Insert.SetValue('NomeArquivo', CodeStatistics.FileName);
      Insert.SetValue('TotalArquivos', Length(CodeStatistics.GetFileNames));
      Insert.SetValue('TotalLinhasEmBranco', CodeStatistics.GetTotalBlankLineCount());
      Insert.SetValue('TotalLinhasCodigo', CodeStatistics.GetTotalLineCodeCount());
      Insert.SetValue('TotalLinhasComentadas', CodeStatistics.GetTotalCommentLineCount());
      Insert.SetValue('TotalClasses', CodeStatistics.GetTotalClassCount());
      Insert.SetValue('TotalPropriedadeClasses', CodeStatistics.GetTotalClassPropertyCount());
      Insert.SetValue('TotalPropriedadeRecord', CodeStatistics.GetTotalRecordPropertyCount());
      Insert.SetValue('TotalInterfaces', CodeStatistics.GetTotalInterfaceCount());
      Insert.SetValue('TotalPropriedadeRecordInterface', CodeStatistics.GetTotalInterfacePropertyCount());
      Insert.SetValue('TotalRecords', CodeStatistics.GetTotalRecordCount());
      Insert.SetValue('TotalEnumerados', CodeStatistics.GetTotalEnumCount());
      Insert.SetValue('TotalMetodosPublicos', CodeStatistics.GetTotalPublicMethodCount());
      Insert.SetValue('TotalMetodosPrivados', CodeStatistics.GetTotalPrivateMethodCount());
      Insert.SetValue('TotalMetodosProtegidos', CodeStatistics.GetTotalProtectedMethodCount());
      Insert.SetValue('TotalMetodosEstaticos', CodeStatistics.GetTotalStaticMethodCount());
      Insert.SetValue('TotalMetodosImplementados', CodeStatistics.GetTotalImplMethodCount());
      Insert.SetValue('ComplexidadeCiclomatica', CodeStatistics.GetTotalCyclomaticComplexity());
      Insert.SetValue('TotalFuncaoGlobal', CodeStatistics.GetTotalGlobalFunctionCount());
      Insert.SetValue('TotalVariavelGlobal', CodeStatistics.GetTotalGlobalVariableCount());
      Insert.SetValue('TotalConstanteGlobal', CodeStatistics.GetTotalGlobalConstantCount());
      Insert.SetValue('TempoAnaliseMS', CodeStatistics.GetTotalAnalysisTimeMs());
      Insert.SetValue('DataHoraInclusao', Now());
      Insert.SetValue('EstacaoTrabalhoInclusao', 'SERVER');
      Insert.SetValue('VersaoInlcusao', '1.0.0.0');
      Insert.Execute();

      for var FileStat in CodeStatistics do
      begin
        const InsertFile = Connection.CreateInsert('Salvar métricas do banco de dados.');
        const TableNameFile = 'ArquivoMetricaCodigo';
        InsertFile.TableName := TableNameFile;

        InsertFile.SetValue('CodArquivoMetricaCodigo', Connection.MaxTable(TableNameFile, 'CodArquivoMetricaCodigo') + 1);
        InsertFile.SetValue('CodMetricaCodigo', CodeMetricaCodigo);
        InsertFile.SetValue('NomeArquivo', FileStat.FileName);
        InsertFile.SetValue('TotalLinhasEmBranco', FileStat.BlankLineCount);
        InsertFile.SetValue('TotalLinhasCodigo', FileStat.LineCodeCount);
        InsertFile.SetValue('TotalLinhasComentadas', FileStat.CommentLineCount);
        InsertFile.SetValue('TotalClasses', FileStat.ClassCount);
        InsertFile.SetValue('TotalPropriedadeClasses', FileStat.ClassPropertyCount);
        InsertFile.SetValue('TotalInterfaces', FileStat.InterfaceCount);
        InsertFile.SetValue('TotalRecords', FileStat.RecordCount);
        InsertFile.SetValue('TotalEnumerados', FileStat.EnumCount);
        InsertFile.SetValue('TotalMetodosPublicos', FileStat.PublicMethodCount);
        InsertFile.SetValue('TotalMetodosPrivados', FileStat.PrivateMethodCount);
        InsertFile.SetValue('TotalMetodosProtegidos', FileStat.ProtectedMethodCount);
        InsertFile.SetValue('TotalMetodosEstaticos', FileStat.StaticMethodCount);
        InsertFile.SetValue('TotalMetodosImplementados', FileStat.ImplMethodCount);
        InsertFile.SetValue('ComplexidadeCiclomatica', FileStat.CyclomaticComplexity);
        InsertFile.SetValue('TotalFuncaoGlobal', FileStat.GlobalFunctionCount);
        InsertFile.SetValue('TotalVariavelGlobal', FileStat.GlobalVariableCount);
        InsertFile.SetValue('TotalConstanteGlobal', FileStat.GlobalConstantCount);
        InsertFile.SetValue('DataHoraInclusao', Now());
        InsertFile.SetValue('EstacaoTrabalhoInclusao', 'SERVER');
        InsertFile.SetValue('VersaoInlcusao', '1.0.0.0');
        InsertFile.Execute();
      end;
    end);
end;

end.
