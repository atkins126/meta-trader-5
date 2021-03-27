unit MT5.Connect;

interface

uses
  System.SysUtils, System.Net.Socket, System.Types, System.Classes,
  MT5.Protocol, MT5.RetCode, MT5.Utils, MT5.Types, System.SyncObjs;

type

  TMTConnect = class
  private
    { private declarations }
  var
    FSocket: TSocket;
    FSocketRead: TSocket;
    FSocketWrite: TSocket;
    FSocketError: TSocket;
    FIPMT5: string;
    FPortMT5: Word;
    FTimeoutConnection: Integer;
    FCryptRand: string;
    FClientCommand: Integer;
    FIsCrypt: Boolean;
    FReadFDSet: PFDSet;
    FWriteFDSet: PFDSet;
    FErrorFDSet: PFDSet;
    FCriticalSection: TCriticalSection;
    FEvent: TEvent;
  const
    MAX_CLIENT_COMMAND = 16383;
    function CreateConnection: TMTRetCodeType;
    function ReadPacket(out AHeader: TMTHeaderProtocol): TArray<Byte>;
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(AIPMT5: string; APortMT5: Word; const ATimeoutConnection: Integer = 5; AIsCrypt: Boolean = True);
    destructor Destroy; override;
    function Connect: TMTRetCodeType;
    procedure Disconnect;
    function Send(ACommand: string; AData: TArray<TMTQuery>; const AFirstRequest: Boolean = False): Boolean;
    function Read(const AAuthPacket: Boolean = False; AIsBinary: Boolean = False): TArray<Byte>;
    procedure SetCryptRand(ACrypt, APassword: string);
  end;

implementation


{ TMTConnect }

function TMTConnect.Connect: TMTRetCodeType;
begin
  Result := CreateConnection;
end;

constructor TMTConnect.Create(AIPMT5: string; APortMT5: Word; const ATimeoutConnection: Integer; AIsCrypt: Boolean);
begin
  FCriticalSection := TCriticalSection.Create;
  FEvent := TEvent.Create;
  FIPMT5 := AIPMT5;
  FPortMT5 := APortMT5;
  FTimeoutConnection := ATimeoutConnection;
  FIsCrypt := AIsCrypt;
  FClientCommand := 0;
  FSocket := nil;
end;

function TMTConnect.CreateConnection: TMTRetCodeType;
begin
  try
    FSocket := TSocket.Create(TSocketType.TCP);
    FSocketRead := TSocket.Create(TSocketType.TCP);
    FSocketWrite := TSocket.Create(TSocketType.TCP);
    FSocketError := TSocket.Create(TSocketType.TCP);
  except
    Exit(TMTRetCodeType.MT_RET_ERR_NETWORK)
  end;

  try
    FSocket.Connect('', FIPMT5, '', FPortMT5);

    FSocketRead.Connect('', FIPMT5, '', FPortMT5);
    FSocketWrite.Connect('', FIPMT5, '', FPortMT5);
    FSocketError.Connect('', FIPMT5, '', FPortMT5);

    FReadFDSet := TFDSet.Create([FSocketRead]);
    FWriteFDSet := TFDSet.Create([FSocketWrite]);
    FErrorFDSet := TFDSet.Create([FSocketError]);

    case FSocket.Select(FReadFDSet, FWriteFDSet, FErrorFDSet, FTimeoutConnection) of
      TWaitResult.wrTimeout:
        Exit(TMTRetCodeType.MT_RET_ERR_TIMEOUT);
      TWaitResult.wrError:
        Exit(TMTRetCodeType.MT_RET_ERR_CONNECTION);
    end;
  except
    Exit(TMTRetCodeType.MT_RET_ERR_CONNECTION)
  end;

  Exit(TMTRetCodeType.MT_RET_OK)

end;

destructor TMTConnect.Destroy;
begin
  FCriticalSection.Free;
  FEvent.SetEvent;
  FreeAndNil(FEvent);
  if FSocketRead <> nil then
    FreeAndNil(FSocketRead);
  if FSocketWrite <> nil then
    FreeAndNil(FSocketWrite);
  if FSocketError <> nil then
    FreeAndNil(FSocketError);
  if FSocket <> nil then
    FreeAndNil(FSocket);
  inherited;
end;

procedure TMTConnect.Disconnect;
begin
  if not Assigned(FSocket) then
    Exit;
  if not(TSocketState.Connected in FSocket.State) then
    Exit;

  FSocket.Close;
end;

function TMTConnect.Read(const AAuthPacket: Boolean; AIsBinary: Boolean): TArray<Byte>;
var
  LData: TArray<Byte>;
  LHeader: TMTHeaderProtocol;
begin
  if not Assigned(FSocket) then
    Exit();
  if not(TSocketState.Connected in FSocket.State) then
    Exit();

  Result := [];

  try
    while True do
    begin
      LData := ReadPacket(LHeader);

      if LHeader = nil then
        Break;

      if (FIsCrypt) and (not AAuthPacket) then
      begin
        { TODO -oCarlos -cImplement : Call DeCryptPacket }
      end;

      Result := Result + LData;

      if LHeader.Flag = 0 then
        Break;
    end;
  finally
    if LHeader <> nil then
      FreeAndNil(LHeader);
  end;

  if AIsBinary then
  begin
    { TODO -oCarlos -cImplement : Implement binary }
  end;

end;

function TMTConnect.ReadPacket(out AHeader: TMTHeaderProtocol): TArray<Byte>;
var
  LReceiveData: TArray<Byte>;
  LRemainingData: TArray<Byte>;
  LData: TArray<Byte>;
  LCountRead: Integer;
  LNeedLen: Integer;
  LHeader: TMTHeaderProtocol;
begin
  LHeader := nil;
  LData := [];
  LRemainingData := [];
  LNeedLen := 0;
  repeat

    FCriticalSection.Enter;
    try
      LCountRead := FSocket.Receive(LReceiveData, -1, [TSocketFlag.WAITALL]);
    finally
      FCriticalSection.Leave;
    end;

    if LCountRead = 0 then
      Break;
    LRemainingData := LRemainingData + LReceiveData;
    repeat
      if LNeedLen <= Length(LData) then
      begin
        if LHeader <> nil then
          FreeAndNil(LHeader);
        LHeader := TMTHeaderProtocol.GetHeader(LRemainingData);
        LNeedLen := LNeedLen + LHeader.SizeBody;
        LRemainingData := Copy(LRemainingData, TMTHeaderProtocol.HEADER_LENGTH, Length(LRemainingData) - TMTHeaderProtocol.HEADER_LENGTH);
      end;
      LData := LData + Copy(LRemainingData, 0, LHeader.SizeBody);
      LRemainingData := Copy(LRemainingData, LHeader.SizeBody, Length(LRemainingData) - LHeader.SizeBody);

      if (Length(LData) = LHeader.SizeBody) then
        Break;
      if (LNeedLen = Length(LData)) then
        Break;
      if Length(LRemainingData) = 0 then
        Break;
    until (not True);
    if (LNeedLen = Length(LData)) and (Length(LRemainingData) = 0) then
      Break;
    if LHeader.Flag = 0 then
      Break;
    Sleep(750);
  until (not True);
  AHeader := LHeader;
  Result := LData;

end;

function TMTConnect.Send(ACommand: string; AData: TArray<TMTQuery>; const AFirstRequest: Boolean): Boolean;
var
  LQueryTemp: string;
  LQueryBody: TArray<Byte>;
  LBodyRequest: string;
  I: Integer;
  LHeaderString: string;
  LHeader: TArray<Byte>;
  LQuery: TArray<Byte>;
  LSendResult: Integer;
begin
  Result := False;
  if not Assigned(FSocket) then
    Exit(False);
  if not(TSocketState.Connected in FSocket.State) then
    Exit(False);

  Inc(FClientCommand);

  if FClientCommand > MAX_CLIENT_COMMAND then
    FClientCommand := 1;

  LQueryTemp := ACommand;

  if Length(AData) > 0 then
  begin
    LQueryTemp := LQueryTemp + '|';
    LBodyRequest := EmptyStr;
    for I := Low(AData) to High(AData) do
    begin
      if AData[I].Key = TMTProtocolConsts.WEB_PARAM_BODYTEXT then
        LBodyRequest := AData[I].Value
      else
        LQueryTemp := LQueryTemp + AData[I].Key + '=' + TMTUtils.Quotes(AData[I].Value) + '|'

    end;
    LQueryTemp := LQueryTemp + #13#10;
    if not LBodyRequest.IsEmpty then
      LQueryTemp := LQueryTemp + LBodyRequest;
  end
  else
    LQueryTemp := LQueryTemp + '|'#13#10;

  LQueryBody := TEncoding.Unicode.GetBytes(LQueryTemp);

  if (AFirstRequest) then
    LHeaderString := Format(TMTProtocolConsts.WEB_PREFIX_WEBAPI, [Length(LQueryBody), FClientCommand])
  else
    LHeaderString := Format(TMTProtocolConsts.WEB_PACKET_FORMAT, [Length(LQueryBody), FClientCommand]);

  LHeader := TEncoding.ASCII.GetBytes(LHeaderString + '0');

  LQuery := LHeader + LQueryBody;
  FCriticalSection.Enter;
  try
    LSendResult := FSocket.Send(LQuery);
  finally
    FCriticalSection.Leave;
  end;
  FEvent.WaitFor(1000);
  FEvent.ResetEvent;
  if LSendResult = Length(LQuery) then
    Result := True;
end;

procedure TMTConnect.SetCryptRand(ACrypt, APassword: string);
var
  LOut: TArray<Byte>;
  I: Integer;
begin
  FCryptRand := ACrypt;
  LOut :=
    TMTUtils.GetMD5(
    TMTUtils.GetMD5(
    TEncoding.Unicode.GetBytes(APassword) +
    TEncoding.UTF8.GetBytes(TMTProtocolConsts.WEB_API_WORD)
    )
    );
  for I := 0 to 15 do
  begin
    LOut :=
      TMTUtils.GetMD5(
      TMTUtils.GetFromHex(
      Copy(FCryptRand, I * 32, 32)
      ) + TMTUtils.GetFromHex(TMTUtils.GetHex(LOut))
      );
  end;
end;

end.
