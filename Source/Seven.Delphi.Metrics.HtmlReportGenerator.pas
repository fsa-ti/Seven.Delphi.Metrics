unit Seven.Delphi.Metrics.HtmlReportGenerator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.JSON;

type
  THtmlReportGenerator = class
  public
    class procedure GenerateProjectReport(const MetricsJsonFile, OutputHtmlFile: string); static;
    class procedure GenerateGitEvolutionReport(const EvolutionJsonFile, OutputHtmlFile: string); static;
  end;

implementation

class procedure THtmlReportGenerator.GenerateProjectReport(const MetricsJsonFile, OutputHtmlFile: string);
var
  JsonText, HtmlContent: string;
begin
  if not TFile.Exists(MetricsJsonFile) then
    raise Exception.CreateFmt('Arquivo JSON de métricas "%s" não encontrado', [MetricsJsonFile]);

  JsonText := TFile.ReadAllText(MetricsJsonFile, TEncoding.UTF8);

  HtmlContent :=
    '<!DOCTYPE html>' + sLineBreak +
    '<html lang="pt-BR" class="dark">' + sLineBreak +
    '<head>' + sLineBreak +
    '  <meta charset="UTF-8">' + sLineBreak +
    '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' + sLineBreak +
    '  <title>Dashboard de M&eacute;tricas de C&oacute;digo - Delphi</title>' + sLineBreak +
    '  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>' + sLineBreak +
    '  <style>' + sLineBreak +
    '    :root { --bg: #0f172a; --card: #1e293b; --text: #f8fafc; --muted: #94a3b8; --primary: #38bdf8; --accent: #818cf8; --border: #334155; }' + sLineBreak +
    '    body { margin: 0; padding: 24px; background: var(--bg); color: var(--text); font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }' + sLineBreak +
    '    .header { margin-bottom: 24px; border-bottom: 1px solid var(--border); padding-bottom: 16px; }' + sLineBreak +
    '    .header h1 { margin: 0; font-size: 1.8rem; color: var(--primary); }' + sLineBreak +
    '    .header p { margin: 4px 0 0; color: var(--muted); font-size: 0.9rem; }' + sLineBreak +
    '    .grid-kpi { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px; }' + sLineBreak +
    '    .card-kpi { background: var(--card); border: 1px solid var(--border); border-radius: 12px; padding: 16px; box-shadow: 0 4px 12px rgba(0,0,0,0.2); }' + sLineBreak +
    '    .card-kpi .label { font-size: 0.8rem; text-transform: uppercase; color: var(--muted); letter-spacing: 0.05em; }' + sLineBreak +
    '    .card-kpi .value { font-size: 1.8rem; font-weight: 700; margin-top: 6px; color: var(--primary); }' + sLineBreak +
    '    .grid-charts { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; }' + sLineBreak +
    '    @media (max-width: 900px) { .grid-charts { grid-template-columns: 1fr; } }' + sLineBreak +
    '    .card-chart { background: var(--card); border: 1px solid var(--border); border-radius: 12px; padding: 20px; }' + sLineBreak +
    '    .card-chart h3 { margin: 0 0 16px; font-size: 1.1rem; color: var(--text); }' + sLineBreak +
    '    .table-container { background: var(--card); border: 1px solid var(--border); border-radius: 12px; padding: 20px; overflow-x: auto; }' + sLineBreak +
    '    table { width: 100%; border-collapse: collapse; text-align: left; font-size: 0.9rem; }' + sLineBreak +
    '    th { border-bottom: 2px solid var(--border); padding: 10px 12px; color: var(--muted); text-transform: uppercase; font-size: 0.75rem; }' + sLineBreak +
    '    td { border-bottom: 1px solid var(--border); padding: 10px 12px; word-break: break-all; }' + sLineBreak +
    '    tr:hover { background: rgba(255,255,255,0.03); }' + sLineBreak +
    '    .badge-error { background: #ef444422; color: #f87171; padding: 2px 8px; border-radius: 4px; font-size: 0.75rem; }' + sLineBreak +
    '  </style>' + sLineBreak +
    '</head>' + sLineBreak +
    '<body>' + sLineBreak +
    '  <div class="header">' + sLineBreak +
    '    <h1>Dashboard de M&eacute;tricas Delphi</h1>' + sLineBreak +
    '    <p id="projectPath">Carregando m&eacute;tricas...</p>' + sLineBreak +
    '  </div>' + sLineBreak +
    '' + sLineBreak +
    '  <div class="grid-kpi">' + sLineBreak +
    '    <div class="card-kpi"><div class="label">Linhas de C&oacute;digo</div><div class="value" id="kpiLoc">0</div></div>' + sLineBreak +
    '    <div class="card-kpi"><div class="label">Classes Totais</div><div class="value" id="kpiClasses">0</div></div>' + sLineBreak +
    '    <div class="card-kpi"><div class="label">M&eacute;todos Implementados</div><div class="value" id="kpiMethods">0</div></div>' + sLineBreak +
    '    <div class="card-kpi"><div class="label">Complexidade (MCC)</div><div class="value" id="kpiComplexity">0</div></div>' + sLineBreak +
    '    <div class="card-kpi"><div class="label">Tempo de An&aacute;lise</div><div class="value" id="kpiTime">0 ms</div></div>' + sLineBreak +
    '  </div>' + sLineBreak +
    '' + sLineBreak +
    '  <div class="grid-charts">' + sLineBreak +
    '    <div class="card-chart"><h3>Distribui&ccedil;&atilde;o de Linhas de C&oacute;digo</h3><canvas id="chartLines"></canvas></div>' + sLineBreak +
    '    <div class="card-chart"><h3>Top 5 Units mais Complexas (MCC)</h3><canvas id="chartHotspots"></canvas></div>' + sLineBreak +
    '  </div>' + sLineBreak +
    '' + sLineBreak +
    '  <div class="table-container">' + sLineBreak +
    '    <h3>Detalhamento por Arquivo Fonte</h3>' + sLineBreak +
    '    <table>' + sLineBreak +
    '      <thead>' + sLineBreak +
    '        <tr>' + sLineBreak +
    '          <th>Arquivo</th>' + sLineBreak +
    '          <th>LOC</th>' + sLineBreak +
    '          <th>Coment&aacute;rios</th>' + sLineBreak +
    '          <th>Em Branco</th>' + sLineBreak +
    '          <th>Classes</th>' + sLineBreak +
    '          <th>M&eacute;todos</th>' + sLineBreak +
    '          <th>Complexidade (MCC)</th>' + sLineBreak +
    '          <th>Status</th>' + sLineBreak +
    '        </tr>' + sLineBreak +
    '      </thead>' + sLineBreak +
    '      <tbody id="tableBody"></tbody>' + sLineBreak +
    '    </table>' + sLineBreak +
    '  </div>' + sLineBreak +
    '' + sLineBreak +
    '  <script>' + sLineBreak +
    '    const rawData = ' + JsonText + ';' + sLineBreak +
    '    document.getElementById("projectPath").innerText = "Projeto: " + (rawData.fileName || "");' + sLineBreak +
    '    document.getElementById("kpiLoc").innerText = (rawData.totalLineCodeCount || 0).toLocaleString();' + sLineBreak +
    '    document.getElementById("kpiClasses").innerText = (rawData.totalClassCount || 0).toLocaleString();' + sLineBreak +
    '    document.getElementById("kpiMethods").innerText = (rawData.totalImplMethodCount || 0).toLocaleString();' + sLineBreak +
    '    document.getElementById("kpiComplexity").innerText = (rawData.totalCyclomaticComplexity || 0).toLocaleString();' + sLineBreak +
    '    document.getElementById("kpiTime").innerText = (rawData.totalAnalysisTimeMs || 0).toFixed(0) + " ms";' + sLineBreak +
    '' + sLineBreak +
    '    new Chart(document.getElementById("chartLines"), {' + sLineBreak +
    '      type: "doughnut",' + sLineBreak +
    '      data: {' + sLineBreak +
    '        labels: ["C&oacute;digo", "Coment&aacute;rios", "Em Branco"],' + sLineBreak +
    '        datasets: [{ data: [rawData.totalLineCodeCount || 0, rawData.totalCommentLineCount || 0, rawData.totalBlankLineCount || 0], backgroundColor: ["#38bdf8", "#34d399", "#64748b"] }]' + sLineBreak +
    '      },' + sLineBreak +
    '      options: { plugins: { legend: { labels: { color: "#f8fafc" } } } }' + sLineBreak +
    '    });' + sLineBreak +
    '' + sLineBreak +
    '    const files = rawData.files || [];' + sLineBreak +
    '    const topHotspots = [...files].sort((a,b) => (b.cyclomaticComplexity||0) - (a.cyclomaticComplexity||0)).slice(0,5);' + sLineBreak +
    '    new Chart(document.getElementById("chartHotspots"), {' + sLineBreak +
    '      type: "bar",' + sLineBreak +
    '      data: {' + sLineBreak +
    '        labels: topHotspots.map(f => (f.fileName || "").split(/[\\\\/]/).pop()),' + sLineBreak +
    '        datasets: [{ label: "MCC", data: topHotspots.map(f => f.cyclomaticComplexity || 0), backgroundColor: "#818cf8" }]' + sLineBreak +
    '      },' + sLineBreak +
    '      options: { scales: { x: { ticks: { color: "#94a3b8" } }, y: { ticks: { color: "#94a3b8" } } }, plugins: { legend: { labels: { color: "#f8fafc" } } } }' + sLineBreak +
    '    });' + sLineBreak +
    '' + sLineBreak +
    '    const tbody = document.getElementById("tableBody");' + sLineBreak +
    '    files.forEach(f => {' + sLineBreak +
    '      const tr = document.createElement("tr");' + sLineBreak +
    '      const status = f.parseError ? ''<span class="badge-error">'' + f.parseError + ''</span>'' : "OK";' + sLineBreak +
    '      tr.innerHTML = "<td>" + (f.fileName || "") + "</td>" +' + sLineBreak +
    '                     "<td>" + (f.lineCodeCount || 0) + "</td>" +' + sLineBreak +
    '                     "<td>" + (f.commentLineCount || 0) + "</td>" +' + sLineBreak +
    '                     "<td>" + (f.blankLineCount || 0) + "</td>" +' + sLineBreak +
    '                     "<td>" + (f.classCount || 0) + "</td>" +' + sLineBreak +
    '                     "<td>" + (f.implMethodCount || 0) + "</td>" +' + sLineBreak +
    '                     "<td>" + (f.cyclomaticComplexity || 0) + "</td>" +' + sLineBreak +
    '                     "<td>" + status + "</td>";' + sLineBreak +
    '      tbody.appendChild(tr);' + sLineBreak +
    '    });' + sLineBreak +
    '  </script>' + sLineBreak +
    '</body>' + sLineBreak +
    '</html>';

  TFile.WriteAllText(OutputHtmlFile, HtmlContent, TEncoding.UTF8);
end;

class procedure THtmlReportGenerator.GenerateGitEvolutionReport(const EvolutionJsonFile, OutputHtmlFile: string);
var
  JsonText, HtmlContent: string;
begin
  if not TFile.Exists(EvolutionJsonFile) then
    raise Exception.CreateFmt('Arquivo JSON de evolução Git "%s" não encontrado', [EvolutionJsonFile]);

  JsonText := TFile.ReadAllText(EvolutionJsonFile, TEncoding.UTF8);

  HtmlContent :=
    '<!DOCTYPE html>' + sLineBreak +
    '<html lang="pt-BR" class="dark">' + sLineBreak +
    '<head>' + sLineBreak +
    '  <meta charset="UTF-8">' + sLineBreak +
    '  <meta name="viewport" content="width=device-width, initial-scale=1.0">' + sLineBreak +
    '  <title>Evolu&ccedil;&atilde;o Hist&oacute;rica de M&eacute;tricas Git - Delphi</title>' + sLineBreak +
    '  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>' + sLineBreak +
    '  <style>' + sLineBreak +
    '    :root { --bg: #0f172a; --card: #1e293b; --text: #f8fafc; --muted: #94a3b8; --primary: #38bdf8; --accent: #818cf8; --border: #334155; }' + sLineBreak +
    '    body { margin: 0; padding: 24px; background: var(--bg); color: var(--text); font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }' + sLineBreak +
    '    .header { margin-bottom: 24px; border-bottom: 1px solid var(--border); padding-bottom: 16px; }' + sLineBreak +
    '    .header h1 { margin: 0; font-size: 1.8rem; color: var(--primary); }' + sLineBreak +
    '    .header p { margin: 4px 0 0; color: var(--muted); font-size: 0.9rem; }' + sLineBreak +
    '    .grid-charts { display: grid; grid-template-columns: 1fr; gap: 24px; margin-bottom: 24px; }' + sLineBreak +
    '    .card-chart { background: var(--card); border: 1px solid var(--border); border-radius: 12px; padding: 20px; }' + sLineBreak +
    '    .card-chart h3 { margin: 0 0 16px; font-size: 1.1rem; color: var(--text); }' + sLineBreak +
    '  </style>' + sLineBreak +
    '</head>' + sLineBreak +
    '<body>' + sLineBreak +
    '  <div class="header">' + sLineBreak +
    '    <h1>Evolu&ccedil;&atilde;o de M&eacute;tricas no Reposit&oacute;rio Git</h1>' + sLineBreak +
    '    <p id="repoPath">Carregando hist&oacute;rico...</p>' + sLineBreak +
    '  </div>' + sLineBreak +
    '' + sLineBreak +
    '  <div class="grid-charts">' + sLineBreak +
    '    <div class="card-chart"><h3>Evolu&ccedil;&atilde;o de Linhas de C&oacute;digo (LOC) por Revis&atilde;o</h3><canvas id="chartLocEvolution"></canvas></div>' + sLineBreak +
    '    <div class="card-chart"><h3>Evolu&ccedil;&atilde;o de Complexidade Ciclom&aacute;tica e M&eacute;todos</h3><canvas id="chartComplexityEvolution"></canvas></div>' + sLineBreak +
    '  </div>' + sLineBreak +
    '' + sLineBreak +
    '  <script>' + sLineBreak +
    '    const rawData = ' + JsonText + ';' + sLineBreak +
    '    document.getElementById("repoPath").innerText = "Reposit&oacute;rio: " + (rawData.repositoryPath || "") + " | Projeto: " + (rawData.projectFile || "");' + sLineBreak +
    '    const series = rawData.evolutionSeries || [];' + sLineBreak +
    '    const labels = series.map(s => (s.authorDate || "") + " (" + (s.revision || "").substring(0,7) + ")");' + sLineBreak +
    '' + sLineBreak +
    '    new Chart(document.getElementById("chartLocEvolution"), {' + sLineBreak +
    '      type: "line",' + sLineBreak +
    '      data: {' + sLineBreak +
    '        labels: labels,' + sLineBreak +
    '        datasets: [{ label: "Linhas de C&oacute;digo", data: series.map(s => s.totalLineCodeCount || 0), borderColor: "#38bdf8", fill: false, tension: 0.1 }]' + sLineBreak +
    '      },' + sLineBreak +
    '      options: { scales: { x: { ticks: { color: "#94a3b8" } }, y: { ticks: { color: "#94a3b8" } } }, plugins: { legend: { labels: { color: "#f8fafc" } } } }' + sLineBreak +
    '    });' + sLineBreak +
    '' + sLineBreak +
    '    new Chart(document.getElementById("chartComplexityEvolution"), {' + sLineBreak +
    '      type: "line",' + sLineBreak +
    '      data: {' + sLineBreak +
    '        labels: labels,' + sLineBreak +
    '        datasets: [' + sLineBreak +
    '          { label: "Complexidade (MCC)", data: series.map(s => s.totalCyclomaticComplexity || 0), borderColor: "#818cf8", fill: false, tension: 0.1 },' + sLineBreak +
    '          { label: "M&eacute;todos Implementados", data: series.map(s => s.totalImplMethodCount || 0), borderColor: "#34d399", fill: false, tension: 0.1 }' + sLineBreak +
    '        ]' + sLineBreak +
    '      },' + sLineBreak +
    '      options: { scales: { x: { ticks: { color: "#94a3b8" } }, y: { ticks: { color: "#94a3b8" } } }, plugins: { legend: { labels: { color: "#f8fafc" } } } }' + sLineBreak +
    '    });' + sLineBreak +
    '  </script>' + sLineBreak +
    '</body>' + sLineBreak +
    '</html>';

  TFile.WriteAllText(OutputHtmlFile, HtmlContent, TEncoding.UTF8);
end;

end.
