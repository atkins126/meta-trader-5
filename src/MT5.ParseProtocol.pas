unit MT5.ParseProtocol;

interface

uses
  System.SysUtils,
  MT5.BaseAnswer, MT5.RetCode;

type

  TMTParseProtocol = record
  public
    { public declarations }
    class function GetCommand(AAnswer: string; var APos: Integer): string; static;
    class function GetNextParam(AAnswer: string; var APos, APosEnd: Integer): TMTAnswerParam; static;
    class function GetRetCode(ARetCode: string): TMTRetCodeType; static;
    class function GetJson(AAnswer: string; APos: Integer): string; static;
  end;

implementation

{ TMTParseProtocol }

class function TMTParseProtocol.GetCommand(AAnswer: string; var APos: Integer): string;
begin
  if AAnswer.IsEmpty then
    Exit(EmptyStr);
  APos := AAnswer.IndexOf('|');
  if APos > 0 then
    Exit(AAnswer.SubString(0, APos));
  Exit(EmptyStr);
end;

class function TMTParseProtocol.GetJson(AAnswer: string; APos: Integer): string;
var
  LPosCode: Integer;
begin
  LPosCode := AAnswer.IndexOf(#13#10, APos);
  if LPosCode > 0 then
    Exit(AAnswer.SubString(APos).Trim);
  Exit(EmptyStr);
end;

class function TMTParseProtocol.GetNextParam(AAnswer: string; var APos, APosEnd: Integer): TMTAnswerParam;
var
  LParam: string;
  LVal: string;
  LCurrParam: Boolean;
  LSymbol: string;
begin
  if APosEnd < 0 then
  begin
    APosEnd := AAnswer.IndexOf(#13#10);
    if APosEnd < 0 then
      APosEnd := Length(AAnswer);
  end;

  if (APos + 1 >= Length(AAnswer)) or (APos + 1 >= APosEnd) then
    Exit(nil);

  LParam := '';
  LVal := '';
  LCurrParam := True;

  Inc(APos);

  while (APos < Length(AAnswer)) and (APos < APosEnd) do
  begin
    LSymbol := AAnswer[APos];

    if (LSymbol = '=') then
    begin
      LCurrParam := False;
      Inc(APos);
      Continue;
    end;
    if (LSymbol = '|') then
      Break;
    if LCurrParam then
      LParam := LParam + LSymbol
    else
      LVal := LVal + LSymbol;
    Inc(APos);
  end;

  Result := TMTAnswerParam.Create(LParam, LVal);
end;

class function TMTParseProtocol.GetRetCode(ARetCode: string): TMTRetCodeType;
var
  LSlitedString: TArray<string>;
  LMTRetCodeInt: Integer;
begin
  if ARetCode.IsEmpty then
    Exit(TMTRetCodeType.MT_RET_ERROR);
  LSlitedString := ARetCode.Split([' '], 2);

  LMTRetCodeInt := StrToIntDef(LSlitedString[0], -1);

  if LMTRetCodeInt = -1 then
    Exit(TMTRetCodeType.MT_RET_ERROR);

  Exit(TMTRetCodeType(LMTRetCodeInt))
end;

end.
