// Marcelo Melo
// 01/05/2025
//
unit Seven.DelphiAST.SyntaxWalker;

interface

uses
  System.SysUtils,
  System.Classes,
  Seven.DelphiAST.Classes;

type

  { TASTVisitorBase }

  TASTVisitorBase = class(TInterfacedObject, IASTVisitor)
  public
    procedure Visit(const ANode: TSyntaxNode); overload; virtual;
  end;

  IDelphiSyntaxWalker = interface(IASTVisitor)
    ['{F8C08165-F663-4C2B-A0BE-F41C88B2C7F5}']
    procedure Visit(const ANode: TSyntaxNode); overload;
    procedure Visit(const ANode: TCompoundSyntaxNode); overload;
    procedure Visit(const ANode: TValuedSyntaxNode); overload;
    procedure Visit(const ANode: TCommentNode); overload;
  end;

  { TDelphiSyntaxWalker }

  TDelphiSyntaxWalker = class(TASTVisitorBase, IDelphiSyntaxWalker)
  public
    procedure Visit(const ANode: TSyntaxNode); overload; override;
    procedure Visit(const ANode: TCompoundSyntaxNode); overload; virtual;
    procedure Visit(const ANode: TValuedSyntaxNode); overload; virtual;
    procedure Visit(const ANode: TCommentNode); overload; virtual;
  end;

  ESyntaxTreeVisitorException = class(EParserException)
  end;

implementation

{ TASTVisitorBase }

procedure TASTVisitorBase.Visit(const ANode: TSyntaxNode);
begin
  for var ChildNode in ANode.ChildNodes do
  begin
    Visit(ChildNode);
  end;
end;

{ TDelphiSyntaxWalker }

procedure TDelphiSyntaxWalker.Visit(const ANode: TSyntaxNode);
begin
  if ANode is TCompoundSyntaxNode then
    Visit(TCompoundSyntaxNode(ANode))
  else if ANode is TValuedSyntaxNode then
    Visit(TValuedSyntaxNode(ANode))
  else if ANode is TCommentNode then
    Visit(TCommentNode(ANode))
  else if not (ANode.ClassType = TSyntaxNode) then
    raise ESyntaxTreeVisitorException.Create(ANode.Line, ANode.Col, ANode.FileName, 'Invalid Syntax Node Class Type: ' + QuotedStr(ANode.ClassType.ClassName));

  inherited Visit(ANode);
end;

procedure TDelphiSyntaxWalker.Visit(const ANode: TCompoundSyntaxNode);
begin
end;

procedure TDelphiSyntaxWalker.Visit(const ANode: TValuedSyntaxNode);
begin
end;

procedure TDelphiSyntaxWalker.Visit(const ANode: TCommentNode);
begin
end;

end.
