unit MT5.History;

interface

uses
  System.SysUtils, System.JSON, REST.JSON,
  System.Generics.Collections,
  MT5.Connect, MT5.RetCode, MT5.Order;

type

  TMTHistoryProtocol = class;
  TMTHistoryTotalAnswer = class;
  TMTHistoryPageAnswer = class;
  TMTHistoryAnswer = class;

  TMTHistoryProtocol = class
  private
    { private declarations }
    FMTConnect: TMTConnect;
    function ParseHistory(ACommand: string; AAnswer: string; out AHistoryAnswer: TMTHistoryAnswer): TMTRetCodeType;
    function ParseHistoryPage(AAnswer: string; out AHistoryPageAnswer: TMTHistoryPageAnswer): TMTRetCodeType;
    function ParseHistoryTotal(AAnswer: string; out AHistoryTotalAnswer: TMTHistoryTotalAnswer): TMTRetCodeType;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(AConnect: TMTConnect);
    function HistoryGet(ATicket: string; out AHistory: TMTOrder): TMTRetCodeType;
    function HistoryGetPage(ALogin, AFrom, ATo, AOffset, ATotal: Integer; out AHistorysCollection: TArray<TMTOrder>): TMTRetCodeType;
    function HistoryGetTotal(ALogin, AFrom, ATo: Integer; out ATotal: Integer): TMTRetCodeType;
  end;

  TMTHistoryTotalAnswer = class
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

  TMTHistoryPageAnswer = class
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

  TMTHistoryAnswer = class
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

implementation

uses
  MT5.Types, MT5.Protocol, MT5.Utils, MT5.BaseAnswer, MT5.ParseProtocol,
  System.Classes;

{ TMTHistoryTotalAnswer }

constructor TMTHistoryTotalAnswer.Create;
begin
  FRetCode := '-1';
  FTotal := 0;
end;

procedure TMTHistoryTotalAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

procedure TMTHistoryTotalAnswer.SetTotal(const Value: Integer);
begin
  FTotal := Value;
end;

{ TMTHistoryPageAnswer }

constructor TMTHistoryPageAnswer.Create;
begin
  FConfigJson := '';
  FRetCode := '-1';
end;

function TMTHistoryPageAnswer.GetArrayFromJson: TArray<TMTOrder>;
var
  LHistorysJsonArray: TJsonArray;
  I: Integer;
begin
  LHistorysJsonArray := TJsonObject.ParseJSONValue(ConfigJson) as TJsonArray;
  try
    for I := 0 to LHistorysJsonArray.Count - 1 do
      Result := Result + [TMTOrderJson.GetFromJson(TJsonObject(LHistorysJsonArray.Items[I]))];
  finally
    LHistorysJsonArray.Free;
  end;
end;

procedure TMTHistoryPageAnswer.SetConfigJson(const Value: string);
begin
  FConfigJson := Value;
end;

procedure TMTHistoryPageAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

{ TMTHistoryAnswer }

constructor TMTHistoryAnswer.Create;
begin
  FConfigJson := '';
  FRetCode := '-1';
end;

function TMTHistoryAnswer.GetFromJson: TMTOrder;
begin
  Result := TMTOrderJson.GetFromJson(TJsonObject.ParseJSONValue(ConfigJson) as TJsonObject);
end;

procedure TMTHistoryAnswer.SetConfigJson(const Value: string);
begin
  FConfigJson := Value;
end;

procedure TMTHistoryAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

{ TMTHistoryProtocol }

constructor TMTHistoryProtocol.Create(AConnect: TMTConnect);
begin
  FMTConnect := AConnect;
end;

function TMTHistoryProtocol.HistoryGet(ATicket: string; out AHistory: TMTOrder): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LHistoryAnswer: TMTHistoryAnswer;
begin
  try
    LData := [
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TICKET, ATicket)
      ];

    if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_HISTORY_GET, LData) then
      Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

    LAnswer := FMTConnect.Read(True);

    if Length(LAnswer) = 0 then
      Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

    LAnswerString := TMTUtils.GetString(LAnswer);

    LRetCodeType := ParseHistory(TMTProtocolConsts.WEB_CMD_HISTORY_GET, LAnswerString, LHistoryAnswer);

    if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
      Exit(LRetCodeType);

    AHistory := LHistoryAnswer.GetFromJson;

    Exit(TMTRetCodeType.MT_RET_OK);
  finally
    if LHistoryAnswer <> nil then
      LHistoryAnswer.Free;
  end;

end;

function TMTHistoryProtocol.HistoryGetPage(ALogin, AFrom, ATo, AOffset, ATotal: Integer; out AHistorysCollection: TArray<TMTOrder>): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LHistoryPageAnswer: TMTHistoryPageAnswer;
begin
  try
    LData := [
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_LOGIN, ALogin.ToString),
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_FROM, AFrom.ToString),
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TO, ATo.ToString),
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_OFFSET, AOffset.ToString),
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TOTAL, ATotal.ToString)
      ];

    if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_HISTORY_GET_PAGE, LData) then
      Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

    LAnswer := FMTConnect.Read(True);

    if Length(LAnswer) = 0 then
      Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

    LAnswerString := TMTUtils.GetString(LAnswer);

    LRetCodeType := ParseHistoryPage(LAnswerString, LHistoryPageAnswer);

    if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
      Exit(LRetCodeType);

    AHistorysCollection := LHistoryPageAnswer.GetArrayFromJson;

    Exit(TMTRetCodeType.MT_RET_OK);
  finally
    if LHistoryPageAnswer <> nil then
      LHistoryPageAnswer.Free;
  end;
end;

function TMTHistoryProtocol.HistoryGetTotal(ALogin, AFrom, ATo: Integer; out ATotal: Integer): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LRetCodeType: TMTRetCodeType;
  LHistoryTotalAnswer: TMTHistoryTotalAnswer;
begin
  try
    ATotal := 0;
    LData := [
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_LOGIN, ALogin.ToString),
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_FROM, AFrom.ToString),
      TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TO, ATo.ToString)
      ];

    if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_HISTORY_GET_TOTAL, LData) then
      Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

    LAnswer := FMTConnect.Read(True);

    if Length(LAnswer) = 0 then
      Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

    LAnswerString := TMTUtils.GetString(LAnswer);

    LRetCodeType := ParseHistoryTotal(LAnswerString, LHistoryTotalAnswer);

    if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
      Exit(LRetCodeType);

    ATotal := LHistoryTotalAnswer.Total;

    Exit(TMTRetCodeType.MT_RET_OK);
  finally
    if LHistoryTotalAnswer <> nil then
      LHistoryTotalAnswer.Free;
  end;

end;

function TMTHistoryProtocol.ParseHistory(ACommand: string; AAnswer: string; out AHistoryAnswer: TMTHistoryAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
  LJsonDataString: string;
begin
  LPos := 0;
  AHistoryAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> ACommand) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  AHistoryAnswer := TMTHistoryAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
    begin
      AHistoryAnswer.RetCode := LParam.Value;
      Break;
    end;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;
  if LParam <> nil then
    FreeAndNil(LParam);

  LRetCodeType := TMTParseProtocol.GetRetCode(AHistoryAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  LJsonDataString := TMTParseProtocol.GetJson(AAnswer, LPosEnd);

  if LJsonDataString = EmptyStr then
    Exit(TMTRetCodeType.MT_RET_REPORT_NODATA);

  AHistoryAnswer.ConfigJson := LJsonDataString;

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTHistoryProtocol.ParseHistoryPage(AAnswer: string; out AHistoryPageAnswer: TMTHistoryPageAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
  LJsonDataString: string;
begin
  LPos := 0;
  AHistoryPageAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> TMTProtocolConsts.WEB_CMD_HISTORY_GET_PAGE) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  AHistoryPageAnswer := TMTHistoryPageAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
    begin
      AHistoryPageAnswer.RetCode := LParam.Value;
      Break;
    end;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;
  if LParam <> nil then
    FreeAndNil(LParam);

  LRetCodeType := TMTParseProtocol.GetRetCode(AHistoryPageAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  LJsonDataString := TMTParseProtocol.GetJson(AAnswer, LPosEnd);

  if LJsonDataString = EmptyStr then
    Exit(TMTRetCodeType.MT_RET_REPORT_NODATA);

  AHistoryPageAnswer.ConfigJson := LJsonDataString;

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTHistoryProtocol.ParseHistoryTotal(AAnswer: string; out AHistoryTotalAnswer: TMTHistoryTotalAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommandReal: string;
  LParam: TMTAnswerParam;
  LRetCodeType: TMTRetCodeType;
begin
  LPos := 0;
  AHistoryTotalAnswer := nil;

  LCommandReal := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommandReal <> TMTProtocolConsts.WEB_CMD_HISTORY_GET_TOTAL) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  AHistoryTotalAnswer := TMTHistoryTotalAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
      AHistoryTotalAnswer.RetCode := LParam.Value;
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_TOTAL then
      AHistoryTotalAnswer.Total := LParam.Value.ToInteger;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;

  LRetCodeType := TMTParseProtocol.GetRetCode(AHistoryTotalAnswer.RetCode);

  if LRetCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LRetCodeType);

  Exit(TMTRetCodeType.MT_RET_OK);
end;

end.
