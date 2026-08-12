# Directivas e Regras Inegociáveis do Projeto (Seven Delphi Metrics)

## Codificação e Encoding (UTF-8 com BOM)
1. **Padrão de Arquivos**: Todos os arquivos gerados ou editados no projeto (`.pas`, `.dpr`, `.inc`, `.json`, `.md`), **com exceção única dos arquivos `.dfm`**, DEVEM ser salvos estritamente em **UTF-8 com BOM** (`EF BB BF`), que é o padrão adotado pelo Embarcadero RAD Studio / Delphi.
2. **Arquivos Form DFM**: Arquivos `.dfm` mantêm o padrão ANSI/DFM do RAD Studio.
3. **Revisão de Ortografia e Acentuação**: Em todas as alterações, verificar minuciosamente a integridade de acentos (`á`, `é`, `í`, `ó`, `ú`, `ã`, `õ`, `ç`, `Á`, `É`, `Í`, `Ó`, `Ú`, `Ã`, `Õ`, `Ç`) garantindo ausência total de mojibake ou caracteres corrompidos.
