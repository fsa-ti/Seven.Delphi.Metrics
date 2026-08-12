// Marcelo Melo
// 03/05/2025
// Pequenas modificações Fernando
// 15/05/2025
// Baseado do arquivo original "Seven.OpenToolsAPI.AnalyticsAndMetrics.CodeAnalyzer"
unit Seven.Builder.AnalyticsAndMetrics.CodeAnalyzer;

interface

uses
  Xml.XMLIntf,
  Seven.DelphiAST.Classes,
  System.Generics.Collections;

type
  ICodeAnalyzerSaveMetricsService = interface;

  TCodeFileStatistics = record
    FileName: string;

    LineCodeCount,
    CommentLineCount,
    BlankLineCount,

    ClassCount,
    InterfaceCount,
    RecordCount,
    EnumCount,
    PublicMethodCount,
    PrivateMethodCount,
    ProtectedMethodCount,
    StaticMethodCount,
    ImplMethodCount,
    CyclomaticComplexity,
    ClassPropertyCount,
    RecordPropertyCount,
    InterfacePropertyCount,
    GlobalFunctionCount,
    GlobalVariableCount,
    GlobalConstantCount: Int64;

    AnalysisTimeMs: Double;
  end;

  TCodeStatistics = class(TList<TCodeFileStatistics>)
  private
    FProjectCount: Int64;
    FFileName: string;
  public
    property FileName: string read FFileName write FFileName;
    property ProjectCount: Int64 read FProjectCount write FProjectCount;

    function GetFileNames(): TArray<string>;

    function GetTotalLineCodeCount(): Int64;
    function GetTotalCommentLineCount(): Int64;
    function GetTotalBlankLineCount(): Int64;

    function GetTotalClassCount(): Int64;
    function GetTotalClassPropertyCount(): Int64;
    function GetTotalRecordPropertyCount(): Int64;
    function GetTotalInterfaceCount(): Int64;
    function GetTotalInterfacePropertyCount(): Int64;
    function GetTotalRecordCount(): Int64;
    function GetTotalEnumCount(): Int64;
    function GetTotalPublicMethodCount(): Int64;
    function GetTotalPrivateMethodCount(): Int64;
    function GetTotalProtectedMethodCount(): Int64;
    function GetTotalStaticMethodCount(): Int64;
    function GetTotalImplMethodCount(): Int64;
    function GetTotalCyclomaticComplexity(): Int64;
    function GetTotalGlobalFunctionCount(): Int64;
    function GetTotalGlobalVariableCount(): Int64;
    function GetTotalGlobalConstantCount: Int64;

    function GetTotalAnalysisTimeMs(): Double;

    function FileExists(const FileName: string): Boolean;
    procedure Reset();
  end;

  TCodeAnalyzer = class
  private
    FXMLDoc: IXMLDocument;
    FResults: TCodeStatistics;
    FSaveMetricsService: ICodeAnalyzerSaveMetricsService;

    function ParseFileToXML(const AFileName: string; var ATotalCommentLines: Integer; var ATotalBlankLines: Integer; var ATotalSourceLines: Integer): string;
    function GetNodeCount(const XPathExpr: string): Int64;
    function CountNewLines(const AText: string): Integer;
    function CountCommentLines(const AComments: TObjectList<TCommentNode>): Integer;
    function CountBlankLines(const ASourceCode: string): Integer;
  public
    constructor Create();
    destructor Destroy; override;
    property Results: TCodeStatistics read FResults;

    procedure AnalyzeFile(const FileName: string);
    property SaveMetricsService: ICodeAnalyzerSaveMetricsService read FSaveMetricsService write FSaveMetricsService;
    procedure SaveResults();
  end;

  ICodeAnalyzerSaveMetricsService = interface
    ['{B7BFA701-7AE0-41F1-B4E7-B1AFF4C97464}']
    procedure Save(const CodeStatistics: TCodeStatistics);
  end;

implementation

uses
  Xml.XMLDoc,
  Xml.xmldom,
  Winapi.msxml,
  Winapi.ActiveX,
  System.IOUtils,
  System.Classes,
  System.SysUtils,
  Seven.DelphiAST,
  System.Diagnostics,
  Seven.DelphiAST.Writer;

{ TCodeStatistics }

function TCodeStatistics.FileExists(const FileName: string): Boolean;
begin
  Result := False;
  for var Index := 0 to Self.Count - 1 do
  begin
    if Self[Index].FileName.ToLower() = FileName.ToLower() then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TCodeStatistics.GetFileNames(): TArray<string>;
begin
  SetLength(Result, Self.Count);
  for var Index := 0 to Self.Count - 1 do
    Result[Index] := Self[Index].FileName;
end;

function TCodeStatistics.GetTotalLineCodeCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].LineCodeCount;
end;

function TCodeStatistics.GetTotalCommentLineCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].CommentLineCount;
end;

function TCodeStatistics.GetTotalBlankLineCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].BlankLineCount;
end;

function TCodeStatistics.GetTotalClassCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].ClassCount;
end;

function TCodeStatistics.GetTotalClassPropertyCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].ClassPropertyCount;
end;

function TCodeStatistics.GetTotalRecordPropertyCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].RecordPropertyCount;
end;

function TCodeStatistics.GetTotalInterfaceCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].InterfaceCount;
end;

function TCodeStatistics.GetTotalInterfacePropertyCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].InterfacePropertyCount;
end;

function TCodeStatistics.GetTotalRecordCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].RecordCount;
end;

function TCodeStatistics.GetTotalEnumCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].EnumCount;
end;

function TCodeStatistics.GetTotalPublicMethodCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].PublicMethodCount;
end;

function TCodeStatistics.GetTotalPrivateMethodCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].PrivateMethodCount;
end;

function TCodeStatistics.GetTotalProtectedMethodCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].ProtectedMethodCount;
end;

function TCodeStatistics.GetTotalStaticMethodCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].StaticMethodCount;
end;

function TCodeStatistics.GetTotalImplMethodCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].ImplMethodCount;
end;

function TCodeStatistics.GetTotalCyclomaticComplexity(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].CyclomaticComplexity;
end;

function TCodeStatistics.GetTotalGlobalFunctionCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].GlobalFunctionCount;
end;

function TCodeStatistics.GetTotalGlobalVariableCount(): Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].GlobalVariableCount;
end;

function TCodeStatistics.GetTotalGlobalConstantCount: Int64;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].GlobalConstantCount;
end;

function TCodeStatistics.GetTotalAnalysisTimeMs(): Double;
begin
  Result := 0;
  for var Index := 0 to Self.Count - 1 do
    Result := Result + Self[Index].AnalysisTimeMs;
end;

procedure TCodeStatistics.Reset();
begin
  Self.Clear();
  FProjectCount := 0;
  FFileName := '';
end;

{ TCodeAnalyzer }

constructor TCodeAnalyzer.Create();
begin
  inherited Create;
  FResults := TCodeStatistics.Create();
  FXMLDoc := TXMLDocument.Create(nil);
  FXMLDoc.Options := [doNodeAutoCreate, doNodeAutoIndent];
end;

destructor TCodeAnalyzer.Destroy;
begin
  FreeAndNil(FResults);
  FXMLDoc := nil;
  inherited;
end;

//------------------------------------------------------------------------------
// Função auxiliar para contar linhas em um texto (para comentários)
//------------------------------------------------------------------------------
function TCodeAnalyzer.CountNewLines(const AText: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(AText) do
    if AText[I] = #10 then Inc(Result);
end;

//------------------------------------------------------------------------------
// Função para contar linhas únicas que contêm comentários
//------------------------------------------------------------------------------
function TCodeAnalyzer.CountCommentLines(const AComments: TObjectList<TCommentNode>): Integer;
var
  CommentLines: THashSet<Integer>;
  LComment: TCommentNode;
  StartLine, EndLine, LineNum, NewLines: Integer;
begin
  Result := 0;
  if not Assigned(AComments) then Exit();
  CommentLines := THashSet<Integer>.Create;
  try
    for LComment in AComments do
    begin
      StartLine := LComment.Line;
      NewLines := CountNewLines(LComment.Text);
      EndLine := StartLine + NewLines;
      for LineNum := StartLine to EndLine do
        CommentLines.Add(LineNum);
    end;
    Result := CommentLines.Count;
  finally
    CommentLines.Free;
  end;
end;

//------------------------------------------------------------------------------
// Função para contar linhas em branco no código fonte original
//------------------------------------------------------------------------------
function TCodeAnalyzer.CountBlankLines(const ASourceCode: string): Integer;
var
  LReader: TStringReader;
  LLine: string;
begin
  Result := 0;
  if ASourceCode = '' then Exit(); // Se não houver código, não há linhas em branco

  // Usar TStringReader para ler linha por linha eficientemente
  LReader := TStringReader.Create(ASourceCode);
  try
    while not LReader.EndOfStream do
    begin
      LLine := LReader.ReadLine;
      // Considera uma linha em branco se, após remover espaços/tabs, ela estiver vazia
      if Trim(LLine) = '' then
        Inc(Result);
    end;
  finally
    LReader.Free;
  end;
end;

function TCodeAnalyzer.ParseFileToXML(const AFileName: string; var ATotalCommentLines: Integer; var ATotalBlankLines: Integer; var ATotalSourceLines: Integer): string;
var
  SyntaxTree: TSyntaxNode;
  Builder: TPasSyntaxTreeBuilder;
  SourceCodeStringStream: TStringStream;
  XMLOutput: string;
  ComInitNeeded: Boolean;
begin
  ComInitNeeded := Succeeded(CoInitialize(nil));
  Result := '';
  ATotalCommentLines := 0;
  ATotalBlankLines := 0;
  ATotalSourceLines := 0;

  SourceCodeStringStream := TStringStream.Create();
  Builder := TPasSyntaxTreeBuilder.Create;
  try
    SourceCodeStringStream.LoadFromFile(AFileName);
    SourceCodeStringStream.Position := 0;

    try
      SyntaxTree := Builder.Run(SourceCodeStringStream);
      try
        XMLOutput := TSyntaxTreeWriter.ToXML(SyntaxTree, True);

        // --- Análise fora do XML ---
        ATotalCommentLines := CountCommentLines(Builder.Comments);
        ATotalBlankLines   := CountBlankLines(SourceCodeStringStream.DataString); // Conta linhas em branco do fonte
        ATotalSourceLines := CountNewLines(SourceCodeStringStream.DataString);

        Result := XMLOutput;
      finally
        SyntaxTree.Free;
      end;
    except
      on E: ESyntaxTreeException do
      begin
        if Assigned(E.SyntaxTree) then
        begin
          XMLOutput := TSyntaxTreeWriter.ToXML(E.SyntaxTree, True);
          Result := XMLOutput;
        end;
        raise Exception.CreateFmt('Erro de análise sintática [%d, %d]: %s',
                                 [E.Line, E.Col, E.Message]);
      end;
    end;
  finally
    SourceCodeStringStream.Free();
    Builder.Free();
    if ComInitNeeded then
      CoUninitialize();
  end;
end;

procedure TCodeAnalyzer.SaveResults;
begin
  if not Assigned(FSaveMetricsService) then
    raise Exception.Create('Propriedade SaveMetricsService não foi configurada');

  FSaveMetricsService.Save(FResults);
end;

function TCodeAnalyzer.GetNodeCount(const XPathExpr: string): Int64;
var
  NodeSelect: IDOMNodeSelect;
  Nodes: IDOMNodeList;
begin
  Result := 0;

  // Garante que o documento e seu elemento raiz existem
  if not Assigned(FXMLDoc) or not Assigned(FXMLDoc.DocumentElement) or not Assigned(FXMLDoc.DOMDocument) then
    Exit();

  if Supports(FXMLDoc.DOMDocument, IDOMNodeSelect, NodeSelect) then
  begin
    Nodes := NodeSelect.SelectNodes(XPathExpr);
    if Assigned(Nodes) then
      Result := Nodes.length;
  end;
end;

procedure TCodeAnalyzer.AnalyzeFile(const FileName: string);
var
  XMLContent: string;
  StopWatch: TStopwatch;
  CodeFileStatistics: TCodeFileStatistics;
  TotalCommentLines: Integer;
  TotalBlankLines: Integer;
  TotalSourceLines: Integer;
begin
  if not TFile.Exists(FileName) then
    Exit();

  if Results.FileExists(FileName) then
    Exit();

  // Inicializar estatísticas
  CodeFileStatistics := Default(TCodeFileStatistics);
  CodeFileStatistics.FileName := FileName;
  StopWatch := TStopwatch.StartNew();

  // Obter o XML do arquivo
  TotalCommentLines := 0;
  TotalBlankLines := 0;
  TotalSourceLines := 0;
  XMLContent := ParseFileToXML(FileName, TotalCommentLines, TotalBlankLines, TotalSourceLines);
  CodeFileStatistics.CommentLineCount := TotalCommentLines;
  CodeFileStatistics.BlankLineCount := TotalBlankLines;
  CodeFileStatistics.LineCodeCount := TotalSourceLines;

  // Carregar o XML no documento
  FXMLDoc.LoadFromXML(XMLContent);

  // Realiza as contagens XPath (incluindo novas e refinadas)
  CodeFileStatistics.ClassCount := GetNodeCount('/UNIT/INTERFACE//TYPESECTION/TYPEDECL[TYPE/@type="class"]');
  CodeFileStatistics.InterfaceCount := GetNodeCount('/UNIT/INTERFACE//TYPESECTION/TYPEDECL[TYPE/@type="interface"]');
  CodeFileStatistics.RecordCount := GetNodeCount('/UNIT/INTERFACE//TYPESECTION/TYPEDECL[TYPE/@type="record"]');
  CodeFileStatistics.EnumCount := GetNodeCount('/UNIT/INTERFACE//TYPESECTION/TYPEDECL[TYPE/@name="enum"]'); // Contagem de Enums

  CodeFileStatistics.PublicMethodCount := GetNodeCount('/UNIT/INTERFACE//TYPESECTION/TYPEDECL/TYPE[@type="class"]/PUBLIC/METHOD');
  CodeFileStatistics.PrivateMethodCount := GetNodeCount('/UNIT/INTERFACE//TYPESECTION/TYPEDECL/TYPE[@type="class"]/PRIVATE/METHOD');
  CodeFileStatistics.ProtectedMethodCount := GetNodeCount('/UNIT/INTERFACE//TYPESECTION/TYPEDECL/TYPE[@type="class"]/PROTECTED/METHOD');
  CodeFileStatistics.StaticMethodCount := GetNodeCount('/UNIT/INTERFACE//TYPESECTION/TYPEDECL/TYPE[@type="class"]//METHOD[@class="true"]'); // Métodos estáticos de classe

  // Contagem de Propriedades
  CodeFileStatistics.ClassPropertyCount := GetNodeCount('/UNIT/INTERFACE//TYPESECTION/TYPEDECL/TYPE[@type="class"]/*/PROPERTY'); // Propriedades em qualquer seção de classe
  CodeFileStatistics.RecordPropertyCount:= GetNodeCount('/UNIT/INTERFACE//TYPESECTION/TYPEDECL/TYPE[@type="record"]/PROPERTY'); // Propriedades de Record (Hipótese: direto sob TYPE)
  CodeFileStatistics.InterfacePropertyCount := GetNodeCount('/UNIT/INTERFACE//TYPESECTION/TYPEDECL/TYPE[@type="interface"]/PROPERTY'); // Propriedades de Interface

  CodeFileStatistics.GlobalFunctionCount := GetNodeCount('/UNIT/INTERFACE/METHOD');
  CodeFileStatistics.GlobalConstantCount := GetNodeCount('/UNIT/INTERFACE/CONSTANTS/CONSTANT');
  CodeFileStatistics.GlobalVariableCount := GetNodeCount('/UNIT/INTERFACE/VARIABLES/VARIABLE');

  // Métodos implementados e Complexidade Ciclomática (MCC)
  CodeFileStatistics.ImplMethodCount := GetNodeCount('/UNIT/IMPLEMENTATION//METHOD');

  var BaseComplexity: Int64 := CodeFileStatistics.ImplMethodCount;
  if BaseComplexity = 0 then
    BaseComplexity := 1;

  const IfCount = GetNodeCount('//IF');
  const CaseCount = GetNodeCount('//CASE');
  const ForCount = GetNodeCount('//FOR');
  const WhileCount = GetNodeCount('//WHILE');
  const RepeatCount = GetNodeCount('//REPEAT');
  const ExceptCount = GetNodeCount('//EXCEPT');
  const AndCount = GetNodeCount('//AND');
  const OrCount = GetNodeCount('//OR');

  CodeFileStatistics.CyclomaticComplexity := BaseComplexity + IfCount + CaseCount + ForCount + WhileCount + RepeatCount + ExceptCount + AndCount + OrCount;

  StopWatch.Stop();
  CodeFileStatistics.AnalysisTimeMs := StopWatch.ElapsedMilliseconds;

  FResults.Add(CodeFileStatistics);
end;


end.
