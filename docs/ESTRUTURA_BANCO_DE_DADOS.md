# Mapeamento e Estrutura do Banco de Dados

## 1. Visão Geral
A persistência de dados do projeto em Banco de Dados é realizada na unidade [`Source/Seven.Builder.AnalyticsAndMetrics.SaveService.pas`](file:///d:/git/laboratorio/GeradorVersaoMetricasCodigo/Source/Seven.Builder.AnalyticsAndMetrics.SaveService.pas) através da classe `TCodeAnalyzerSaveMetricsServiceDatabase`.

- **Biblioteca ORM / Acesso**: `Breeze.Redist.Database.Client` (`TBreezeDatabaseDll`).
- **SGDB Alvo**: PostgreSQL.
- **Modelo de Dados**: Estrutura Mestre-Detalhe (**1 para N**) composta por duas tabelas:
  1. `MetricaCodigo`: Registro consolidado da execução de análise do projeto/versão.
  2. `ArquivoMetricaCodigo`: Registro granular com as métricas individuais de cada arquivo `.pas`/`.dpr`/`.dpk`.

---

## 2. Dicionário de Dados

### A. Tabela Mestre: `MetricaCodigo`

Guarda as métricas consolidadas (totais agregados) de um projeto ou grupo de projetos analisados em uma determinada versão e data.

| Campo | Tipo SQL | Campo no Delphi | Descrição |
|---|---|---|---|
| `CodMetricaCodigo` | `INTEGER` (PK) | `CodMetricaCodigo` | Chave Primária |
| `Versao` | `VARCHAR(50)` | `FVersionCode` | Identificador de versão da aplicação analisada |
| `DataVersao` | `TIMESTAMP` | `FVersionDate` | Data de referência da versão |
| `NomeArquivo` | `VARCHAR(500)` | `CodeStatistics.FileName` | Nome/Caminho do arquivo `.dproj` ou `.groupproj` |
| `TotalArquivos` | `INTEGER` | `Length(GetFileNames)` | Quantidade total de arquivos analisados |
| `TotalLinhasEmBranco` | `BIGINT` | `GetTotalBlankLineCount` | Soma de linhas em branco |
| `TotalLinhasCodigo` | `BIGINT` | `GetTotalLineCodeCount` | Soma de linhas totais de código |
| `TotalLinhasComentadas` | `BIGINT` | `GetTotalCommentLineCount` | Soma de linhas de comentário |
| `TotalClasses` | `BIGINT` | `GetTotalClassCount` | Total de classes declaradas |
| `TotalPropriedadeClasses` | `BIGINT` | `GetTotalClassPropertyCount` | Total de propriedades de classes |
| `TotalPropriedadeRecord` | `BIGINT` | `GetTotalRecordPropertyCount` | Total de propriedades em records |
| `TotalInterfaces` | `BIGINT` | `GetTotalInterfaceCount` | Total de interfaces declaradas |
| `TotalPropriedadeRecordInterface` | `BIGINT` | `GetTotalInterfacePropertyCount` | Total de propriedades em interfaces |
| `TotalRecords` | `BIGINT` | `GetTotalRecordCount` | Total de estruras record |
| `TotalEnumerados` | `BIGINT` | `GetTotalEnumCount` | Total de tipos enumerados |
| `TotalMetodosPublicos` | `BIGINT` | `GetTotalPublicMethodCount` | Total de métodos públicos |
| `TotalMetodosPrivados` | `BIGINT` | `GetTotalPrivateMethodCount` | Total de métodos privados |
| `TotalMetodosProtegidos` | `BIGINT` | `GetTotalProtectedMethodCount` | Total de métodos protegidos |
| `TotalMetodosEstaticos` | `BIGINT` | `GetTotalStaticMethodCount` | Total de métodos estáticos |
| `TotalMetodosImplementados` | `BIGINT` | `GetTotalImplMethodCount` | Total de procedimentos/funções no `IMPLEMENTATION` |
| `ComplexidadeCiclomatica` | `BIGINT` | `GetTotalCyclomaticComplexity` | Soma da Complexidade Ciclomática (McCabe - MCC) |
| `TotalFuncaoGlobal` | `BIGINT` | `GetTotalGlobalFunctionCount` | Total de funções/procedimentos globais |
| `TotalVariavelGlobal` | `BIGINT` | `GetTotalGlobalVariableCount` | Total de variáveis globais |
| `TotalConstanteGlobal` | `BIGINT` | `GetTotalGlobalConstantCount` | Total de constantes globais |
| `TempoAnaliseMS` | `DOUBLE PRECISION` | `GetTotalAnalysisTimeMs` | Tempo total de execução do parse em milissegundos |
| `DataHoraInclusao` | `TIMESTAMP` | `Now()` | Data/Hora de gravação no banco |
| `EstacaoTrabalhoInclusao` | `VARCHAR(100)` | `'SERVER'` | Estação de trabalho geradora |
| `VersaoInlcusao` | `VARCHAR(50)` | `'1.0.0.0'` | Versão do executável coletor |

---

### B. Tabela Detalhe: `ArquivoMetricaCodigo`

Guarda as métricas individuais e detalhadas de cada arquivo fonte analisado.

| Campo | Tipo SQL | Campo no Delphi | Descrição |
|---|---|---|---|
| `CodArquivoMetricaCodigo` | `INTEGER` (PK) | `CodArquivoMetricaCodigo` | Chave Primária |
| `CodMetricaCodigo` | `INTEGER` (FK) | `CodMetricaCodigo` | Chave Estrangeira referente a `MetricaCodigo` |
| `NomeArquivo` | `VARCHAR(500)` | `FileStat.FileName` | Caminho do arquivo `.pas`/`.dpr`/`.dpk` |
| `TotalLinhasEmBranco` | `BIGINT` | `FileStat.BlankLineCount` | Linhas em branco do arquivo |
| `TotalLinhasCodigo` | `BIGINT` | `FileStat.LineCodeCount` | Linhas totais de código do arquivo |
| `TotalLinhasComentadas` | `BIGINT` | `FileStat.CommentLineCount` | Linhas de comentário do arquivo |
| `TotalClasses` | `BIGINT` | `FileStat.ClassCount` | Classes no arquivo |
| `TotalPropriedadeClasses` | `BIGINT` | `FileStat.ClassPropertyCount` | Propriedades de classe no arquivo |
| `TotalInterfaces` | `BIGINT` | `FileStat.InterfaceCount` | Interfaces no arquivo |
| `TotalRecords` | `BIGINT` | `FileStat.RecordCount` | Records no arquivo |
| `TotalEnumerados` | `BIGINT` | `FileStat.EnumCount` | Enums no arquivo |
| `TotalMetodosPublicos` | `BIGINT` | `FileStat.PublicMethodCount` | Métodos públicos |
| `TotalMetodosPrivados` | `BIGINT` | `FileStat.PrivateMethodCount` | Métodos privados |
| `TotalMetodosProtegidos` | `BIGINT` | `FileStat.ProtectedMethodCount` | Métodos protegidos |
| `TotalMetodosEstaticos` | `BIGINT` | `FileStat.StaticMethodCount` | Métodos estáticos |
| `TotalMetodosImplementados` | `BIGINT` | `FileStat.ImplMethodCount` | Métodos implementados na seção `IMPLEMENTATION` |
| `ComplexidadeCiclomatica` | `BIGINT` | `FileStat.CyclomaticComplexity` | Complexidade Ciclomática (MCC) do arquivo |
| `TotalFuncaoGlobal` | `BIGINT` | `FileStat.GlobalFunctionCount` | Funções globais |
| `TotalVariavelGlobal` | `BIGINT` | `FileStat.GlobalVariableCount` | Variáveis globais |
| `TotalConstanteGlobal` | `BIGINT` | `FileStat.GlobalConstantCount` | Constantes globais |
| `DataHoraInclusao` | `TIMESTAMP` | `Now()` | Data/Hora de gravação |
| `EstacaoTrabalhoInclusao` | `VARCHAR(100)` | `'SERVER'` | Estação de trabalho |
| `VersaoInlcusao` | `VARCHAR(50)` | `'1.0.0.0'` | Versão do executável coletor |

---

## 3. Script DDL para Criação no PostgreSQL

```sql
CREATE TABLE IF NOT EXISTS MetricaCodigo (
    CodMetricaCodigo INT PRIMARY KEY,
    Versao VARCHAR(50),
    DataVersao TIMESTAMP,
    NomeArquivo VARCHAR(500),
    TotalArquivos INT,
    TotalLinhasEmBranco BIGINT,
    TotalLinhasCodigo BIGINT,
    TotalLinhasComentadas BIGINT,
    TotalClasses BIGINT,
    TotalPropriedadeClasses BIGINT,
    TotalPropriedadeRecord BIGINT,
    TotalInterfaces BIGINT,
    TotalPropriedadeRecordInterface BIGINT,
    TotalRecords BIGINT,
    TotalEnumerados BIGINT,
    TotalMetodosPublicos BIGINT,
    TotalMetodosPrivados BIGINT,
    TotalMetodosProtegidos BIGINT,
    TotalMetodosEstaticos BIGINT,
    TotalMetodosImplementados BIGINT,
    ComplexidadeCiclomatica BIGINT,
    TotalFuncaoGlobal BIGINT,
    TotalVariavelGlobal BIGINT,
    TotalConstanteGlobal BIGINT,
    TempoAnaliseMS DOUBLE PRECISION,
    DataHoraInclusao TIMESTAMP,
    EstacaoTrabalhoInclusao VARCHAR(100),
    VersaoInlcusao VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS ArquivoMetricaCodigo (
    CodArquivoMetricaCodigo INT PRIMARY KEY,
    CodMetricaCodigo INT REFERENCES MetricaCodigo(CodMetricaCodigo),
    NomeArquivo VARCHAR(500),
    TotalLinhasEmBranco BIGINT,
    TotalLinhasCodigo BIGINT,
    TotalLinhasComentadas BIGINT,
    TotalClasses BIGINT,
    TotalPropriedadeClasses BIGINT,
    TotalInterfaces BIGINT,
    TotalRecords BIGINT,
    TotalEnumerados BIGINT,
    TotalMetodosPublicos BIGINT,
    TotalMetodosPrivados BIGINT,
    TotalMetodosProtegidos BIGINT,
    TotalMetodosEstaticos BIGINT,
    TotalMetodosImplementados BIGINT,
    ComplexidadeCiclomatica BIGINT,
    TotalFuncaoGlobal BIGINT,
    TotalVariavelGlobal BIGINT,
    TotalConstanteGlobal BIGINT,
    DataHoraInclusao TIMESTAMP,
    EstacaoTrabalhoInclusao VARCHAR(100),
    VersaoInlcusao VARCHAR(50)
);

-- Índices de Performance Recomendados
CREATE INDEX IF NOT EXISTS idx_metricacodigo_versao ON MetricaCodigo(Versao);
CREATE INDEX IF NOT EXISTS idx_metricacodigo_dataversao ON MetricaCodigo(DataVersao);
CREATE INDEX IF NOT EXISTS idx_arquivometricacodigo_codmetrica ON ArquivoMetricaCodigo(CodMetricaCodigo);
CREATE INDEX IF NOT EXISTS idx_arquivometricacodigo_nomearquivo ON ArquivoMetricaCodigo(NomeArquivo);
```
