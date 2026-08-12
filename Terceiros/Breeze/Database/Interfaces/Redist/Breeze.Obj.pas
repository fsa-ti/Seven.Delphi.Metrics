unit Breeze.Obj;

interface

uses
  Breeze.Types;

type
  TBreezeObject = class
  public
    class procedure SafeFreeAndNil(Obj: TObject); static;
  end;

  TBreezeObjectInterfaced = class(TInterfacedObject)
  end;

  TFreeOnExit = class(TBreezeObjectInterfaced, IUnknown)
  private
    FObj: TObject;
  public
    constructor Create(Obj: TObject);
    destructor Destroy; override;

    class function Add(Obj: TObject): IUnknown;
  end;

  IBreezeString = interface(IBreezeInterface)
    ['{BA4E6BCA-C36C-458D-ACA1-6F7CC88D96B8}']
    function GetValue: PWideChar;
    property Value: PWideChar read GetValue;
  end;

  TBreezeString = class
  public
    class function Create(const Value: TBreezeWideString): IBreezeString; static;
  end;

implementation

uses
  System.SysUtils;

type
  TBreezeStringImpl = class(TBreezeObjectInterfaced, IBreezeString)
  private
    FValue: WideString;
    function GetValue: PWideChar;
  public
    constructor Create(const Value: WideString);
    destructor Destroy; override;
  end;

{ TFreeOnExit }

constructor TFreeOnExit.Create(Obj: TObject);
begin
  FObj := Obj;
end;

destructor TFreeOnExit.Destroy;
begin
  if Assigned(FObj) then
    FreeAndNil(FObj);

  inherited;
end;

class function TFreeOnExit.Add(Obj: TObject): IUnknown;
begin
  Result := TFreeOnExit.Create(Obj);
end;

{ TBreezeObject }

class procedure TBreezeObject.SafeFreeAndNil(Obj: TObject);
begin
  if Assigned(Obj) then
    FreeAndNil(Obj);
end;

{ TBreezeStringImpl }

constructor TBreezeStringImpl.Create(const Value: WideString);
begin
  FValue := StrNew(PWideChar(Value));
end;

destructor TBreezeStringImpl.Destroy;
begin
  inherited;
end;

function TBreezeStringImpl.GetValue: PWideChar;
begin
  Result := PWideChar(FValue);
end;

{ TBreezeString }

class function TBreezeString.Create(const Value: TBreezeWideString): IBreezeString;
begin
  Result := TBreezeStringImpl.Create(Value);
end;

end.
