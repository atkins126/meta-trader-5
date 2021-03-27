unit MT5.Deal;
{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils, System.JSON, REST.JSON, System.Generics.Collections,
  MT5.Connect, MT5.RetCode;

type

  TMTDealProtocol = class;
  TMTDeal = class;
  TMTDealTotalAnswer = class;
  TMTDealPageAnswer = class;
  TMTDealAnswer = class;
  TMTDealJson = class;

  TMTDealProtocol = class
  private
    { private declarations }
    FMTConnect: TMTConnect;
    function ParseDeal(ACommand: string; AAnswer: string; out ADealAnswer: TMTDealAnswer): TMTRetCodeType;
    function ParseDealPage(AAnswer: string; out ADealPageAnswer: TMTDealPageAnswer): TMTRetCodeType;
    function ParseDealTotal(AAnswer: string; out ADealTotalAnswer: TMTDealTotalAnswer): TMTRetCodeType;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(AConnect: TMTConnect);
    function DealGet(ATicket: string; out ADeal: TMTDeal): TMTRetCodeType;
    function DealGetPage(ALogin, AFrom, ATo, AOffset, ATotal: Integer; out ADealsCollection: TArray<TMTDeal>): TMTRetCodeType;
    function DealGetTotal(ALogin, AFrom, ATo: Integer; out ATotal: Integer): TMTRetCodeType;
  end;

  TMTEnDealAction = (
    DEAL_BUY = 0, // buy
    DEAL_SELL = 1, // sell
    DEAL_BALANCE = 2, // deposit operation
    DEAL_CREDIT = 3, // credit operation
    DEAL_CHARGE = 4, // additional charges
    DEAL_CORRECTION = 5, // correction deals
    DEAL_BONUS = 6, // bouns
    DEAL_COMMISSION = 7, // commission
    DEAL_COMMISSION_DAILY = 8, // daily commission
    DEAL_COMMISSION_MONTHLY = 9, // monthly commission
    DEAL_AGENT_DAILY = 10, // daily agent commission
    DEAL_AGENT_MONTHLY = 11, // monthly agent commission
    DEAL_INTERESTRATE = 12, // interest rate charges
    DEAL_BUY_CANCELED = 13, // canceled buy deal
    DEAL_SELL_CANCELED = 14, // canceled sell deal
    DEAL_DIVIDEND = 15, // dividend
    DEAL_DIVIDEND_FRANKED = 16, // franked dividend
    DEAL_TAX = 17, // taxes
    DEAL_AGENT = 18, // instant agent commission
    DEAL_SO_COMPENSATION = 19, // negative balance compensation after stop-out
    // --- enumeration borders
    DEAL_FIRST = TMTEnDealAction.DEAL_BUY,
    DEAL_LAST = TMTEnDealAction.DEAL_SO_COMPENSATION
    );

  TMTEnEntryFlags = (
    ENTRY_IN = 0, // in market
    ENTRY_OUT = 1, // out of market
    ENTRY_INOUT = 2, // reverse
    ENTRY_OUT_BY = 3, // closed by  hedged position
    ENTRY_STATE = 255, // state record
    // --- enumeration borders
    ENTRY_FIRST = TMTEnEntryFlags.ENTRY_IN,
    ENTRY_LAST = TMTEnEntryFlags.ENTRY_STATE
    );

  TMTEnDealReason = (
    DEAL_REASON_CLIENT = 0, // deal placed manually
    DEAL_REASON_EXPERT = 1, // deal placed by expert
    DEAL_REASON_DEALER = 2, // deal placed by dealer
    DEAL_REASON_SL = 3, // deal placed due SL
    DEAL_REASON_TP = 4, // deal placed due TP
    DEAL_REASON_SO = 5, // deal placed due Stop-Out
    DEAL_REASON_ROLLOVER = 6, // deal placed due rollover
    DEAL_REASON_EXTERNAL_CLIENT = 7, // deal placed from the external system by client
    DEAL_REASON_VMARGIN = 8, // deal placed due variation margin
    DEAL_REASON_GATEWAY = 9, // deal placed by gateway
    DEAL_REASON_SIGNAL = 10, // deal placed by signal service
    DEAL_REASON_SETTLEMENT = 11, // deal placed due settlement
    DEAL_REASON_TRANSFER = 12, // deal placed due position transfer
    DEAL_REASON_SYNC = 13, // deal placed due position synchronization
    DEAL_REASON_EXTERNAL_SERVICE = 14, // deal placed from the external system due service issues
    DEAL_REASON_MIGRATION = 15, // deal placed due migration
    DEAL_REASON_MOBILE = 16, // deal placed manually by mobile terminal
    DEAL_REASON_WEB = 17, // deal placed manually by web terminal
    DEAL_REASON_SPLIT = 18, // deal placed due split
    // --- enumeration borders
    DEAL_REASON_FIRST = TMTEnDealReason.DEAL_REASON_CLIENT,
    DEAL_REASON_LAST = TMTEnDealReason.DEAL_REASON_SPLIT
    );

  TMTEnTradeModifyFlags = (
    MODIFY_FLAGS_ADMIN = 1,
    MODIFY_FLAGS_MANAGER = 2,
    MODIFY_FLAGS_POSITION = 4,
    MODIFY_FLAGS_RESTORE = 8,
    MODIFY_FLAGS_API_ADMIN = 16,
    MODIFY_FLAGS_API_MANAGER = 32,
    MODIFY_FLAGS_API_SERVER = 64,
    MODIFY_FLAGS_API_GATEWAY = 128,
    MODIFY_FLAGS_API_SERVER_ADD = 256,
    // --- enumeration borders
    MODIFY_FLAGS_NONE = 0,
    MODIFY_FLAGS_ALL = 511
    );

  TMTDeal = class
  private
    FSymbol: string;
    FPriceGateway: Single;
    FExternalID: string;
    FRateMargin: Single;
    FPricePosition: Single;
    FComment: string;
    FPrice: Single;
    FExpertID: Int64;
    FContractSize: Single;
    FRateProfit: Single;
    FDeal: Int64;
    FPositionID: Int64;
    FOrder: Int64;
    FReason: TMTEnDealReason;
    FDealer: Int64;
    FDigitsCurrency: Int64;
    FVolumeExt: Int64;
    FDigits: Int64;
    FCommission: Single;
    FTime: Int64;
    FModifyFlags: TMTEnEntryFlags;
    FStorage: Single;
    FVolumeClosedExt: Int64;
    FVolume: Int64;
    FEntry: TMTEnEntryFlags;
    FLogin: Int64;
    FAction: TMTEnDealAction;
    FGateway: string;
    FTimeMsc: string;
    FVolumeClosed: Int64;
    FProfitRaw: Single;
    FTickValue: Single;
    FFlags: Int64;
    FTickSize: Single;
    FProfit: Single;
    FPriceSL: Single;
    FPriceTP: Single;
    procedure SetAction(const Value: TMTEnDealAction);
    procedure SetComment(const Value: string);
    procedure SetCommission(const Value: Single);
    procedure SetContractSize(const Value: Single);
    procedure SetDeal(const Value: Int64);
    procedure SetDealer(const Value: Int64);
    procedure SetDigits(const Value: Int64);
    procedure SetDigitsCurrency(const Value: Int64);
    procedure SetEntry(const Value: TMTEnEntryFlags);
    procedure SetExpertID(const Value: Int64);
    procedure SetExternalID(const Value: string);
    procedure SetFlags(const Value: Int64);
    procedure SetGateway(const Value: string);
    procedure SetLogin(const Value: Int64);
    procedure SetModifyFlags(const Value: TMTEnEntryFlags);
    procedure SetOrder(const Value: Int64);
    procedure SetPositionID(const Value: Int64);
    procedure SetPrice(const Value: Single);
    procedure SetPriceGateway(const Value: Single);
    procedure SetPricePosition(const Value: Single);
    procedure SetProfit(const Value: Single);
    procedure SetProfitRaw(const Value: Single);
    procedure SetRateMargin(const Value: Single);
    procedure SetRateProfit(const Value: Single);
    procedure SetReason(const Value: TMTEnDealReason);
    procedure SetStorage(const Value: Single);
    procedure SetSymbol(const Value: string);
    procedure SetTickSize(const Value: Single);
    procedure SetTickValue(const Value: Single);
    procedure SetTime(const Value: Int64);
    procedure SetTimeMsc(const Value: string);
    procedure SetVolume(const Value: Int64);
    procedure SetVolumeClosed(const Value: Int64);
    procedure SetVolumeClosedExt(const Value: Int64);
    procedure SetVolumeExt(const Value: Int64);
    procedure SetPriceSL(const Value: Single);
    procedure SetPriceTP(const Value: Single);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    property Deal: Int64 read FDeal write SetDeal;
    property ExternalID: string read FExternalID write SetExternalID;
    property Login: Int64 read FLogin write SetLogin;
    property Dealer: Int64 read FDealer write SetDealer;
    property Order: Int64 read FOrder write SetOrder;
    property Action: TMTEnDealAction read FAction write SetAction;
    property Entry: TMTEnEntryFlags read FEntry write SetEntry;
    property Reason: TMTEnDealReason read FReason write SetReason;
    property Digits: Int64 read FDigits write SetDigits;
    property DigitsCurrency: Int64 read FDigitsCurrency write SetDigitsCurrency;
    property ContractSize: Single read FContractSize write SetContractSize;
    property Time: Int64 read FTime write SetTime;
    property TimeMsc: string read FTimeMsc write SetTimeMsc;
    property Symbol: string read FSymbol write SetSymbol;
    property Price: Single read FPrice write SetPrice;
    property Volume: Int64 read FVolume write SetVolume;
    property VolumeExt: Int64 read FVolumeExt write SetVolumeExt;
    property Profit: Single read FProfit write SetProfit;
    property Storage: Single read FStorage write SetStorage;
    property Commission: Single read FCommission write SetCommission;
    property RateProfit: Single read FRateProfit write SetRateProfit;
    property RateMargin: Single read FRateMargin write SetRateMargin;
    property ExpertID: Int64 read FExpertID write SetExpertID;
    property PositionID: Int64 read FPositionID write SetPositionID;
    property Comment: string read FComment write SetComment;
    property ProfitRaw: Single read FProfitRaw write SetProfitRaw;
    property PricePosition: Single read FPricePosition write SetPricePosition;
    property VolumeClosed: Int64 read FVolumeClosed write SetVolumeClosed;
    property VolumeClosedExt: Int64 read FVolumeClosedExt write SetVolumeClosedExt;
    property TickValue: Single read FTickValue write SetTickValue;
    property TickSize: Single read FTickSize write SetTickSize;
    property Flags: Int64 read FFlags write SetFlags;
    property Gateway: string read FGateway write SetGateway;
    property PriceGateway: Single read FPriceGateway write SetPriceGateway;
    property ModifyFlags: TMTEnEntryFlags read FModifyFlags write SetModifyFlags;
    property PriceSL: Single read FPriceSL write SetPriceSL;
    property PriceTP: Single read FPriceTP write SetPriceTP;
  end;

  TMTDealTotalAnswer = class
  private
    FRetCode: string;
    FTotal: Integer;
    procedure SetRetCode(const Value: string);
    procedure SetTotal(const Value: Integer);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create; virtual;
    property RetCode: string read FRetCode write SetRetCode;
    property Total: Integer read FTotal write SetTotal;
  end;

  TMTDealPageAnswer = class
  private
    FConfigJson: string;
    FRetCode: string;
    procedure SetConfigJson(const Value: string);
    procedure SetRetCode(const Value: string);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create; virtual;
    property RetCode: string read FRetCode write SetRetCode;
    property ConfigJson: string read FConfigJson write SetConfigJson;
    function GetArrayFromJson: TArray<TMTDeal>;
  end;

  TMTDealAnswer = class
  private
    FConfigJson: string;
    FRetCode: string;
    procedure SetConfigJson(const Value: string);
    procedure SetRetCode(const Value: string);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create; virtual;
    property RetCode: string read FRetCode write SetRetCode;
    property ConfigJson: string read FConfigJson write SetConfigJson;
    function GetFromJson: TMTDeal;
  end;

  TMTDealJson = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function GetFromJson(AJsonObject: TJsonObject): TMTDeal;
  end;

implementation

uses
  MT5.Types, MT5.Protocol, MT5.Utils, MT5.BaseAnswer, MT5.ParseProtocol;

{ TMTDealProtocol }

constructor TMTDealProtocol.Create(AConnect: TMTConnect);
begin
  FMTConnect := AConnect;
end;

function TMTDealProtocol.DealGet(ATicket: string; out ADeal: TMTDeal): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LDealAnswer: TMTDealAnswer;
begin
  LData := [
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TICKET, ATicket)
    ];

  if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_DEAL_GET, LData) then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswer := FMTConnect.Read(True);

  if Length(LAnswer) = 0 then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswerString := TMTUtils.GetString(LAnswer);

  LRetCodeType := ParseDeal(TMTProtocolConsts.WEB_CMD_DEAL_GET, LAnswerString, LDealAnswer);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  ADeal := LDealAnswer.GetFromJson;

  Exit(TMTRetCodeType.MT_RET_OK);

end;

function TMTDealProtocol.DealGetPage(ALogin, AFrom, ATo, AOffset, ATotal: Integer; out ADealsCollection: TArray<TMTDeal>): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LDealPageAnswer: TMTDealPageAnswer;
begin
  LData := [
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_LOGIN, ALogin.ToString),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_FROM, AFrom.ToString),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TO, ATo.ToString),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_OFFSET, AOffset.ToString),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TOTAL, ATotal.ToString)
    ];

  if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_DEAL_GET_PAGE, LData) then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswer := FMTConnect.Read(True);

  if Length(LAnswer) = 0 then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswerString := TMTUtils.GetString(LAnswer);

  LRetCodeType := ParseDealPage(LAnswerString, LDealPageAnswer);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  ADealsCollection := LDealPageAnswer.GetArrayFromJson;

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTDealProtocol.DealGetTotal(ALogin, AFrom, ATo: Integer; out ATotal: Integer): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LDealTotalAnswer: TMTDealTotalAnswer;
begin
  ATotal := 0;
  LData := [
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_LOGIN, ALogin.ToString),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_FROM, AFrom.ToString),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TO, ATo.ToString)
    ];

  if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_DEAL_GET_TOTAL, LData) then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswer := FMTConnect.Read(True);

  if Length(LAnswer) = 0 then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswerString := TMTUtils.GetString(LAnswer);

  LRetCodeType := ParseDealTotal(LAnswerString, LDealTotalAnswer);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  ATotal := LDealTotalAnswer.Total;

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTDealProtocol.ParseDeal(ACommand, AAnswer: string; out ADealAnswer: TMTDealAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
  LJsonDataString: string;
begin
  LPos := 0;
  ADealAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> ACommand) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  ADealAnswer := TMTDealAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
    begin
      ADealAnswer.RetCode := LParam.Value;
      Break;
    end;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;
  if LParam <> nil then
    FreeAndNil(LParam);

  LRetCodeType := TMTParseProtocol.GetRetCode(ADealAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  LJsonDataString := TMTParseProtocol.GetJson(AAnswer, LPosEnd);

  if LJsonDataString = EmptyStr then
    Exit(TMTRetCodeType.MT_RET_REPORT_NODATA);

  ADealAnswer.ConfigJson := LJsonDataString;

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTDealProtocol.ParseDealPage(AAnswer: string; out ADealPageAnswer: TMTDealPageAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
  LJsonDataString: string;
begin
  LPos := 0;
  ADealPageAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> TMTProtocolConsts.WEB_CMD_DEAL_GET_PAGE) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  ADealPageAnswer := TMTDealPageAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
    begin
      ADealPageAnswer.RetCode := LParam.Value;
      Break;
    end;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;
  if LParam <> nil then
    FreeAndNil(LParam);

  LRetCodeType := TMTParseProtocol.GetRetCode(ADealPageAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  LJsonDataString := TMTParseProtocol.GetJson(AAnswer, LPosEnd);

  if LJsonDataString = EmptyStr then
    Exit(TMTRetCodeType.MT_RET_REPORT_NODATA);

  ADealPageAnswer.ConfigJson := LJsonDataString;

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTDealProtocol.ParseDealTotal(AAnswer: string; out ADealTotalAnswer: TMTDealTotalAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
begin
  LPos := 0;
  ADealTotalAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> TMTProtocolConsts.WEB_CMD_DEAL_GET_TOTAL) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  ADealTotalAnswer := TMTDealTotalAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
      ADealTotalAnswer.RetCode := LParam.Value;
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_TOTAL then
      ADealTotalAnswer.Total := LParam.Value.ToInteger;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;

  LRetCodeType := TMTParseProtocol.GetRetCode(ADealTotalAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  Exit(TMTRetCodeType.MT_RET_OK);
end;

{ TMTDeal }

procedure TMTDeal.SetAction(const Value: TMTEnDealAction);
begin
  FAction := Value;
end;

procedure TMTDeal.SetComment(const Value: string);
begin
  FComment := Value;
end;

procedure TMTDeal.SetCommission(const Value: Single);
begin
  FCommission := Value;
end;

procedure TMTDeal.SetContractSize(const Value: Single);
begin
  FContractSize := Value;
end;

procedure TMTDeal.SetDeal(const Value: Int64);
begin
  FDeal := Value;
end;

procedure TMTDeal.SetDealer(const Value: Int64);
begin
  FDealer := Value;
end;

procedure TMTDeal.SetDigits(const Value: Int64);
begin
  FDigits := Value;
end;

procedure TMTDeal.SetDigitsCurrency(const Value: Int64);
begin
  FDigitsCurrency := Value;
end;

procedure TMTDeal.SetEntry(const Value: TMTEnEntryFlags);
begin
  FEntry := Value;
end;

procedure TMTDeal.SetExpertID(const Value: Int64);
begin
  FExpertID := Value;
end;

procedure TMTDeal.SetExternalID(const Value: string);
begin
  FExternalID := Value;
end;

procedure TMTDeal.SetFlags(const Value: Int64);
begin
  FFlags := Value;
end;

procedure TMTDeal.SetGateway(const Value: string);
begin
  FGateway := Value;
end;

procedure TMTDeal.SetLogin(const Value: Int64);
begin
  FLogin := Value;
end;

procedure TMTDeal.SetModifyFlags(const Value: TMTEnEntryFlags);
begin
  FModifyFlags := Value;
end;

procedure TMTDeal.SetOrder(const Value: Int64);
begin
  FOrder := Value;
end;

procedure TMTDeal.SetPositionID(const Value: Int64);
begin
  FPositionID := Value;
end;

procedure TMTDeal.SetPrice(const Value: Single);
begin
  FPrice := Value;
end;

procedure TMTDeal.SetPriceGateway(const Value: Single);
begin
  FPriceGateway := Value;
end;

procedure TMTDeal.SetPricePosition(const Value: Single);
begin
  FPricePosition := Value;
end;

procedure TMTDeal.SetPriceSL(const Value: Single);
begin
  FPriceSL := Value;
end;

procedure TMTDeal.SetPriceTP(const Value: Single);
begin
  FPriceTP := Value;
end;

procedure TMTDeal.SetProfit(const Value: Single);
begin
  FProfit := Value;
end;

procedure TMTDeal.SetProfitRaw(const Value: Single);
begin
  FProfitRaw := Value;
end;

procedure TMTDeal.SetRateMargin(const Value: Single);
begin
  FRateMargin := Value;
end;

procedure TMTDeal.SetRateProfit(const Value: Single);
begin
  FRateProfit := Value;
end;

procedure TMTDeal.SetReason(const Value: TMTEnDealReason);
begin
  FReason := Value;
end;

procedure TMTDeal.SetStorage(const Value: Single);
begin
  FStorage := Value;
end;

procedure TMTDeal.SetSymbol(const Value: string);
begin
  FSymbol := Value;
end;

procedure TMTDeal.SetTickSize(const Value: Single);
begin
  FTickSize := Value;
end;

procedure TMTDeal.SetTickValue(const Value: Single);
begin
  FTickValue := Value;
end;

procedure TMTDeal.SetTime(const Value: Int64);
begin
  FTime := Value;
end;

procedure TMTDeal.SetTimeMsc(const Value: string);
begin
  FTimeMsc := Value;
end;

procedure TMTDeal.SetVolume(const Value: Int64);
begin
  FVolume := Value;
end;

procedure TMTDeal.SetVolumeClosed(const Value: Int64);
begin
  FVolumeClosed := Value;
end;

procedure TMTDeal.SetVolumeClosedExt(const Value: Int64);
begin
  FVolumeClosedExt := Value;
end;

procedure TMTDeal.SetVolumeExt(const Value: Int64);
begin
  FVolumeExt := Value;
end;

{ TMTDealTotalAnswer }

constructor TMTDealTotalAnswer.Create;
begin
  FRetCode := '-1';
  FTotal := 0;
end;

procedure TMTDealTotalAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

procedure TMTDealTotalAnswer.SetTotal(const Value: Integer);
begin
  FTotal := Value;
end;

{ TMTDealPageAnswer }

constructor TMTDealPageAnswer.Create;
begin
  FConfigJson := '';
  FRetCode := '-1';
end;

function TMTDealPageAnswer.GetArrayFromJson: TArray<TMTDeal>;
var
  LDealsJsonArray: TJsonArray;
  I: Integer;
begin
  LDealsJsonArray := TJsonObject.ParseJSONValue(ConfigJson) as TJsonArray;
  for I := 0 to LDealsJsonArray.Count - 1 do
    Result := Result + [TMTDealJson.GetFromJson(TJsonObject(LDealsJsonArray.Items[I]))];
end;

procedure TMTDealPageAnswer.SetConfigJson(const Value: string);
begin
  FConfigJson := Value;
end;

procedure TMTDealPageAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

{ TMTDealAnswer }

constructor TMTDealAnswer.Create;
begin
  FConfigJson := '';
  FRetCode := '-1';
end;

function TMTDealAnswer.GetFromJson: TMTDeal;
begin
  Result := TMTDealJson.GetFromJson(TJsonObject.ParseJSONValue(ConfigJson) as TJsonObject);
end;

procedure TMTDealAnswer.SetConfigJson(const Value: string);
begin
  FConfigJson := Value;
end;

procedure TMTDealAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

{ TMTDealJson }

class function TMTDealJson.GetFromJson(AJsonObject: TJsonObject): TMTDeal;
var
  LDeal: TMTDeal;
  LVolumeExt: Int64;
  LVolumeClosedExt: Int64;
  LPriceSL: Single;
  LPriceTP: Single;
begin

  LDeal := TMTDeal.Create;

  LDeal.Symbol := AJsonObject.GetValue<string>('Symbol');
  LDeal.PriceGateway := AJsonObject.GetValue<Single>('PriceGateway');
  LDeal.ExternalID := AJsonObject.GetValue<string>('ExternalID');
  LDeal.RateMargin := AJsonObject.GetValue<Single>('RateMargin');
  LDeal.PricePosition := AJsonObject.GetValue<Single>('PricePosition');
  LDeal.Comment := AJsonObject.GetValue<string>('Comment');
  LDeal.Price := AJsonObject.GetValue<Single>('Price');
  LDeal.ExpertID := AJsonObject.GetValue<Int64>('ExpertID');
  LDeal.ContractSize := AJsonObject.GetValue<Single>('ContractSize');
  LDeal.RateProfit := AJsonObject.GetValue<Single>('RateProfit');
  LDeal.Deal := AJsonObject.GetValue<Int64>('Deal');
  LDeal.PositionID := AJsonObject.GetValue<Int64>('PositionID');
  LDeal.Order := AJsonObject.GetValue<Int64>('Order');
  LDeal.Reason := TMTEnDealReason(AJsonObject.GetValue<Integer>('Reason'));
  LDeal.Dealer := AJsonObject.GetValue<Int64>('Dealer');
  LDeal.DigitsCurrency := AJsonObject.GetValue<Int64>('DigitsCurrency');

  if AJsonObject.TryGetValue<Int64>('VolumeExt', LVolumeExt) then
    LDeal.VolumeExt := AJsonObject.GetValue<Int64>('VolumeExt')
  else
    LDeal.VolumeExt := TMTUtils.ToNewVolume(LDeal.Volume);

  LDeal.Digits := AJsonObject.GetValue<Int64>('Digits');
  LDeal.Commission := AJsonObject.GetValue<Single>('Commission');
  LDeal.Time := AJsonObject.GetValue<Int64>('Time');
  LDeal.ModifyFlags := TMTEnEntryFlags(AJsonObject.GetValue<Integer>('ModifyFlags'));
  LDeal.Storage := AJsonObject.GetValue<Single>('Storage');

  if AJsonObject.TryGetValue<Int64>('VolumeClosedExt', LVolumeClosedExt) then
    LDeal.VolumeClosedExt := AJsonObject.GetValue<Int64>('VolumeClosedExt')
  else
    LDeal.VolumeClosedExt := TMTUtils.ToNewVolume(LDeal.VolumeClosed);

  if AJsonObject.TryGetValue<Single>('PriceSL', LPriceSL) then
    LDeal.PriceSL := LPriceSL;
  if AJsonObject.TryGetValue<Single>('PriceTP', LPriceTP) then
    LDeal.PriceTP := LPriceTP;

  LDeal.Volume := AJsonObject.GetValue<Int64>('Volume');
  LDeal.Entry := TMTEnEntryFlags(AJsonObject.GetValue<Integer>('Entry'));
  LDeal.Login := AJsonObject.GetValue<Int64>('Login');
  LDeal.Action := TMTEnDealAction(AJsonObject.GetValue<Integer>('Action'));
  LDeal.Gateway := AJsonObject.GetValue<string>('Gateway');
  LDeal.TimeMsc := AJsonObject.GetValue<string>('TimeMsc');
  LDeal.VolumeClosed := AJsonObject.GetValue<Int64>('VolumeClosed');
  LDeal.ProfitRaw := AJsonObject.GetValue<Single>('ProfitRaw');
  LDeal.TickValue := AJsonObject.GetValue<Single>('TickValue');
  LDeal.Flags := AJsonObject.GetValue<Int64>('Flags');
  LDeal.TickSize := AJsonObject.GetValue<Single>('TickSize');
  LDeal.Profit := AJsonObject.GetValue<Single>('Profit');

  Result := LDeal;

end;

end.
