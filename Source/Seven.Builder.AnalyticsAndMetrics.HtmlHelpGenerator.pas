unit Seven.Builder.AnalyticsAndMetrics.HtmlHelpGenerator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Winapi.Windows,
  Winapi.ShellAPI;

type
  THtmlHelpGenerator = class
  public
    class procedure OpenHelpGuide(const TargetHtmlFile: string = ''); static;
  end;

implementation

class procedure THtmlHelpGenerator.OpenHelpGuide(const TargetHtmlFile: string = '');
var
  OutputFile, HtmlContent: string;
begin
  if TargetHtmlFile <> '' then
    OutputFile := TargetHtmlFile
  else
    OutputFile := TPath.Combine(ExtractFilePath(ParamStr(0)), 'GuiaAjudaMetricas.html');

  HtmlContent :=
    '<!DOCTYPE html>' + sLineBreak +
    '<html lang="pt-BR" class="dark">' + sLineBreak +
    '<head>' + sLineBreak +
    '  <meta charset="UTF-8">' + sLineBreak +
    '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' + sLineBreak +
    '  <title>Guia Oficial de M&eacute;tricas &amp; Ajuda - Seven Builder Metrics</title>' + sLineBreak +
    '  <style>' + sLineBreak +
    '    :root {' + sLineBreak +
    '      --bg: #0f172a;' + sLineBreak +
    '      --card: #1e293b;' + sLineBreak +
    '      --text: #f8fafc;' + sLineBreak +
    '      --muted: #94a3b8;' + sLineBreak +
    '      --primary: #38bdf8;' + sLineBreak +
    '      --accent: #818cf8;' + sLineBreak +
    '      --success: #34d399;' + sLineBreak +
    '      --warning: #fbbf24;' + sLineBreak +
    '      --danger: #f87171;' + sLineBreak +
    '      --border: #334155;' + sLineBreak +
    '      --code-bg: #090d16;' + sLineBreak +
    '    }' + sLineBreak +
    '    * { box-sizing: border-box; }' + sLineBreak +
    '    body {' + sLineBreak +
    '      margin: 0;' + sLineBreak +
    '      padding: 0;' + sLineBreak +
    '      background: var(--bg);' + sLineBreak +
    '      color: var(--text);' + sLineBreak +
    '      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;' + sLineBreak +
    '      line-height: 1.6;' + sLineBreak +
    '    }' + sLineBreak +
    '    .container { max-width: 1100px; margin: 0 auto; padding: 40px 24px; }' + sLineBreak +
    '    .hero {' + sLineBreak +
    '      text-align: center;' + sLineBreak +
    '      padding: 40px 20px;' + sLineBreak +
    '      background: linear-gradient(135deg, rgba(56,189,248,0.1) 0%, rgba(129,140,248,0.1) 100%);' + sLineBreak +
    '      border: 1px solid var(--border);' + sLineBreak +
    '      border-radius: 16px;' + sLineBreak +
    '      margin-bottom: 40px;' + sLineBreak +
    '    }' + sLineBreak +
    '    .hero h1 { margin: 0; font-size: 2.4rem; color: var(--primary); letter-spacing: -0.02em; }' + sLineBreak +
    '    .hero p { margin: 12px 0 0; color: var(--muted); font-size: 1.1rem; max-width: 700px; margin-left: auto; margin-right: auto; }' + sLineBreak +
    '    .badge { display: inline-block; padding: 4px 12px; background: rgba(56,189,248,0.15); color: var(--primary); border-radius: 9999px; font-size: 0.8rem; font-weight: 600; margin-bottom: 12px; text-transform: uppercase; letter-spacing: 0.05em; }' + sLineBreak +
    '    .section { margin-bottom: 40px; }' + sLineBreak +
    '    .section-title { font-size: 1.6rem; color: var(--text); margin-bottom: 20px; border-bottom: 2px solid var(--border); padding-bottom: 8px; display: flex; align-items: center; gap: 10px; }' + sLineBreak +
    '    .grid-cards { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 24px; }' + sLineBreak +
    '    .card {' + sLineBreak +
    '      background: var(--card);' + sLineBreak +
    '      border: 1px solid var(--border);' + sLineBreak +
    '      border-radius: 14px;' + sLineBreak +
    '      padding: 24px;' + sLineBreak +
    '      transition: transform 0.2s, border-color 0.2s;' + sLineBreak +
    '    }' + sLineBreak +
    '    .card:hover { transform: translateY(-2px); border-color: var(--primary); }' + sLineBreak +
    '    .card h3 { margin-top: 0; color: var(--primary); font-size: 1.2rem; display: flex; align-items: center; justify-content: space-between; }' + sLineBreak +
    '    .card p { color: var(--muted); font-size: 0.95rem; margin-bottom: 16px; }' + sLineBreak +
    '    .step-number { display: inline-flex; align-items: center; justify-content: center; width: 28px; height: 28px; background: var(--primary); color: #000; border-radius: 50%; font-weight: bold; font-size: 0.9rem; }' + sLineBreak +
    '    .mcc-scale { margin-top: 16px; background: rgba(0,0,0,0.3); border-radius: 8px; padding: 12px; font-size: 0.85rem; }' + sLineBreak +
    '    .mcc-item { display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid rgba(255,255,255,0.05); }' + sLineBreak +
    '    .mcc-item:last-child { border-bottom: none; }' + sLineBreak +
    '    .tag-success { color: var(--success); font-weight: bold; }' + sLineBreak +
    '    .tag-warning { color: var(--warning); font-weight: bold; }' + sLineBreak +
    '    .tag-danger { color: var(--danger); font-weight: bold; }' + sLineBreak +
    '    pre, code {' + sLineBreak +
    '      background: var(--code-bg);' + sLineBreak +
    '      color: #e2e8f0;' + sLineBreak +
    '      font-family: "Fira Code", Consolas, Monaco, "Courier New", monospace;' + sLineBreak +
    '      border-radius: 8px;' + sLineBreak +
    '      font-size: 0.85rem;' + sLineBreak +
    '    }' + sLineBreak +
    '    pre { padding: 16px; overflow-x: auto; border: 1px solid var(--border); }' + sLineBreak +
    '    .footer { text-align: center; margin-top: 60px; padding-top: 20px; border-top: 1px solid var(--border); color: var(--muted); font-size: 0.9rem; }' + sLineBreak +
    '  </style>' + sLineBreak +
    '</head>' + sLineBreak +
    '<body>' + sLineBreak +
    '  <div class="container">' + sLineBreak +
    '    <div class="hero">' + sLineBreak +
    '      <span class="badge">Documenta&ccedil;&atilde;o &amp; Guia do Usu&aacute;rio v1.0</span>' + sLineBreak +
    '      <h1>Seven Builder Metrics for Delphi</h1>' + sLineBreak +
    '      <p>Manual completo de utiliza&ccedil;&atilde;o, m&eacute;tricas de qualidade de c&oacute;digo, complexidade ciclom&aacute;tica (MCC) e integra&ccedil;&atilde;o cont&iacute;nua.</p>' + sLineBreak +
    '    </div>' + sLineBreak +
    '' + sLineBreak +
    '    <!-- SEÇÃO 1: COMO USAR A FERRAMENTA -->' + sLineBreak +
    '    <div class="section">' + sLineBreak +
    '      <div class="section-title">🚀 1. Como Usar a Ferramenta</div>' + sLineBreak +
    '      <div class="grid-cards">' + sLineBreak +
    '        <div class="card">' + sLineBreak +
    '          <h3><span><span class="step-number">1</span> Sele&ccedil;&atilde;o do Alvo</span></h3>' + sLineBreak +
    '          <p>Escolha o tipo de escopo que deseja analisar:</p>' + sLineBreak +
    '          <ul>' + sLineBreak +
    '            <li><b>Projeto (.dproj):</b> Analisa todas as units registradas no projeto Delphi.</li>' + sLineBreak +
    '            <li><b>Grupo (.groupproj):</b> Varia e analisa em lote todos os projetos do grupo.</li>' + sLineBreak +
    '            <li><b>Pasta:</b> Varre recursivamente todos os arquivos <code>.pas</code> e <code>.dpr</code> do diret&oacute;rio.</li>' + sLineBreak +
    '          </ul>' + sLineBreak +
    '        </div>' + sLineBreak +
    '        <div class="card">' + sLineBreak +
    '          <h3><span><span class="step-number">2</span> Op&ccedil;&otilde;es de Relat&oacute;rio</span></h3>' + sLineBreak +
    '          <p>Configure as sa&iacute;das desejadas:</p>' + sLineBreak +
    '          <ul>' + sLineBreak +
    '            <li><b>Exportar JSON:</b> Gera arquivo estruturado para integra&ccedil;&atilde;o CI/CD.</li>' + sLineBreak +
    '            <li><b>Dashboard HTML:</b> Gera um painel interativo com gr&aacute;ficos e tabela.</li>' + sLineBreak +
    '            <li><b>Evolu&ccedil;&atilde;o Git:</b> Analisa os &uacute;ltimos <i>N</i> commits para mapear o hist&oacute;rico.</li>' + sLineBreak +
    '            <li><b>Banco PostgreSQL:</b> Grava as m&eacute;tricas na base de dados configurada.</li>' + sLineBreak +
    '          </ul>' + sLineBreak +
    '        </div>' + sLineBreak +
    '        <div class="card">' + sLineBreak +
    '          <h3><span><span class="step-number">3</span> Execu&ccedil;&atilde;o em 1-Clique ou CLI</span></h3>' + sLineBreak +
    '          <p>Clique no bot&atilde;o <b>EXECUTAR AN&Aacute;LISE EST&Aacute;TICA DE C&Oacute;DIGO</b> na interface visual, ou execute via terminal:</p>' + sLineBreak +
    '          <pre>Seven.Builder.Metrics.exe -project "C:\\MeuProjeto.dproj" -html "C:\\Relatorio.html" -db</pre>' + sLineBreak +
    '        </div>' + sLineBreak +
    '      </div>' + sLineBreak +
    '    </div>' + sLineBreak +
    '' + sLineBreak +
    '    <!-- SEÇÃO 2: DICIONÁRIO DE MÉTRICAS DE CÓDIGO -->' + sLineBreak +
    '    <div class="section">' + sLineBreak +
    '      <div class="section-title">📊 2. Dicion&aacute;rio de M&eacute;tricas de C&oacute;digo</div>' + sLineBreak +
    '      <div class="grid-cards">' + sLineBreak +
    '        <div class="card">' + sLineBreak +
    '          <h3>LOC - Lines of Code</h3>' + sLineBreak +
    '          <p>Contagem de linhas efetivas de c&oacute;digo-fonte (excluindo linhas em branco e coment&aacute;rios). Mede o tamanho e volume do projeto.</p>' + sLineBreak +
    '        </div>' + sLineBreak +
    '        <div class="card">' + sLineBreak +
    '          <h3>Complexidade Ciclom&aacute;tica (MCC)</h3>' + sLineBreak +
    '          <p>M&eacute;trica de McCabe que calcula o n&uacute;mero de caminhos independentes de fluxo de controle no c&oacute;digo (decis&otilde;es e ramifica&ccedil;&otilde;es).</p>' + sLineBreak +
    '          <div class="mcc-scale">' + sLineBreak +
    '            <div class="mcc-item"><span>MCC 1 a 10</span><span class="tag-success">Baixo Risco (Excelente)</span></div>' + sLineBreak +
    '            <div class="mcc-item"><span>MCC 11 a 20</span><span class="tag-warning">Risco Moderado</span></div>' + sLineBreak +
    '            <div class="mcc-item"><span>MCC &gt; 20</span><span class="tag-danger">Alto Risco (Hotspot!)</span></div>' + sLineBreak +
    '          </div>' + sLineBreak +
    '        </div>' + sLineBreak +
    '        <div class="card">' + sLineBreak +
    '          <h3>Classes, Interface &amp; Records</h3>' + sLineBreak +
    '          <p>Contagem de estruturas de dados declaradas nas se&ccedil;&otilde;es <code>interface</code> das unidades Delphi.</p>' + sLineBreak +
    '        </div>' + sLineBreak +
    '        <div class="card">' + sLineBreak +
    '          <h3>M&eacute;todos Implementados (Body)</h3>' + sLineBreak +
    '          <p>Mede a quantidade de procedimentos e fun&ccedil;&otilde;es efetivamente codificados na se&ccedil;&atilde;o <code>implementation</code>.</p>' + sLineBreak +
    '        </div>' + sLineBreak +
    '      </div>' + sLineBreak +
    '    </div>' + sLineBreak +
    '' + sLineBreak +
    '    <!-- SEÇÃO 3: EXEMPLO PRÁTICO DE CÁLCULO DE COMPLEXIDADE (MCC) -->' + sLineBreak +
    '    <div class="section">' + sLineBreak +
    '      <div class="section-title">💡 3. Exemplo Pr&aacute;tico de C&aacute;lculo de Complexidade (MCC)</div>' + sLineBreak +
    '      <p>A complexidade ciclom&aacute;tica incrementa a cada instru&ccedil;&atilde;o de ramifica&ccedil;&atilde;o (<code>if</code>, <code>case</code>, <code>while</code>, <code>for</code>, <code>repeat</code>, <code>except</code>, <code>and</code>, <code>or</code>):</p>' + sLineBreak +
    '      <pre>' + sLineBreak +
    '// Exemplo Delphi com MCC = 5 (1 Base + 4 Decis&otilde;es)' + sLineBreak +
    'function ValidarCliente(const ACliente: TCliente): Boolean;' + sLineBreak +
    'begin' + sLineBreak +
    '  Result := False;' + sLineBreak +
    '  if (ACliente &lt;&gt; nil) and (ACliente.Ativo) then   // +1 (if), +1 (and)' + sLineBreak +
    '  begin' + sLineBreak +
    '    case ACliente.Tipo of                       // +1 (case)' + sLineBreak +
    '      tcFisica:   Result := ACliente.CPF &lt;&gt; '''';' + sLineBreak +
    '      tcJuridica: Result := ACliente.CNPJ &lt;&gt; '''';' + sLineBreak +
    '    end;' + sLineBreak +
    '  end' + sLineBreak +
    '  else if ACliente = nil then                   // +1 (else if)' + sLineBreak +
    '    raise Exception.Create(''Cliente inv&aacute;lido'');' + sLineBreak +
    'end;' + sLineBreak +
    '      </pre>' + sLineBreak +
    '    </div>' + sLineBreak +
    '' + sLineBreak +
    '    <!-- SEÇÃO 4: INTEGRAÇÃO E BANCO DE DADOS -->' + sLineBreak +
    '    <div class="section">' + sLineBreak +
    '      <div class="section-title">🗄️ 4. Estrutura do Banco de Dados PostgreSQL</div>' + sLineBreak +
    '      <p>As m&eacute;tricas cadastradas no banco s&atilde;o armazenadas nas duas tabelas principais:</p>' + sLineBreak +
    '      <ul>' + sLineBreak +
    '        <li><code>MetricaCodigo</code>: Registro por projeto/vers&atilde;o (Cont&eacute;m totais de LOC, Classes, M&eacute;todos, MCC global).</li>' + sLineBreak +
    '        <li><code>ArquivoMetricaCodigo</code>: Detalhamento por arquivo fonte <code>.pas</code> vinculado &agrave; tabela pai.</li>' + sLineBreak +
    '      </ul>' + sLineBreak +
    '    </div>' + sLineBreak +
    '' + sLineBreak +
    '    <div class="footer">' + sLineBreak +
    '      Seven Builder Metrics for Delphi &copy; 2026 - Todos os direitos reservados.' + sLineBreak +
    '    </div>' + sLineBreak +
    '  </div>' + sLineBreak +
    '</body>' + sLineBreak +
    '</html>';

  TFile.WriteAllText(OutputFile, HtmlContent, TEncoding.UTF8);

  // Abrir automaticamente no navegador padrao
  ShellExecute(0, 'open', PChar(OutputFile), nil, nil, SW_SHOWNORMAL);
end;

end.
