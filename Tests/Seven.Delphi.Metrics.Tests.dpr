program Seven.Builder.Metrics.Tests;

{$APPTYPE CONSOLE}

{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  Winapi.ActiveX,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  Seven.Builder.AnalyticsAndMetrics.GitAnalyzer in '..\Source\Seven.Builder.AnalyticsAndMetrics.GitAnalyzer.pas',
  Seven.Builder.AnalyticsAndMetrics.ProjectParser in '..\Source\Seven.Builder.AnalyticsAndMetrics.ProjectParser.pas',
  Seven.Builder.AnalyticsAndMetrics.CodeAnalyzer in '..\Source\Seven.Builder.AnalyticsAndMetrics.CodeAnalyzer.pas',
  Seven.Builder.AnalyticsAndMetrics in '..\Source\Seven.Builder.AnalyticsAndMetrics.pas',
  Seven.Builder.AnalyticsAndMetrics.SaveService in '..\Source\Seven.Builder.AnalyticsAndMetrics.SaveService.pas',
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
    CoUninitialize();
  end;
end.
