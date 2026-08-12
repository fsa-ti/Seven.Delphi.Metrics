unit Test.CodeAnalyzer;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.IOUtils,
  System.JSON,
  Seven.Delphi.Metrics.CodeAnalyzer,
  Seven.Delphi.Metrics.ProjectParser,
  Seven.Delphi.Metrics.GitAnalyzer,
  Seven.Delphi.Metrics.Engine,
  Seven.Delphi.Metrics.SaveService,
  Seven.Delphi.Metrics.PresetService;

type
  [TestFixture]
  TCodeAnalyzerTest = class
  private
    FTempDir: string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestLineCountingSampleCode;

    [Test]
    procedure TestCodeAnalyzerMetricsExtraction;

    [Test]
    procedure TestJsonSaveServiceStructure;

    [Test]
    procedure TestDprojParserExtraction;

    [Test]
    procedure TestGroupProjParserExtraction;

    [Test]
    procedure TestProjectAnalysisExecutionWithJson;

    [Test]
    procedure TestImplementationSectionXml;

    [Test]
    procedure TestGitAnalyzerGetCurrentHead;

    [Test]
    procedure TestGitAnalyzerEvolutionExport;
  end;

implementation

procedure TCodeAnalyzerTest.Setup;
begin
  FTempDir := TPath.Combine(TPath.GetTempPath, 'DelphiMetricsTests_' + TGuid.NewGuid.ToString);
  TDirectory.CreateDirectory(FTempDir);
end;

procedure TCodeAnalyzerTest.TearDown;
begin
  if TDirectory.Exists(FTempDir) then
    TDirectory.Delete(FTempDir, True);
end;

procedure TCodeAnalyzerTest.TestLineCountingSampleCode;
var
  Analyzer: TCodeAnalyzer;
  SampleFile: string;
  SampleCode: string;
begin
  SampleFile := TPath.Combine(FTempDir, 'TestUnit.pas');
  SampleCode :=
    'unit TestUnit;' + sLineBreak +
    '' + sLineBreak +
    'interface' + sLineBreak +
    '' + sLineBreak +
    '// Line comment' + sLineBreak +
    '(* Block comment *)' + sLineBreak +
    'type' + sLineBreak +
    '  IFoo = interface' + sLineBreak +
    '    procedure Bar;' + sLineBreak +
    '  end;' + sLineBreak +
    '' + sLineBreak +
    '  TFoo = class(TInterfacedObject, IFoo)' + sLineBreak +
    '  private' + sLineBreak +
    '    FVal: Integer;' + sLineBreak +
    '  public' + sLineBreak +
    '    procedure Bar;' + sLineBreak +
    '    property Val: Integer read FVal;' + sLineBreak +
    '  end;' + sLineBreak +
    '' + sLineBreak +
    'implementation' + sLineBreak +
    '' + sLineBreak +
    'procedure TFoo.Bar;' + sLineBreak +
    'begin' + sLineBreak +
    'end;' + sLineBreak +
    '' + sLineBreak +
    'end.';

  TFile.WriteAllText(SampleFile, SampleCode, TEncoding.UTF8);

  Analyzer := TCodeAnalyzer.Create();
  try
    Analyzer.AnalyzeFile(SampleFile);

    Assert.AreEqual<Integer>(1, Analyzer.Results.Count, 'Should analyze 1 file');
    const Stats = Analyzer.Results[0];

    Assert.AreEqual<Int64>(1, Stats.InterfaceCount, 'Interface count should be 1');
    Assert.AreEqual<Int64>(1, Stats.ClassCount, 'Class count should be 1');
    Assert.AreEqual<Int64>(1, Stats.PublicMethodCount, 'Public method count in class should be 1');
    Assert.AreEqual<Int64>(1, Stats.ClassPropertyCount, 'Class property count should be 1');
    Assert.IsTrue(Stats.BlankLineCount > 0, 'Blank lines should be > 0');
    Assert.IsTrue(Stats.CommentLineCount >= 2, 'Comment lines should be >= 2');
    Assert.IsTrue(Stats.LineCodeCount > 15, 'Total lines should be > 15');
  finally
    Analyzer.Free();
  end;
end;

procedure TCodeAnalyzerTest.TestCodeAnalyzerMetricsExtraction;
var
  Analyzer: TCodeAnalyzer;
  SampleFile: string;
  SampleCode: string;
begin
  SampleFile := TPath.Combine(FTempDir, 'ComplexUnit.pas');
  SampleCode :=
    'unit ComplexUnit;' + sLineBreak +
    'interface' + sLineBreak +
    'type' + sLineBreak +
    '  TMyEnum = (enumOne, enumTwo);' + sLineBreak +
    '  TMyRecord = record' + sLineBreak +
    '    X: Integer;' + sLineBreak +
    '  end;' + sLineBreak +
    'const' + sLineBreak +
    '  MY_CONST = 42;' + sLineBreak +
    'var' + sLineBreak +
    '  GVar: String;' + sLineBreak +
    'procedure GlobalProc;' + sLineBreak +
    'implementation' + sLineBreak +
    'procedure GlobalProc; begin end;' + sLineBreak +
    'end.';

  TFile.WriteAllText(SampleFile, SampleCode, TEncoding.UTF8);

  Analyzer := TCodeAnalyzer.Create();
  try
    Analyzer.AnalyzeFile(SampleFile);

    Assert.AreEqual<Integer>(1, Analyzer.Results.Count);
    const Stats = Analyzer.Results[0];

    Assert.AreEqual<Int64>(1, Stats.RecordCount, 'Record count should be 1');
    Assert.AreEqual<Int64>(1, Stats.GlobalConstantCount, 'Global constant count should be 1');
    Assert.AreEqual<Int64>(1, Stats.GlobalVariableCount, 'Global variable count should be 1');
    Assert.AreEqual<Int64>(1, Stats.GlobalFunctionCount, 'Global function count should be 1');
  finally
    Analyzer.Free();
  end;
end;

procedure TCodeAnalyzerTest.TestJsonSaveServiceStructure;
var
  Stats: TCodeStatistics;
  FileStat: TCodeFileStatistics;
  JsonFile: string;
  SaveService: ICodeAnalyzerSaveMetricsService;
  JsonContent: string;
  JsonObj: TJSONObject;
  FilesArray: TJSONArray;
  FirstFileObj: TJSONObject;
begin
  Stats := TCodeStatistics.Create();
  try
    Stats.FileName := 'TestProject.dproj';
    FileStat := Default(TCodeFileStatistics);
    FileStat.FileName := 'Unit1.pas';
    FileStat.ClassCount := 3;
    FileStat.LineCodeCount := 120;
    FileStat.ImplMethodCount := 5;
    FileStat.CyclomaticComplexity := 8;
    Stats.Add(FileStat);

    JsonFile := TPath.Combine(FTempDir, 'OutputMetrics.json');
    SaveService := TSaveServiceFileFactory.CreateFileJson(JsonFile);
    SaveService.Save(Stats);

    Assert.IsTrue(TFile.Exists(JsonFile), 'JSON file should be created');
    JsonContent := TFile.ReadAllText(JsonFile, TEncoding.UTF8);
    JsonObj := TJSONObject.ParseJSONValue(JsonContent) as TJSONObject;
    try
      Assert.IsNotNull(JsonObj, 'JSON should parse successfully');
      Assert.AreEqual('TestProject.dproj', JsonObj.GetValue('fileName').Value);
      Assert.AreEqual<Int64>(120, JsonObj.GetValue('totalLineCodeCount').AsType<Int64>);
      Assert.AreEqual<Int64>(3, JsonObj.GetValue('totalClassCount').AsType<Int64>);
      Assert.AreEqual<Int64>(5, JsonObj.GetValue('totalImplMethodCount').AsType<Int64>);
      Assert.AreEqual<Int64>(8, JsonObj.GetValue('totalCyclomaticComplexity').AsType<Int64>);

      FilesArray := JsonObj.GetValue('files') as TJSONArray;
      Assert.IsNotNull(FilesArray, 'files array should exist');
      Assert.AreEqual<Integer>(1, FilesArray.Count);

      FirstFileObj := FilesArray.Items[0] as TJSONObject;
      Assert.AreEqual('Unit1.pas', FirstFileObj.GetValue('fileName').Value);
      Assert.AreEqual<Int64>(3, FirstFileObj.GetValue('classCount').AsType<Int64>);
      Assert.AreEqual<Int64>(120, FirstFileObj.GetValue('lineCodeCount').AsType<Int64>);
      Assert.AreEqual<Int64>(5, FirstFileObj.GetValue('implMethodCount').AsType<Int64>);
      Assert.AreEqual<Int64>(8, FirstFileObj.GetValue('cyclomaticComplexity').AsType<Int64>);
    finally
      JsonObj.Free();
    end;
  finally
    Stats.Free();
  end;
end;

procedure TCodeAnalyzerTest.TestDprojParserExtraction;
var
  Unit1File, Unit2File, DprojFile: string;
  DprojXml: string;
  ExtractedFiles: TArray<string>;
begin
  Unit1File := TPath.Combine(FTempDir, 'Unit1.pas');
  Unit2File := TPath.Combine(FTempDir, 'Unit2.pas');
  TFile.WriteAllText(Unit1File, 'unit Unit1; interface implementation end.', TEncoding.UTF8);
  TFile.WriteAllText(Unit2File, 'unit Unit2; interface implementation end.', TEncoding.UTF8);

  DprojFile := TPath.Combine(FTempDir, 'TestApp.dproj');
  DprojXml :=
    '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">' +
    '  <ItemGroup>' +
    '    <DCCReference Include="Unit1.pas"/>' +
    '    <DCCReference Include="Unit2.pas"/>' +
    '  </ItemGroup>' +
    '</Project>';
  TFile.WriteAllText(DprojFile, DprojXml, TEncoding.UTF8);

  ExtractedFiles := TProjectParser.ExtractProjectFiles(DprojFile);
  Assert.AreEqual<Integer>(2, Length(ExtractedFiles), 'Should extract 2 units from dproj');
end;

procedure TCodeAnalyzerTest.TestGroupProjParserExtraction;
var
  SubDir1, SubDir2: string;
  Unit1File, Unit2File: string;
  Dproj1File, Dproj2File, GroupProjFile: string;
  GroupXml: string;
  ExtractedFiles: TArray<string>;
begin
  SubDir1 := TPath.Combine(FTempDir, 'Proj1');
  SubDir2 := TPath.Combine(FTempDir, 'Proj2');
  TDirectory.CreateDirectory(SubDir1);
  TDirectory.CreateDirectory(SubDir2);

  Unit1File := TPath.Combine(SubDir1, 'CoreUnit.pas');
  Unit2File := TPath.Combine(SubDir2, 'UiUnit.pas');
  TFile.WriteAllText(Unit1File, 'unit CoreUnit; interface implementation end.', TEncoding.UTF8);
  TFile.WriteAllText(Unit2File, 'unit UiUnit; interface implementation end.', TEncoding.UTF8);

  Dproj1File := TPath.Combine(SubDir1, 'CoreProj.dproj');
  TFile.WriteAllText(Dproj1File,
    '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">' +
    '  <ItemGroup><DCCReference Include="CoreUnit.pas"/></ItemGroup>' +
    '</Project>', TEncoding.UTF8);

  Dproj2File := TPath.Combine(SubDir2, 'UiProj.dproj');
  TFile.WriteAllText(Dproj2File,
    '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">' +
    '  <ItemGroup><DCCReference Include="UiUnit.pas"/></ItemGroup>' +
    '</Project>', TEncoding.UTF8);

  GroupProjFile := TPath.Combine(FTempDir, 'MyGroup.groupproj');
  GroupXml :=
    '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">' +
    '  <ItemGroup>' +
    '    <Projects Include="Proj1\CoreProj.dproj"/>' +
    '    <Projects Include="Proj2\UiProj.dproj"/>' +
    '  </ItemGroup>' +
    '</Project>';
  TFile.WriteAllText(GroupProjFile, GroupXml, TEncoding.UTF8);

  ExtractedFiles := TProjectParser.ExtractProjectFiles(GroupProjFile);
  Assert.AreEqual<Integer>(2, Length(ExtractedFiles), 'Should extract 2 units across group projects');
end;

procedure TCodeAnalyzerTest.TestProjectAnalysisExecutionWithJson;
var
  UnitFile, DprojFile, JsonFile: string;
  SaveService: ICodeAnalyzerSaveMetricsService;
  JsonContent: string;
  JsonObj: TJSONObject;
begin
  UnitFile := TPath.Combine(FTempDir, 'SampleUnit.pas');
  TFile.WriteAllText(UnitFile, 'unit SampleUnit; interface type TTest = class end; implementation end.', TEncoding.UTF8);

  DprojFile := TPath.Combine(FTempDir, 'SampleProj.dproj');
  TFile.WriteAllText(DprojFile,
    '<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">' +
    '  <ItemGroup><DCCReference Include="SampleUnit.pas"/></ItemGroup>' +
    '</Project>', TEncoding.UTF8);

  JsonFile := TPath.Combine(FTempDir, 'ProjectResult.json');
  SaveService := TSaveServiceFileFactory.CreateFileJson(JsonFile);

  TSevenAnalyticsAndMetrics.ExecuteProjectAnalysis(SaveService, DprojFile);

  Assert.IsTrue(TFile.Exists(JsonFile), 'JSON result should exist');
  JsonContent := TFile.ReadAllText(JsonFile, TEncoding.UTF8);
  JsonObj := TJSONObject.ParseJSONValue(JsonContent) as TJSONObject;
  try
    Assert.IsNotNull(JsonObj);
    Assert.AreEqual<Int64>(1, JsonObj.GetValue('totalClassCount').AsType<Int64>);
  finally
    JsonObj.Free();
  end;
end;

procedure TCodeAnalyzerTest.TestImplementationSectionXml;
var
  Analyzer: TCodeAnalyzer;
  SampleFile: string;
  SampleCode: string;
begin
  SampleFile := TPath.Combine(FTempDir, 'ImplUnit.pas');
  SampleCode :=
    'unit ImplUnit;' + sLineBreak +
    'interface' + sLineBreak +
    'procedure DoWork(Val: Integer);' + sLineBreak +
    'implementation' + sLineBreak +
    'procedure DoWork(Val: Integer);' + sLineBreak +
    'begin' + sLineBreak +
    '  if Val > 10 then' + sLineBreak +
    '    Writeln(''High'')' + sLineBreak +
    '  else' + sLineBreak +
    '    Writeln(''Low'');' + sLineBreak +
    '  while Val > 0 do' + sLineBreak +
    '    Dec(Val);' + sLineBreak +
    'end;' + sLineBreak +
    'end.';

  TFile.WriteAllText(SampleFile, SampleCode, TEncoding.UTF8);

  Analyzer := TCodeAnalyzer.Create();
  try
    Analyzer.AnalyzeFile(SampleFile);
    Assert.AreEqual<Integer>(1, Analyzer.Results.Count);
    const Stats = Analyzer.Results[0];

    Assert.AreEqual<Int64>(1, Stats.ImplMethodCount, 'Implementation method count should be 1');
    Assert.IsTrue(Stats.CyclomaticComplexity >= 3, 'Cyclomatic complexity should include base + if + while (>=3)');
  finally
    Analyzer.Free();
  end;
end;

procedure TCodeAnalyzerTest.TestGitAnalyzerGetCurrentHead;
var
  RepoPath: string;
  HeadRef: string;
begin
  RepoPath := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..\..\'));
  HeadRef := TGitAnalyzer.GetCurrentHead(RepoPath);
  Assert.IsTrue(HeadRef <> '', 'Head ref should not be empty');
end;

procedure TCodeAnalyzerTest.TestGitAnalyzerEvolutionExport;
var
  RepoPath, OutputJson: string;
  JsonContent: string;
  JsonObj: TJSONObject;
  Series: TJSONArray;
begin
  RepoPath := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\..\..\'));
  OutputJson := TPath.Combine(FTempDir, 'GitEvolution.json');

  TGitAnalyzer.AnalyzeGitEvolution(RepoPath, 'Seven.Delphi.Metrics.dproj', OutputJson, False, 3);

  Assert.IsTrue(TFile.Exists(OutputJson), 'Git evolution JSON should be created');
  JsonContent := TFile.ReadAllText(OutputJson, TEncoding.UTF8);
  JsonObj := TJSONObject.ParseJSONValue(JsonContent) as TJSONObject;
  try
    Assert.IsNotNull(JsonObj);
    Series := JsonObj.GetValue('evolutionSeries') as TJSONArray;
    Assert.IsNotNull(Series, 'evolutionSeries should exist');
    Assert.IsTrue(Series.Count > 0, 'evolutionSeries should contain at least 1 entry');
  finally
    JsonObj.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TCodeAnalyzerTest);

end.
