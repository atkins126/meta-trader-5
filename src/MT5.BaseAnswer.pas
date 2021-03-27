unit MT5.BaseAnswer;

interface

type

  TMTAnswerParam = class
  private
    FName: string;
    FValue: string;
    procedure SetName(const Value: string);
    procedure SetValue(const Value: string);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create(AName: string; AValue: string);
    property Name: string read FName write SetName;
    property Value: string read FValue write SetValue;
  end;

implementation

{ TMTAnswerParam }

constructor TMTAnswerParam.Create(AName, AValue: string);
begin
  SetName(AName);
  SetValue(AValue);
end;

procedure TMTAnswerParam.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TMTAnswerParam.SetValue(const Value: string);
begin
  FValue := Value;
end;

end.
