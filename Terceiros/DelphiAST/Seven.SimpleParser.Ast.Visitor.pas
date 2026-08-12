// Marcelo Melo
// 06/05/2025
//
unit Seven.SimpleParser.Ast.Visitor;

interface

uses
  System.Classes, System.SysUtils,
  Seven.SimpleParser.Lexer.Types,
  Seven.DelphiAST.Classes;

type
  /// <summary>
  /// Classe base abstrata para implementar o padrão Visitor para percorrer a AST.
  /// </summary>
  TAbstractSyntaxTreeBaseVisitor = class
  protected
    // Métodos auxiliares internos
    procedure ProcessChildren(ANode: TSyntaxNode); virtual;
    function GetNodeTypeName(ANode: TSyntaxNode): string; virtual;
    function ShouldVisitChildNodes(ANode: TSyntaxNode): Boolean; virtual;
  public
    constructor Create; overload; virtual;
    destructor Destroy; override;

    /// <summary>
    /// Método base para visitar qualquer nó sintático.
    /// Decide qual método especializado chamar com base no tipo do nó.
    /// </summary>
    procedure VisitSyntaxNode(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Visita um nó composto e seus filhos.
    /// </summary>
    procedure VisitCompoundSyntaxNode(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Visita um nó de valor que contém um valor específico.
    /// </summary>
    procedure VisitValuedSyntaxNode(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Visita um nó de comentário.
    /// </summary>
    procedure VisitCommentSyntaxNode(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Método de entrada principal para iniciar a visitação da árvore.
    /// </summary>
    procedure Visit(ANode: TSyntaxNode); virtual;
  end;

implementation

uses
  Seven.DelphiAST.Helpers;

{ TAbstractSyntaxTreeBaseVisitor }

constructor TAbstractSyntaxTreeBaseVisitor.Create;
begin
  inherited Create;
end;

destructor TAbstractSyntaxTreeBaseVisitor.Destroy;
begin
  inherited;
end;

function TAbstractSyntaxTreeBaseVisitor.GetNodeTypeName(ANode: TSyntaxNode): string;
begin
  if ANode <> nil then
    Result := ANode.Typ.ToString()
  else
    Result := '';
end;

procedure TAbstractSyntaxTreeBaseVisitor.ProcessChildren(ANode: TSyntaxNode);
var
  I: Integer;
  ChildNode: TSyntaxNode;
begin
  if (ANode = nil) or (not ShouldVisitChildNodes(ANode)) then
    Exit;

  // Visita todos os nós filhos
  for I := 0 to ANode.ChildNodeCount - 1 do
  begin
    ChildNode := ANode.ChildNodes[I];
    if ChildNode <> nil then
      VisitSyntaxNode(ChildNode);
  end;
end;

function TAbstractSyntaxTreeBaseVisitor.ShouldVisitChildNodes(ANode: TSyntaxNode): Boolean;
begin
  // Por padrão, sempre visita os nós filhos
  Result := True;
end;

procedure TAbstractSyntaxTreeBaseVisitor.Visit(ANode: TSyntaxNode);
begin
  if ANode <> nil then
    VisitSyntaxNode(ANode);
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitCommentSyntaxNode(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada com nós de comentário
  // As classes derivadas podem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitCompoundSyntaxNode(ANode: TSyntaxNode);
begin
  // A implementação padrão para um nó composto é visitar seus filhos
  ProcessChildren(ANode);
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitSyntaxNode(ANode: TSyntaxNode);
begin
  if ANode = nil then
    Exit;

  // Com base no tipo do nó, decide qual método especializado chamar
  if ANode is TValuedSyntaxNode then
    VisitValuedSyntaxNode(ANode)
  else if ANode is TCommentNode then
    VisitCommentSyntaxNode(ANode)
  else if ANode is TCompoundSyntaxNode then
    VisitCompoundSyntaxNode(ANode)
  else
    // Para um TSyntaxNode básico, apenas processa seus filhos
    ProcessChildren(ANode);
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitValuedSyntaxNode(ANode: TSyntaxNode);
begin
  // A implementação padrão para um nó de valor é visitar seus filhos
  ProcessChildren(ANode);
end;

end.
