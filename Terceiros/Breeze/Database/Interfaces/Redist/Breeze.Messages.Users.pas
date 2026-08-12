unit Breeze.Messages.Users;

interface

uses
  Breeze.Types;

type
  IUserMessage = interface(IBreezeInterface)
    ['{109E622A-8F67-4E9E-B9BA-F56A634442AC}']
    function AddMessage(const Language, Name, MessageUser: TBreezeWideString): IUserMessage;
    function Get(const Name: TBreezeWideString): TBreezeWideString; overload;
    function Get(const Name: TBreezeWideString; const Args: array of const): TBreezeWideString; overload;

    procedure SetCurrentLanguage(const Value: TBreezeWideString);
    function GetCurrentLanguage: TBreezeWideString;
    property CurrentCurrent: TBreezeWideString read GetCurrentLanguage write SetCurrentLanguage;
  end;

implementation

end.
