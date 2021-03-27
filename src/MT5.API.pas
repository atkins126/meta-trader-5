unit MT5.Api;

interface

uses
  System.SysUtils, System.Generics.Collections,
  MT5.Connect, MT5.RetCode, MT5.Auth, MT5.Order,
  MT5.Position, MT5.History, MT5.Deal;

type

  TMTApi = class
  private
    { private declarations }
    FMTConnect: TMTConnect;
    FAgent: string;
    FIsCrypt: Boolean;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(const AAgent: string = 'WebAPI'; AIsCrypt: Boolean = True);
    destructor Destroy; override;
    function Connect(AIp: string; APort: Word; ATimeout: Integer; ALogin: string; APassword: string): TMTRetCodeType;
    procedure Disconnect;
    // ORDER
    function OrderGet(ATicket: string; out AOrder: TMTOrder): TMTRetCodeType;
    function OrderGetPage(ALogin, AOffset, ATotal: Integer; out AOrdersCollection: TArray<TMTOrder>): TMTRetCodeType;
    function OrderGetTotal(ALogin: Integer; out ATotal: Integer): TMTRetCodeType;
    // POSITION
    function PositionGet(ALogin: Integer; ASymbol: string; out APosition: TMTPosition): TMTRetCodeType;
    function PositionGetPage(ALogin, AOffset, ATotal: Integer; out APositionsCollection: TArray<TMTPosition>): TMTRetCodeType;
    function PositionGetTotal(ALogin: Integer; out ATotal: Integer): TMTRetCodeType;
    // HISTORY
    function HistoryGet(ATicket: string; out AHistory: TMTOrder): TMTRetCodeType;
    function HistoryGetPage(ALogin, AFrom, ATo, AOffset, ATotal: Integer; out AHistorysCollection: TArray<TMTOrder>): TMTRetCodeType;
    function HistoryGetTotal(ALogin, AFrom, ATo: Integer; out ATotal: Integer): TMTRetCodeType;
    // DEAL
    function DealGet(ATicket: string; out ADeal: TMTDeal): TMTRetCodeType;
    function DealGetPage(ALogin, AFrom, ATo, AOffset, ATotal: Integer; out ADealsCollection: TArray<TMTDeal>): TMTRetCodeType;
    function DealGetTotal(ALogin, AFrom, ATo: Integer; out ATotal: Integer): TMTRetCodeType;
  end;

implementation

{ TMTApi }

function TMTApi.Connect(AIp: string; APort: Word; ATimeout: Integer; ALogin, APassword: string): TMTRetCodeType;
var
  LConnectionCode: TMTRetCodeType;
  LAuthCode: TMTRetCodeType;
  LAuthProtocol: TMTAuthProtocol;
  LCryptRand: string;
begin
  Result := TMTRetCodeType.MT_RET_ERROR;

  FMTConnect := TMTConnect.Create(AIp, APort, ATimeout);

  LConnectionCode := FMTConnect.Connect;
  if LConnectionCode <> TMTRetCodeType.MT_RET_OK then
    Exit(LConnectionCode);

  LAuthProtocol := TMTAuthProtocol.Create(FMTConnect, FAgent);
  try
    LCryptRand := '';
    LAuthCode := LAuthProtocol.Auth(ALogin, APassword, FIsCrypt, LCryptRand);
    if LAuthCode <> TMTRetCodeType.MT_RET_OK then
    begin
      FMTConnect.Disconnect;
      Exit(LAuthCode);
    end;
    if FIsCrypt then
      FMTConnect.SetCryptRand(LCryptRand, APassword);
    Result :=  LAuthCode;
  finally
    LAuthProtocol.Free;
  end;
end;

constructor TMTApi.Create(const AAgent: string; AIsCrypt: Boolean);
begin
  FMTConnect := nil;
  FAgent := AAgent;
  FIsCrypt := FIsCrypt;
end;

function TMTApi.DealGet(ATicket: string; out ADeal: TMTDeal): TMTRetCodeType;
var
  LDealProtocol: TMTDealProtocol;
begin
  LDealProtocol := TMTDealProtocol.Create(FMTConnect);
  try
    Result := LDealProtocol.DealGet(ATicket, ADeal);
  finally
    LDealProtocol.Free;
  end;
end;

function TMTApi.DealGetPage(ALogin, AFrom, ATo, AOffset, ATotal: Integer; out ADealsCollection: TArray<TMTDeal>): TMTRetCodeType;
var
  LDealProtocol: TMTDealProtocol;
begin
  LDealProtocol := TMTDealProtocol.Create(FMTConnect);
  try
    Result := LDealProtocol.DealGetPage(ALogin, AFrom, ATo, AOffset, ATotal, ADealsCollection);
  finally
    LDealProtocol.Free;
  end;
end;

function TMTApi.DealGetTotal(ALogin, AFrom, ATo: Integer; out ATotal: Integer): TMTRetCodeType;
var
  LDealProtocol: TMTDealProtocol;
begin
  LDealProtocol := TMTDealProtocol.Create(FMTConnect);
  try
    Result := LDealProtocol.DealGetTotal(ALogin, AFrom, ATo, ATotal);
  finally
    LDealProtocol.Free;
  end;
end;

destructor TMTApi.Destroy;
begin
  if FMTConnect <> nil then
    FMTConnect.Free;
  inherited;
end;

procedure TMTApi.Disconnect;
begin
  if FMTConnect <> nil then
    FMTConnect.Disconnect;
end;

function TMTApi.HistoryGet(ATicket: string; out AHistory: TMTOrder): TMTRetCodeType;
var
  LHistoryProtocol: TMTHistoryProtocol;
begin
  LHistoryProtocol := TMTHistoryProtocol.Create(FMTConnect);
  try
    Result := LHistoryProtocol.HistoryGet(ATicket, AHistory);
  finally
    LHistoryProtocol.Free;
  end;
end;

function TMTApi.HistoryGetPage(ALogin, AFrom, ATo, AOffset, ATotal: Integer; out AHistorysCollection: TArray<TMTOrder>): TMTRetCodeType;
var
  LHistoryProtocol: TMTHistoryProtocol;
begin
  LHistoryProtocol := TMTHistoryProtocol.Create(FMTConnect);
  try
    Result := LHistoryProtocol.HistoryGetPage(ALogin, AFrom, ATo, AOffset, ATotal, AHistorysCollection);
  finally
    LHistoryProtocol.Free;
  end;
end;

function TMTApi.HistoryGetTotal(ALogin, AFrom, ATo: Integer; out ATotal: Integer): TMTRetCodeType;
var
  LHistoryProtocol: TMTHistoryProtocol;
begin
  LHistoryProtocol := TMTHistoryProtocol.Create(FMTConnect);
  try
    Result := LHistoryProtocol.HistoryGetTotal(ALogin, AFrom, ATo, ATotal);
  finally
    LHistoryProtocol.Free;
  end;
end;

function TMTApi.OrderGet(ATicket: string; out AOrder: TMTOrder): TMTRetCodeType;
var
  LOrderProtocol: TMTOrderProtocol;
begin
  LOrderProtocol := TMTOrderProtocol.Create(FMTConnect);
  try
    Result := LOrderProtocol.OrderGet(ATicket, AOrder);
  finally
    LOrderProtocol.Free;
  end;
end;

function TMTApi.OrderGetPage(ALogin, AOffset, ATotal: Integer; out AOrdersCollection: TArray<TMTOrder>): TMTRetCodeType;
var
  LOrderProtocol: TMTOrderProtocol;
begin
  LOrderProtocol := TMTOrderProtocol.Create(FMTConnect);
  try
    Result := LOrderProtocol.OrderGetPage(ALogin, AOffset, ATotal, AOrdersCollection);
  finally
    LOrderProtocol.Free;
  end;
end;

function TMTApi.OrderGetTotal(ALogin: Integer; out ATotal: Integer): TMTRetCodeType;
var
  LOrderProtocol: TMTOrderProtocol;
begin
  LOrderProtocol := TMTOrderProtocol.Create(FMTConnect);
  try
    Result := LOrderProtocol.OrderGetTotal(ALogin, ATotal);
  finally
    LOrderProtocol.Free;
  end;
end;

function TMTApi.PositionGet(ALogin: Integer; ASymbol: string; out APosition: TMTPosition): TMTRetCodeType;
var
  LPositionProtocol: TMTPositionProtocol;
begin
  LPositionProtocol := TMTPositionProtocol.Create(FMTConnect);
  try
    Result := LPositionProtocol.PositionGet(ALogin, ASymbol, APosition);
  finally
    LPositionProtocol.Free;
  end;
end;

function TMTApi.PositionGetPage(ALogin, AOffset, ATotal: Integer; out APositionsCollection: TArray<TMTPosition>): TMTRetCodeType;
var
  LPositionProtocol: TMTPositionProtocol;
begin
  LPositionProtocol := TMTPositionProtocol.Create(FMTConnect);
  try
    Result := LPositionProtocol.PositionGetPage(ALogin, AOffset, ATotal, APositionsCollection);
  finally
    LPositionProtocol.Free;
  end;
end;

function TMTApi.PositionGetTotal(ALogin: Integer; out ATotal: Integer): TMTRetCodeType;
var
  LPositionProtocol: TMTPositionProtocol;
begin
  LPositionProtocol := TMTPositionProtocol.Create(FMTConnect);
  try
    Result := LPositionProtocol.PositionGetTotal(ALogin, ATotal);
  finally
    LPositionProtocol.Free;
  end;
end;

end.
