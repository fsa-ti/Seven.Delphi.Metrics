unit Seven.Delphi.Metrics.PresetService;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.JSON,
  System.Generics.Collections;

type
  TPresetProjectItem = record
    Path: string;
    Enabled: Boolean;
  end;

  TPresetData = record
    PresetName: string;
    TargetPath: string;
    Projects: TArray<TPresetProjectItem>;
  end;

  TPresetService = class
  public
    class procedure SavePresetToFile(const AFileName: string; const APreset: TPresetData); static;
    class function LoadPresetFromFile(const AFileName: string; out APreset: TPresetData): Boolean; static;
  end;

implementation

{ TPresetService }

class procedure TPresetService.SavePresetToFile(const AFileName: string; const APreset: TPresetData);
var
  RootObj, ItemObj: TJSONObject;
  ProjectsArr: TJSONArray;
begin
  RootObj := TJSONObject.Create();
  try
    RootObj.AddPair('presetName', APreset.PresetName);
    RootObj.AddPair('targetPath', APreset.TargetPath);

    ProjectsArr := TJSONArray.Create();
    for var Item in APreset.Projects do
    begin
      ItemObj := TJSONObject.Create();
      ItemObj.AddPair('path', Item.Path);
      ItemObj.AddPair('enabled', TJSONBool.Create(Item.Enabled));
      ProjectsArr.AddElement(ItemObj);
    end;
    RootObj.AddPair('projects', ProjectsArr);

    const DirectoryPath = TPath.GetDirectoryName(AFileName);
    if (DirectoryPath <> '') and not TDirectory.Exists(DirectoryPath) then
      TDirectory.CreateDirectory(DirectoryPath);

    TFile.WriteAllText(AFileName, RootObj.Format(2), TEncoding.UTF8);
  finally
    RootObj.Free();
  end;
end;

class function TPresetService.LoadPresetFromFile(const AFileName: string; out APreset: TPresetData): Boolean;
var
  RootObj: TJSONObject;
  ProjectsArr: TJSONArray;
  ItemObj: TJSONObject;
  Item: TPresetProjectItem;
begin
  Result := False;
  APreset := Default(TPresetData);

  if not TFile.Exists(AFileName) then
    Exit();

  try
    const JsonText = TFile.ReadAllText(AFileName, TEncoding.UTF8);
    RootObj := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
    if not Assigned(RootObj) then
      Exit();

    try
      APreset.PresetName := RootObj.GetValue<string>('presetName', '');
      APreset.TargetPath := RootObj.GetValue<string>('targetPath', '');

      ProjectsArr := RootObj.GetValue<TJSONArray>('projects');
      if Assigned(ProjectsArr) then
      begin
        SetLength(APreset.Projects, ProjectsArr.Count);
        for var Index := 0 to ProjectsArr.Count - 1 do
        begin
          ItemObj := ProjectsArr.Items[Index] as TJSONObject;
          if Assigned(ItemObj) then
          begin
            Item.Path := ItemObj.GetValue<string>('path', '');
            Item.Enabled := ItemObj.GetValue<Boolean>('enabled', True);
            APreset.Projects[Index] := Item;
          end;
        end;
      end;
      Result := True;
    finally
      RootObj.Free();
    end;
  except
    Result := False;
  end;
end;

end.
