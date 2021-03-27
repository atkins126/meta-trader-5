unit MT5.Order;
{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils, System.JSON, REST.JSON,
  System.Generics.Collections,
  MT5.Connect, MT5.RetCode;

type

  TMTOrderProtocol = class;
  TMTOrder = class;
  TMTOrderTotalAnswer = class;
  TMTOrderPageAnswer = class;
  TMTOrderAnswer = class;
  TMTOrderJson = class;

  TMTOrderProtocol = class
  private
    { private declarations }
    FMTConnect: TMTConnect;
    function ParseOrder(ACommand: string; AAnswer: string; out AOrderAnswer: TMTOrderAnswer): TMTRetCodeType;
    function ParseOrderPage(AAnswer: string; out AOrderPageAnswer: TMTOrderPageAnswer): TMTRetCodeType;
    function ParseOrderTotal(AAnswer: string; out AOrderTotalAnswer: TMTOrderTotalAnswer): TMTRetCodeType;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(AConnect: TMTConnect);
    function OrderGet(ATicket: string; out AOrder: TMTOrder): TMTRetCodeType;
    function OrderGetPage(ALogin, AOffset, ATotal: Integer; out AOrdersCollection: TArray<TMTOrder>): TMTRetCodeType;
    function OrderGetTotal(ALogin: Integer; out ATotal: Integer): TMTRetCodeType;
  end;

  TMTEnOrderType = (
    OP_BUY = 0, // buy order
    OP_SELL = 1, // sell order
    OP_BUY_LIMIT = 2, // buy limit order
    OP_SELL_LIMIT = 3, // sell limit order
    OP_BUY_STOP = 4, // buy stop order
    OP_SELL_STOP = 5, // sell stop order
    OP_BUY_STOP_LIMIT = 6, // buy stop limit order
    OP_SELL_STOP_LIMIT = 7, // sell stop limit order
    OP_CLOSE_BY = 8, // close by
    // --- enumeration borders
    OP_FIRST = TMTEnOrderType.OP_BUY,
    OP_LAST = TMTEnOrderType.OP_CLOSE_BY
    );

  TMTEnOrderFilling = (
    ORDER_FILL_FOK = 0, // fill or kill
    ORDER_FILL_IOC = 1, // immediate or cancel
    ORDER_FILL_RETURN = 2, // return order in queue
    // --- enumeration borders
    ORDER_FILL_FIRST = TMTEnOrderFilling.ORDER_FILL_FOK,
    ORDER_FILL_LAST = TMTEnOrderFilling.ORDER_FILL_RETURN
    );

  TMTEnOrderTime = (
    ORDER_TIME_GTC = 0, // good till cancel
    ORDER_TIME_DAY = 1, // good till day
    ORDER_TIME_SPECIFIED = 2, // good till specified
    ORDER_TIME_SPECIFIED_DAY = 3, // good till specified day
    // --- enumeration borders
    ORDER_TIME_FIRST = TMTEnOrderTime.ORDER_TIME_GTC,
    ORDER_TIME_LAST = TMTEnOrderTime.ORDER_TIME_SPECIFIED_DAY
    );

  TMTEnOrderState = (
    ORDER_STATE_STARTED = 0, // order started
    ORDER_STATE_PLACED = 1, // order placed in system
    ORDER_STATE_CANCELED = 2, // order canceled by client
    ORDER_STATE_PARTIAL = 3, // order partially filled
    ORDER_STATE_FILLED = 4, // order filled
    ORDER_STATE_REJECTED = 5, // order rejected
    ORDER_STATE_EXPIRED = 6, // order expired
    ORDER_STATE_REQUEST_ADD = 7,
    ORDER_STATE_REQUEST_MODIFY = 8,
    ORDER_STATE_REQUEST_CANCEL = 9,
    // --- enumeration borders
    ORDER_STATE_FIRST = TMTEnOrderState.ORDER_STATE_STARTED,
    ORDER_STATE_LAST = TMTEnOrderState.ORDER_STATE_REQUEST_CANCEL
    );

  TMTEnOrderActivation = (
    ACTIVATION_NONE = 0, // none
    ACTIVATION_PENDING = 1, // pending order activated
    ACTIVATION_STOPLIMIT = 2, // stop-limit order activated
    ACTIVATION_EXPIRATION = 3,
    ACTIVATION_STOPOUT = 4, // order activate for stop-out
    // --- enumeration borders
    ACTIVATION_FIRST = TMTEnOrderActivation.ACTIVATION_NONE,
    ACTIVATION_LAST = TMTEnOrderActivation.ACTIVATION_STOPOUT
    );

  TMTEnOrderReason = (
    ORDER_REASON_CLIENT = 0, // order placed manually
    ORDER_REASON_EXPERT = 1, // order placed by expert
    ORDER_REASON_DEALER = 2, // order placed by dealer
    ORDER_REASON_SL = 3, // order placed due SL
    ORDER_REASON_TP = 4, // order placed due TP
    ORDER_REASON_SO = 5, // order placed due Stop-Out
    ORDER_REASON_ROLLOVER = 6, // order placed due rollover
    ORDER_REASON_EXTERNAL_CLIENT = 7, // order placed from the external system by client
    ORDER_REASON_VMARGIN = 8, // order placed due variation margin
    ORDER_REASON_GATEWAY = 9, // order placed by gateway
    ORDER_REASON_SIGNAL = 10, // order placed by signal service
    ORDER_REASON_SETTLEMENT = 11, // order placed by settlement
    ORDER_REASON_TRANSFER = 12, // order placed due transfer
    ORDER_REASON_SYNC = 13, // order placed due synchronization
    ORDER_REASON_EXTERNAL_SERVICE = 14, // order placed from the external system due service issues
    ORDER_REASON_MIGRATION = 15, // order placed due account migration from MetaTrader 4 or MetaTrader 5
    ORDER_REASON_MOBILE = 16, // order placed manually by mobile terminal
    ORDER_REASON_WEB = 17, // order placed manually by web terminal
    ORDER_REASON_SPLIT = 18, // order placed due split
    // --- enumeration borders
    ORDER_REASON_FIRST = TMTEnOrderReason.ORDER_REASON_CLIENT,
    ORDER_REASON_LAST = TMTEnOrderReason.ORDER_REASON_SPLIT
    );

  TMTEnTradeActivationFlags = (
    ACTIV_FLAGS_NO_LIMIT = $01,
    ACTIV_FLAGS_NO_STOP = $02,
    ACTIV_FLAGS_NO_SLIMIT = $04,
    ACTIV_FLAGS_NO_SL = $08,
    ACTIV_FLAGS_NO_TP = $10,
    ACTIV_FLAGS_NO_SO = $20,
    ACTIV_FLAGS_NO_EXPIRATION = $40,
    // ---
    ACTIV_FLAGS_NONE = $00,
    ACTIV_FLAGS_ALL = $7F
    );

  TMTEnOrderTradeModifyFlags = (
    MODIFY_FLAGS_ADMIN = $001,
    MODIFY_FLAGS_MANAGER = $002,
    MODIFY_FLAGS_POSITION = $004,
    MODIFY_FLAGS_RESTORE = $008,
    MODIFY_FLAGS_API_ADMIN = $010,
    MODIFY_FLAGS_API_MANAGER = $020,
    MODIFY_FLAGS_API_SERVER = $040,
    MODIFY_FLAGS_API_GATEWAY = $080,
    MODIFY_FLAGS_API_SERVER_ADD = $100,
    // --- enumeration borders
    MODIFY_FLAGS_NONE = $000,
    MODIFY_FLAGS_ALL = $1FF
    );

  TMTOrder = class
  private
    FSymbol: string;
    FActivationMode: TMTEnOrderActivation;
    FExternalID: string;
    FActivationPrice: Single;
    FPositionByID: Single;
    FPriceSL: Single;
    FComment: string;
    FExpertPositionID: Single;
    FVolumeInitialExt: Int64;
    FExpertID: Single;
    FTypeTime: TMTEnOrderTime;
    FContractSize: Single;
    FPriceCurrent: Single;
    FState: TMTEnOrderState;
    FVolumeInitial: Int64;
    FTypeFill: TMTEnOrderFilling;
    FTimeSetup: Int64;
    FOrder: Int64;
    FReason: TMTEnOrderReason;
    FActivationTime: Int64;
    FDealer: Int64;
    FDigitsCurrency: Int64;
    FDigits: Int64;
    FTimeSetupMsc: Int64;
    FVolumeCurrentExt: Int64;
    FModifyFlags: TMTEnOrderTradeModifyFlags;
    FTimeExpiration: Int64;
    FPriceOrder: Single;
    FTimeDone: Int64;
    FType: TMTEnOrderType;
    FVolumeCurrent: Int64;
    FActivationFlags: TMTEnTradeActivationFlags;
    FLogin: Int64;
    FPriceTrigger: Single;
    FTimeDoneMsc: Int64;
    FPriceTP: Single;
    procedure SetActivationFlags(const Value: TMTEnTradeActivationFlags);
    procedure SetActivationMode(const Value: TMTEnOrderActivation);
    procedure SetActivationPrice(const Value: Single);
    procedure SetActivationTime(const Value: Int64);
    procedure SetComment(const Value: string);
    procedure SetContractSize(const Value: Single);
    procedure SetDealer(const Value: Int64);
    procedure SetDigits(const Value: Int64);
    procedure SetDigitsCurrency(const Value: Int64);
    procedure SetExpertID(const Value: Single);
    procedure SetExpertPositionID(const Value: Single);
    procedure SetExternalID(const Value: string);
    procedure SetLogin(const Value: Int64);
    procedure SetModifyFlags(const Value: TMTEnOrderTradeModifyFlags);
    procedure SetOrder(const Value: Int64);
    procedure SetPositionByID(const Value: Single);
    procedure SetPriceCurrent(const Value: Single);
    procedure SetPriceOrder(const Value: Single);
    procedure SetPriceSL(const Value: Single);
    procedure SetPriceTP(const Value: Single);
    procedure SetPriceTrigger(const Value: Single);
    procedure SetReason(const Value: TMTEnOrderReason);
    procedure SetState(const Value: TMTEnOrderState);
    procedure SetSymbol(const Value: string);
    procedure SetTimeDone(const Value: Int64);
    procedure SetTimeDoneMsc(const Value: Int64);
    procedure SetTimeExpiration(const Value: Int64);
    procedure SetTimeSetup(const Value: Int64);
    procedure SetTimeSetupMsc(const Value: Int64);
    procedure SetType(const Value: TMTEnOrderType);
    procedure SetTypeFill(const Value: TMTEnOrderFilling);
    procedure SetTypeTime(const Value: TMTEnOrderTime);
    procedure SetVolumeCurrent(const Value: Int64);
    procedure SetVolumeCurrentExt(const Value: Int64);
    procedure SetVolumeInitial(const Value: Int64);
    procedure SetVolumeInitialExt(const Value: Int64);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }

    // --- order ticket
    property Order: Int64 read FOrder write SetOrder;
    // --- order ticket in external system (exchange, ECN, etc)
    property ExternalID: string read FExternalID write SetExternalID;
    // --- client login
    property Login: Int64 read FLogin write SetLogin;
    // --- processed dealer login (0-means auto)
    property Dealer: Int64 read FDealer write SetDealer;
    // --- order symbol
    property Symbol: string read FSymbol write SetSymbol;
    // --- price digits
    property Digits: Int64 read FDigits write SetDigits;
    // --- currency digits
    property DigitsCurrency: Int64 read FDigitsCurrency write SetDigitsCurrency;
    // --- contract size
    property ContractSize: Single read FContractSize write SetContractSize;
    // --- MTEnOrderState
    property State: TMTEnOrderState read FState write SetState;
    // --- MTEnOrderReason
    property Reason: TMTEnOrderReason read FReason write SetReason;
    // --- order setup time
    property TimeSetup: Int64 read FTimeSetup write SetTimeSetup;
    // --- order expiration
    property TimeExpiration: Int64 read FTimeExpiration write SetTimeExpiration;
    // --- order filling/cancel time
    property TimeDone: Int64 read FTimeDone write SetTimeDone;
    // --- order setup time in msc since 1970.01.01
    property TimeSetupMsc: Int64 read FTimeSetupMsc write SetTimeSetupMsc;
    // --- order filling/cancel time in msc since 1970.01.01
    property TimeDoneMsc: Int64 read FTimeDoneMsc write SetTimeDoneMsc;
    // --- modification flags (type is MTEnOrderTradeModifyFlags)
    property ModifyFlags: TMTEnOrderTradeModifyFlags read FModifyFlags write SetModifyFlags;
    // --- MTEnOrderType
    property &Type: TMTEnOrderType read FType write SetType;
    // --- MTEnOrderFilling
    property TypeFill: TMTEnOrderFilling read FTypeFill write SetTypeFill;
    // --- MTEnOrderTime
    property TypeTime: TMTEnOrderTime read FTypeTime write SetTypeTime;
    // --- order price
    property PriceOrder: Single read FPriceOrder write SetPriceOrder;
    // --- order trigger price (stop-limit price)
    property PriceTrigger: Single read FPriceTrigger write SetPriceTrigger;
    // --- order current price
    property PriceCurrent: Single read FPriceCurrent write SetPriceCurrent;
    // --- order SL
    property PriceSL: Single read FPriceSL write SetPriceSL;
    // --- order TP
    property PriceTP: Single read FPriceTP write SetPriceTP;
    // --- order initial volume
    property VolumeInitial: Int64 read FVolumeInitial write SetVolumeInitial;
    // --- order initial volume
    property VolumeInitialExt: Int64 read FVolumeInitialExt write SetVolumeInitialExt;
    // --- order current volume
    property VolumeCurrent: Int64 read FVolumeCurrent write SetVolumeCurrent;
    // --- order current volume
    property VolumeCurrentExt: Int64 read FVolumeCurrentExt write SetVolumeCurrentExt;
    // --- expert id (filled by expert advisor)
    property ExpertID: Single read FExpertID write SetExpertID;
    // --- expert position id (filled by expert advisor)
    property ExpertPositionID: Single read FExpertPositionID write SetExpertPositionID;
    // --- position by id
    property PositionByID: Single read FPositionByID write SetPositionByID;
    // --- order comment
    property Comment: string read FComment write SetComment;
    // --- order activation state (type is MTEnOrderActivation)
    property ActivationMode: TMTEnOrderActivation read FActivationMode write SetActivationMode;
    // --- order activation time
    property ActivationTime: Int64 read FActivationTime write SetActivationTime;
    // --- order activation  price
    property ActivationPrice: Single read FActivationPrice write SetActivationPrice;
    // --- order activation flag (type is MTEnTradeActivationFlags)
    property ActivationFlags: TMTEnTradeActivationFlags read FActivationFlags write SetActivationFlags;
  end;

  TMTOrderTotalAnswer = class
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

  TMTOrderPageAnswer = class
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
    function GetArrayFromJson: TArray<TMTOrder>;
  end;

  TMTOrderAnswer = class
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
    function GetFromJson: TMTOrder;
  end;

  TMTOrderJson = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function GetFromJson(AJsonObject: TJsonObject): TMTOrder;
  end;

implementation

uses
  MT5.Types, MT5.Protocol, MT5.Utils, MT5.BaseAnswer, MT5.ParseProtocol;

{ TMTOrder }

procedure TMTOrder.SetActivationFlags(const Value: TMTEnTradeActivationFlags);
begin
  FActivationFlags := Value;
end;

procedure TMTOrder.SetActivationMode(const Value: TMTEnOrderActivation);
begin
  FActivationMode := Value;
end;

procedure TMTOrder.SetActivationPrice(const Value: Single);
begin
  FActivationPrice := Value;
end;

procedure TMTOrder.SetActivationTime(const Value: Int64);
begin
  FActivationTime := Value;
end;

procedure TMTOrder.SetComment(const Value: string);
begin
  FComment := Value;
end;

procedure TMTOrder.SetContractSize(const Value: Single);
begin
  FContractSize := Value;
end;

procedure TMTOrder.SetDealer(const Value: Int64);
begin
  FDealer := Value;
end;

procedure TMTOrder.SetDigits(const Value: Int64);
begin
  FDigits := Value;
end;

procedure TMTOrder.SetDigitsCurrency(const Value: Int64);
begin
  FDigitsCurrency := Value;
end;

procedure TMTOrder.SetExpertID(const Value: Single);
begin
  FExpertID := Value;
end;

procedure TMTOrder.SetExpertPositionID(const Value: Single);
begin
  FExpertPositionID := Value;
end;

procedure TMTOrder.SetExternalID(const Value: string);
begin
  FExternalID := Value;
end;

procedure TMTOrder.SetLogin(const Value: Int64);
begin
  FLogin := Value;
end;

procedure TMTOrder.SetModifyFlags(const Value: TMTEnOrderTradeModifyFlags);
begin
  FModifyFlags := Value;
end;

procedure TMTOrder.SetOrder(const Value: Int64);
begin
  FOrder := Value;
end;

procedure TMTOrder.SetPositionByID(const Value: Single);
begin
  FPositionByID := Value;
end;

procedure TMTOrder.SetPriceCurrent(const Value: Single);
begin
  FPriceCurrent := Value;
end;

procedure TMTOrder.SetPriceOrder(const Value: Single);
begin
  FPriceOrder := Value;
end;

procedure TMTOrder.SetPriceSL(const Value: Single);
begin
  FPriceSL := Value;
end;

procedure TMTOrder.SetPriceTP(const Value: Single);
begin
  FPriceTP := Value;
end;

procedure TMTOrder.SetPriceTrigger(const Value: Single);
begin
  FPriceTrigger := Value;
end;

procedure TMTOrder.SetReason(const Value: TMTEnOrderReason);
begin
  FReason := Value;
end;

procedure TMTOrder.SetState(const Value: TMTEnOrderState);
begin
  FState := Value;
end;

procedure TMTOrder.SetSymbol(const Value: string);
begin
  FSymbol := Value;
end;

procedure TMTOrder.SetTimeDone(const Value: Int64);
begin
  FTimeDone := Value;
end;

procedure TMTOrder.SetTimeDoneMsc(const Value: Int64);
begin
  FTimeDoneMsc := Value;
end;

procedure TMTOrder.SetTimeExpiration(const Value: Int64);
begin
  FTimeExpiration := Value;
end;

procedure TMTOrder.SetTimeSetup(const Value: Int64);
begin
  FTimeSetup := Value;
end;

procedure TMTOrder.SetTimeSetupMsc(const Value: Int64);
begin
  FTimeSetupMsc := Value;
end;

procedure TMTOrder.SetType(const Value: TMTEnOrderType);
begin
  FType := Value;
end;

procedure TMTOrder.SetTypeFill(const Value: TMTEnOrderFilling);
begin
  FTypeFill := Value;
end;

procedure TMTOrder.SetTypeTime(const Value: TMTEnOrderTime);
begin
  FTypeTime := Value;
end;

procedure TMTOrder.SetVolumeCurrent(const Value: Int64);
begin
  FVolumeCurrent := Value;
end;

procedure TMTOrder.SetVolumeCurrentExt(const Value: Int64);
begin
  FVolumeCurrentExt := Value;
end;

procedure TMTOrder.SetVolumeInitial(const Value: Int64);
begin
  FVolumeInitial := Value;
end;

procedure TMTOrder.SetVolumeInitialExt(const Value: Int64);
begin
  FVolumeInitialExt := Value;
end;

{ TMTOrderTotalAnswer }

constructor TMTOrderTotalAnswer.Create;
begin
  FRetCode := '-1';
  FTotal := 0;
end;

procedure TMTOrderTotalAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

procedure TMTOrderTotalAnswer.SetTotal(const Value: Integer);
begin
  FTotal := Value;
end;

{ TMTOrderPageAnswer }

constructor TMTOrderPageAnswer.Create;
begin
  FConfigJson := '';
  FRetCode := '-1';
end;

function TMTOrderPageAnswer.GetArrayFromJson: TArray<TMTOrder>;
var
  LOrdersJsonArray: TJsonArray;
  I: Integer;
begin
  LOrdersJsonArray := TJsonObject.ParseJSONValue(ConfigJson) as TJsonArray;
  for I := 0 to LOrdersJsonArray.Count - 1 do
    Result := Result + [TMTOrderJson.GetFromJson(TJsonObject(LOrdersJsonArray.Items[I]))];
end;

procedure TMTOrderPageAnswer.SetConfigJson(const Value: string);
begin
  FConfigJson := Value;
end;

procedure TMTOrderPageAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

{ TMTOrderAnswer }

constructor TMTOrderAnswer.Create;
begin
  FConfigJson := '';
  FRetCode := '-1';
end;

function TMTOrderAnswer.GetFromJson: TMTOrder;
begin
  Result := TMTOrderJson.GetFromJson(TJsonObject.ParseJSONValue(ConfigJson) as TJsonObject);
end;

procedure TMTOrderAnswer.SetConfigJson(const Value: string);
begin
  FConfigJson := Value;
end;

procedure TMTOrderAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

{ TMTOrderJson }

class function TMTOrderJson.GetFromJson(AJsonObject: TJsonObject): TMTOrder;
var
  LOrder: TMTOrder;
  LVolumeInitialExt: Int64;
  LVolumeCurrentExt: Int64;
begin
  LOrder := TMTOrder.Create;

  LOrder.Order := AJsonObject.GetValue<Int64>('Order');
  LOrder.ExternalID := AJsonObject.GetValue<string>('ExternalID');
  LOrder.Login := AJsonObject.GetValue<Int64>('Login');
  LOrder.Dealer := AJsonObject.GetValue<Int64>('Dealer');
  LOrder.Symbol := AJsonObject.GetValue<string>('Symbol');
  LOrder.Digits := AJsonObject.GetValue<Int64>('Digits');
  LOrder.DigitsCurrency := AJsonObject.GetValue<Int64>('DigitsCurrency');
  LOrder.ContractSize := AJsonObject.GetValue<Single>('ContractSize');
  LOrder.State := TMTEnOrderState(AJsonObject.GetValue<Int64>('State'));
  LOrder.Reason := TMTEnOrderReason(AJsonObject.GetValue<Int64>('Reason'));
  LOrder.TimeSetup := AJsonObject.GetValue<Int64>('TimeSetup');
  LOrder.TimeExpiration := AJsonObject.GetValue<Int64>('TimeExpiration');
  LOrder.TimeDone := AJsonObject.GetValue<Int64>('TimeDone');
  LOrder.TimeSetupMsc := AJsonObject.GetValue<Int64>('TimeSetupMsc');
  LOrder.TimeDoneMsc := AJsonObject.GetValue<Int64>('TimeDoneMsc');
  LOrder.ModifyFlags := TMTEnOrderTradeModifyFlags(AJsonObject.GetValue<Integer>('ModifyFlags'));
  LOrder.&Type := TMTEnOrderType(AJsonObject.GetValue<Int64>('Type'));
  LOrder.TypeFill := TMTEnOrderFilling(AJsonObject.GetValue<Int64>('TypeFill'));
  LOrder.TypeTime := TMTEnOrderTime(AJsonObject.GetValue<Int64>('TypeTime'));
  LOrder.PriceOrder := AJsonObject.GetValue<Single>('PriceOrder');
  LOrder.PriceTrigger := AJsonObject.GetValue<Single>('PriceTrigger');
  LOrder.PriceCurrent := AJsonObject.GetValue<Single>('PriceCurrent');
  LOrder.PriceSL := AJsonObject.GetValue<Single>('PriceSL');
  LOrder.PriceTP := AJsonObject.GetValue<Single>('PriceTP');
  LOrder.VolumeInitial := AJsonObject.GetValue<Int64>('VolumeInitial');
  if AJsonObject.TryGetValue<Int64>('VolumeInitialExt', LVolumeInitialExt) then
    LOrder.VolumeInitialExt := LVolumeInitialExt
  else
    LOrder.VolumeInitialExt := TMTUtils.ToNewVolume(LOrder.VolumeInitial);

  LOrder.VolumeCurrent := AJsonObject.GetValue<Int64>('VolumeCurrent');

  if AJsonObject.TryGetValue<Int64>('VolumeCurrentExt', LVolumeCurrentExt) then
    LOrder.VolumeCurrentExt := LVolumeCurrentExt
  else
    LOrder.VolumeCurrentExt := TMTUtils.ToNewVolume(LOrder.VolumeCurrent);

  LOrder.ExpertID := AJsonObject.GetValue<Single>('ExpertID');
  LOrder.ExpertPositionID := AJsonObject.GetValue<Single>('PositionID');
  LOrder.PositionByID := AJsonObject.GetValue<Single>('PositionByID');
  LOrder.Comment := AJsonObject.GetValue<string>('Comment');
  LOrder.ActivationMode := TMTEnOrderActivation(AJsonObject.GetValue<Integer>('ActivationMode'));
  LOrder.ActivationTime := AJsonObject.GetValue<Int64>('ActivationTime');
  LOrder.ActivationPrice := AJsonObject.GetValue<Single>('ActivationPrice');
  LOrder.ActivationFlags := TMTEnTradeActivationFlags(AJsonObject.GetValue<Integer>('ActivationFlags'));

  Result := LOrder;
end;

{ TMTOrderProtocol }

constructor TMTOrderProtocol.Create(AConnect: TMTConnect);
begin
  FMTConnect := AConnect;
end;

function TMTOrderProtocol.OrderGet(ATicket: string; out AOrder: TMTOrder): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LOrderAnswer: TMTOrderAnswer;
begin
  LData := [
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TICKET, ATicket)
    ];

  if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_ORDER_GET, LData) then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswer := FMTConnect.Read(True);

  if Length(LAnswer) = 0 then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswerString := TMTUtils.GetString(LAnswer);

  LRetCodeType := ParseOrder(TMTProtocolConsts.WEB_CMD_ORDER_GET, LAnswerString, LOrderAnswer);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  AOrder := LOrderAnswer.GetFromJson;

  Exit(TMTRetCodeType.MT_RET_OK);

end;

function TMTOrderProtocol.OrderGetPage(ALogin, AOffset, ATotal: Integer; out AOrdersCollection: TArray<TMTOrder>): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LOrderPageAnswer: TMTOrderPageAnswer;
begin
  try
    LData := [
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_LOGIN, ALogin.ToString),
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_OFFSET, AOffset.ToString),
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TOTAL, AOffset.ToString)
      ];

    if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_ORDER_GET_PAGE, LData) then
      Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

    LAnswer := FMTConnect.Read(True);

    if Length(LAnswer) = 0 then
      Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

    LAnswerString := TMTUtils.GetString(LAnswer);

    LRetCodeType := ParseOrderPage(LAnswerString, LOrderPageAnswer);

    if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
      Exit(LRetCodeType);

    AOrdersCollection := LOrderPageAnswer.GetArrayFromJson;

    Exit(TMTRetCodeType.MT_RET_OK);
  finally
    if LOrderPageAnswer <> nil then
      LOrderPageAnswer.Free;
  end;
end;

function TMTOrderProtocol.OrderGetTotal(ALogin: Integer; out ATotal: Integer): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LOrderTotalAnswer: TMTOrderTotalAnswer;
begin
  ATotal := 0;
  LData := [
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_LOGIN, ALogin.ToString)
    ];

  if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_ORDER_GET_TOTAL, LData) then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswer := FMTConnect.Read(True);

  if Length(LAnswer) = 0 then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswerString := TMTUtils.GetString(LAnswer);

  LRetCodeType := ParseOrderTotal(LAnswerString, LOrderTotalAnswer);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  ATotal := LOrderTotalAnswer.Total;

  Exit(TMTRetCodeType.MT_RET_OK);

end;

function TMTOrderProtocol.ParseOrder(ACommand: string; AAnswer: string; out AOrderAnswer: TMTOrderAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
  LJsonDataString: string;
begin
  LPos := 0;
  AOrderAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> ACommand) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  AOrderAnswer := TMTOrderAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
    begin
      AOrderAnswer.RetCode := LParam.Value;
      Break;
    end;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;
  if LParam <> nil then
    FreeAndNil(LParam);

  LRetCodeType := TMTParseProtocol.GetRetCode(AOrderAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  LJsonDataString := TMTParseProtocol.GetJson(AAnswer, LPosEnd);

  if LJsonDataString = EmptyStr then
    Exit(TMTRetCodeType.MT_RET_REPORT_NODATA);

  AOrderAnswer.ConfigJson := LJsonDataString;

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTOrderProtocol.ParseOrderPage(AAnswer: string; out AOrderPageAnswer: TMTOrderPageAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
  LJsonDataString: string;
begin
  LPos := 0;
  AOrderPageAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> TMTProtocolConsts.WEB_CMD_ORDER_GET_PAGE) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  AOrderPageAnswer := TMTOrderPageAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
    begin
      AOrderPageAnswer.RetCode := LParam.Value;
      Break;
    end;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;
  if LParam <> nil then
    FreeAndNil(LParam);

  LRetCodeType := TMTParseProtocol.GetRetCode(AOrderPageAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  LJsonDataString := TMTParseProtocol.GetJson(AAnswer, LPosEnd);

  if LJsonDataString = EmptyStr then
    Exit(TMTRetCodeType.MT_RET_REPORT_NODATA);

  AOrderPageAnswer.ConfigJson := LJsonDataString;

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTOrderProtocol.ParseOrderTotal(AAnswer: string; out AOrderTotalAnswer: TMTOrderTotalAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
begin
  LPos := 0;
  AOrderTotalAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> TMTProtocolConsts.WEB_CMD_ORDER_GET_TOTAL) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  AOrderTotalAnswer := TMTOrderTotalAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
      AOrderTotalAnswer.RetCode := LParam.Value;
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_TOTAL then
      AOrderTotalAnswer.Total := LParam.Value.ToInteger;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;

  LRetCodeType := TMTParseProtocol.GetRetCode(AOrderTotalAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  Exit(TMTRetCodeType.MT_RET_OK);
end;

end.
