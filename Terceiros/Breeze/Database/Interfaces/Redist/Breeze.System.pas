unit Breeze.System;

interface

uses
  Breeze.Obj,
  Breeze.Types,
  System.Types,
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  Breeze.Messages.Users,
  System.Generics.Collections;

type
  TBreezeString = Breeze.Obj.TBreezeString;
  TBreezeNativeString = string;
  TBreezeCriticalSection = System.SyncObjs.TCriticalSection;
  TBreezeWideString = Breeze.Types.TBreezeWideString;
  TBreezePString = Breeze.Types.TBreezePString;
  TBreezeDouble = Breeze.Types.TBreezeDouble;
  TBreezeBoolean = Breeze.Types.TBreezeBoolean;
  TBreezeInteger = Breeze.Types.TBreezeInteger;
  TBreezeVariant = Variant;
  TBreezeByte = Byte;
  TBreezeBytes = TBytes;
  TBreezeHandle = THandle;
  TBreezeObject = Breeze.Obj.TBreezeObject;
  TBreezeObjectInterfaced = Breeze.Obj.TBreezeObjectInterfaced;
  TFreeOnExit = Breeze.Obj.TFreeOnExit;
  TUserMessages = System.Generics.Collections.TDictionary<TBreezeWideString, TBreezeWideString>;
  TLanguageUserMessages = System.Generics.Collections.TObjectDictionary<TBreezeWideString, TUserMessages>;
  TBreezeEncondig = System.SysUtils.TEncoding;
  TBreezeDWord = System.Types.DWORD;
  TBreezeDictionary<K,V> = class(System.Generics.Collections.TDictionary<K,V>);
  TBreezeStringList = class(System.Classes.TStringList);
  TBreezeProc = TProc;
  TBreezeInt64 = Int64;
  TBreezeDate = TDate;
  TBreezeDateTime = TDateTime;
  TBreezeTime = TTime;

  IUserMessage = Breeze.Messages.Users.IUserMessage;
  IBreezeString = Breeze.Obj.IBreezeString;
  IBreezeInterface = Breeze.Types.IBreezeInterface;

implementation

end.
