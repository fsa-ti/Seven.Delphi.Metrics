unit Seven.DelphiAST.Helpers;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  Seven.DelphiAST.Consts,
  Seven.DelphiAST.Classes,
  Seven.SimpleParser.Lexer.Types;

type

  TSyntaxNodeTypeHelper = record helper for TSyntaxNodeType
  public
    function ToString(): string;
    class operator Equal(const a: TSyntaxNodeType; const b: string): Boolean; inline;
    class operator Equal(const a: string; const b: TSyntaxNodeType): Boolean; inline;
    function Equal(const a: string): Boolean; inline;
    function NotEqual(const a: string): Boolean; inline;
    class function FromString(const ANodeTypeStr: string): TSyntaxNodeType; static;
  end;

  TAttributeNameHelper = record helper for TAttributeName
  public
    class function FromString(const AKey: string): TAttributeName; static;
  end;

  TSyntaxNodeHelper = class helper for TSyntaxNode
  private
    function GetChildNodeCount(): Integer;
  public
    function GetBodyNode: TSyntaxNode;
    function IsConstructorOrDestructor: Boolean;
    function HasNode(const ANodeType: string): Boolean;
    function GetMemberNodes(): TArray<TSyntaxNode>;
    function HasMembers(): Boolean;
    property ChildNodeCount: Integer read GetChildNodeCount;
    function FindNode(const ANodeType: string): TSyntaxNode; overload;
    function GetAttribute(const AKey: string): string; overload;
    function HasAttribute(const AKey: string): Boolean; overload;
    procedure SetAttribute(const AKey: string; const AValue: string); overload;

    function GetMemberNode: TSyntaxNode;
    function GetObjectNode: TSyntaxNode;
    function IsMemberAccess: Boolean;
    function IsQualifiedIdentifier: Boolean;

    function HasBody: Boolean;
    function FindBodyNode: TSyntaxNode;
    function HasChildNodes(): Boolean;
  end;

  TSymbolKind = (
    askSymbolKind = Ord(TAttributeName.anAlign) + 1,
    askDeclarationLine,
    askDeclarationCol
  );

  TSymbolKindHelper = record helper for TSymbolKind
  public
    class function TryFromString(const AKey: string; out ASymbolKind: TSymbolKind): Boolean; static;
  end;



const
  SymbolKindNames: array [Low(TSymbolKind)..High(TSymbolKind)] of string = (
    'symbolkind',
    'declarationline',
    'declarationcol'
  );

function IsKeywordDelphiStr(const AStr: string): Boolean;

const
  TokenKindStrings: array[TptTokenKind.ptAbsolute..TptTokenKind.ptXor] of string = (
    'absolute',
    'abstract',
    'add',
    'addressop',
    'align',
    'ampersand',
    'and',
    'ansicomment',
    'ansistring',
    'array',
    'as',
    'asciichar',
    'asm',
    'assembler',
    'assign',
    'at',
    'automated',
    'begin',
    'boolean',
    'borcomment',
    'braceclose',
    'braceopen',
    'break',
    'byte',
    'bytebool',
    'cardinal',
    'case',
    'cdecl',
    'char',
    'class',
    'classforward',
    'classfunction',
    'classprocedure',
    'colon',
    'comma',
    'comp',
    'compdirect',
    'const',
    'constructor',
    'contains',
    'continue',
    'crlf',
    'crlfco',
    'currency',
    'default',
    'definedirect',
    'deprecated',
    'destructor',
    'dispid',
    'dispinterface',
    'div',
    'do',
    'dotdot',
    'double',
    'doubleaddressop',
    'downto',
    'dword',
    'dynamic',
    'else',
    'elsedirect',
    'end',
    'endifdirect',
    'equal',
    'error',
    'except',
    'exit',
    'export',
    'exports',
    'extended',
    'external',
    'far',
    'file',
    'final',
    'experimental',
    'delayed',
    'finalization',
    'finally',
    'float',
    'for',
    'forward',
    'function',
    'goto',
    'greater',
    'greaterequal',
    'halt',
    'helper',
    'identifier',
    'if',
    'ifdirect',
    'ifenddirect',
    'elseifdirect',
    'ifdefdirect',
    'ifndefdirect',
    'ifoptdirect',
    'implementation',
    'implements',
    'in',
    'includedirect',
    'index',
    'inherited',
    'initialization',
    'inline',
    'int64',
    'integer',
    'integerconst',
    'interface',
    'is',
    'label',
    'library',
    'local',
    'longbool',
    'longint',
    'longword',
    'lower',
    'lowerequal',
    'message',
    'minus',
    'mod',
    'name',
    'near',
    'nil',
    'nodefault',
    'none',
    'not',
    'notequal',
    'null',
    'object',
    'of',
    'olevariant',
    'on',
    'operator',
    'or',
    'out',
    'overload',
    'override',
    'package',
    'packed',
    'pascal',
    'pchar',
    'platform',
    'plus',
    'point',
    'pointersymbol',
    'private',
    'procedure',
    'program',
    'property',
    'protected',
    'public',
    'published',
    'raise',
    'read',
    'readonly',
    'real',
    'real48',
    'record',
    'reference',
    'register',
    'reintroduce',
    'remove',
    'repeat',
    'requires',
    'resident',
    'resourcedirect',
    'resourcestring',
    'roundclose',
    'roundopen',
    'runerror',
    'safecall',
    'scopedenumsdirect',
    'sealed',
    'semicolon',
    'set',
    'shl',
    'shortint',
    'shortstring',
    'shr',
    'single',
    'slash',
    'slashescomment',
    'smallint',
    'space',
    'squareclose',
    'squareopen',
    'star',
    'static',
    'stdcall',
    'stored',
    'strict',
    'string',
    'stringconst',
    'stringdqconst',
    'stringresource',
    'symbol',
    'then',
    'threadvar',
    'to',
    'try',
    'type',
    'undefdirect',
    'unit',
    'unknown',
    'unsafe',
    'until',
    'uses',
    'var',
    'varargs',
    'variant',
    'virtual',
    'while',
    'widechar',
    'widestring',
    'with',
    'word',
    'wordbool',
    'write',
    'writeonly',
    'xor'
  );

implementation

{ TSyntaxNodeTypeHelper }

class operator TSyntaxNodeTypeHelper.Equal(const a: TSyntaxNodeType; const b: string): Boolean;
begin
  Result := a.ToString().ToLower() = b.ToLower();
end;

class operator TSyntaxNodeTypeHelper.Equal(const a: string; const b: TSyntaxNodeType): Boolean;
begin
  Result := a.ToLower() = b.ToString().ToLower();
end;

function TSyntaxNodeTypeHelper.Equal(const a: string): Boolean;
begin
  Result := Self.ToString().ToLower = a.ToLower();
end;

class function TSyntaxNodeTypeHelper.FromString(const ANodeTypeStr: string): TSyntaxNodeType;
begin
  for var Index := 0 to Length(SyntaxNodeNames) - 1 do
  begin
    if SyntaxNodeNames[TSyntaxNodeType(Index)].ToLower() = ANodeTypeStr.ToLower() then
      Exit(TSyntaxNodeType(Index));
  end;


  raise ENotSupportedException.CreateFmt('Nome do TSyntaxNodeType inválido: %s', [ANodeTypeStr]);
end;

function TSyntaxNodeTypeHelper.NotEqual(const a: string): Boolean;
begin
  Result := not Self.Equal(a);
end;

function TSyntaxNodeTypeHelper.ToString: string;
begin
  Result := SyntaxNodeNames[Self];
end;

{ TSyntaxNodeHelper }

function TSyntaxNodeHelper.FindNode(const ANodeType: string): TSyntaxNode;
begin
  var NodeType: TSyntaxNodeType := TSyntaxNodeType.FromString(ANodeType);
  Result := FindNode(NodeType);
end;

// Verifica se este nó representa um acesso a membro (Objeto.Membro)
function TSyntaxNodeHelper.IsMemberAccess: Boolean;
begin
  // No DelphiAST, acesso a membro geralmente é representado como um nó
  // com um ponto (.) e tem dois nós filhos - o objeto e o membro
  Result := (Self.Typ = ntDot) and (Self.ChildNodeCount = 2);
end;

//// Verifica se este nó representa um acesso a membro (Objeto.Membro)
//function TSyntaxNodeHelper.IsMemberAccess: Boolean;
//begin
//  // Semelhante aos identificadores qualificados
//  Result := IsQualifiedIdentifier;
//
//  // Pode adicionar mais verificações específicas para diferenciar
//  // entre identificadores qualificados e acessos a membros, se necessário
//end;

// Verifica se este nó representa um identificador qualificado (Unidade.Tipo)
function TSyntaxNodeHelper.IsQualifiedIdentifier: Boolean;
begin
  // No DelphiAST, um identificador qualificado é semelhante ao acesso a membro
  // geralmente representado como um nó com um ponto (.) que separa as partes
  Result := (Self.Typ = ntDot) and (Self.ChildNodeCount = 2);
end;

// Obtém o nó do objeto (parte esquerda do acesso a membro)
function TSyntaxNodeHelper.GetObjectNode: TSyntaxNode;
begin
  Result := nil;
  if Self.IsMemberAccess and (Self.ChildNodeCount >= 1) then
    Result := Self.ChildNodes[0];
end;

// Obtém o nó do membro (parte direita do acesso a membro)
function TSyntaxNodeHelper.GetMemberNode: TSyntaxNode;
begin
  Result := nil;
  if Self.IsMemberAccess and (Self.ChildNodeCount >= 2) then
    Result := Self.ChildNodes[1];
end;

//function TSyntaxNodeHelper.GetAttribute(const AKey: string): string;
//begin
//  var AtributeName: TAttributeName := TAttributeName.FromString(AKey);
//  Result := GetAttribute(AtributeName);
//end;

function TSyntaxNodeHelper.GetAttribute(const AKey: string): string;
begin
  // Verificamos se o atributo é um dos tipos enumerados válidos
  try
    var AttrName := TAttributeName.FromString(AKey);
    Result := GetAttribute(AttrName);
  except
    on E: ENotSupportedException do
    begin
      // Casos especiais para atributos que não existem como TAttributeName mas aparecem no XML
      if LowerCase(AKey) = 'value' then
      begin
        if Typ = TSyntaxNodeType.ntIdentifier then
          Result := GetAttribute(anName)
        else if Typ = TSyntaxNodeType.ntValue then
          // Tentamos diferentes abordagens para obter o valor
          Result := GetAttribute(anName);
      end
      else
        Result := ''; // Para outros casos retornamos vazio
    end;
  end;
end;

function TSyntaxNodeHelper.GetChildNodeCount: Integer;
begin
  Result := Length(Self.ChildNodes);
end;

function TSyntaxNodeHelper.HasAttribute(const AKey: string): Boolean;
var
  SymbolKind: TSymbolKind;
  AtributeName: TAttributeName;
begin
  if TSymbolKind.TryFromString(AKey, SymbolKind) then
    AtributeName := TAttributeName(Ord(SymbolKind))
  else
    AtributeName := TAttributeName.FromString(AKey);

  Result := HasAttribute(AtributeName);
end;

procedure TSyntaxNodeHelper.SetAttribute(const AKey: string; const AValue: string);
var
  SymbolKind: TSymbolKind;
  AtributeName: TAttributeName;
begin

  if TSymbolKind.TryFromString(AKey, SymbolKind) then
    AtributeName := TAttributeName(Ord(SymbolKind))
  else
    AtributeName := TAttributeName.FromString(AKey);

  SetAttribute(AtributeName, AValue);
end;

//procedure TSyntaxNodeHelper.SetAttribute(const AKey: string; const AValue: string);
//begin
//  // Primeiro tentamos usar um TAttributeName se existir
//  try
//    var AttrName := TAttributeName.FromString(AKey);
//    // Implemente sua própria lógica para definir o atributo usando o enum
//    // Como isso é feito depende da implementação do seu DelphiAST
//  except
//    on E: ENotSupportedException do
//    begin
//      // Para atributos personalizados, armazenamos em um dicionário ou outra estrutura
//      // Isso depende de como você quer implementar atributos personalizados
//      // Uma opção é usar Tags ou Properties:
//      if Self.PropertyCount = 0 then
//        Self.PropertyCount := 1; // Inicializa o contador de propriedades se necessário
//
//      Self.Properties[AKey] := AValue;
//    end;
//  end;
//end;

function TSyntaxNodeHelper.HasBody: Boolean;
var
  i: Integer;
  BodyNodeTypes: array of string;
begin
  // Tipos de nós que podem representar o corpo de um procedimento/função
  BodyNodeTypes := ['Block', 'CompoundStatement', 'BeginEnd'];

  Result := False;
  for i := 0 to ChildNodeCount - 1 do
  begin
    if ChildNodes[i] <> nil then
    begin
      // Verifica se o nó filho é um dos tipos que podem representar um corpo
      for var NodeType in BodyNodeTypes do
      begin
        if ChildNodes[i].Typ.Equal(NodeType) then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;
end;

function TSyntaxNodeHelper.HasChildNodes(): Boolean;
begin
  Result := HasChildren;
end;

// Este método verifica se o nó tem um filho com o tipo especificado
function TSyntaxNodeHelper.HasNode(const ANodeType: string): Boolean;
var
  NodeTyp: TSyntaxNodeType;
begin
  try
    NodeTyp := TSyntaxNodeType.FromString(ANodeType);
    Result := FindNode(NodeTyp) <> nil;
  except
    on E: ENotSupportedException do
    begin
      // Casos especiais
      if LowerCase(ANodeType) = 'members' then
      begin
        // Uma classe/record pode ter vários tipos de membros
        Result := False;
        for var Child in ChildNodes do
        begin
          if (Child <> nil) and
             ((Child.Typ = TSyntaxNodeType.ntField) or
              (Child.Typ = TSyntaxNodeType.ntMethod) or
              (Child.Typ = TSyntaxNodeType.ntProperty)) then
          begin
            Result := True;
            Break;
          end;
        end;
      end
      else if LowerCase(ANodeType) = 'body' then
      begin
        // Um método pode ter corpo representado por statements
        Result := False;
        for var Child in ChildNodes do
        begin
          if (Child <> nil) and
             ((Child.Typ = TSyntaxNodeType.ntStatements) or
              (Child.Typ = TSyntaxNodeType.ntStatement)) then
          begin
            Result := True;
            Break;
          end;
        end;
      end
      else
        Result := False;
    end;
  end;
end;

// Função para verificar se é um construtor ou destrutor
function TSyntaxNodeHelper.IsConstructorOrDestructor: Boolean;
begin
  Result := HasAttribute(anMethodBinding) and
           ((LowerCase(GetAttribute(anMethodBinding)) = 'constructor') or
            (LowerCase(GetAttribute(anMethodBinding)) = 'destructor'));
end;

// Função para obter o corpo de um método
function TSyntaxNodeHelper.GetBodyNode: TSyntaxNode;
begin
  Result := nil;

  for var Child in ChildNodes do
  begin
    if (Child <> nil) and
       ((Child.Typ = TSyntaxNodeType.ntStatements) or
        (Child.Typ = TSyntaxNodeType.ntStatement)) then
    begin
      Result := Child;
      Break;
    end;
  end;
end;

// Função para obter membros de uma classe/record
function TSyntaxNodeHelper.GetMemberNodes: TArray<TSyntaxNode>;
var
  Count: Integer;
begin
  Count := 0;
  SetLength(Result, ChildNodeCount);

  for var i := 0 to ChildNodeCount - 1 do
  begin
    if (ChildNodes[i] <> nil) and
       ((ChildNodes[i].Typ = TSyntaxNodeType.ntField) or
        (ChildNodes[i].Typ = TSyntaxNodeType.ntMethod) or
        (ChildNodes[i].Typ = TSyntaxNodeType.ntProperty)) then
    begin
      Result[Count] := ChildNodes[i];
      Inc(Count);
    end;
  end;

  SetLength(Result, Count);
end;

function TSyntaxNodeHelper.FindBodyNode: TSyntaxNode;
var
  i: Integer;
  BodyNodeTypes: array of string;
begin
  // Tipos de nós que podem representar o corpo de um procedimento/função
  BodyNodeTypes := ['Block', 'CompoundStatement', 'BeginEnd'];

  Result := nil;
  for i := 0 to ChildNodeCount - 1 do
  begin
    if ChildNodes[i] <> nil then
    begin
      // Verifica se o nó filho é um dos tipos que podem representar um corpo
      for var NodeType in BodyNodeTypes do
      begin
        if ChildNodes[i].Typ.Equal(NodeType) then
        begin
          Result := ChildNodes[i];
          Exit;
        end;
      end;
    end;
  end;
end;

function TSyntaxNodeHelper.HasMembers: Boolean;
var
  Members: TArray<TSyntaxNode>;
begin
  Members := GetMemberNodes;
  Result := Length(Members) > 0;
end;

{ TAttributeNameHelper }

class function TAttributeNameHelper.FromString(const AKey: string): TAttributeName;
begin
  for var Index := 0 to Length(AttributeNameStrings) - 1 do
  begin
    if AttributeNameStrings[TAttributeName(Index)].ToLower() = AKey.ToLower() then
      Exit(TAttributeName(Index));
  end;


  raise ENotSupportedException.CreateFmt('TAttributeName inválido: %s', [AKey.ToLower()]);
end;

//function IsKeywordToken(TokenKind: TptTokenKind): Boolean;
//begin
//  Result := (TokenKind >= ptAbsolute) and (TokenKind <= ptXor);
//end;

//function TokenKindToString(TokenKind: TptTokenKind): string;
//begin
//  Result := TokenKindStrings[TokenKind];
//end;
//
//function IsKeywordDelphiStr(const AStr: string): Boolean;
//const
//  // Lista das palavras-chave reais do Delphi
//  KeywordsList: array[0..61] of string = (
//    'and', 'array', 'as', 'asm', 'begin', 'case', 'class', 'const',
//    'constructor', 'destructor', 'dispinterface', 'div', 'do', 'downto',
//    'else', 'end', 'except', 'exports', 'file', 'finalization', 'finally',
//    'for', 'function', 'goto', 'if', 'implementation', 'in', 'inherited',
//    'initialization', 'inline', 'interface', 'is', 'label', 'library', 'mod',
//    'nil', 'not', 'object', 'of', 'or', 'out', 'packed', 'procedure',
//    'program', 'property', 'raise', 'record', 'repeat', 'resourcestring',
//    'set', 'shl', 'shr', 'string', 'then', 'threadvar', 'to', 'try',
//    'type', 'unit', 'until', 'uses', 'var', 'while', 'with', 'xor'
//  );
//var
//  LowerStr: string;
//  i: Integer;
//begin
//  LowerStr := LowerCase(AStr);
//
//  for i := Low(KeywordsList) to High(KeywordsList) do
//    if LowerStr = KeywordsList[i] then
//      Exit(True);
//
//  Result := False;
//end;

{ Função auxiliar para verificar se a string é uma palavra-chave do Delphi }
function IsKeywordDelphiStr(const AStr: string): Boolean;
const
  DelphiKeywords: array[0..69] of string = (
    'and', 'array', 'as', 'asm', 'begin', 'case', 'class', 'const',
    'constructor', 'destructor', 'dispinterface', 'div', 'do', 'downto',
    'else', 'end', 'except', 'exports', 'file', 'finalization', 'finally',
    'for', 'function', 'goto', 'if', 'implementation', 'in', 'inherited',
    'initialization', 'inline', 'interface', 'is', 'label', 'library', 'mod',
    'nil', 'not', 'object', 'of', 'or', 'out', 'packed', 'procedure',
    'program', 'property', 'raise', 'record', 'repeat', 'resourcestring',
    'set', 'shl', 'shr', 'string', 'then', 'threadvar', 'to', 'try',
    'type', 'unit', 'until', 'uses', 'var', 'while', 'with', 'xor',
    'on', 'private', 'protected', 'public', 'published'
  );
var
  LowerStr: string;
  I: Integer;
begin
  LowerStr := LowerCase(AStr);
  for I := Low(DelphiKeywords) to High(DelphiKeywords) do
    if LowerStr = DelphiKeywords[I] then
      Exit(True);
  Result := False;
end;


{ TSymbolKindHelper }

class function TSymbolKindHelper.TryFromString(const AKey: string; out ASymbolKind: TSymbolKind): Boolean;
begin
  Result := False;

  for var Index := Low(SymbolKindNames) to High(SymbolKindNames) do
  begin
    if SymbolKindNames[Index].ToLower() = AKey.ToLower() then
    begin
      ASymbolKind := TSymbolKind(Index);
      Result := True;
      Break;
    end;
  end;
end;

end.
