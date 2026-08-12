unit Breeze.Redist.Logger;

{$SCOPEDENUMS ON}

interface

uses
  Breeze.System;

type
  TBreezeLoggerLevel = (None, Erro, Warn, Info, Debug);

  IBreezeLoggerWriter = interface(IBreezeInterface)
    ['{3F4B1BD0-B4AE-4003-9E16-30792660E03C}']
    procedure Write(const Value: TBreezeWideString); overload;
  end;

  IBreezeLogger = interface(IBreezeInterface)
    ['{749F1AEE-A856-43A9-AAD7-A181E2D99C09}']
    procedure Configure(const Level: TBreezeLoggerLevel; const FolderLogs, Name: TBreezeWideString);

    procedure Debug(const Value: TBreezeWideString); overload;
    procedure Info(const Value: TBreezeWideString); overload;
    procedure Warn(const Value: TBreezeWideString); overload;
    procedure Error(const Value: TBreezeWideString); overload;

    function TraceMethod(const ClassName, MethodName: TBreezeWideString): IUnknown; overload;
  end;

  IBreezeLoggerFmt = interface(IBreezeInterface)
    ['{C58EA1AC-4D21-4DFD-BC06-D9A969FD458C}']
    procedure Configure(const Level: TBreezeLoggerLevel; const FolderLogs, Name: TBreezeWideString);

    procedure Debug(const Value: TBreezeWideString); overload;
    procedure Debug(const Value: TBreezeWideString; const Args: array of const); overload;
    procedure Debug(const Obj: TObject; const Value: TBreezeWideString); overload;
    procedure Debug(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const); overload;

    procedure Info(const Value: TBreezeWideString); overload;
    procedure Info(const Value: TBreezeWideString; const Args: array of const); overload;
    procedure Info(const Obj: TObject; const Value: TBreezeWideString); overload;
    procedure Info(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const); overload;

    procedure Warn(const Value: TBreezeWideString); overload;
    procedure Warn(const Value: TBreezeWideString; const Args: array of const); overload;
    procedure Warn(const Obj: TObject; const Value: TBreezeWideString); overload;
    procedure Warn(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const); overload;

    procedure Error(const Value: TBreezeWideString); overload;
    procedure Error(const Value: TBreezeWideString; const Args: array of const); overload;
    procedure Error(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const); overload;
    procedure Error(const Obj: TObject; const Value: TBreezeWideString); overload;

    function TraceMethod(const Obj: TObject; const MethodName: TBreezeWideString): IUnknown; overload;
  end;

{$IFDEF MSWINDOWS}
  TBreezeLoggerDll = record
  public
    class function GetLoggerInstance: IBreezeLogger; static;
  end;
{$ENDIF}

implementation

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
  System.IOUtils,
  System.SysUtils;

type
  TGetLoggerInstance = function: IBreezeLogger;

  TBreezeLoggerFmt = class(TBreezeObjectInterfaced, IBreezeLoggerFmt)
  private
    FBreezeLogger: IBreezeLogger;

    function CreateString(const Obj: TObject; Value: TBreezeWideString; const Args: array of const): TBreezeWideString; overload;
    function CreateString(const Obj: TObject; Value: TBreezeWideString): TBreezeWideString; overload;
    function CreateString(Value: TBreezeWideString; const Args: array of const): TBreezeWideString; overload;
    function CreateString(Value: TBreezeWideString): TBreezeWideString; overload;
  public
    constructor Create(const BreezeLogger: IBreezeLogger);
    procedure Configure(const Level: TBreezeLoggerLevel; const FolderLogs, Name: TBreezeWideString);

    procedure Debug(const Value: TBreezeWideString); overload;
    procedure Debug(const Value: TBreezeWideString; const Args: array of const); overload;
    procedure Debug(const Obj: TObject; const Value: TBreezeWideString); overload;
    procedure Debug(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const); overload;

    procedure Info(const Value: TBreezeWideString); overload;
    procedure Info(const Value: TBreezeWideString; const Args: array of const); overload;
    procedure Info(const Obj: TObject; const Value: TBreezeWideString); overload;
    procedure Info(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const); overload;

    procedure Warn(const Value: TBreezeWideString); overload;
    procedure Warn(const Value: TBreezeWideString; const Args: array of const); overload;
    procedure Warn(const Obj: TObject; const Value: TBreezeWideString); overload;
    procedure Warn(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const); overload;

    procedure Error(const Value: TBreezeWideString); overload;
    procedure Error(const Value: TBreezeWideString; const Args: array of const); overload;
    procedure Error(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const); overload;
    procedure Error(const Obj: TObject; const Value: TBreezeWideString); overload;

    function TraceMethod(const Obj: TObject; const MethodName: TBreezeWideString): IUnknown; overload;
  end;

{$IFDEF MSWINDOWS}
{ TBreezeLoggerDll }

class function TBreezeLoggerDll.GetLoggerInstance: IBreezeLogger;
begin
  var GetLoggerInstance: TGetLoggerInstance;

  @GetLoggerInstance := nil;
  const Path = '.\Breeze.Logger.dll';
  var Handle := GetModuleHandle(PChar(Path));

  if Handle = 0 then
    Handle := LoadLibrary(PChar(Path));

  if Handle = 0 then
    raise Exception.CreateFmt('Failed to load library %s', [Path]);

  @GetLoggerInstance := GetProcAddress(Handle, PChar('GetLoggerInstance'));

  if @GetLoggerInstance = nil then
    raise Exception.CreateFmt('Failed to find method "CreateLogger" in library %s', [Path]);

  Result := GetLoggerInstance();
end;
{$ENDIF}

{ TBreezeLoggerFmt }

procedure TBreezeLoggerFmt.Configure(const Level: TBreezeLoggerLevel; const FolderLogs, Name: TBreezeWideString);
begin
  FBreezeLogger.Configure(Level, FolderLogs, Name);
end;

constructor TBreezeLoggerFmt.Create(const BreezeLogger: IBreezeLogger);
begin
  FBreezeLogger := BreezeLogger;
end;

function TBreezeLoggerFmt.CreateString(const Obj: TObject; Value: TBreezeWideString; const Args: array of const): TBreezeWideString;
begin
  const FormatMessage = Format('%s - %s', [Obj.ClassName(), Value]);
  Result := Format(Value, Args);
end;

function TBreezeLoggerFmt.CreateString(Value: TBreezeWideString; const Args: array of const): TBreezeWideString;
begin
  Result := Format(Value, Args);
end;

function TBreezeLoggerFmt.CreateString(Value: TBreezeWideString): TBreezeWideString;
begin
  Result := Value;
end;

function TBreezeLoggerFmt.CreateString(const Obj: TObject; Value: TBreezeWideString): TBreezeWideString;
begin
  Result := Format('%s - %s', [Obj.ClassName(), Value]);
end;

procedure TBreezeLoggerFmt.Debug(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const);
begin
  FBreezeLogger.Debug(CreateString(Obj, Value, Args));
end;

procedure TBreezeLoggerFmt.Debug(const Obj: TObject; const Value: TBreezeWideString);
begin
  FBreezeLogger.Debug(CreateString(Obj, Value));
end;

procedure TBreezeLoggerFmt.Debug(const Value: TBreezeWideString; const Args: array of const);
begin
  FBreezeLogger.Debug(CreateString(Value, Args));
end;

procedure TBreezeLoggerFmt.Debug(const Value: TBreezeWideString);
begin
  FBreezeLogger.Debug(CreateString(Value));
end;

procedure TBreezeLoggerFmt.Error(const Obj: TObject; const Value: TBreezeWideString);
begin
  FBreezeLogger.Error(CreateString(Obj, Value));
end;

procedure TBreezeLoggerFmt.Error(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const);
begin
  FBreezeLogger.Error(CreateString(Obj, Value, Args));
end;

procedure TBreezeLoggerFmt.Error(const Value: TBreezeWideString);
begin
  FBreezeLogger.Error(CreateString(Value));
end;

procedure TBreezeLoggerFmt.Error(const Value: TBreezeWideString; const Args: array of const);
begin
  FBreezeLogger.Error(CreateString(Value, Args));
end;

procedure TBreezeLoggerFmt.Info(const Value: TBreezeWideString; const Args: array of const);
begin
  FBreezeLogger.Info(CreateString(Value, Args));
end;

procedure TBreezeLoggerFmt.Info(const Value: TBreezeWideString);
begin
  FBreezeLogger.Info(CreateString(Value));
end;

procedure TBreezeLoggerFmt.Info(const Obj: TObject; const Value: TBreezeWideString);
begin
  FBreezeLogger.Info(CreateString(Obj, Value));
end;

procedure TBreezeLoggerFmt.Info(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const);
begin
  FBreezeLogger.Info(CreateString(Obj, Value, Args));
end;

function TBreezeLoggerFmt.TraceMethod(const Obj: TObject; const MethodName: TBreezeWideString): IUnknown;
begin
  FBreezeLogger.TraceMethod(Obj.ClassName(), MethodName);
end;

procedure TBreezeLoggerFmt.Warn(const Value: TBreezeWideString);
begin
  FBreezeLogger.Warn(CreateString(Value));
end;

procedure TBreezeLoggerFmt.Warn(const Value: TBreezeWideString; const Args: array of const);
begin
  FBreezeLogger.Warn(CreateString(Value, Args));
end;

procedure TBreezeLoggerFmt.Warn(const Obj: TObject; const Value: TBreezeWideString);
begin
  FBreezeLogger.Warn(CreateString(Obj, Value));
end;

procedure TBreezeLoggerFmt.Warn(const Obj: TObject; const Value: TBreezeWideString; const Args: array of const);
begin
  FBreezeLogger.Warn(CreateString(Obj, Value, Args));
end;

end.
