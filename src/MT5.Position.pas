unit MT5.Position;

interface

uses
  System.SysUtils, System.JSON, REST.JSON,
  System.Generics.Collections,
  MT5.Connect, MT5.RetCode;

type

  TMTPositionProtocol = class;
  TMTPosition = class;
  TMTPositionTotalAnswer = class;
  TMTPositionPageAnswer = class;
  TMTPositionAnswer = class;
  TMTPositionJson = class;

  TMTPositionProtocol = class
  private
    { private declarations }
    FMTConnect: TMTConnect;
  protected
    { protected declarations }
    function ParsePosition(ACommand: string; AAnswer: string; out APositionAnswer: TMTPositionAnswer): TMTRetCodeType;
    function ParsePositionPage(AAnswer: string; out APositionPageAnswer: TMTPositionPageAnswer): TMTRetCodeType;
    function ParsePositionTotal(AAnswer: string; out APositionTotalAnswer: TMTPositionTotalAnswer): TMTRetCodeType;
  public
    { public declarations }
    constructor Create(AConnect: TMTConnect);
    function PositionGet(ALogin: Integer; ASymbol: string; out APosition: TMTPosition): TMTRetCodeType;
    function PositionGetPage(ALogin, AOffset, ATotal: Integer; out APositionsCollection: TArray<TMTPosition>): TMTRetCodeType;
    function PositionGetTotal(ALogin: Integer; out ATotal: Integer): TMTRetCodeType;

  end;

  TMTEnPositionAction = (
    POSITION_BUY = 0, // buy
    POSITION_SELL = 1, // sell
    // --- enumeration borders
    POSITION_FIRST = TMTEnPositionAction.POSITION_BUY,
    POSITION_LAST = TMTEnPositionAction.POSITION_SELL
    );

  TMTEnActivation = (
    ACTIVATION_NONE = 0, // none
    ACTIVATION_SL = 1, // SL activated
    ACTIVATION_TP = 2, // TP activated
    ACTIVATION_STOPOUT = 3, // Stop-Out activated
    // --- enumeration borders
    ACTIVATION_FIRST = TMTEnActivation.ACTIVATION_NONE,
    ACTIVATION_LAST = TMTEnActivation.ACTIVATION_STOPOUT
    );

  TMTEnPositionTradeActivationFlags = (
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

  TMTEnPositionReason = (
    POSITION_REASON_CLIENT = 0, // position placed manually
    POSITION_REASON_EXPERT = 1, // position placed by expert
    POSITION_REASON_DEALER = 2, // position placed by dealer
    POSITION_REASON_SL = 3, // position placed due SL
    POSITION_REASON_TP = 4, // position placed due TP
    POSITION_REASON_SO = 5, // position placed due Stop-Out
    POSITION_REASON_ROLLOVER = 6, // position placed due rollover
    POSITION_REASON_EXTERNAL_CLIENT = 7, // position placed from the external system by client
    POSITION_REASON_VMARGIN = 8, // position placed due variation margin
    POSITION_REASON_GATEWAY = 9, // position placed by gateway
    POSITION_REASON_SIGNAL = 10, // position placed by signal service
    POSITION_REASON_SETTLEMENT = 11, // position placed due settlement
    POSITION_REASON_TRANSFER = 12, // position placed due position transfer
    POSITION_REASON_SYNC = 13, // position placed due position synchronization
    POSITION_REASON_EXTERNAL_SERVICE = 14, // position placed from the external system due service issues
    POSITION_REASON_MIGRATION = 15, // position placed due migration
    POSITION_REASON_MOBILE = 16, // position placed by mobile terminal
    POSITION_REASON_WEB = 17, // position placed by web terminal
    POSITION_REASON_SPLIT = 18, // position placed due split
    // --- enumeration borders
    POSITION_REASON_FIRST = TMTEnPositionReason.POSITION_REASON_CLIENT,
    POSITION_REASON_LAST = TMTEnPositionReason.POSITION_REASON_SPLIT
    );

  TMTPositionEnTradeModifyFlags = (
    MODIFY_FLAGS_ADMIN = $01,
    MODIFY_FLAGS_MANAGER = $02,
    MODIFY_FLAGS_POSITION = $04,
    MODIFY_FLAGS_RESTORE = $08,
    MODIFY_FLAGS_API_ADMIN = $10,
    MODIFY_FLAGS_API_MANAGER = $20,
    MODIFY_FLAGS_API_SERVER = $40,
    MODIFY_FLAGS_API_GATEWAY = $80,
    // --- enumeration borders
    MODIFY_FLAGS_NONE = $00,
    MODIFY_FLAGS_ALL = $FF
    );

  TMTPosition = class
  private
    FSymbol: string;
    FActivationMode: TMTEnActivation;
    FExternalID: string;
    FActivationPrice: Single;
    FRateMargin: Single;
    FPriceSL: Single;
    FComment: string;
    FExpertPositionID: Int64;
    FExpertID: Int64;
    FContractSize: Single;
    FRateProfit: Single;
    FPriceCurrent: Single;
    FTimeUpdate: Int64;
    FReason: TMTEnPositionReason;
    FActivationTime: Int64;
    FDealer: Int64;
    FDigitsCurrency: Int64;
    FVolumeExt: Int64;
    FDigits: Int64;
    FStorage: Single;
    FModifyFlags: TMTPositionEnTradeModifyFlags;
    FTimeCreate: Int64;
    FVolume: Int64;
    FPriceOpen: Single;
    FAction: Int64;
    FActivationFlags: TMTEnPositionTradeActivationFlags;
    FLogin: Int64;
    FPosition: Int64;
    FProfit: Single;
    FPriceTP: Single;
    procedure SetAction(const Value: Int64);
    procedure SetActivationFlags(const Value: TMTEnPositionTradeActivationFlags);
    procedure SetActivationMode(const Value: TMTEnActivation);
    procedure SetActivationPrice(const Value: Single);
    procedure SetActivationTime(const Value: Int64);
    procedure SetComment(const Value: string);
    procedure SetContractSize(const Value: Single);
    procedure SetDealer(const Value: Int64);
    procedure SetDigits(const Value: Int64);
    procedure SetDigitsCurrency(const Value: Int64);
    procedure SetExpertID(const Value: Int64);
    procedure SetExpertPositionID(const Value: Int64);
    procedure SetExternalID(const Value: string);
    procedure SetLogin(const Value: Int64);
    procedure SetModifyFlags(const Value: TMTPositionEnTradeModifyFlags);
    procedure SetPosition(const Value: Int64);
    procedure SetPriceCurrent(const Value: Single);
    procedure SetPriceOpen(const Value: Single);
    procedure SetPriceSL(const Value: Single);
    procedure SetPriceTP(const Value: Single);
    procedure SetProfit(const Value: Single);
    procedure SetRateMargin(const Value: Single);
    procedure SetRateProfit(const Value: Single);
    procedure SetReason(const Value: TMTEnPositionReason);
    procedure SetStorage(const Value: Single);
    procedure SetSymbol(const Value: string);
    procedure SetTimeCreate(const Value: Int64);
    procedure SetTimeUpdate(const Value: Int64);
    procedure SetVolume(const Value: Int64);
    procedure SetVolumeExt(const Value: Int64);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    // --- position ticket
    property Position: Int64 read FPosition write SetPosition;
    // --- position ticket in external system (exchange, ECN, etc)
    property ExternalID: string read FExternalID write SetExternalID;
    // --- owner client login
    property Login: Int64 read FLogin write SetLogin;
    // --- processed dealer login (0-means auto) (first position deal dealer)
    property Dealer: Int64 read FDealer write SetDealer;
    // --- position symbol
    property Symbol: string read FSymbol write SetSymbol;
    // --- MTEnPositionAction
    property Action: Int64 read FAction write SetAction;
    // --- price digits
    property Digits: Int64 read FDigits write SetDigits;
    // --- currency digits
    property DigitsCurrency: Int64 read FDigitsCurrency write SetDigitsCurrency;
    // --- position reason (type is MTEnPositionReason)
    property Reason: TMTEnPositionReason read FReason write SetReason;
    // --- symbol contract size
    property ContractSize: Single read FContractSize write SetContractSize;
    // --- position create time
    property TimeCreate: Int64 read FTimeCreate write SetTimeCreate;
    // --- position last update time
    property TimeUpdate: Int64 read FTimeUpdate write SetTimeUpdate;
    // --- modification flags (type is MTPositionEnTradeModifyFlags)
    property ModifyFlags: TMTPositionEnTradeModifyFlags read FModifyFlags write SetModifyFlags;
    // --- position weighted average open price
    property PriceOpen: Single read FPriceOpen write SetPriceOpen;
    // --- position current price
    property PriceCurrent: Single read FPriceCurrent write SetPriceCurrent;
    // --- position SL price
    property PriceSL: Single read FPriceSL write SetPriceSL;
    // --- position TP price
    property PriceTP: Single read FPriceTP write SetPriceTP;
    // --- position volume
    property Volume: Int64 read FVolume write SetVolume;
    // --- position volume
    property VolumeExt: Int64 read FVolumeExt write SetVolumeExt;
    // --- position floating profit
    property Profit: Single read FProfit write SetProfit;
    // --- position accumulated swaps
    property Storage: Single read FStorage write SetStorage;
    // --- profit conversion rate (from symbol profit currency to deposit currency)
    property RateProfit: Single read FRateProfit write SetRateProfit;
    // --- margin conversion rate (from symbol margin currency to deposit currency)
    property RateMargin: Single read FRateMargin write SetRateMargin;
    // --- expert id (filled by expert advisor)
    property ExpertID: Int64 read FExpertID write SetExpertID;
    // --- expert position id (filled by expert advisor)
    property ExpertPositionID: Int64 read FExpertPositionID write SetExpertPositionID;
    // --- comment
    property Comment: string read FComment write SetComment;
    // --- order activation state (type is MTEnActivation)
    property ActivationMode: TMTEnActivation read FActivationMode write SetActivationMode;
    // --- order activation time
    property ActivationTime: Int64 read FActivationTime write SetActivationTime;
    // --- order activation price
    property ActivationPrice: Single read FActivationPrice write SetActivationPrice;
    // --- order activation flags (type is MTEnPositionTradeActivationFlags)
    property ActivationFlags: TMTEnPositionTradeActivationFlags read FActivationFlags write SetActivationFlags;
  end;

  TMTPositionTotalAnswer = class
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

  TMTPositionPageAnswer = class
  private
    FRetCode: string;
    FConfigJson: string;
    procedure SetRetCode(const Value: string);
    procedure SetConfigJson(const Value: string);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create; virtual;
    property RetCode: string read FRetCode write SetRetCode;
    property ConfigJson: string read FConfigJson write SetConfigJson;
    function GetArrayFromJson: TArray<TMTPosition>;
  end;

  TMTPositionAnswer = class
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
    function GetFromJson: TMTPosition;
  end;

  TMTPositionJson = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class function GetFromJson(AJsonObject: TJsonObject): TMTPosition;
  end;

implementation

uses
  MT5.Types, MT5.Protocol, MT5.Utils, MT5.BaseAnswer, MT5.ParseProtocol;

{ TMTPositionProtocol }

constructor TMTPositionProtocol.Create(AConnect: TMTConnect);
begin
  FMTConnect := AConnect;
end;

function TMTPositionProtocol.ParsePosition(ACommand, AAnswer: string; out APositionAnswer: TMTPositionAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
  LJsonDataString: string;
begin
  LPos := 0;
  APositionAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> ACommand) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  APositionAnswer := TMTPositionAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
    begin
      APositionAnswer.RetCode := LParam.Value;
      Break;
    end;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;
  if LParam <> nil then
    FreeAndNil(LParam);

  LRetCodeType := TMTParseProtocol.GetRetCode(APositionAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  LJsonDataString := TMTParseProtocol.GetJson(AAnswer, LPosEnd);

  if LJsonDataString = EmptyStr then
    Exit(TMTRetCodeType.MT_RET_REPORT_NODATA);

  APositionAnswer.ConfigJson := LJsonDataString;

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTPositionProtocol.ParsePositionPage(AAnswer: string; out APositionPageAnswer: TMTPositionPageAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
  LJsonDataString: string;
begin
  LPos := 0;
  APositionPageAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> TMTProtocolConsts.WEB_CMD_POSITION_GET_PAGE) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  APositionPageAnswer := TMTPositionPageAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
    begin
      APositionPageAnswer.RetCode := LParam.Value;
      Break;
    end;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;
  if LParam <> nil then
    FreeAndNil(LParam);

  LRetCodeType := TMTParseProtocol.GetRetCode(APositionPageAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  LJsonDataString := TMTParseProtocol.GetJson(AAnswer, LPosEnd);

  if LJsonDataString = EmptyStr then
    Exit(TMTRetCodeType.MT_RET_REPORT_NODATA);

  APositionPageAnswer.ConfigJson := LJsonDataString;

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTPositionProtocol.ParsePositionTotal(AAnswer: string; out APositionTotalAnswer: TMTPositionTotalAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
begin
  LPos := 0;
  APositionTotalAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> TMTProtocolConsts.WEB_CMD_POSITION_GET_TOTAL) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  APositionTotalAnswer := TMTPositionTotalAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
      APositionTotalAnswer.RetCode := LParam.Value;
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_TOTAL then
      APositionTotalAnswer.Total := LParam.Value.ToInteger;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;

  LRetCodeType := TMTParseProtocol.GetRetCode(APositionTotalAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTPositionProtocol.PositionGet(ALogin: Integer; ASymbol: string; out APosition: TMTPosition): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LPositionAnswer: TMTPositionAnswer;
begin
  LData := [
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_LOGIN, ALogin.ToString),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_SYMBOL, ASymbol)
  ];

  if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_POSITION_GET, LData) then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswer := FMTConnect.Read(True);

  if Length(LAnswer) = 0 then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswerString := TMTUtils.GetString(LAnswer);

  LRetCodeType := ParsePosition(TMTProtocolConsts.WEB_CMD_POSITION_GET, LAnswerString, LPositionAnswer);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  APosition := LPositionAnswer.GetFromJson;

  Exit(TMTRetCodeType.MT_RET_OK);

end;

function TMTPositionProtocol.PositionGetPage(ALogin, AOffset, ATotal: Integer; out APositionsCollection: TArray<TMTPosition>): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LPositionPageAnswer: TMTPositionPageAnswer;
begin
  LData := [
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_LOGIN, ALogin.ToString),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_OFFSET, AOffset.ToString),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TOTAL, AOffset.ToString)
    ];

  if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_POSITION_GET_PAGE, LData) then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswer := FMTConnect.Read(True);

  if Length(LAnswer) = 0 then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswerString := TMTUtils.GetString(LAnswer);

  LRetCodeType := ParsePositionPage(LAnswerString, LPositionPageAnswer);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  APositionsCollection := LPositionPageAnswer.GetArrayFromJson;

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTPositionProtocol.PositionGetTotal(ALogin: Integer; out ATotal: Integer): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LPositionTotalAnswer: TMTPositionTotalAnswer;
begin
  ATotal := 0;
  LData := [
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_LOGIN, ALogin.ToString)
    ];

  if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_POSITION_GET_TOTAL, LData) then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswer := FMTConnect.Read(True);

  if Length(LAnswer) = 0 then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswerString := TMTUtils.GetString(LAnswer);

  LRetCodeType := ParsePositionTotal(LAnswerString, LPositionTotalAnswer);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  ATotal := LPositionTotalAnswer.Total;

  Exit(TMTRetCodeType.MT_RET_OK);

end;

{ TMTPosition }

procedure TMTPosition.SetAction(const Value: Int64);
begin
  FAction := Value;
end;

procedure TMTPosition.SetActivationFlags(const Value: TMTEnPositionTradeActivationFlags);
begin
  FActivationFlags := Value;
end;

procedure TMTPosition.SetActivationMode(const Value: TMTEnActivation);
begin
  FActivationMode := Value;
end;

procedure TMTPosition.SetActivationPrice(const Value: Single);
begin
  FActivationPrice := Value;
end;

procedure TMTPosition.SetActivationTime(const Value: Int64);
begin
  FActivationTime := Value;
end;

procedure TMTPosition.SetComment(const Value: string);
begin
  FComment := Value;
end;

procedure TMTPosition.SetContractSize(const Value: Single);
begin
  FContractSize := Value;
end;

procedure TMTPosition.SetDealer(const Value: Int64);
begin
  FDealer := Value;
end;

procedure TMTPosition.SetDigits(const Value: Int64);
begin
  FDigits := Value;
end;

procedure TMTPosition.SetDigitsCurrency(const Value: Int64);
begin
  FDigitsCurrency := Value;
end;

procedure TMTPosition.SetExpertID(const Value: Int64);
begin
  FExpertID := Value;
end;

procedure TMTPosition.SetExpertPositionID(const Value: Int64);
begin
  FExpertPositionID := Value;
end;

procedure TMTPosition.SetExternalID(const Value: string);
begin
  FExternalID := Value;
end;

procedure TMTPosition.SetLogin(const Value: Int64);
begin
  FLogin := Value;
end;

procedure TMTPosition.SetModifyFlags(const Value: TMTPositionEnTradeModifyFlags);
begin
  FModifyFlags := Value;
end;

procedure TMTPosition.SetPosition(const Value: Int64);
begin
  FPosition := Value;
end;

procedure TMTPosition.SetPriceCurrent(const Value: Single);
begin
  FPriceCurrent := Value;
end;

procedure TMTPosition.SetPriceOpen(const Value: Single);
begin
  FPriceOpen := Value;
end;

procedure TMTPosition.SetPriceSL(const Value: Single);
begin
  FPriceSL := Value;
end;

procedure TMTPosition.SetPriceTP(const Value: Single);
begin
  FPriceTP := Value;
end;

procedure TMTPosition.SetProfit(const Value: Single);
begin
  FProfit := Value;
end;

procedure TMTPosition.SetRateMargin(const Value: Single);
begin
  FRateMargin := Value;
end;

procedure TMTPosition.SetRateProfit(const Value: Single);
begin
  FRateProfit := Value;
end;

procedure TMTPosition.SetReason(const Value: TMTEnPositionReason);
begin
  FReason := Value;
end;

procedure TMTPosition.SetStorage(const Value: Single);
begin
  FStorage := Value;
end;

procedure TMTPosition.SetSymbol(const Value: string);
begin
  FSymbol := Value;
end;

procedure TMTPosition.SetTimeCreate(const Value: Int64);
begin
  FTimeCreate := Value;
end;

procedure TMTPosition.SetTimeUpdate(const Value: Int64);
begin
  FTimeUpdate := Value;
end;

procedure TMTPosition.SetVolume(const Value: Int64);
begin
  FVolume := Value;
end;

procedure TMTPosition.SetVolumeExt(const Value: Int64);
begin
  FVolumeExt := Value;
end;

{ TMTPositionTotalAnswer }

constructor TMTPositionTotalAnswer.Create;
begin
  FRetCode := '-1';
  FTotal := 0;
end;

procedure TMTPositionTotalAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

procedure TMTPositionTotalAnswer.SetTotal(const Value: Integer);
begin
  FTotal := Value;
end;

{ TMTPositionPageAnswer }

constructor TMTPositionPageAnswer.Create;
begin
  FRetCode := '-1';
  FConfigJson := '';
end;

function TMTPositionPageAnswer.GetArrayFromJson: TArray<TMTPosition>;
var
  LPositionsJsonArray: TJsonArray;
  I: Integer;
begin
  LPositionsJsonArray := TJsonObject.ParseJSONValue(ConfigJson) as TJsonArray;
  for I := 0 to LPositionsJsonArray.Count - 1 do
    Result := Result + [TMTPositionJson.GetFromJson(TJsonObject(LPositionsJsonArray.Items[I]))];
end;

procedure TMTPositionPageAnswer.SetConfigJson(const Value: string);
begin
  FConfigJson := Value;
end;

procedure TMTPositionPageAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

{ TMTPositionAnswer }

constructor TMTPositionAnswer.Create;
begin
  FConfigJson := '';
  FRetCode := '-1';
end;

function TMTPositionAnswer.GetFromJson: TMTPosition;
begin
  Result := TMTPositionJson.GetFromJson(TJsonObject.ParseJSONValue(ConfigJson) as TJsonObject);
end;

procedure TMTPositionAnswer.SetConfigJson(const Value: string);
begin
  FConfigJson := Value;
end;

procedure TMTPositionAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

{ TMTPositionJson }

class function TMTPositionJson.GetFromJson(AJsonObject: TJsonObject): TMTPosition;
var
  LPosition: TMTPosition;
  LVolumeExt: Int64;
begin
  LPosition := TMTPosition.Create;

  LPosition.Position := AJsonObject.GetValue<Integer>('Position');
  LPosition.ExternalID := AJsonObject.GetValue<string>('ExternalID');
  LPosition.Login := AJsonObject.GetValue<Integer>('Login');
  LPosition.Dealer := AJsonObject.GetValue<Integer>('Dealer');
  LPosition.Symbol := AJsonObject.GetValue<string>('Symbol');
  LPosition.Action := AJsonObject.GetValue<Integer>('Action');
  LPosition.Digits := AJsonObject.GetValue<Integer>('Digits');
  LPosition.DigitsCurrency := AJsonObject.GetValue<Integer>('DigitsCurrency');
  LPosition.Reason := TMTEnPositionReason(AJsonObject.GetValue<Integer>('Reason'));
  LPosition.ContractSize := AJsonObject.GetValue<Single>('ContractSize');
  LPosition.TimeCreate := AJsonObject.GetValue<Integer>('TimeCreate');
  LPosition.TimeUpdate := AJsonObject.GetValue<Integer>('TimeUpdate');
  LPosition.ModifyFlags := TMTPositionEnTradeModifyFlags(AJsonObject.GetValue<Integer>('ModifyFlags'));
  LPosition.PriceOpen := AJsonObject.GetValue<Single>('PriceOpen');
  LPosition.PriceCurrent := AJsonObject.GetValue<Single>('PriceCurrent');
  LPosition.PriceSL := AJsonObject.GetValue<Single>('PriceSL');
  LPosition.PriceTP := AJsonObject.GetValue<Single>('PriceTP');
  LPosition.Volume := AJsonObject.GetValue<Int64>('Volume');
  if AJsonObject.TryGetValue('VolumeExt', LVolumeExt) then
    LPosition.VolumeExt := AJsonObject.GetValue<Int64>('VolumeExt')
  else
    LPosition.VolumeExt := TMTUtils.ToNewVolume(LPosition.Volume);
  LPosition.Profit := AJsonObject.GetValue<Single>('Profit');
  LPosition.Storage := AJsonObject.GetValue<Single>('Storage');
  LPosition.RateProfit := AJsonObject.GetValue<Single>('RateProfit');
  LPosition.RateMargin := AJsonObject.GetValue<Single>('RateMargin');
  LPosition.ExpertID := AJsonObject.GetValue<Int64>('ExpertID');
  LPosition.ExpertPositionID := AJsonObject.GetValue<Int64>('ExpertPositionID');
  LPosition.Comment := AJsonObject.GetValue<string>('Comment');
  LPosition.ActivationMode := TMTEnActivation(AJsonObject.GetValue<Integer>('ActivationMode'));
  LPosition.ActivationTime := AJsonObject.GetValue<Integer>('ActivationTime');
  LPosition.ActivationPrice := AJsonObject.GetValue<Single>('ActivationPrice');
  LPosition.ActivationFlags := TMTEnPositionTradeActivationFlags(AJsonObject.GetValue<Integer>('ActivationFlags'));

  Result := LPosition;
end;

end.
