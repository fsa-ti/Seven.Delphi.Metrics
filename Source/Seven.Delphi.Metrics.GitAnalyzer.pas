unit Seven.Delphi.Metrics.GitAnalyzer;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.JSON,
  System.Generics.Collections,
  Seven.Delphi.Metrics.CodeAnalyzer,
  Seven.Delphi.Metrics.SaveService;

type
  TGitRevisionInfo = record
    Revision: string;
    AuthorDate: string;
    Subject: string;
    IsTag: Boolean;
  end;

  TGitEvolutionMetric = record
    Revision: string;
    AuthorDate: string;
    Subject: string;
    IsTag: Boolean;
    TotalFiles: Int64;
    TotalLineCodeCount: Int64;
    TotalCommentLineCount: Int64;
    TotalBlankLineCount: Int64;
    TotalClassCount: Int64;
    TotalInterfaceCount: Int64;
    TotalRecordCount: Int64;
    TotalEnumCount: Int64;
    TotalPublicMethodCount: Int64;
    TotalImplMethodCount: Int64;
    TotalCyclomaticComplexity: Int64;
    AnalysisTimeMs: Double;
  end;

  TGitAnalyzer = class
  private
    class function RunGitCommand(const AWorkingDir, Args: string; out Output: string): Boolean; static;
  public
    class function GetCurrentHead(const ARepoPath: string): string; static;
    class function GetGitTags(const ARepoPath: string): TArray<TGitRevisionInfo>; static;
    class function GetGitCommits(const ARepoPath: string; MaxCount: Integer = 20): TArray<TGitRevisionInfo>; static;
    class procedure AnalyzeGitEvolution(const ARepoPath, AProjectRelPath, AOutputJsonFile: string; const ATagsOnly: Boolean = False; MaxCommits: Integer = 20); static;
  end;

implementation

uses
  Winapi.Windows,
  Seven.Delphi.Metrics.Engine;

class function TGitAnalyzer.RunGitCommand(const AWorkingDir, Args: string; out Output: string): Boolean;
var
  SaAttr: TSecurityAttributes;
  hRead, hWrite: THandle;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CommandLine: string;
  Buffer: array[0..4095] of Byte;
  BytesRead: DWORD;
  Stream: TMemoryStream;
begin
  Result := False;
  Output := '';

  SaAttr.nLength := SizeOf(TSecurityAttributes);
  SaAttr.bInheritHandle := True;
  SaAttr.lpSecurityDescriptor := nil;

  if not CreatePipe(hRead, hWrite, @SaAttr, 0) then
    Exit;

  SetHandleInformation(hRead, HANDLE_FLAG_INHERIT, 0);

  FillChar(StartInfo, SizeOf(TStartupInfo), 0);
  StartInfo.cb := SizeOf(TStartupInfo);
  StartInfo.hStdOutput := hWrite;
  StartInfo.hStdError := hWrite;
  StartInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  StartInfo.wShowWindow := SW_HIDE;

  CommandLine := 'git.exe ' + Args;
  UniqueString(CommandLine);

  if CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil, PChar(AWorkingDir), StartInfo, ProcInfo) then
  begin
    CloseHandle(hWrite);

    Stream := TMemoryStream.Create;
    try
      repeat
        if ReadFile(hRead, Buffer, SizeOf(Buffer), BytesRead, nil) and (BytesRead > 0) then
          Stream.Write(Buffer, BytesRead)
        else
          Break;
      until False;

      CloseHandle(ProcInfo.hProcess);
      CloseHandle(ProcInfo.hThread);
      CloseHandle(hRead);

      Stream.Position := 0;
      if Stream.Size > 0 then
      begin
        var StringList := TStringList.Create;
        try
          StringList.LoadFromStream(Stream, TEncoding.UTF8);
          Output := StringList.Text;
        finally
          StringList.Free;
        end;
      end;

      Result := True;
    finally
      Stream.Free;
    end;
  end
  else
  begin
    CloseHandle(hRead);
    CloseHandle(hWrite);
  end;
end;

class function TGitAnalyzer.GetCurrentHead(const ARepoPath: string): string;
var
  OutText: string;
begin
  if RunGitCommand(ARepoPath, 'rev-parse --abbrev-ref HEAD', OutText) then
  begin
    Result := Trim(OutText);
    if (Result = '') or (Result = 'HEAD') then
    begin
      RunGitCommand(ARepoPath, 'rev-parse HEAD', OutText);
      Result := Trim(OutText);
    end;
  end
  else
    Result := 'master';
end;

class function TGitAnalyzer.GetGitTags(const ARepoPath: string): TArray<TGitRevisionInfo>;
var
  OutText: string;
  Lines: TArray<string>;
  List: TList<TGitRevisionInfo>;
begin
  List := TList<TGitRevisionInfo>.Create;
  try
    if RunGitCommand(ARepoPath, 'tag --list --format="%(refname:short)|%(creatordate:short)|%(subject)"', OutText) then
    begin
      Lines := OutText.Split([#13#10, #10]);
      for var Line in Lines do
      begin
        if Trim(Line) = '' then Continue;
        var Parts := Line.Split(['|']);
        if Length(Parts) >= 2 then
        begin
          var Info: TGitRevisionInfo;
          Info.Revision := Parts[0];
          Info.AuthorDate := Parts[1];
          if Length(Parts) >= 3 then Info.Subject := Parts[2] else Info.Subject := '';
          Info.IsTag := True;
          List.Add(Info);
        end;
      end;
    end;
    Result := List.ToArray();
  finally
    List.Free;
  end;
end;

class function TGitAnalyzer.GetGitCommits(const ARepoPath: string; MaxCount: Integer): TArray<TGitRevisionInfo>;
var
  OutText: string;
  Lines: TArray<string>;
  List: TList<TGitRevisionInfo>;
begin
  List := TList<TGitRevisionInfo>.Create;
  try
    const Cmd = Format('log -n %d --format="%%H|%%ad|%%s" --date=short', [MaxCount]);
    if RunGitCommand(ARepoPath, Cmd, OutText) then
    begin
      Lines := OutText.Split([#13#10, #10]);
      for var Line in Lines do
      begin
        if Trim(Line) = '' then Continue;
        var Parts := Line.Split(['|']);
        if Length(Parts) >= 2 then
        begin
          var Info: TGitRevisionInfo;
          Info.Revision := Parts[0];
          Info.AuthorDate := Parts[1];
          if Length(Parts) >= 3 then Info.Subject := Parts[2] else Info.Subject := '';
          Info.IsTag := False;
          List.Add(Info);
        end;
      end;
    end;
    Result := List.ToArray();
  finally
    List.Free;
  end;
end;

class procedure TGitAnalyzer.AnalyzeGitEvolution(const ARepoPath, AProjectRelPath, AOutputJsonFile: string; const ATagsOnly: Boolean; MaxCommits: Integer);
var
  OriginalRef: string;
  Revisions: TArray<TGitRevisionInfo>;
  EvolutionList: TList<TGitEvolutionMetric>;
  OutText: string;
  FullProjectPath: string;
  TempJsonFile: string;
  DidStash: Boolean;
begin
  OriginalRef := GetCurrentHead(ARepoPath);
  EvolutionList := TList<TGitEvolutionMetric>.Create;
  TempJsonFile := TPath.Combine(TPath.GetTempPath, 'GitEvolutionTemp_' + TGuid.NewGuid.ToString + '.json');

  DidStash := RunGitCommand(ARepoPath, 'stash --include-untracked', OutText) and not OutText.Contains('No local changes to save');
  try
    if ATagsOnly then
      Revisions := GetGitTags(ARepoPath)
    else
      Revisions := GetGitCommits(ARepoPath, MaxCommits);

    if Length(Revisions) = 0 then
    begin
      SetLength(Revisions, 1);
      Revisions[0].Revision := OriginalRef;
      Revisions[0].AuthorDate := FormatDateTime('yyyy-mm-dd', Now);
      Revisions[0].Subject := 'Current Working Tree';
      Revisions[0].IsTag := False;
    end;

    for var RevInfo in Revisions do
    begin
      if RevInfo.Revision <> OriginalRef then
        RunGitCommand(ARepoPath, Format('checkout -f %s', [RevInfo.Revision]), OutText);

      FullProjectPath := TPath.Combine(ARepoPath, AProjectRelPath);
      if not TFile.Exists(FullProjectPath) then
      begin
        var FoundDprojs := TDirectory.GetFiles(ARepoPath, '*.dproj', TSearchOption.soTopDirectoryOnly);
        if Length(FoundDprojs) = 0 then
          FoundDprojs := TDirectory.GetFiles(ARepoPath, '*.dproj', TSearchOption.soAllDirectories);
        if Length(FoundDprojs) > 0 then
          FullProjectPath := FoundDprojs[0];
      end;

      if TFile.Exists(FullProjectPath) then
      begin
        const SaveService = TSaveServiceFileFactory.CreateFileJson(TempJsonFile);
        try
          TSevenAnalyticsAndMetrics.ExecuteProjectAnalysis(SaveService, FullProjectPath);

          if TFile.Exists(TempJsonFile) then
          begin
            const JsonText = TFile.ReadAllText(TempJsonFile, TEncoding.UTF8);
            const JsonObj = TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
            if Assigned(JsonObj) then
            begin
              try
                var Metric: TGitEvolutionMetric;
                Metric.Revision := RevInfo.Revision;
                Metric.AuthorDate := RevInfo.AuthorDate;
                Metric.Subject := RevInfo.Subject;
                Metric.IsTag := RevInfo.IsTag;

                const FilesArray = JsonObj.GetValue('files') as TJSONArray;
                if Assigned(FilesArray) then Metric.TotalFiles := FilesArray.Count else Metric.TotalFiles := 0;

                var V: TJSONValue;
                V := JsonObj.GetValue('totalLineCodeCount');
                if Assigned(V) then Metric.TotalLineCodeCount := StrToInt64Def(V.Value, 0) else Metric.TotalLineCodeCount := 0;

                V := JsonObj.GetValue('totalCommentLineCount');
                if Assigned(V) then Metric.TotalCommentLineCount := StrToInt64Def(V.Value, 0) else Metric.TotalCommentLineCount := 0;

                V := JsonObj.GetValue('totalBlankLineCount');
                if Assigned(V) then Metric.TotalBlankLineCount := StrToInt64Def(V.Value, 0) else Metric.TotalBlankLineCount := 0;

                V := JsonObj.GetValue('totalClassCount');
                if Assigned(V) then Metric.TotalClassCount := StrToInt64Def(V.Value, 0) else Metric.TotalClassCount := 0;

                V := JsonObj.GetValue('totalInterfaceCount');
                if Assigned(V) then Metric.TotalInterfaceCount := StrToInt64Def(V.Value, 0) else Metric.TotalInterfaceCount := 0;

                V := JsonObj.GetValue('totalRecordCount');
                if Assigned(V) then Metric.TotalRecordCount := StrToInt64Def(V.Value, 0) else Metric.TotalRecordCount := 0;

                V := JsonObj.GetValue('totalEnumCount');
                if Assigned(V) then Metric.TotalEnumCount := StrToInt64Def(V.Value, 0) else Metric.TotalEnumCount := 0;

                V := JsonObj.GetValue('totalPublicMethodCount');
                if Assigned(V) then Metric.TotalPublicMethodCount := StrToInt64Def(V.Value, 0) else Metric.TotalPublicMethodCount := 0;

                V := JsonObj.GetValue('totalImplMethodCount');
                if Assigned(V) then Metric.TotalImplMethodCount := StrToInt64Def(V.Value, 0) else Metric.TotalImplMethodCount := 0;

                V := JsonObj.GetValue('totalCyclomaticComplexity');
                if Assigned(V) then Metric.TotalCyclomaticComplexity := StrToInt64Def(V.Value, 0) else Metric.TotalCyclomaticComplexity := 0;

                V := JsonObj.GetValue('totalAnalysisTimeMs');
                if Assigned(V) then Metric.AnalysisTimeMs := StrToFloatDef(V.Value, 0.0) else Metric.AnalysisTimeMs := 0.0;

                EvolutionList.Add(Metric);
              finally
                JsonObj.Free;
              end;
            end;
          end;
        except
          // Skip commits where parsing failed or file missing
        end;
      end;
    end;
  finally
    RunGitCommand(ARepoPath, Format('checkout -f %s', [OriginalRef]), OutText);
    if DidStash then
      RunGitCommand(ARepoPath, 'stash pop', OutText);

    // Save final evolution JSON
    const RootJson = TJSONObject.Create();
    RootJson.AddPair('repositoryPath', ARepoPath);
    RootJson.AddPair('projectFile', AProjectRelPath);

    const SeriesArray = TJSONArray.Create();
    for var Metric in EvolutionList do
    begin
      const Item = TJSONObject.Create();
      Item.AddPair('revision', Metric.Revision)
          .AddPair('authorDate', Metric.AuthorDate)
          .AddPair('subject', Metric.Subject)
          .AddPair('isTag', Metric.IsTag)
          .AddPair('totalFiles', TJSONNumber.Create(Metric.TotalFiles))
          .AddPair('totalLineCodeCount', TJSONNumber.Create(Metric.TotalLineCodeCount))
          .AddPair('totalCommentLineCount', TJSONNumber.Create(Metric.TotalCommentLineCount))
          .AddPair('totalBlankLineCount', TJSONNumber.Create(Metric.TotalBlankLineCount))
          .AddPair('totalClassCount', TJSONNumber.Create(Metric.TotalClassCount))
          .AddPair('totalInterfaceCount', TJSONNumber.Create(Metric.TotalInterfaceCount))
          .AddPair('totalRecordCount', TJSONNumber.Create(Metric.TotalRecordCount))
          .AddPair('totalEnumCount', TJSONNumber.Create(Metric.TotalEnumCount))
          .AddPair('totalPublicMethodCount', TJSONNumber.Create(Metric.TotalPublicMethodCount))
          .AddPair('totalImplMethodCount', TJSONNumber.Create(Metric.TotalImplMethodCount))
          .AddPair('totalCyclomaticComplexity', TJSONNumber.Create(Metric.TotalCyclomaticComplexity))
          .AddPair('analysisTimeMs', TJSONNumber.Create(Metric.AnalysisTimeMs));
      SeriesArray.AddElement(Item);
    end;

    RootJson.AddPair('evolutionSeries', SeriesArray);

    TFile.WriteAllText(AOutputJsonFile, RootJson.Format(2), TEncoding.UTF8);
    RootJson.Free;
    EvolutionList.Free;
    if TFile.Exists(TempJsonFile) then
      TFile.Delete(TempJsonFile);
  end;
end;

end.
