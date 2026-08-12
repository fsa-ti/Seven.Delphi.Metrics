# Regra Inegociável de Codificação e Encoding (Delphi / RAD Studio)

## 1. Padrão de Codificação de Arquivos
- **Todos os arquivos de código-fonte (`.pas`, `.dpr`, `.inc`, `.json`, `.md`)** DEVEM ser obrigatoriamente salvos no formato **UTF-8 com BOM** (Byte Order Mark: `EF BB BF`), que é o padrão oficial do RAD Studio / Embarcadero Delphi.
- **Exceção**: Arquivos de formulários visuais (`.dfm`) usam o formato de texto ANSI/DFM do Delphi (com escapes numéricos `#225`, `#231`, etc. quando necessário) para garantir compatibilidade com o carregador interno da IDE.

## 2. Acentuação e Ortografia (Português)
- NUNCA salvar ou modificar código com acentuação corrompida, caracteres truncados ou sequências inválidas de codificação (como `Ã§Ã£o`, `An'#193'lise`, etc.).
- Todas as mensagens de interface, títulos, caixas de diálogo e comentários devem obrigatoriamente utilizar ortografia em Português correta (`Análise`, `Configuração`, `Evolução`, `Relatório`, `Seleção`, `Deduplicação`, etc.).

## 3. Checklist Obrigatório a Cada Iteração
1. Garantir que todo novo arquivo `.pas`, `.dpr`, `.json` ou `.md` possua o header UTF-8 BOM.
2. Verificar se todas as strings da interface gráfica (`TFormMainMetrics`) possuem acentuação válida e legível.
3. Compilar e executar os testes unitários (`Seven.Delphi.Metrics.Tests.exe`) validando 0 erros.
