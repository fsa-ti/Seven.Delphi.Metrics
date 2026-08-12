unit Seven.Builder.AnalyticsAndMetrics.HistoryService;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  System.JSON;

type
  TRecentTargetItem = record
    TargetPath: string;
    TargetType: Integer; // 0=Project, 1=GroupProject, 2=Directory
    ExportJson: Boolean;
    GenerateHtml: Boolean;
    EnableGit: Boolean;
    EnableDb: Boolean;
    LastAnalyzed: string;
  end;

  THistoryService = class
  private
    class function GetHistoryFilePath: string; static;
  public
    class function LoadHistory: TArray<TRecentTargetItem>; static;
    class procedure AddToHistory(const TargetPath: string; TargetType: Integer;
      ExportJson, GenerateHtml, EnableGit, EnableDb: Boolean); static;
    class procedure ClearHistory; static;
  end;

implementation

class function THistoryService.GetHistoryFilePath: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'recent_history.json');
end;

class function THistoryService.LoadHistory: TArray<TRecentTargetItem>;
var
  FilePath, JsonText: string;
  JsonArr: TJSONArray;
  JsonObj: TJSONObject;
  Val: TJSONValue;
  I: Integer;
  Items: TList<TRecentTargetItem>;
  Item: TRecentTargetItem;
begin
  Items := TList<TRecentTargetItem>.Create;
  try
    FilePath := GetHistoryFilePath();
    if FileExists(FilePath) then
    begin
      try
        JsonText := TFile.ReadAllText(FilePath, TEncoding.UTF8);
        Val := TJSONObject.ParseJSONValue(JsonText);
        if (Val <> nil) and (Val is TJSONArray) then
        begin
          JsonArr := TJSONArray(Val);
          for I := 0 to JsonArr.Count - 1 do
          begin
            if JsonArr.Items[I] is TJSONObject then
            begin
              JsonObj := TJSONObject(JsonArr.Items[I]);
              Item.TargetPath := JsonObj.GetValue<string>('targetPath', '');
              Item.TargetType := JsonObj.GetValue<Integer>('targetType', 0);
              Item.ExportJson := JsonObj.GetValue<Boolean>('exportJson', True);
              Item.GenerateHtml := JsonObj.GetValue<Boolean>('generateHtml', True);
              Item.EnableGit := JsonObj.GetValue<Boolean>('enableGit', False);
              Item.EnableDb := JsonObj.GetValue<Boolean>('enableDb', False);
              Item.LastAnalyzed := JsonObj.GetValue<string>('lastAnalyzed', '');
              if (Item.TargetPath <> '') and FileExists(FilePath) then
                Items.Add(Item);
            end;
          end;
        end;
        Val.Free;
      except
        // Em caso de falha de parsing, mantem lista vazia
      end;
    end;
    Result := Items.ToArray;
  finally
    Items.Free;
  end;
end;

class procedure THistoryService.AddToHistory(const TargetPath: string; TargetType: Integer;
  ExportJson, GenerateHtml, EnableGit, EnableDb: Boolean);
var
  History: TArray<TRecentTargetItem>;
  List: TList<TRecentTargetItem>;
  Item: TRecentTargetItem;
  I: Integer;
  CleanPath, FilePath: string;
  JsonArr: TJSONArray;
  JsonObj: TJSONObject;
begin
  CleanPath := Trim(TargetPath);
  if CleanPath = '' then
    Exit;

  List := TList<TRecentTargetItem>.Create;
  try
    History := LoadHistory();
    for I := 0 to Length(History) - 1 do
    begin
      if not SameText(History[I].TargetPath, CleanPath) then
        List.Add(History[I]);
    end;

    Item.TargetPath := CleanPath;
    Item.TargetType := TargetType;
    Item.ExportJson := ExportJson;
    Item.GenerateHtml := GenerateHtml;
    Item.EnableGit := EnableGit;
    Item.EnableDb := EnableDb;
    Item.LastAnalyzed := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);

    List.Insert(0, Item);

    // Limita aos ultimos 15 itens historicos
    while List.Count > 15 do
      List.Delete(List.Count - 1);

    JsonArr := TJSONArray.Create;
    try
      for I := 0 to List.Count - 1 do
      begin
        JsonObj := TJSONObject.Create;
        JsonObj.AddPair('targetPath', List[I].TargetPath);
        JsonObj.AddPair('targetType', TJSONNumber.Create(List[I].TargetType));
        JsonObj.AddPair('exportJson', TJSONBool.Create(List[I].ExportJson));
        JsonObj.AddPair('generateHtml', TJSONBool.Create(List[I].GenerateHtml));
        JsonObj.AddPair('enableGit', TJSONBool.Create(List[I].EnableGit));
        JsonObj.AddPair('enableDb', TJSONBool.Create(List[I].EnableDb));
        JsonObj.AddPair('lastAnalyzed', List[I].LastAnalyzed);
        JsonArr.AddElement(JsonObj);
      end;

      FilePath := GetHistoryFilePath();
      TFile.WriteAllText(FilePath, JsonArr.Format(2), TEncoding.UTF8);
    finally
      JsonArr.Free;
    end;
  finally
    List.Free;
  end;
end;

class procedure THistoryService.ClearHistory;
var
  FilePath: string;
begin
  FilePath := GetHistoryFilePath();
  if FileExists(FilePath) then
    TFile.Delete(FilePath);
end;

end.
