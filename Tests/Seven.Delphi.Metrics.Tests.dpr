program Seven.Delphi.Metrics.Tests;

{$APPTYPE CONSOLE}

{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  Winapi.ActiveX,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  Seven.Delphi.Metrics.GitAnalyzer in '..\Source\Seven.Delphi.Metrics.GitAnalyzer.pas',
  Seven.Delphi.Metrics.ProjectParser in '..\Source\Seven.Delphi.Metrics.ProjectParser.pas',
  Seven.Delphi.Metrics.CodeAnalyzer in '..\Source\Seven.Delphi.Metrics.CodeAnalyzer.pas',
  Seven.Delphi.Metrics.Engine in '..\Source\Seven.Delphi.Metrics.Engine.pas',
  Seven.Delphi.Metrics.SaveService in '..\Source\Seven.Delphi.Metrics.SaveService.pas',
  Seven.Delphi.Metrics.PresetService in '..\Source\Seven.Delphi.Metrics.PresetService.pas',
  Test.CodeAnalyzer in 'Test.CodeAnalyzer.pas';

var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
begin
  CoInitialize(nil);
  try
    // Create the test runner
    runner := TDUnitX.CreateRunner;

    // Tell the runner to use RTTI to find Fixtures
    logger := TDUnitXConsoleLogger.Create(True);
    runner.AddLogger(logger);

    // Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := 1;
  finally
    CoUninitialize;
  end;
end.
