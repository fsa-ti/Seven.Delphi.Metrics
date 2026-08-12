unit Seven.Delphi.Metrics.ProjectParser;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  Xml.XMLDoc,
  Xml.XMLIntf,
  Xml.XMLDom,
  Winapi.ActiveX;

type
  TProjectParser = class
  private
    class function ParseDproj(const ADprojFile: string): TArray<string>; static;
    class function ParseGroupProj(const AGroupProjFile: string): TArray<string>; static;
    class procedure ExtractNodesInclude(const XMLDoc: IXMLDocument; const XPath: string; const BaseDir: string; const OutputList: THashSet<string>); static;
  public
    class function ExtractProjectFiles(const AProjectPath: string): TArray<string>; static;
    class function ExtractDprojFromGroupproj(const AGroupProjFile: string): TArray<string>; static;
  end;

implementation

uses
  Winapi.msxml;

function LoadFileTextSafely(const AFileName: string): string;
var
  Bytes: TBytes;
  Encoding: TEncoding;
begin
  if not TFile.Exists(AFileName) then
    Exit('');

  Bytes := TFile.ReadAllBytes(AFileName);
  if Length(Bytes) = 0 then
    Exit('');

  Encoding := nil;
  TEncoding.GetBufferEncoding(Bytes, Encoding, TEncoding.UTF8);
  if Encoding = nil then
    Encoding := TEncoding.UTF8;

  try
    Result := Encoding.GetString(Bytes);
  except
    try
      Result := TEncoding.ANSI.GetString(Bytes);
    except
      Result := TEncoding.Default.GetString(Bytes);
    end;
  end;

  if (Length(Result) > 0) and (Result[1] = #$FEFF) then
    Delete(Result, 1, 1);
end;

procedure LoadXMLSafely(const XMLDoc: IXMLDocument; const AFileName: string);
var
  DOM2: IXMLDOMDocument2;
  Content: string;
begin
  Content := LoadFileTextSafely(AFileName);
  XMLDoc.Active := True;
  if Supports(XMLDoc.DOMDocument, IXMLDOMDocument2, DOM2) then
  begin
    try
      DOM2.setProperty('MaxElementDepth', 0);
    except
    end;
  end;
  if Content <> '' then
    XMLDoc.LoadFromXML(Content);
end;

class function TProjectParser.ExtractProjectFiles(const AProjectPath: string): TArray<string>;
begin
  if not TFile.Exists(AProjectPath) then
    raise Exception.CreateFmt('Arquivo de projeto "%s" não existe', [AProjectPath]);

  const Ext = TPath.GetExtension(AProjectPath).ToLower();

  if Ext = '.groupproj' then
    Result := ParseGroupProj(AProjectPath)
  else if (Ext = '.dproj') or (Ext = '.dpr') or (Ext = '.dpk') then
    Result := ParseDproj(AProjectPath)
  else
    raise Exception.CreateFmt('Extensão não suportada para o arquivo de projeto "%s"', [AProjectPath]);
end;

class procedure TProjectParser.ExtractNodesInclude(const XMLDoc: IXMLDocument; const XPath: string; const BaseDir: string; const OutputList: THashSet<string>);
var
  NodeSelect: IDOMNodeSelect;
begin
  if not Assigned(XMLDoc) or not Assigned(XMLDoc.DocumentElement) or not Assigned(XMLDoc.DOMDocument) then
    Exit;

  if Supports(XMLDoc.DOMDocument, IDOMNodeSelect, NodeSelect) then
  begin
    const Nodes = NodeSelect.selectNodes(XPath);
    if not Assigned(Nodes) then
      Exit;

    for var I := 0 to Nodes.length - 1 do
    begin
      const Node = Nodes.Item[I];
      const AttrInclude = Node.Attributes.GetNamedItem('Include');
      if Assigned(AttrInclude) then
      begin
        var RelPath := AttrInclude.NodeValue;
        if Trim(RelPath) <> '' then
        begin
          // Expand variables like $(PROJECTDIR) if present
          RelPath := StringReplace(RelPath, '$(PROJECTDIR)', BaseDir, [rfIgnoreCase, rfReplaceAll]);
          var FullPath := TPath.Combine(BaseDir, RelPath);
          try
            FullPath := TPath.GetFullPath(FullPath);
          except
            // Keep combined path if GetFullPath fails
          end;
          OutputList.Add(FullPath);
        end;
      end;
    end;
  end;
end;

class function TProjectParser.ParseDproj(const ADprojFile: string): TArray<string>;
var
  FileList: THashSet<string>;
  XMLDoc: IXMLDocument;
  ComInitNeeded: Boolean;
begin
  ComInitNeeded := Succeeded(CoInitialize(nil));
  FileList := THashSet<string>.Create;
  try
    const Ext = TPath.GetExtension(ADprojFile).ToLower();

    // If it's directly a .pas, .dpr or .dpk file, add itself if valid
    if (Ext = '.pas') or (Ext = '.dpr') or (Ext = '.dpk') then
    begin
      FileList.Add(TPath.GetFullPath(ADprojFile));
    end;

    if Ext = '.dproj' then
    begin
      const ProjectDir = TPath.GetDirectoryName(ADprojFile);
      XMLDoc := TXMLDocument.Create(nil);
      XMLDoc.Options := [];
      XMLDoc.ParseOptions := [poPreserveWhiteSpace];
      LoadXMLSafely(XMLDoc, ADprojFile);

      ExtractNodesInclude(XMLDoc, '//*[local-name()="DCCReference"]', ProjectDir, FileList);
      ExtractNodesInclude(XMLDoc, '//*[local-name()="Compile"]', ProjectDir, FileList);
      ExtractNodesInclude(XMLDoc, '//*[local-name()="MainSource"]', ProjectDir, FileList);
    end;

    // Filter valid files
    var Filtered: TList<string> := TList<string>.Create();
    try
      for var FilePath in FileList do
      begin
        const FileExt = TPath.GetExtension(FilePath).ToLower();
        if (FileExt = '.pas') or (FileExt = '.dpr') or (FileExt = '.dpk') or (FileExt = '.inc') then
        begin
          if TFile.Exists(FilePath) then
            Filtered.Add(FilePath);
        end;
      end;
      Result := Filtered.ToArray();
    finally
      Filtered.Free();
    end;
  finally
    FileList.Free();
    if ComInitNeeded then
      CoUninitialize();
  end;
end;

class function TProjectParser.ParseGroupProj(const AGroupProjFile: string): TArray<string>;
var
  GroupDir: string;
  DprojSet: THashSet<string>;
  ResultSet: THashSet<string>;
  XMLDoc: IXMLDocument;
  ComInitNeeded: Boolean;
begin
  ComInitNeeded := Succeeded(CoInitialize(nil));
  GroupDir := TPath.GetDirectoryName(AGroupProjFile);
  DprojSet := THashSet<string>.Create;
  ResultSet := THashSet<string>.Create;
  try
    XMLDoc := TXMLDocument.Create(nil);
    XMLDoc.Options := [];
    XMLDoc.ParseOptions := [poPreserveWhiteSpace];
    LoadXMLSafely(XMLDoc, AGroupProjFile);

    // Extract project references in groupproj
    ExtractNodesInclude(XMLDoc, '//*[local-name()="Projects"]/*[local-name()="Project"]', GroupDir, DprojSet);
    ExtractNodesInclude(XMLDoc, '//*[local-name()="Projects"]', GroupDir, DprojSet);
    ExtractNodesInclude(XMLDoc, '//*[local-name()="Project"]', GroupDir, DprojSet);

    for var DprojPath in DprojSet do
    begin
      const SubExt = TPath.GetExtension(DprojPath).ToLower();
      if (SubExt = '.dproj') and TFile.Exists(DprojPath) then
      begin
        const SubFiles = ParseDproj(DprojPath);
        for var FilePath in SubFiles do
          ResultSet.Add(FilePath);
      end;
    end;

    Result := ResultSet.ToArray();
  finally
    DprojSet.Free();
    ResultSet.Free();
    if ComInitNeeded then
      CoUninitialize();
  end;
end;

class function TProjectParser.ExtractDprojFromGroupproj(const AGroupProjFile: string): TArray<string>;
var
  GroupDir: string;
  DprojSet: THashSet<string>;
  XMLDoc: IXMLDocument;
  ComInitNeeded: Boolean;
  FilteredList: TList<string>;
begin
  if not TFile.Exists(AGroupProjFile) then
    Exit(nil);

  ComInitNeeded := Succeeded(CoInitialize(nil));
  GroupDir := TPath.GetDirectoryName(AGroupProjFile);
  DprojSet := THashSet<string>.Create;
  try
    XMLDoc := TXMLDocument.Create(nil);
    XMLDoc.Options := [];
    XMLDoc.ParseOptions := [poPreserveWhiteSpace];
    LoadXMLSafely(XMLDoc, AGroupProjFile);

    ExtractNodesInclude(XMLDoc, '//*[local-name()="Projects"]/*[local-name()="Project"]', GroupDir, DprojSet);
    ExtractNodesInclude(XMLDoc, '//*[local-name()="Projects"]', GroupDir, DprojSet);
    ExtractNodesInclude(XMLDoc, '//*[local-name()="Project"]', GroupDir, DprojSet);

    FilteredList := TList<string>.Create;
    try
      for var DprojPath in DprojSet do
      begin
        const SubExt = TPath.GetExtension(DprojPath).ToLower();
        if (SubExt = '.dproj') and TFile.Exists(DprojPath) then
          FilteredList.Add(DprojPath);
      end;
      Result := FilteredList.ToArray();
    finally
      FilteredList.Free();
    end;
  finally
    DprojSet.Free();
    if ComInitNeeded then
      CoUninitialize();
  end;
end;

end.
