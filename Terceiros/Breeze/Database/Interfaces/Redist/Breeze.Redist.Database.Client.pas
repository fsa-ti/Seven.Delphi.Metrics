unit Breeze.Redist.Database.Client;

{$SCOPEDENUMS ON}

interface

uses
  Breeze.System,
  Breeze.Redist.Logger;

type
  TBreezeProviderDatabase = (SQLServer, SybaseAnywhere, Postgres);

  IBreezeDatabaseConfig = interface(IBreezeInterface)
    ['{097C0F90-C268-47CE-A8CC-0A925134C617}']
    procedure SetProvider(const Value: TBreezeProviderDatabase);
    function GetProvider: TBreezeProviderDatabase;
    property Provider: TBreezeProviderDatabase read GetProvider write SetProvider;

    procedure SetDatabase(const Value: TBreezeWideString);
    function GetDatabase: TBreezeWideString;
    property Database: TBreezeWideString read GetDatabase write SetDatabase;

    procedure SetServer(const Value: TBreezeWideString);
    function GetServer: TBreezeWideString;
    property Server: TBreezeWideString read GetServer write SetServer;

    procedure SetPort(const Value: TBreezeInteger);
    function GetPort: TBreezeInteger;
    property Port: TBreezeInteger read GetPort write SetPort;

    procedure SetUser(const Value: TBreezeWideString);
    function GetUser: TBreezeWideString;
    property User: TBreezeWideString read GetUser write SetUser;

    procedure SetPassword(const Value: TBreezeWideString);
    function GetPassword: TBreezeWideString;
    property Password: TBreezeWideString read GetPassword write SetPassword;

    procedure SetDescription(const Value: TBreezeWideString);
    function GetDescription: TBreezeWideString;
    property Description: TBreezeWideString read GetDescription write SetDescription;
  end;

  IBreezeDataReader = interface(IBreezeInterface)
    ['{5873BA20-53B4-47FD-8878-C6293EFF7B83}']
    function GetInteger(const FieldName: TBreezeWideString): TBreezeInteger;
    function GetInt64(const FieldName: TBreezeWideString): TBreezeInt64;
    function GetDouble(const FieldName: TBreezeWideString): TBreezeDouble;
    function GetBoolean(const FieldName: TBreezeWideString): TBreezeBoolean;
    function GetString(const FieldName: TBreezeWideString): TBreezeWideString;
    function GetDate(const FieldName: TBreezeWideString): TBreezeDate;
    function GetTime(const FieldName: TBreezeWideString): TBreezeTime;
    function GetDateTime(const FieldName: TBreezeWideString): TBreezeDateTime;

    function Next: TBreezeBoolean;
  end;

  IBreezeStatement = interface(IBreezeInterface)
    ['{CEBD4820-D128-4D68-9373-F57997FAF554}']
    function Execute: IBreezeStatement;
    function ExecuteUpdate: TBreezeBoolean;
    function ExecuteReader: IBreezeDataReader;

    function SetValue(const Name, Value: TBreezeWideString): IBreezeStatement; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeDouble): IBreezeStatement; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeInteger): IBreezeStatement; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeBoolean): IBreezeStatement; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeDate): IBreezeStatement; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeTime): IBreezeStatement; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeDateTime): IBreezeStatement; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeInt64): IBreezeStatement; overload;

    function SetOpt(const Name, Value: TBreezeWideString): IBreezeStatement; overload;
    function SetOpt(const Name: TBreezeWideString; const Value: TBreezeDouble): IBreezeStatement; overload;
    function SetOpt(const Name: TBreezeWideString; const Value: TBreezeInteger): IBreezeStatement; overload;

    procedure SetText(const Value: TBreezeWideString);
    function GetText: TBreezeWideString;
    property Text: TBreezeWideString read GetText write SetText;
  end;

  IBreezeDatabaseInsert = interface(IBreezeInterface)
    ['{BE25E94B-499A-4855-87CF-DF6EE023A5BC}']

    procedure SetTableName(const Value: TBreezeWideString);
    function GetTableName: TBreezeWideString;
    property TableName: TBreezeWideString read GetTableName write SetTableName;

    function SetValue(const Name, Value: TBreezeWideString): IBreezeDatabaseInsert; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeDouble): IBreezeDatabaseInsert; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeInteger): IBreezeDatabaseInsert; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeBoolean): IBreezeDatabaseInsert; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeDate): IBreezeDatabaseInsert; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeTime): IBreezeDatabaseInsert; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeDateTime): IBreezeDatabaseInsert; overload;
    function SetValue(const Name: TBreezeWideString; const Value: TBreezeInt64): IBreezeDatabaseInsert; overload;
    function GetCommandText: TBreezeWideString;

    procedure Execute;
  end;

  IBreezeDatabaseConnection = interface(IBreezeInterface)
    ['{D1D4B93D-B26C-4285-A333-8BC3148F745A}']
    function GetConfig: IBreezeDatabaseConfig;
    property Config: IBreezeDatabaseConfig read GetConfig;

    function Open: TBreezeBoolean;
    function Close: TBreezeBoolean;
    function StartTransaction: IUnknown;
    procedure RollBack;
    procedure Commit;

    function CreateStatement(const Description: TBreezeWideString): IBreezeStatement;
    function CreateInsert(const Description: TBreezeWideString): IBreezeDatabaseInsert;
    procedure ConfigureLogger(const Level: TBreezeLoggerLevel; const FolderLogs, Name: TBreezeWideString);
    procedure ExecuteInTransaction(const Proc: TBreezeProc);
    function MaxTable(const TableName, Field: TBreezeWideString): TBreezeInt64;
  end;

{$IFDEF MSWINDOWS}
  TBreezeDatabaseDll = record
  public
    class function CreateConnection: IBreezeDatabaseConnection; static;
  end;
{$ENDIF}

implementation

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}

  System.SysUtils;

type
  TCreateConnection = function: IBreezeDatabaseConnection;

{$IFDEF MSWINDOWS}

{ TBreezeDatabaseDll }

class function TBreezeDatabaseDll.CreateConnection: IBreezeDatabaseConnection;
begin
  var ExecCreateConnection: TCreateConnection;

  @ExecCreateConnection := nil;
  const Path = '.\Breeze.Database.Client.dll';
  var Handle := GetModuleHandle(PChar(Path));

  if Handle = 0 then
    Handle := LoadLibrary(PChar(Path));

  if Handle = 0 then
    raise Exception.CreateFmt('Failed to load library %s', [Path]);

  @ExecCreateConnection := GetProcAddress(Handle, PChar('CreateConnection'));

  if @ExecCreateConnection = nil then
    raise Exception.CreateFmt('Failed to find method "CreateConnection" in library %s', [Path]);

  Result := ExecCreateConnection();
end;
{$ENDIF}

end.
