unit Seven.SimpleParser.Ast.Visitor1;

interface

uses
  Seven.SimpleParser.Lexer.Types, Seven.DelphiAST.Classes;

type
  /// <summary>
  /// Classe base abstrata para implementar o padrão Visitor para percorrer a AST.
  /// Fornece implementações padrão vazias para todos os métodos de visitante.
  /// </summary>
  TAbstractSyntaxTreeBaseVisitor = class
  public
    /// <summary>
    /// Chamado quando o visitante encontra qualquer nó sintático.
    /// Método base para todas as visitas.
    /// </summary>
    procedure VisitSyntaxNode(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra um nó composto que contém outros nós.
    /// </summary>
    procedure VisitCompoundSyntaxNode(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra um nó de valor.
    /// </summary>
    procedure VisitValuedSyntaxNode(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra um nó de comentário.
    /// </summary>
    procedure VisitCommentSyntaxNode(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra uma declaração de tipo.
    /// </summary>
    procedure VisitTypeDeclaration(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra uma declaração de variável.
    /// </summary>
    procedure VisitVariableDeclaration(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra uma declaração de constante.
    /// </summary>
    procedure VisitConstantDeclaration(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra uma declaração de procedimento/função.
    /// </summary>
    procedure VisitProcedureDeclaration(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra uma implementação de método.
    /// </summary>
    procedure VisitMethodImplementation(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra uma seção de interface.
    /// </summary>
    procedure VisitInterfaceSection(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra uma seção de implementação.
    /// </summary>
    procedure VisitImplementationSection(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra uma seção uses.
    /// </summary>
    procedure VisitUsesSection(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra uma expressão.
    /// </summary>
    procedure VisitExpression(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra uma declaração.
    /// </summary>
    procedure VisitStatement(ANode: TSyntaxNode); virtual;

    /// <summary>
    /// Chamado quando o visitante encontra um identificador.
    /// </summary>
    procedure VisitIdentifier(ANode: TSyntaxNode); virtual;
  end;

implementation

{ TAbstractSyntaxTreeBaseVisitor }

procedure TAbstractSyntaxTreeBaseVisitor.VisitSyntaxNode(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitCompoundSyntaxNode(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitValuedSyntaxNode(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitCommentSyntaxNode(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitTypeDeclaration(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitVariableDeclaration(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitConstantDeclaration(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitProcedureDeclaration(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitMethodImplementation(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitInterfaceSection(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitImplementationSection(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitUsesSection(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitExpression(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitStatement(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

procedure TAbstractSyntaxTreeBaseVisitor.VisitIdentifier(ANode: TSyntaxNode);
begin
  // Implementação base: não faz nada
  // As classes derivadas devem sobrescrever este método
end;

end.
