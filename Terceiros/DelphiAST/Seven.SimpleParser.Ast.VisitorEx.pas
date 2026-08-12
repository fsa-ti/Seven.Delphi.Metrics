unit Seven.SimpleParser.Ast.VisitorEx;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Seven.SimpleParser.Lexer.Types,
  Seven.DelphiAST.Classes,
  Seven.SimpleParser.Ast.Visitor;

type
  /// <summary>
  /// Classe de visitante estendida com métodos específicos para cada tipo de nó do DelphiAST.
  /// Estende a classe base TAbstractSyntaxTreeBaseVisitor com métodos adicionais.
  /// </summary>
  TExtendedSyntaxTreeVisitor = class(TAbstractSyntaxTreeBaseVisitor)
  private
    FVisitedNodes: TDictionary<TSyntaxNode, Boolean>;
    FCurrentPath: TList<TSyntaxNode>;

    function IsNodeVisited(ANode: TSyntaxNode): Boolean;
    procedure MarkNodeVisited(ANode: TSyntaxNode);

    procedure EnterNode(ANode: TSyntaxNode);
    procedure ExitNode(ANode: TSyntaxNode);
  protected
    // Sobrescreve método da classe base para implementar detecção de ciclos
    procedure ProcessChildren(ANode: TSyntaxNode); override;

    // Métodos específicos para tipos de nós
    procedure DispatchByNodeType(ANode: TSyntaxNode); virtual;
  public
    constructor Create; override;
    destructor Destroy; override;

    // Sobrescreve método base para implementar dispatch por tipo
    procedure VisitSyntaxNode(ANode: TSyntaxNode); override;

    // Métodos específicos para cada tipo de nó do DelphiAST

    // Seções de unidade
    procedure VisitUnit(ANode: TSyntaxNode); virtual;
    procedure VisitInterfaceSection(ANode: TSyntaxNode); virtual;
    procedure VisitImplementationSection(ANode: TSyntaxNode); virtual;
    procedure VisitUsesClause(ANode: TSyntaxNode); virtual;

    // Declarações
    procedure VisitTypeSection(ANode: TSyntaxNode); virtual;
    procedure VisitTypeDeclaration(ANode: TSyntaxNode); virtual;
    procedure VisitVarSection(ANode: TSyntaxNode); virtual;
    procedure VisitVarDeclaration(ANode: TSyntaxNode); virtual;
    procedure VisitConstSection(ANode: TSyntaxNode); virtual;
    procedure VisitConstDeclaration(ANode: TSyntaxNode); virtual;

    // Procedimentos e funções
    procedure VisitMethodDeclaration(ANode: TSyntaxNode); virtual;
    procedure VisitProcedureDeclaration(ANode: TSyntaxNode); virtual;
    procedure VisitFunctionDeclaration(ANode: TSyntaxNode); virtual;
    procedure VisitMethodImplementation(ANode: TSyntaxNode); virtual;
    procedure VisitParameter(ANode: TSyntaxNode); virtual;
    procedure VisitParameters(ANode: TSyntaxNode); virtual;

    // Classes e interfaces
    procedure VisitClassType(ANode: TSyntaxNode); virtual;
    procedure VisitClassField(ANode: TSyntaxNode); virtual;
    procedure VisitClassMethod(ANode: TSyntaxNode); virtual;
    procedure VisitClassProperty(ANode: TSyntaxNode); virtual;
    procedure VisitInterfaceType(ANode: TSyntaxNode); virtual;
    procedure VisitInterfaceMethod(ANode: TSyntaxNode); virtual;
    procedure VisitInterfaceProperty(ANode: TSyntaxNode); virtual;

    // Outros tipos
    procedure VisitRecordType(ANode: TSyntaxNode); virtual;
    procedure VisitEnumType(ANode: TSyntaxNode); virtual;
    procedure VisitSetType(ANode: TSyntaxNode); virtual;
    procedure VisitPointerType(ANode: TSyntaxNode); virtual;
    procedure VisitArrayType(ANode: TSyntaxNode); virtual;

    // Declarações
    procedure VisitIfStatement(ANode: TSyntaxNode); virtual;
    procedure VisitForStatement(ANode: TSyntaxNode); virtual;
    procedure VisitWhileStatement(ANode: TSyntaxNode); virtual;
    procedure VisitRepeatStatement(ANode: TSyntaxNode); virtual;
    procedure VisitTryStatement(ANode: TSyntaxNode); virtual;
    procedure VisitExceptBlock(ANode: TSyntaxNode); virtual;
    procedure VisitCaseStatement(ANode: TSyntaxNode); virtual;
    procedure VisitCaseItem(ANode: TSyntaxNode); virtual;

    // Expressões
    procedure VisitExpression(ANode: TSyntaxNode); virtual;
    procedure VisitBinaryExpression(ANode: TSyntaxNode); virtual;
    procedure VisitUnaryExpression(ANode: TSyntaxNode); virtual;

    // Outros elementos
    procedure VisitIdentifier(ANode: TSyntaxNode); virtual;
    procedure VisitQualifiedIdentifier(ANode: TSyntaxNode); virtual;
    procedure VisitLiteral(ANode: TSyntaxNode); virtual;
    procedure VisitMethodCall(ANode: TSyntaxNode); virtual;
    procedure VisitAssignment(ANode: TSyntaxNode); virtual;
    procedure VisitBlock(ANode: TSyntaxNode); virtual;

    // Propriedades
    property CurrentPath: TList<TSyntaxNode> read FCurrentPath;
  end;

implementation

uses
  Seven.DelphiAST.Helpers;

{ TExtendedSyntaxTreeVisitor }

constructor TExtendedSyntaxTreeVisitor.Create;
begin
  inherited;
  FVisitedNodes := TDictionary<TSyntaxNode, Boolean>.Create;
  FCurrentPath := TList<TSyntaxNode>.Create;
end;

destructor TExtendedSyntaxTreeVisitor.Destroy;
begin
  FCurrentPath.Free;
  FVisitedNodes.Free;
  inherited;
end;

procedure TExtendedSyntaxTreeVisitor.DispatchByNodeType(ANode: TSyntaxNode);
var
  NodeType: string;
begin
  if ANode = nil then
    Exit;

  NodeType := GetNodeTypeName(ANode);

  // Despacha para o método específico com base no tipo do nó
  if NodeType = 'Unit' then
    VisitUnit(ANode)
  else if NodeType = 'Interface' then
    VisitInterfaceSection(ANode)
  else if NodeType = 'Implementation' then
    VisitImplementationSection(ANode)
  else if NodeType = 'Uses' then
    VisitUsesClause(ANode)
  else if NodeType = 'TypeSection' then
    VisitTypeSection(ANode)
  else if NodeType = 'TypeDecl' then
    VisitTypeDeclaration(ANode)
  else if NodeType = 'VarSection' then
    VisitVarSection(ANode)
  else if NodeType = 'VarDecl' then
    VisitVarDeclaration(ANode)
  else if NodeType = 'ConstSection' then
    VisitConstSection(ANode)
  else if NodeType = 'ConstDecl' then
    VisitConstDeclaration(ANode)
  else if NodeType = 'MethodDecl' then
    VisitMethodDeclaration(ANode)
  else if NodeType = 'ProcedureDecl' then
    VisitProcedureDeclaration(ANode)
  else if NodeType = 'FunctionDecl' then
    VisitFunctionDeclaration(ANode)
  else if NodeType = 'MethodImpl' then
    VisitMethodImplementation(ANode)
  else if NodeType = 'Parameter' then
    VisitParameter(ANode)
  else if NodeType = 'Parameters' then
    VisitParameters(ANode)
  else if NodeType = 'ClassType' then
    VisitClassType(ANode)
  else if NodeType = 'ClassField' then
    VisitClassField(ANode)
  else if NodeType = 'ClassMethod' then
    VisitClassMethod(ANode)
  else if NodeType = 'ClassProperty' then
    VisitClassProperty(ANode)
  else if NodeType = 'InterfaceType' then
    VisitInterfaceType(ANode)
  else if NodeType = 'InterfaceMethod' then
    VisitInterfaceMethod(ANode)
  else if NodeType = 'InterfaceProperty' then
    VisitInterfaceProperty(ANode)
  else if NodeType = 'RecordType' then
    VisitRecordType(ANode)
  else if NodeType = 'EnumType' then
    VisitEnumType(ANode)
  else if NodeType = 'SetType' then
    VisitSetType(ANode)
  else if NodeType = 'PointerType' then
    VisitPointerType(ANode)
  else if NodeType = 'ArrayType' then
    VisitArrayType(ANode)
  else if NodeType = 'If' then
    VisitIfStatement(ANode)
  else if NodeType = 'For' then
    VisitForStatement(ANode)
  else if NodeType = 'While' then
    VisitWhileStatement(ANode)
  else if NodeType = 'Repeat' then
    VisitRepeatStatement(ANode)
  else if NodeType = 'Try' then
    VisitTryStatement(ANode)
  else if NodeType = 'Except' then
    VisitExceptBlock(ANode)
  else if NodeType = 'Case' then
    VisitCaseStatement(ANode)
  else if NodeType = 'CaseItem' then
    VisitCaseItem(ANode)
  else if NodeType = 'Expression' then
    VisitExpression(ANode)
  else if NodeType = 'BinaryExpression' then
    VisitBinaryExpression(ANode)
  else if NodeType = 'UnaryExpression' then
    VisitUnaryExpression(ANode)
  else if NodeType = 'Identifier' then
    VisitIdentifier(ANode)
  else if NodeType = 'QualifiedIdentifier' then
    VisitQualifiedIdentifier(ANode)
  else if NodeType = 'Literal' then
    VisitLiteral(ANode)
  else if NodeType = 'MethodCall' then
    VisitMethodCall(ANode)
  else if NodeType = 'Assignment' then
    VisitAssignment(ANode)
  else if NodeType = 'Block' then
    VisitBlock(ANode)
  else
    // Se não for um tipo conhecido, chama o método básico da classe base
    inherited VisitSyntaxNode(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.EnterNode(ANode: TSyntaxNode);
begin
  FCurrentPath.Add(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.ExitNode(ANode: TSyntaxNode);
begin
  if (FCurrentPath.Count > 0) and (FCurrentPath[FCurrentPath.Count - 1] = ANode) then
    FCurrentPath.Delete(FCurrentPath.Count - 1);
end;

function TExtendedSyntaxTreeVisitor.IsNodeVisited(ANode: TSyntaxNode): Boolean;
begin
  Result := FVisitedNodes.ContainsKey(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.MarkNodeVisited(ANode: TSyntaxNode);
begin
  if not FVisitedNodes.ContainsKey(ANode) then
    FVisitedNodes.Add(ANode, True);
end;

procedure TExtendedSyntaxTreeVisitor.ProcessChildren(ANode: TSyntaxNode);
var
  I: Integer;
  ChildNode: TSyntaxNode;
begin
  if (ANode = nil) or (not ShouldVisitChildNodes(ANode)) then
    Exit;

  // Visita todos os nós filhos, evitando ciclos
  for I := 0 to ANode.ChildNodeCount - 1 do
  begin
    ChildNode := ANode.ChildNodes[I];
    if (ChildNode <> nil) and (not IsNodeVisited(ChildNode)) then
      VisitSyntaxNode(ChildNode);
  end;
end;

procedure TExtendedSyntaxTreeVisitor.VisitSyntaxNode(ANode: TSyntaxNode);
begin
  if (ANode = nil) or IsNodeVisited(ANode) then
    Exit;

  // Marca o nó como visitado para evitar ciclos
  MarkNodeVisited(ANode);

  // Entra no nó (adiciona ao caminho atual)
  EnterNode(ANode);

  try
    // Despacha para o método específico com base no tipo do nó
    DispatchByNodeType(ANode);
  finally
    // Sai do nó (remove do caminho atual)
    ExitNode(ANode);
  end;
end;

// Implementações dos métodos específicos (vazios por padrão)

procedure TExtendedSyntaxTreeVisitor.VisitArrayType(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitAssignment(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitBinaryExpression(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitBlock(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitCaseItem(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitCaseStatement(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitClassField(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitClassMethod(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitClassProperty(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitClassType(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitConstDeclaration(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitConstSection(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitEnumType(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitExceptBlock(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitExpression(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitForStatement(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitFunctionDeclaration(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitIdentifier(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitIfStatement(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitImplementationSection(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitInterfaceMethod(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitInterfaceProperty(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitInterfaceSection(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitInterfaceType(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitLiteral(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitMethodCall(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitMethodDeclaration(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitMethodImplementation(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitParameter(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitParameters(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitPointerType(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitProcedureDeclaration(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitQualifiedIdentifier(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitRecordType(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitRepeatStatement(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitSetType(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitTryStatement(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitTypeDeclaration(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitTypeSection(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitUnaryExpression(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitUnit(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitUsesClause(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitVarDeclaration(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitVarSection(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

procedure TExtendedSyntaxTreeVisitor.VisitWhileStatement(ANode: TSyntaxNode);
begin
  ProcessChildren(ANode);
end;

end.
