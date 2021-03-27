unit MT5.Utils;

interface

uses
  System.SysUtils, System.SyncObjs, System.Classes, System.Math, System.StrUtils, System.Hash;

type

  TMTUtils = class
  private
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    class procedure AsynAwait(AProc: TProc);
    class function BytesToStr(ABytes: TArray<Byte>): string;
    class function StrToHex(AString: string): string;
    class function HexToInt(AHexadecimal: string): Integer;
    class function GetHex(AHash: TArray<Byte>): string;
    class function GetMD5(AInput: TArray<Byte>): TArray<Byte>;
    class function Quotes(AString: string): string;
    class function GetString(ABytes: TArray<Byte>): string;
    class function GetFromHex(AHexString: string): TArray<Byte>;
    class function GetRandomHex(ALength: Integer): TArray<Byte>;
    class function GetHashFromPassword(APassword: string; ARandCode: TArray<Byte>): TArray<Byte>;
    class function CompareBytes(ABytesLeft: TArray<Byte>; ABytesRight: TArray<Byte>): Boolean;
    class function ToOldVolume(ANewVolume: Int64): Int64;
    class function ToNewVolume(AOldVolume: Int64): Int64;
    class function GetEndPosHeaderData(AHeaderData: TArray<Byte>): Int64;
  end;

implementation

{ TMTUtils }

uses
  MT5.Protocol;

class procedure TMTUtils.AsynAwait(AProc: TProc);
var
  LEvent: TEvent;
begin
  LEvent := TEvent.Create;
  try
    TThread.CreateAnonymousThread(
      procedure
      begin
        try
          AProc;
        finally
          LEvent.SetEvent;
        end;
      end
      ).Start;
    LEvent.WaitFor;
  finally
    LEvent.Free;
  end;

end;

class function TMTUtils.BytesToStr(ABytes: TArray<Byte>): string;
var
  I: Integer;
begin
  Result := EmptyStr;
  for I := Low(ABytes) to High(ABytes) do
    Result := Result + Chr(ABytes[I]);
end;

class function TMTUtils.CompareBytes(ABytesLeft, ABytesRight: TArray<Byte>): Boolean;
var
  I: Integer;
begin
  if Length(ABytesLeft) = 0 then
    Exit(Length(ABytesRight) = 0);
  if Length(ABytesRight) = 0 then
    Exit(False);
  if Length(ABytesLeft) <> Length(ABytesRight) then
    Exit(False);

  for I := Low(ABytesLeft) to High(ABytesLeft) do
  begin
    if ABytesLeft[I] <> ABytesRight[I] then
      Exit(False)
  end;
  Exit(True);
end;

class function TMTUtils.GetEndPosHeaderData(AHeaderData: TArray<Byte>): Int64;
var
  LPos: Int64;
  I: Integer;
begin
  LPos := 0;
  try
    for I := Low(AHeaderData) to High(AHeaderData) div 9 do
    begin
      if AHeaderData[(I + 1) * 9 + 1] = $0 then
      begin
        LPos := (I + 1) * 9;
        Break;
      end;
    end;
  finally
    Result := LPos;
  end;

end;

class function TMTUtils.GetFromHex(AHexString: string): TArray<Byte>;
var
  I: Integer;
begin
  if AHexString.IsEmpty then
    Exit();
  if Length(AHexString) mod 2 <> 0 then
    Exit();
  SetLength(Result, Length(AHexString) div 2);
  I := 0;
  while I < Length(AHexString) do
  begin
    Result[I div 2] := Byte(HexToInt(AHexString.Substring(I, 2)));
    Inc(I, 2);
  end;
end;

class function TMTUtils.GetHashFromPassword(APassword: string; ARandCode: TArray<Byte>): TArray<Byte>;
var
  LHash: TArray<Byte>;
  LApiWord: TArray<Byte>;
  LHashContains: TArray<Byte>;
begin
  if Length(ARandCode) = 0 then
    Exit();
  try
    LHash := GetMD5(TEncoding.Unicode.GetBytes(APassword));
    if Length(LHash) = 0 then
      Exit();
    LApiWord := TEncoding.UTF8.GetBytes(TMTProtocolConsts.WEB_API_WORD);
    LHashContains := LHash + LApiWord;
    if Length(LHashContains) = 0 then
      Exit();
    LHash := GetMD5(LHashContains);
    if Length(LHash) = 0 then
      Exit();
    LHashContains := LHash + ARandCode;
    if Length(LHashContains) = 0 then
      Exit();
    Exit(GetMD5(LHashContains));
  except
    Exit();
  end;
end;

class function TMTUtils.GetHex(AHash: TArray<Byte>): string;
var
  I: Integer;
begin
  Result := '';
  if Length(AHash) = 0 then
    Exit;
  for I := Low(AHash) to High(AHash) do
    Result := Result + IntToHex(AHash[I], 2);
end;

class function TMTUtils.GetMD5(AInput: TArray<Byte>): TArray<Byte>;
var
  LMemoryStream: TMemoryStream;
begin
  LMemoryStream := TMemoryStream.Create;
  try
    LMemoryStream.Position := 0;
    LMemoryStream.WriteBuffer(AInput, Length(AInput));
    LMemoryStream.Position := 0;
    Result := THashMD5.GetHashBytes(LMemoryStream);
  finally
    LMemoryStream.Free;
  end;
end;

class function TMTUtils.GetRandomHex(ALength: Integer): TArray<Byte>;
var
  I: Integer;
begin
  SetLength(Result, 16);
  for I := Low(Result) to High(Result) do
    Result[I] := Byte(Random(256) - 1);
end;

class function TMTUtils.GetString(ABytes: TArray<Byte>): string;
begin
  try
    Result := TEncoding.Unicode.GetString(ABytes);
  except
    Result := EmptyStr;
  end;
end;

class function TMTUtils.HexToInt(AHexadecimal: String): Integer;
begin
  Result := StrToInt('$' + AHexadecimal);
end;

class function TMTUtils.Quotes(AString: string): string;
begin
  Result := AString.Replace('\\', '\\\\');
  Result := Result.Replace('=', '\=');
  Result := Result.Replace('|', '\|');
  Result := Result.Replace('\n', '\\\n');
end;

class function TMTUtils.StrToHex(AString: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(AString) do
    Result := Result + IntToHex(Ord(AString[I]), 2);
end;

class function TMTUtils.ToNewVolume(AOldVolume: Int64): Int64;
begin
  Result := AOldVolume * 10000;
end;

class function TMTUtils.ToOldVolume(ANewVolume: Int64): Int64;
begin
  Result := ANewVolume div 10000;
end;

end.

