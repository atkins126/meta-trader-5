unit MT5.Auth;

interface

uses
  System.SysUtils, System.StrUtils, System.Classes,
  MT5.Types, MT5.Utils, MT5.Connect, MT5.ParseProtocol,
  MT5.RetCode, MT5.Protocol, MT5.Defines, MT5.BaseAnswer;

type

  TMTAuthAnswer = class
  private
    FCliRand: string;
    FRetCode: string;
    FCryptRand: string;
    procedure SetCliRand(const Value: string);
    procedure SetCryptRand(const Value: string);
    procedure SetRetCode(const Value: string);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    property RetCode: string read FRetCode write SetRetCode;
    property CliRand: string read FCliRand write SetCliRand;
    property CryptRand: string read FCryptRand write SetCryptRand;
  end;

  TMTAuthStartAnswer = class
  private
    FRetCode: string;
    FSrvRand: string;
    procedure SetRetCode(const Value: string);
    procedure SetSrvRand(const Value: string);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    property RetCode: string read FRetCode write SetRetCode;
    property SrvRand: string read FSrvRand write SetSrvRand;
    procedure MTAuthStartAnswer;
  end;

  TMTAuthProtocol = class
  private
    { private declarations }
    FMTConnect: TMTConnect;
    FAgent: string;
    function ParseAuthStart(AAnswer: string; out AAuthStartAnswer: TMTAuthStartAnswer): TMTRetCodeType;
    function ParseAuthAnswer(AAnswer: string; out AAuthAnswer: TMTAuthAnswer; out AError: string): TMTRetCodeType;
  protected
    { protected declarations }
    function SendAuthStart(ALogin: string; AIsCrypt: Boolean; out AAuthAnswer: TMTAuthStartAnswer): TMTRetCodeType;
    function SendAuthAnswer(AHash, ARandomCliCode: TArray<Byte>; out AAuthAnswer: TMTAuthAnswer): TMTRetCodeType;
  public
    { public declarations }
    constructor Create(AConnect: TMTConnect; AAgent: string);
    function Auth(ALogin: string; APassword: string; AIsCrypt: Boolean; out ACryptRand: string): TMTRetCodeType;
  end;

implementation

{ TMTAuthProtocol }

function TMTAuthProtocol.Auth(ALogin, APassword: string; AIsCrypt: Boolean; out ACryptRand: string): TMTRetCodeType;
var
  LConnectionCode: TMTRetCodeType;
  LAuthAnswerCode: TMTRetCodeType;
  LAuthStartAnswer: TMTAuthStartAnswer;
  LMTAuthAnswer: TMTAuthAnswer;
  LRandCode: TArray<Byte>;
  LRandomCliCode: TArray<Byte>;
  LHash: TArray<Byte>;
  LHashPassword: TArray<Byte>;
begin
  LMTAuthAnswer := nil;
  LAuthStartAnswer := nil;
  try
    LConnectionCode := SendAuthStart(ALogin, AIsCrypt, LAuthStartAnswer);
    if LConnectionCode <> TMTRetCodeType.MT_RET_OK then
      Exit(LConnectionCode);

    LRandCode := TMTUtils.GetFromHex(LAuthStartAnswer.SrvRand);
    LRandomCliCode := TMTUtils.GetRandomHex(16);
    LHash := TMTUtils.GetHashFromPassword(APassword, LRandCode);

    LAuthAnswerCode := SendAuthAnswer(LHash, LRandomCliCode, LMTAuthAnswer);

    if LAuthAnswerCode <> TMTRetCodeType.MT_RET_OK then
      Exit(LAuthAnswerCode);

    LHashPassword := TMTUtils.GetHashFromPassword(APassword, LRandomCliCode);

    if not TMTUtils.CompareBytes(LHashPassword, TMTUtils.GetFromHex(LMTAuthAnswer.CliRand)) then
      Exit(TMTRetCodeType.MT_RET_AUTH_SERVER_BAD);

    ACryptRand := LMTAuthAnswer.CryptRand;
    Exit(TMTRetCodeType.MT_RET_OK);
  finally
    if LMTAuthAnswer <> nil then
      FreeAndNil(LMTAuthAnswer);
    if LAuthStartAnswer <> nil then
      FreeAndNil(LAuthStartAnswer);
  end;
end;

constructor TMTAuthProtocol.Create(AConnect: TMTConnect; AAgent: string);
begin
  FMTConnect := AConnect;
  FAgent := AAgent;
end;

function TMTAuthProtocol.ParseAuthAnswer(AAnswer: string; out AAuthAnswer: TMTAuthAnswer; out AError: string): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommand: string;
  LParam: TMTAnswerParam;
  lMTRetCodeTypeRetCode: TMTRetCodeType;
begin
  LPos := 0;
  AAuthAnswer := nil;

  LCommand := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommand <> TMTProtocolConsts.WEB_CMD_AUTH_ANSWER) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  AAuthAnswer := TMTAuthAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
      AAuthAnswer.RetCode := LParam.Value;
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_CLI_RAND_ANSWER then
      AAuthAnswer.CliRand := LParam.Value;
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_CRYPT_RAND then
      AAuthAnswer.CryptRand := LParam.Value;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;

  lMTRetCodeTypeRetCode := TMTParseProtocol.GetRetCode(AAuthAnswer.RetCode);

  if lMTRetCodeTypeRetCode <> TMTRetCodeType.MT_RET_OK then
    Exit(lMTRetCodeTypeRetCode);

  if (AAuthAnswer.CliRand.IsEmpty) or (AAuthAnswer.CliRand = 'none') then
    Exit(TMTRetCodeType.MT_RET_ERR_PARAMS);

  Exit(TMTRetCodeType.MT_RET_OK)
end;

function TMTAuthProtocol.ParseAuthStart(AAnswer: string; out AAuthStartAnswer: TMTAuthStartAnswer): TMTRetCodeType;
var
  LPos: Integer;
  LPosEnd: Integer;
  LCommand: string;
  LParam: TMTAnswerParam;
  lMTRetCodeTypeRetCode: TMTRetCodeType;
begin
  LPos := 0;
  AAuthStartAnswer := nil;

  LCommand := TMTParseProtocol.GetCommand(AAnswer, LPos);

  if (LCommand <> TMTProtocolConsts.WEB_CMD_AUTH_START) then
    Exit(TMTRetCodeType.MT_RET_ERR_DATA);

  AAuthStartAnswer := TMTAuthStartAnswer.Create;

  LPosEnd := -1;

  LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  while LParam <> nil do
  begin
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_RETCODE then
      AAuthStartAnswer.RetCode := LParam.Value;
    if LParam.Name = TMTProtocolConsts.WEB_PARAM_SRV_RAND then
      AAuthStartAnswer.SrvRand := LParam.Value;
    FreeAndNil(LParam);
    LParam := TMTParseProtocol.GetNextParam(AAnswer, LPos, LPosEnd);
  end;

  lMTRetCodeTypeRetCode := TMTParseProtocol.GetRetCode(AAuthStartAnswer.RetCode);

  if lMTRetCodeTypeRetCode <> TMTRetCodeType.MT_RET_OK then
    Exit(lMTRetCodeTypeRetCode);

  if (AAuthStartAnswer.SrvRand.IsEmpty) or (AAuthStartAnswer.SrvRand = 'none') then
    Exit(TMTRetCodeType.MT_RET_ERR_PARAMS);

  Exit(TMTRetCodeType.MT_RET_OK)
end;

function TMTAuthProtocol.SendAuthAnswer(AHash, ARandomCliCode: TArray<Byte>; out AAuthAnswer: TMTAuthAnswer): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LParseAuthAnswerCodeType: TMTRetCodeType;
  LError: string;
begin
  AAuthAnswer := nil;
  LData := [
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_SRV_RAND_ANSWER, TMTUtils.GetHex(AHash)),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_CLI_RAND, TMTUtils.GetHex(ARandomCliCode))
    ];
  if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_AUTH_ANSWER, LData) then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswer := FMTConnect.Read(True);

  if Length(LAnswer) = 0 then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswerString := TMTUtils.GetString(LAnswer);

  LParseAuthAnswerCodeType := ParseAuthAnswer(LAnswerString, AAuthAnswer, LError);

  if LParseAuthAnswerCodeType <> TMTRetCodeType.MT_RET_OK then
    Exit(LParseAuthAnswerCodeType);

  Exit(TMTRetCodeType.MT_RET_OK);
end;

function TMTAuthProtocol.SendAuthStart(ALogin: string; AIsCrypt: Boolean; out AAuthAnswer: TMTAuthStartAnswer): TMTRetCodeType;
var
  LData: TArray<TMTQuery>;
  LAnswer: TArray<Byte>;
  LAnswerString: string;
  LParseAuthStartResult: TMTRetCodeType;
begin
  AAuthAnswer := nil;
  LData := [
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_VERSION, WEB_API_VERSION),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_AGENT, FAgent),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_LOGIN, ALogin),
    TMTQuery.Create(TMTProtocolConsts.WEB_PARAM_TYPE, 'MANAGER'),
    TMTQuery.Create(
    TMTProtocolConsts.WEB_PARAM_CRYPT_METHOD,
    IfThen(
    AIsCrypt,
    TMTProtocolConsts.WEB_VAL_CRYPT_AES256OFB,
    TMTProtocolConsts.WEB_VAL_CRYPT_NONE
    )
    )
    ];
  if not FMTConnect.Send(TMTProtocolConsts.WEB_CMD_AUTH_START, LData, True) then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswer := FMTConnect.Read(True);

  if Length(LAnswer) = 0 then
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK);

  LAnswerString := TMTUtils.GetString(LAnswer);

  LParseAuthStartResult := ParseAuthStart(LAnswerString, AAuthAnswer);

  if LParseAuthStartResult <> TMTRetCodeType.MT_RET_OK then
    Exit(LParseAuthStartResult);

  Result := TMTRetCodeType.MT_RET_OK;

end;

{ TMTAuthStartAnswer }

procedure TMTAuthStartAnswer.MTAuthStartAnswer;
begin
  FRetCode := '-1';
  FSrvRand := 'none';
end;

procedure TMTAuthStartAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

procedure TMTAuthStartAnswer.SetSrvRand(const Value: string);
begin
  FSrvRand := Value;
end;

{ TMTAuthAnswer }

procedure TMTAuthAnswer.SetCliRand(const Value: string);
begin
  FCliRand := Value;
end;

procedure TMTAuthAnswer.SetCryptRand(const Value: string);
begin
  FCryptRand := Value;
end;

procedure TMTAuthAnswer.SetRetCode(const Value: string);
begin
  FRetCode := Value;
end;

end.
