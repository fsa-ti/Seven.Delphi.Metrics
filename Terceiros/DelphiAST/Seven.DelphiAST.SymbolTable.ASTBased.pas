unit Seven.DelphiAST.SymbolTable.ASTBased;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Defaults, System.Generics.Collections,
  Seven.DelphiAST, Seven.DelphiAST.Classes;

type
  // Forward declarations
  TSymbol = class;
  TSymbolTable = class;
  TUnitInfo = class;

  // Tipos de Símbolos (Kind) - Para clareza
  TSymbolKind = (
    skUnknown, skUnit, skClass, skInterface, skRecord, skObject, skEnum,
    skTypeAlias, skArray, skSet, skFile, skPointer, skProcedureType, skStringType, // Tipos diversos
    skMethod, skConstructor, skDestructor, // Subtipos de 'routine'
    skFunction, skProcedure, // Globais ou locais
    skProperty, skField, skVariable, skConstant, skParameter, skEnumValue,
    skLabel, skNamespace // Potenciais futuros
  );

  // Interface para um símbolo na tabela
  IDelphiASTSymbol = interface; // Definido abaixo

  // Acesso rápido aos nós AST que definem escopos
  IScopeDefiningNode = interface(ISyntaxNode)
    ['{1A8D9C4C-E0B9-4F5A-9E63-8B3172B3F9D7}']
    function GetDefinedSymbol: IDelphiASTSymbol; // Símbolo associado a este escopo
    procedure SetDefinedSymbol(const Value: IDelphiASTSymbol);
    property DefinedSymbol: IDelphiASTSymbol read GetDefinedSymbol write SetDefinedSymbol;
  end;

  IDelphiASTSymbol = interface(IInterface)
    ['{F4B3A1D2-C7E8-4D9A-B3C1-9D2A1E7C8B0F}']
    // Identificação e Localização
    function GetName: string;             // Nome simples (ex: MyMethod)
    function GetFullyQualifiedName: string; // Nome completo (ex: Unit1.TMyClass.MyMethod)
    function GetKind: TSymbolKind;        // Tipo do símbolo (class, method, variable, etc.)
    function GetLine: Integer;            // Linha da declaração
    function GetColumn: Integer;          // Coluna da declaração
    function GetDeclarationNode: ISyntaxNode; // Nó AST original da declaração
    function GetFullFileName: string;     // Caminho completo do arquivo

    // Informações de Tipo e Escopo
    function GetScope: IDelphiASTSymbol;      // Símbolo do escopo pai (a classe, unit, método, etc.)
    function GetValueTypeName: string;        // Nome declarado do tipo de dado (string)
    function GetValueType: IDelphiASTSymbol;  // Símbolo resolvido do tipo de dado
    function GetAncestorTypeName: string;     // Nome declarado do ancestral (string)
    function GetAncestorType: IDelphiASTSymbol;// Símbolo resolvido do ancestral

    // Tratamento de Sobrecargas/Duplicatas
    function GetNextOverload: IDelphiASTSymbol; // Próxima definição com mesmo FQN

    // Propriedades para facilitar acesso
    property Name: string read GetName;
    property FullyQualifiedName: string read GetFullyQualifiedName;
    property Kind: TSymbolKind read GetKind;
    property Line: Integer read GetLine;
    property Column: Integer read GetColumn;
    property DeclarationNode: ISyntaxNode read GetDeclarationNode;
    property FullFileName: string read GetFullFileName;
    property Scope: IDelphiASTSymbol read GetScope;
    property ValueTypeName: string read GetValueTypeName;
    property ValueType: IDelphiASTSymbol read GetValueType;
    property AncestorTypeName: string read GetAncestorTypeName;
    property AncestorType: IDelphiASTSymbol read GetAncestorType;
    property NextOverload: IDelphiASTSymbol read GetNextOverload;
  end;

  // Implementação concreta do símbolo
  TSymbol = class(TInterfacedObject, IDelphiASTSymbol)
  private
    FName: string;
    FFullyQualifiedName: string;
    FKind: TSymbolKind;
    FLine: Integer;
    FColumn: Integer;
    FDeclarationNode: ISyntaxNode; // Mantém o nó original
    FFullFileName: string;
    FValueTypeName: string;
    FAncestorTypeName: string;
    FUnitSection: string; // 'interface' ou 'implementation' (para visibilidade de uses)

    FSymbolTableRef: TSymbolTable; // Referência à tabela para lookups internos
    FScopeSymbol: IDelphiASTSymbol;      // Resolvido no PostProcess
    FValueTypeSymbol: IDelphiASTSymbol;  // Resolvido no PostProcess
    FAncestorTypeSymbol: IDelphiASTSymbol;// Resolvido no PostProcess
    FNextOverload: IDelphiASTSymbol;     // Ligado durante adição

    fResolved: Boolean; // Flag para PostProcess

    // --- IDelphiASTSymbol ---
    function GetName: string;
    function GetFullyQualifiedName: string;
    function GetKind: TSymbolKind;
    function GetLine: Integer;
    function GetColumn: Integer;
    function GetDeclarationNode: ISyntaxNode;
    function GetFullFileName: string;
    function GetScope: IDelphiASTSymbol;
    function GetValueTypeName: string;
    function GetValueType: IDelphiASTSymbol;
    function GetAncestorTypeName: string;
    function GetAncestorType: IDelphiASTSymbol;
    function GetNextOverload: IDelphiASTSymbol;
  public
    constructor Create(ASymbolTable: TSymbolTable; AFullFileName: string; ADeclarationNode: ISyntaxNode;
      AFullyQualifiedName: string; AName: string; AKind: TSymbolKind;
      AValueTypeName, AAncestorTypeName, AUnitSection: string; ALine, AColumn: Integer);

    procedure ResolveLinks; // Chamado pelo PostProcess

    property NextOverloadImpl: IDelphiASTSymbol read FNextOverload write FNextOverload; // Para AddSymbol
    property ScopeImpl: IDelphiASTSymbol read FScopeSymbol write FScopeSymbol; // Para PostProcess
    property ValueTypeImpl: IDelphiASTSymbol read FValueTypeSymbol write FValueTypeSymbol; // Para PostProcess
    property AncestorTypeImpl: IDelphiASTSymbol read FAncestorTypeSymbol write FAncestorTypeSymbol; // Para PostProcess
  end;

  // Informações sobre uma unidade (principalmente 'uses')
  TUnitInfo = class
  private
    FUnitName: string;
    FInterfaceUses: THashSet<string>; // Nomes das units usadas na interface (lowercase)
    FImplementationUses: THashSet<string>; // Nomes das units usadas na implementation (lowercase)
    FUnitSymbol: IDelphiASTSymbol; // O símbolo da própria unit
  public
    constructor Create(AUnitSymbol: IDelphiASTSymbol);
    destructor Destroy; override;
    procedure AddInterfaceUse(const UsedUnitName: string);
    procedure AddImplementationUse(const UsedUnitName: string);
    function CheckInterfaceUses(const UsedUnitName: string): Boolean;
    function CheckImplementationUses(const UsedUnitName: string): Boolean;

    property UnitSymbol: IDelphiASTSymbol read FUnitSymbol;
    property UnitName: string read FUnitName;
    // Expor coleções como read-only ou via métodos seguros
    function GetInterfaceUses: TArray<string>;
    function GetImplementationUses: TArray<string>;
  end;

  // A Tabela de Símbolos principal
  TSymbolTable = class(TObject)
  private
    FSymbols: TDictionary<string, IDelphiASTSymbol>; // FQN -> Símbolo
    FUnits: TDictionary<string, TUnitInfo>;       // Nome Unit (lowercase) -> UnitInfo
    FScopeStack: TStack<IDelphiASTSymbol>;         // Pilha para rastrear escopo atual durante travessia

    // Helpers de Travessia e Construção
    procedure ProcessNodeRecursive(ANode: ISyntaxNode; const AFullFileName, AUnitSection: string);
    procedure PushScope(AScopeSymbol: IDelphiASTSymbol);
    procedure PopScope;
    function GetCurrentScope: IDelphiASTSymbol;
    function BuildFQN(const ParentScopeFQN: string; const SimpleName: string): string;
    function GetNodeSymbolKind(ANode: ISyntaxNode): TSymbolKind; // Determina TSymbolKind a partir do TSynaxNode
    procedure ExtractUses(AUnitSymbol: IDelphiASTSymbol; ANode: ISyntaxNode); // Extrai uses da Interface/Implementation
    procedure AddSymbol(ASymbol: IDelphiASTSymbol); // Adiciona à tabela, lida com overloads

    // Helpers de Lookup
    function LookupDirect(const AFQN: string): IDelphiASTSymbol; // Busca direta no dicionário
    function LookupInScopeHierarchy(AStartingScopeFQN: string; const ASimpleName: string): IDelphiASTSymbol;
    function LookupInUnitUses(const ACurrentUnitName: string; const ASimpleName: string): IDelphiASTSymbol;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    // Processa uma árvore AST (raiz geralmente é TUnitNode)
    procedure ProcessAst(const AFullFileName: string; ARootNode: ISyntaxNode);
    procedure PostProcess; // Resolve links

    // Função principal de busca
    function LookupSymbol(AStartingScope: IDelphiASTSymbol; const ASymbolName: string): IDelphiASTSymbol;
    // Função para resolver um nó de *uso* (mais complexa, baseada em LookupSymbol)
    function ResolveNode(AUsageNode: ISyntaxNode): IDelphiASTSymbol;

    property Symbols: TDictionary<string, IDelphiASTSymbol> read FSymbols; // Para debug ou análise externa
  end;

implementation

uses
  System.IOUtils, System.Types, System.Rtti; // StringSplitOptions


{ TSymbol }

constructor TSymbol.Create(ASymbolTable: TSymbolTable; AFullFileName: string; ADeclarationNode: ISyntaxNode;
  AFullyQualifiedName: string; AName: string; AKind: TSymbolKind;
  AValueTypeName, AAncestorTypeName, AUnitSection: string; ALine, AColumn: Integer);
begin
  inherited Create;
  FSymbolTableRef := ASymbolTable;
  FFullFileName := AFullFileName;
  FDeclarationNode := ADeclarationNode;
  FFullyQualifiedName := LowerCase(AFullyQualifiedName);
  FName := AName; // Manter case original pode ser útil para exibição
  FKind := AKind;
  FValueTypeName := AValueTypeName; // Nome como string, será resolvido depois
  FAncestorTypeName := AAncestorTypeName;
  FUnitSection := LowerCase(AUnitSection);
  FLine := ALine;
  FColumn := AColumn;
  fResolved := False;
end;

function TSymbol.GetName: string; begin Result := FName; end;
function TSymbol.GetFullyQualifiedName: string; begin Result := FFullyQualifiedName; end;
function TSymbol.GetKind: TSymbolKind; begin Result := FKind; end;
function TSymbol.GetLine: Integer; begin Result := FLine; end;
function TSymbol.GetColumn: Integer; begin Result := FColumn; end;
function TSymbol.GetDeclarationNode: ISyntaxNode; begin Result := FDeclarationNode; end;
function TSymbol.GetFullFileName: string; begin Result := FFullFileName; end;
function TSymbol.GetScope: IDelphiASTSymbol; begin Result := FScopeSymbol; end;
function TSymbol.GetValueTypeName: string; begin Result := FValueTypeName; end;
function TSymbol.GetValueType: IDelphiASTSymbol; begin Result := FValueTypeSymbol; end;
function TSymbol.GetAncestorTypeName: string; begin Result := FAncestorTypeName; end;
function TSymbol.GetAncestorType: IDelphiASTSymbol; begin Result := FAncestorTypeSymbol; end;
function TSymbol.GetNextOverload: IDelphiASTSymbol; begin Result := FNextOverload; end;

procedure TSymbol.ResolveLinks;
var
  LStartingScope: IDelphiASTSymbol;
begin
  if fResolved then Exit;
  fResolved := True;

  // 1. Encontrar Escopo Pai (se já não estiver setado)
  // (Idealmente, o escopo pai é definido durante a travessia/criação do símbolo)
  // Se não foi, podemos tentar achar baseado no FQN:
  if not Assigned(FScopeSymbol) then
  begin
     // TODO: Achar o símbolo pai baseado no FQN e lookup na tabela
     // LParentFQN := FSymbolTableRef.ExtractParentFQN(FFullyQualifiedName); ?
     // FScopeSymbol := FSymbolTableRef.LookupDirect(LParentFQN);
     // Cuidado: Como saber o FQN exato do PAI se ele não foi passado na criação?
     // É MELHOR passar o escopo pai durante a CRIAÇÃO do símbolo.
     // A pilha de escopos na TSymbolTable ajuda nisso.
  end;

  LStartingScope := GetScope; // Começa a busca a partir do escopo pai do símbolo atual

  // 2. Resolver Tipo de Valor
  if (FValueTypeName <> '') and not Assigned(FValueTypeSymbol) then
  begin
    FValueTypeSymbol := FSymbolTableRef.LookupSymbol(LStartingScope, FValueTypeName);
    // TODO: Lógica mais sofisticada pode ser necessária para tipos genéricos, etc.
  end;

  // 3. Resolver Tipo Ancestral
  if (FAncestorTypeName <> '') and not Assigned(FAncestorTypeSymbol) then
  begin
    FAncestorTypeSymbol := FSymbolTableRef.LookupSymbol(LStartingScope, FAncestorTypeName);
     // TODO: Pode precisar buscar em units do SYSTEM implicitamente usadas.
  end;
end;


{ TUnitInfo }

constructor TUnitInfo.Create(AUnitSymbol: IDelphiASTSymbol);
begin
  inherited Create;
  FUnitSymbol := AUnitSymbol;
  FUnitName := AUnitSymbol.Name; // Pega o nome simples da unit do símbolo
  FInterfaceUses := THashSet<string>.Create;
  FImplementationUses := THashSet<string>.Create;
end;

destructor TUnitInfo.Destroy;
begin
  FInterfaceUses.Free;
  FImplementationUses.Free;
  inherited;
end;

procedure TUnitInfo.AddInterfaceUse(const UsedUnitName: string);
begin
  FInterfaceUses.Add(LowerCase(UsedUnitName));
end;

procedure TUnitInfo.AddImplementationUse(const UsedUnitName: string);
begin
  FImplementationUses.Add(LowerCase(UsedUnitName));
end;

function TUnitInfo.CheckInterfaceUses(const UsedUnitName: string): Boolean;
begin
  Result := FInterfaceUses.Contains(LowerCase(UsedUnitName));
end;

// Na implementation, podemos ver uses da interface e da implementation
function TUnitInfo.CheckImplementationUses(const UsedUnitName: string): Boolean;
var LLowerName: string;
begin
  LLowerName := LowerCase(UsedUnitName);
  Result := FInterfaceUses.Contains(LLowerName) or FImplementationUses.Contains(LLowerName);
end;

function TUnitInfo.GetInterfaceUses: TArray<string>;
begin
  Result := FInterfaceUses.ToArray; // Converte para array se necessário exportar
end;

function TUnitInfo.GetImplementationUses: TArray<string>;
begin
  Result := FImplementationUses.ToArray;
end;


{ TSymbolTable }

constructor TSymbolTable.Create;
begin
  inherited Create;
  FSymbols := TDictionary<string, IDelphiASTSymbol>.Create;
  FUnits := TDictionary<string, TUnitInfo>.Create; // Não possui valores aqui, TUnitInfo é criado depois
  FScopeStack := TStack<IDelphiASTSymbol>.Create;
end;

destructor TSymbolTable.Destroy;
begin
  FSymbols.Free;
  // TUnitInfo são gerenciados por contagem de referência se FUnits armazena interface? Não.
  // Se FUnits for TObjectDictionary com doOwnsValues, OK. Se TDictionary<string, IUnitInfo>, ok também.
  // Se TDictionary<string, TUnitInfo>, precisa liberar manualmente ou mudar para TObjectDictionary
  FreeAndNil(FUnits);   // Mudar para TObjectDictionary<string, TUnitInfo>.Create([doOwnsValues]) é melhor
  FScopeStack.Free;
  inherited;
end;

procedure TSymbolTable.Clear;
begin
  FSymbols.Clear; // Interfaces são liberadas por ARC
  FUnits.Clear;   // TObjectDictionary cuidará da liberação dos TUnitInfo
  FScopeStack.Clear;
end;

procedure TSymbolTable.PushScope(AScopeSymbol: IDelphiASTSymbol);
begin
  FScopeStack.Push(AScopeSymbol);
end;

procedure TSymbolTable.PopScope;
begin
  if FScopeStack.Count > 0 then
    FScopeStack.Pop;
end;

function TSymbolTable.GetCurrentScope: IDelphiASTSymbol;
begin
  if FScopeStack.Count > 0 then
    Result := FScopeStack.Peek
  else
    Result := nil; // Escopo global (nenhuma unit/classe/método pai)
end;

function TSymbolTable.BuildFQN(const ParentScopeFQN: string; const SimpleName: string): string;
begin
  if ParentScopeFQN = '' then
    Result := LowerCase(SimpleName) // Nível de Unit ou global
  else
    Result := ParentScopeFQN + '.' + LowerCase(SimpleName);
end;

// Adiciona símbolo à tabela, tratando sobrecargas
procedure TSymbolTable.AddSymbol(ASymbol: IDelphiASTSymbol);
var
  LExistingSymbol: IDelphiASTSymbol;
  LLastSymbol: TSymbol;
begin
  if not Assigned(ASymbol) or (ASymbol.FullyQualifiedName = '') then Exit;

  if FSymbols.TryGetValue(ASymbol.FullyQualifiedName, LExistingSymbol) then
  begin
    // Encadeia (a checagem de compatibilidade de sobrecarga é mais complexa)
    if LExistingSymbol is TSymbol then
    begin
      LLastSymbol := TSymbol(LExistingSymbol);
      while Assigned(LLastSymbol.NextOverloadImpl) do
      begin
         if LLastSymbol.NextOverloadImpl is TSymbol then
            LLastSymbol := TSymbol(LLastSymbol.NextOverloadImpl)
         else Break;
      end;
      // Verifica se o TSymbol concreto pode acessar NextOverloadImpl
       if LLastSymbol is TSymbol then
          LLastSymbol.NextOverloadImpl := ASymbol;

    end;
  end
  else
    FSymbols.Add(ASymbol.FullyQualifiedName, ASymbol);
end;

// Função principal de travessia e coleta
procedure TSymbolTable.ProcessNodeRecursive(ANode: ISyntaxNode; const AFullFileName, AUnitSection: string);
var
  LSymbol: IDelphiASTSymbol;
  LChildNode: ISyntaxNode;
  LKind: TSymbolKind;
  LName, LFQN, LValueTypeName, LAncestorTypeName, LParentFQN: string;
  LLine, LCol: Integer;
  LScopePushed: Boolean;
  LTypeDeclNode: TTypeDeclNode;
  LMethodDeclNode: TMethodDeclNode;
  LFieldDeclNode: TFieldDeclNode;
  LVariableDeclNode: TVariableDeclNode;
  LConstantDeclNode: TConstantDeclNode;
  TTypeSpecifierNode: TTypeSpecifierNode;
  LParamDeclNode : TParameterDeclNode;
  LPropertyDeclNode : TPropertyDeclNode;
  // ... outras variáveis para extrair info ...

begin
  if not Assigned(ANode) then Exit;

  LSymbol := nil;
  LKind := skUnknown;
  LName := '';
  LValueTypeName := '';
  LAncestorTypeName := '';
  LLine := ANode.Line;
  LCol := ANode.Col;
  LScopePushed := False;
  LParentFQN := '';

  // Obtém o FQN do escopo pai ATUAL antes de processar o nó
  if Assigned(GetCurrentScope) then
    LParentFQN := GetCurrentScope.FullyQualifiedName;

  // --- Identifica se o NÓ ATUAL declara um símbolo ---
  // (Esta parte precisa mapear TSynaxNode concrete types para TSymbolKind e extrair dados)

  if ANode is TUnitNode then // Pode ser que o raiz seja apenas ISyntaxNode
  begin
     // Handle Unit Name specifically? DelphiAST might use TUnitNode or just name attribute on root.
     // Let's assume the root ISyntaxNode passed to ProcessAst has the name.
  end
  else if ANode is TTypeDeclNode then
  begin
    LTypeDeclNode := TTypeDeclNode(ANode);
    LName := LTypeDeclNode.Name.Value; // Assume Name is TIdentifierNode
    LKind := GetNodeSymbolKind(LTypeDeclNode.TypeSpecifier); // Determina kind (class, record, enum...)
    LLine := LTypeDeclNode.Name.Line;
    LCol := LTypeDeclNode.Name.Col;

    // Extrai Ancestral (se for class/interface/object)
    if (LKind in [skClass, skInterface, skObject]) and (LTypeDeclNode.TypeSpecifier is TClassTypeNode) then
    begin
       if Length(TClassTypeNode(LTypeDeclNode.TypeSpecifier).BaseTypes) > 0 then
          if TClassTypeNode(LTypeDeclNode.TypeSpecifier).BaseTypes[0] is TIdentTypeNode then // Mais comum
             LAncestorTypeName := TIdentTypeNode(TClassTypeNode(LTypeDeclNode.TypeSpecifier).BaseTypes[0]).Name.Value;
          // TODO: Handle qualified ancestor names TModule.TBaseClass?
    end;
     // Extrair tipo de valor não faz sentido para uma declaração de TIPO em si.
  end
  else if ANode is TMethodDeclNode then
  begin
    LMethodDeclNode := TMethodDeclNode(ANode);
    LName := LMethodDeclNode.Name.Value;
    LKind := GetNodeSymbolKind(ANode); // skMethod, skConstructor, skDestructor, skFunction, skProcedure
    LLine := LMethodDeclNode.Name.Line; // Ou LMethodDeclNode.Line? Verificar qual é mais preciso.
    LCol := LMethodDeclNode.Name.Col;
    // Extrai Tipo de Retorno (para funções)
    if (LKind = skFunction) and Assigned(LMethodDeclNode.ReturnType) then
        if LMethodDeclNode.ReturnType is TIdentTypeNode then
            LValueTypeName := TIdentTypeNode(LMethodDeclNode.ReturnType).Name.Value
        else
           LValueTypeName := '<complex_type>'; // TODO: Lidar com function types, etc.

  end
  else if ANode is TFieldDeclNode then
  begin
     LFieldDeclNode := TFieldDeclNode(ANode);
     // Um TFieldDeclNode pode declarar VÁRIOS campos (F1, F2: Integer)
     for var LNameNode in LFieldDeclNode.Names do // Itera nos TIdentifierNode em Names
     begin
        LName := LNameNode.Value;
        LKind := skField;
        TTypeSpecifierNode := LFieldDeclNode.TypeSpecifier; // Tipo é o mesmo para todos
        if TTypeSpecifierNode is TIdentTypeNode then
           LValueTypeName := TIdentTypeNode(TTypeSpecifierNode).Name.Value
        else LValueTypeName := '<complex_type>';
        LLine := LNameNode.Line;
        LCol := LNameNode.Col;

        // Cria e adiciona um símbolo para CADA nome na lista
        LFQN := BuildFQN(LParentFQN, LName);
        LSymbol := TSymbol.Create(Self, AFullFileName, LNameNode, LFQN, LName, LKind, LValueTypeName, '', AUnitSection, LLine, LCol);
        AddSymbol(LSymbol);
     end;
     LName := ''; // Limpa para não processar o FieldDecl como um símbolo único abaixo
  end
  else if ANode is TVariableDeclNode then
  begin
      LVariableDeclNode := TVariableDeclNode(ANode);
      // Similar a TFieldDeclNode, pode ter múltiplos nomes
       for var LNameNode in LVariableDeclNode.Names do
       begin
          LName := LNameNode.Value;
          LKind := skVariable;
          TTypeSpecifierNode := LVariableDeclNode.TypeSpecifier;
          if Assigned(TTypeSpecifierNode) then // Tipo pode ser inferido (var x := 10)
          begin
             if TTypeSpecifierNode is TIdentTypeNode then
                 LValueTypeName := TIdentTypeNode(TTypeSpecifierNode).Name.Value
             else LValueTypeName := '<complex_type>';
          end else LValueTypeName := '<inferred>'; // TODO: Tentar inferir do valor inicial? (Mais complexo)
          LLine := LNameNode.Line;
          LCol := LNameNode.Col;
          LFQN := BuildFQN(LParentFQN, LName);
          LSymbol := TSymbol.Create(Self, AFullFileName, LNameNode, LFQN, LName, LKind, LValueTypeName, '', AUnitSection, LLine, LCol);
          AddSymbol(LSymbol);
       end;
      LName := '';
  end
  else if ANode is TConstantDeclNode then
  begin
     LConstantDeclNode := TConstantDeclNode(ANode);
     LName := LConstantDeclNode.Name.Value;
     LKind := skConstant;
     TTypeSpecifierNode := LConstantDeclNode.TypeSpecifier; // Pode ter tipo explícito (const C: Integer = 5)
     if Assigned(TTypeSpecifierNode) then begin
        if TTypeSpecifierNode is TIdentTypeNode then LValueTypeName := TIdentTypeNode(TTypeSpecifierNode).Name.Value
        else LValueTypeName := '<complex_type>';
     end else LValueTypeName := '<deduced>'; // Tipo deduzido do valor
     LLine := LConstantDeclNode.Name.Line;
     LCol := LConstantDeclNode.Name.Col;
  end
  else if ANode is TParameterDeclNode then
  begin
     LParamDeclNode := TParameterDeclNode(ANode);
      // Pode ter múltiplos nomes (P1, P2: Integer)
      for var LNameNode in LParamDeclNode.Names do
      begin
         LName := LNameNode.Value;
         LKind := skParameter;
         TTypeSpecifierNode := LParamDeclNode.TypeSpecifier;
         if TTypeSpecifierNode is TIdentTypeNode then
             LValueTypeName := TIdentTypeNode(TTypeSpecifierNode).Name.Value
         else LValueTypeName := '<complex_type>';
         LLine := LNameNode.Line;
         LCol := LNameNode.Col;
         LFQN := BuildFQN(LParentFQN, LName); // Parâmetros pertencem ao escopo do método pai
         LSymbol := TSymbol.Create(Self, AFullFileName, LNameNode, LFQN, LName, LKind, LValueTypeName, '', AUnitSection, LLine, LCol);
         AddSymbol(LSymbol);
      end;
      LName := '';
  end
    else if ANode is TPropertyDeclNode then
  begin
     LPropertyDeclNode := TPropertyDeclNode(ANode);
     LName := LPropertyDeclNode.Name.Value;
     LKind := skProperty;
     TTypeSpecifierNode := LPropertyDeclNode.TypeSpecifier;
      if TTypeSpecifierNode is TIdentTypeNode then
          LValueTypeName := TIdentTypeNode(TTypeSpecifierNode).Name.Value
      else LValueTypeName := '<complex_type>';
      LLine := LPropertyDeclNode.Name.Line;
      LCol := LPropertyDeclNode.Name.Col;
  end;

  // --- Se um símbolo foi identificado, cria e adiciona ---
  if (LKind <> skUnknown) and (LName <> '') then
  begin
    LFQN := BuildFQN(LParentFQN, LName);
    LSymbol := TSymbol.Create(Self, AFullFileName, ANode, LFQN, LName, LKind, LValueTypeName, LAncestorTypeName, AUnitSection, LLine, LCol);
    AddSymbol(LSymbol); // Adiciona/encadeia na tabela

    // Associa o símbolo ao nó que define o escopo (se for o caso)
    // Isso pode ser útil depois para encontrar o escopo de um nó qualquer.
    // Precisa de uma forma de marcar nós AST. Talvez um TDictionary<ISyntaxNode, IDelphiASTSymbol> externo?
    // Ou modificar as classes DelphiAST (não ideal).
    // Uma alternativa é o ResolveNode fazer a busca pelo escopo pai na tabela.

    // Se o símbolo atual define um novo escopo (Unit, Class, Method, etc.), empilha
    if LKind in [skUnit, skClass, skInterface, skRecord, skObject, skMethod, skConstructor, skDestructor, skFunction, skProcedure] then
    begin
      PushScope(LSymbol);
      LScopePushed := True;
    end;
  end;

  // --- Processa filhos recursivamente ---
  if Length(ANode.ChildNodes) > 0 then
  begin
    for LChildNode in ANode.ChildNodes do
      ProcessNodeRecursive(LChildNode, AFullFileName, AUnitSection);
  end;

  // --- Desempilha o escopo se ele foi empilhado neste nível ---
  if LScopePushed then
    PopScope;

end;

// Determina o TSymbolKind com base no tipo do nó AST
// (PRECISA SER EXPANDIDA com mais tipos de DelphiAST.Classes)
function TSymbolTable.GetNodeSymbolKind(ANode: ISyntaxNode): TSymbolKind;
begin
  Result := skUnknown;
  if not Assigned(ANode) then Exit;

  if ANode is TClassTypeNode then Result := skClass
  else if ANode is TInterfaceTypeNode then Result := skInterface
  else if ANode is TRecordTypeNode then Result := skRecord
  else if ANode is TEnumTypeNode then Result := skEnum
  else if ANode is TStringTypeNode then Result := skStringType
  else if ANode is TArrayTypeNode then Result := skArray
  else if ANode is TSetTypeNode then Result := skSet
  else if ANode is TPointerTypeNode then Result := skPointer
  else if ANode is TProcedureTypeNode then Result := skProcedureType
  else if ANode is TMethodDeclNode then // Verificar subtipos
  begin
     case TMethodDeclNode(ANode).MethodKind of // Precisa checar se DelphiAST tem essa prop
       mkFunction: Result := skFunction;
       mkProcedure: Result := skProcedure;
       mkConstructor: Result := skConstructor;
       mkDestructor: Result := skDestructor;
     else Result := skMethod; // Genérico
     end;
  end
  else if ANode is TPropertyDeclNode then Result := skProperty
  else if ANode is TFieldDeclNode then Result := skField // Note: ProcessNodeRecursive trata múltiplos
  else if ANode is TVariableDeclNode then Result := skVariable // Note: ProcessNodeRecursive trata múltiplos
  else if ANode is TConstantDeclNode then Result := skConstant
  else if ANode is TParameterDeclNode then Result := skParameter // Note: ProcessNodeRecursive trata múltiplos
  else if ANode is TIdentTypeNode then Result := skTypeAlias; // Ou pode ser uso de tipo existente

  // ... adicionar mais mapeamentos ...
end;

// Extrai uses da Interface/Implementation
procedure TSymbolTable.ExtractUses(AUnitSymbol: IDelphiASTSymbol; ANode: ISyntaxNode);
var
  LUnitInfo: TUnitInfo;
  LUsesList: TNodeList<TUnitRefNode>; // Tipo correto do DelphiAST para lista de uses?
  LInterfaceUsesNode, LImplementationUsesNode: ISyntaxNode; // Nós <USES>
  LUnitRefNode: TUnitRefNode;
  I: Integer;
begin
  // Acha/Cria o TUnitInfo para esta unit
  if not FUnits.TryGetValue(AUnitSymbol.Name, LUnitInfo) then
  begin
     // Não deveria acontecer se AUnitSymbol já foi adicionado
     LUnitInfo := TUnitInfo.Create(AUnitSymbol);
     FUnits.Add(LUnitInfo.UnitName, LUnitInfo); // Assumindo TObjectDictionary
  end;

  // Encontra nós USES na Interface e Implementation
  // (Precisa adaptar aos métodos de busca do DelphiAST ou navegar manualmente)
  // Exemplo conceitual:
  LInterfaceUsesNode := ANode.FindFirstChild(TInterfaceSectionNode).FindFirstChild(TUsesClauseNode); // Exemplo, API pode variar
  if Assigned(LInterfaceUsesNode) and (LInterfaceUsesNode is TUsesClauseNode) then
  begin
     LUsesList := TUsesClauseNode(LInterfaceUsesNode).Units; // Exemplo
     for LUnitRefNode in LUsesList do
       LUnitInfo.AddInterfaceUse(LUnitRefNode.Name.Value);
  end;

  // Similar para Implementation
  // ...

end;


// Primeira fase: Constrói a tabela a partir da AST
procedure TSymbolTable.ProcessAst(const AFullFileName: string; ARootNode: ISyntaxNode);
var LUnitSymbol: IDelphiASTSymbol; LUnitName, LRootName: string; LKind: TSymbolKind;
begin
  if not Assigned(ARootNode) then Exit;

  // 1. Cria símbolo para a própria UNIT
  LRootName := '';
  // Tenta pegar o nome da unit do nó raiz (pode ser atributo ou nó filho)
  if ARootNode is TUnitNode then LRootName := TUnitNode(ARootNode).Name.Value // Se houver TUnitNode
  else begin
     // Tenta achar atributo 'name' se for genérico ISyntaxNode
     var LNameAttr := ARootNode.FindAttribute('name'); // Supondo que DelphiAST tenha FindAttribute
     if Assigned(LNameAttr) then LRootName := LNameAttr.Value;
  end;

  if LRootName = '' then LRootName := TPath.GetFileNameWithoutExtension(AFullFileName); // Fallback

  LKind := skUnit;
  LUnitName := LowerCase(LRootName);
  LUnitSymbol := TSymbol.Create(Self, AFullFileName, ARootNode, LUnitName, LRootName, LKind, '', '', 'unit', ARootNode.Line, ARootNode.Col);
  AddSymbol(LUnitSymbol);

  // 2. Empilha o escopo da Unit
  PushScope(LUnitSymbol);
  try
    // 3. Extrai os USES desta Unit
    ExtractUses(LUnitSymbol, ARootNode); // Implementar busca dos nós USES

    // 4. Processa recursivamente o restante da árvore
    // Determina a seção inicial (geralmente interface)
    var LInterfaceSectionNode := ARootNode.FindFirstChild(TInterfaceSectionNode); // Exemplo
    if Assigned(LInterfaceSectionNode) then
       ProcessNodeRecursive(LInterfaceSectionNode, AFullFileName, 'interface');

    var LImplementationSectionNode := ARootNode.FindFirstChild(TImplementationSectionNode); // Exemplo
    if Assigned(LImplementationSectionNode) then
       ProcessNodeRecursive(LImplementationSectionNode, AFullFileName, 'implementation');

     // Processar outras seções se houver (initialization, finalization)?

  finally
    // 5. Desempilha o escopo da Unit
    PopScope;
  end;
end;

// Segunda fase: Resolve os links
procedure TSymbolTable.PostProcess;
var LSymbol: IDelphiASTSymbol;
begin
  for LSymbol in FSymbols.Values do
  begin
    if LSymbol is TSymbol then // Acessa a implementação concreta
      TSymbol(LSymbol).ResolveLinks;
  end;
end;

// --- Funções de Busca ---

function TSymbolTable.LookupDirect(const AFQN: string): IDelphiASTSymbol;
begin
  FSymbols.TryGetValue(LowerCase(AFQN), Result);
end;

// Procura em escopos pais, subindo na hierarquia do FQN
function TSymbolTable.LookupInScopeHierarchy(AStartingScopeFQN: string; const ASimpleName: string): IDelphiASTSymbol;
var LScopeFQN: string; LTargetFQN: string;
begin
  Result := nil;
  LScopeFQN := LowerCase(AStartingScopeFQN);
  while LScopeFQN <> '' do
  begin
    LTargetFQN := LScopeFQN + '.' + LowerCase(ASimpleName);
    if FSymbols.TryGetValue(LTargetFQN, Result) then Exit; // Encontrado
    // Prepara para buscar no próximo escopo pai
    LScopeFQN := ExtractParentFQN(LScopeFQN);
  end;
  // Se chegou aqui, não encontrou subindo nos escopos FQN diretos
end;

// Procura nas Units da seção USES (Interface e/ou Implementation)
function TSymbolTable.LookupInUnitUses(const ACurrentUnitName: string; const ASimpleName: string): IDelphiASTSymbol;
var
  LUnitInfo: TUnitInfo;
  LUsedUnitName: string;
  LTargetFQN: string;
begin
  Result := nil;
  if not FUnits.TryGetValue(LowerCase(ACurrentUnitName), LUnitInfo) then Exit;

  // 1. Uses da Interface
  for LUsedUnitName in LUnitInfo.FInterfaceUses do // Acessando HashSet diretamente
  begin
    LTargetFQN := LUsedUnitName + '.' + LowerCase(ASimpleName);
    if FSymbols.TryGetValue(LTargetFQN, Result) then Exit;
  end;

  // 2. Uses da Implementation (somente os que não estão na Interface)
  for LUsedUnitName in LUnitInfo.FImplementationUses do
  begin
    if not LUnitInfo.FInterfaceUses.Contains(LUsedUnitName) then // Evita re-checar
    begin
      LTargetFQN := LUsedUnitName + '.' + LowerCase(ASimpleName);
      if FSymbols.TryGetValue(LTargetFQN, Result) then Exit;
    end;
  end;
end;

// Função principal de busca - combina busca local, hierárquica e em USES
function TSymbolTable.LookupSymbol(AStartingScope: IDelphiASTSymbol; const ASymbolName: string): IDelphiASTSymbol;
var
  LSearchName: string;
  LScopeFQN: string;
  LUnitName: string;
  LParts: TArray<string>;
  LCurrentResolved: IDelphiASTSymbol;
  I: Integer;
begin
  Result := nil;
  LSearchName := ASymbolName; // Manter Case original para partes pode ser importante? Não, lookup é sempre lowercase.
  LSearchName := LowerCase(LSearchName);
  if LSearchName = '' then Exit;

  // --- Define o ponto de partida da busca ---
  LScopeFQN := ''; // FQN do escopo inicial
  LUnitName := ''; // Nome da Unit do escopo inicial
  if Assigned(AStartingScope) then
  begin
     LScopeFQN := AStartingScope.FullyQualifiedName;
     // Determina a Unit do escopo inicial
     if AStartingScope.Kind = skUnit then
       LUnitName := AStartingScope.Name
     else
       LUnitName := ExtractUnitName(LScopeFQN); // Pega a primeira parte do FQN
  end;


  // --- Caso 1: Nome Simples ---
  if Pos('.', LSearchName) = 0 then
  begin
     // 1.1 Busca subindo na hierarquia de escopos do FQN
     Result := LookupInScopeHierarchy(LScopeFQN, LSearchName);
     if Assigned(Result) then Exit;

     // 1.2 Busca como símbolo global na Unit atual (se houver unit)
     if LUnitName <> '' then
     begin
        Result := LookupDirect(LUnitName + '.' + LSearchName);
        if Assigned(Result) then Exit;

        // 1.3 Busca nas Units da seção USES
        Result := LookupInUnitUses(LUnitName, LSearchName);
        if Assigned(Result) then Exit;
     end;

     // 1.4 (Opcional) Busca em Units padrão (System, SysUtils) - Adicionar lógica aqui

     // 1.5 (Último recurso) Busca como símbolo global absoluto (sem prefixo de unit)
     // Pode ser útil para tipos intrínsecos como 'integer', 'string' se não adicionados explicitamente
      Result := LookupDirect(LSearchName);

  end
  // --- Caso 2: Nome Qualificado (A.B.C) ---
  else
  begin
     LParts := LSearchName.Split(['.']);
     if Length(LParts) = 0 then Exit;

     // Resolve a primeira parte (LParts[0])
     // Pode ser uma Unit ou um símbolo local/herdado
     LCurrentResolved := LookupSymbol(AStartingScope, LParts[0]); // Busca recursiva

     // Resolve as partes subsequentes
     for I := 1 to High(LParts) do
     begin
        if not Assigned(LCurrentResolved) then Exit(nil); // Perdeu a cadeia

        // Determina o escopo para procurar a próxima parte:
        // É o TIPO do símbolo atual!
        var LNextScope: IDelphiASTSymbol := nil;
        if Assigned(LCurrentResolved.ValueType) then LNextScope := LCurrentResolved.ValueType // Prefere tipo de valor
        else if Assigned(LCurrentResolved.AncestorType) then LNextScope := LCurrentResolved.AncestorType // Usa ancestral se for tipo
        else LNextScope := LCurrentResolved; // Usa o próprio símbolo se não for tipo (ex: Unit)


        // Busca a próxima parte (LParts[I]) DENTRO do escopo encontrado
        if Assigned(LNextScope) then
            LCurrentResolved := LookupDirect(LNextScope.FullyQualifiedName + '.' + LParts[I])
        else
            LCurrentResolved := nil; // Não conseguiu determinar o escopo para a próxima parte
     end;

     Result := LCurrentResolved; // O resultado é o último símbolo encontrado na cadeia
  end;
end;

// Resolve um nó de *uso* para encontrar sua declaração correspondente
function TSymbolTable.ResolveNode(AUsageNode: ISyntaxNode): IDelphiASTSymbol;
var
  LSearchName: string;
  LParentNode: ISyntaxNode;
  LParentSymbol: IDelphiASTSymbol; // Símbolo do escopo onde AUsageNode está
begin
  Result := nil;
  if not Assigned(AUsageNode) then Exit;

  // 1. Extrair o nome/caminho do símbolo do nó de uso
  // (Esta é a parte mais complexa, pois AUsageNode pode ser TIdentifierNode, TDotNode, etc.)
  // Exemplo MUITO simplificado:
  if AUsageNode is TIdentifierNode then
     LSearchName := TIdentifierNode(AUsageNode).Value
  // else if AUsageNode is TDotNode then ... reconstruir A.B.C ...
  else
     Exit; // Precisa de lógica para extrair nome de outros tipos de nó

  if LSearchName = '' then Exit;

  // 2. Encontrar o símbolo do ESCOPO onde AUsageNode está inserido
  // Isso é crucial e difícil. Uma maneira:
  //   a) Caminhar para cima no ParentNode até achar um nó que SABEMOS que tem símbolo (método, classe, unit)
  //   b) Olhar um possível TDictionary<ISyntaxNode, IDelphiASTSymbol> preenchido durante o parse.
  //   c) Por simplicidade *INCORRETA*, vamos assumir que o escopo é nulo (global) por enquanto
  LParentSymbol := nil; // <<< PRECISA DE IMPLEMENTAÇÃO CORRETA PARA ACHAR O ESCOPO DO NÓ
  // Ex: LParentSymbol := FindScopeSymbolForNode(AUsageNode);

  // 3. Chamar a busca principal
  Result := LookupSymbol(LParentSymbol, LSearchName);
end;

end.


Explicações e Próximos Passos:

TSymbol (Interface/Classe):

Agora usa TInterfacedObject para gerenciamento automático de memória.

IDelphiASTSymbol define o contrato.

Campos FValueTypeSymbol, FAncestorTypeSymbol, FScopeSymbol armazenam as interfaces resolvidas.

ResolveLinks: Método chamado na segunda fase para encontrar e ligar esses símbolos referenciados usando LookupSymbol.

FSymbolTableRef: Necessário para que ResolveLinks possa chamar LookupSymbol.

TUnitInfo:

Armazena o IDelphiASTSymbol da própria unit.

Usa THashSet<string> para os uses, oferecendo busca Contains O(1).

TSymbolTable:

FSymbols: TDictionary<string, IDelphiASTSymbol>. Armazena interfaces.

FUnits: Idealmente TObjectDictionary<string, TUnitInfo>.Create([doOwnsValues]) ou TDictionary<string, TUnitInfo> e gerenciar TUnitInfo manualmente/via interface.

FScopeStack: Usado durante a travessia (ProcessNodeRecursive) para saber o escopo pai ao criar novos símbolos.

ProcessAst e ProcessNodeRecursive: Esta é a nova lógica central da Fase 1. Percorre a árvore ISyntaxNode.

Precisa de lógica detalhada para cada tipo de nó de declaração (TTypeDeclNode, TMethodDeclNode, etc.) para extrair as informações corretas (Nome, Kind, Tipo, Ancestral, Linha, Col). Isso envolve conhecer bem as classes em DelphiAST.Classes.

Usa GetCurrentScope (baseado na FScopeStack) para determinar o pai ao criar FQNs e potencialmente o FScopeSymbol.

Empilha/Desempilha escopos (PushScope, PopScope) ao entrar/sair de nós que definem escopo (units, classes, métodos).

Chama AddSymbol para inserir na tabela.

AddSymbol: Adiciona ao dicionário ou encadeia em NextOverloadImpl.

PostProcess: Simplesmente itera e chama TSymbol.ResolveLinks.

LookupSymbol: Função principal de busca. Separa lógica para nomes simples e qualificados. Usa LookupInScopeHierarchy e LookupInUnitUses.

ResolveNode: O mais complexo. Precisa extrair o nome do nó de uso e determinar corretamente o escopo desse nó para chamar LookupSymbol. Essa é a base para "Go to Definition" e type hints.

Trabalho a Fazer:

Completar ProcessNodeRecursive: Mapear TODOS os TSyntaxNode relevantes de DelphiAST.Classes que representam declarações. Extrair corretamente Name, Kind, ValueTypeName, AncestorTypeName, Line, Col.

Implementar ExtractUses: Usar a API do DelphiAST para encontrar os nós USES e TUnitRefNode (ou equivalentes).

Refinar BuildFQN / Gerenciamento de Escopo: Garantir que o FQN seja construído corretamente baseado na FScopeStack.

Implementar ResolveNode robustamente: Achar o escopo de um nó de uso é chave. Pode exigir informações adicionais armazenadas durante o parse ou uma busca para cima mais inteligente.

Tratamento de Erros e Casos Especiais: O que fazer com tipos não resolvidos? E genéricos? E diretivas de compilação? Sobrecarga real?

Otimização (Se Necessário): Para arquivos muito grandes, a construção inicial ainda pode levar tempo.

API Pública: Decidir quais métodos da TSymbolTable devem ser públicos para quem for usar a biblioteca.

Este código é um ponto de partida mais robusto e performático por operar diretamente no AST. O esforço agora se concentra em mapear corretamente as estruturas do DelphiAST para a tabela de símbolos e implementar a lógica de resolução de escopo de forma precisa. É um desafio, mas com certeza factível e um ótimo projeto para a comunidade! Boa sorte!
