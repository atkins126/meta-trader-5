unit MT5.Protocol;

interface

uses
  MT5.Utils;

type

  TMTHeaderProtocol = class
  private
    { private declarations }
  var
    FSizeBody: Integer;
    FFlag: Integer;
    FNumberPacket: Integer;
  protected
    { protected declarations }
  public
  { public declarations }
    const
    HEADER_LENGTH = 9;
    constructor Create(ASizeBody, ANumberPacket, AFlag: Integer);
    property SizeBody: Integer read FSizeBody;
    property NumberPacket: Integer read FNumberPacket;
    property Flag: Integer read FFlag;
    class function GetHeader(AHeaderData: TArray<Byte>): TMTHeaderProtocol;
  end;

  TMTProtocolConsts = class
  const
    WEB_CMD_AUTH_START = 'AUTH_START'; // begin of authorization on server
    WEB_CMD_AUTH_ANSWER = 'AUTH_ANSWER'; // end of authorization on server
    // --- config
    WEB_CMD_COMMON_GET = 'COMMON_GET'; // get config
    // --- time
    WEB_CMD_TIME_SERVER = 'TIME_SERVER'; // get time of server
    WEB_CMD_TIME_GET = 'TIME_GET'; // get config of times
    // --- api
    WEB_PREFIX_WEBAPI = 'MT5WEBAPI%04x%04x'; // format of package for api
    WEB_PACKET_FORMAT = '%04x%04x'; // format of packages second or more request
    WEB_API_WORD = 'WebAPI';
    // ---
    WEB_PARAM_VERSION = 'VERSION'; // version of authorization
    WEB_PARAM_RETCODE = 'RETCODE'; // code answer
    WEB_PARAM_LOGIN = 'LOGIN'; // login
    WEB_PARAM_TYPE = 'TYPE'; // type of connection, type of data, type of operation
    WEB_PARAM_AGENT = 'AGENT'; // agent name
    WEB_PARAM_SRV_RAND = 'SRV_RAND'; // server random string
    WEB_PARAM_SRV_RAND_ANSWER = 'SRV_RAND_ANSWER'; // answer on server random string
    WEB_PARAM_CLI_RAND = 'CLI_RAND'; // client's random string
    WEB_PARAM_CLI_RAND_ANSWER = 'CLI_RAND_ANSWER'; // answer to clients random string
    WEB_PARAM_TIME = 'TIME'; // time param
    WEB_PARAM_TOTAL = 'TOTAL'; // total
    WEB_PARAM_INDEX = 'INDEX'; // index
    WEB_PARAM_GROUP = 'GROUP'; // group
    WEB_PARAM_SYMBOL = 'SYMBOL'; // symbol
    WEB_PARAM_NAME = 'NAME'; // name
    WEB_PARAM_COMPANY = 'COMPANY'; // company
    WEB_PARAM_LANGUAGE = 'LANGUAGE'; // language (LANGID)
    WEB_PARAM_COUNTRY = 'COUNTRY'; // country
    WEB_PARAM_CITY = 'CITY'; // city
    WEB_PARAM_STATE = 'STATE'; // state
    WEB_PARAM_ZIPCODE = 'ZIPCODE'; // zipcode
    WEB_PARAM_ADDRESS = 'ADDRESS'; // address
    WEB_PARAM_PHONE = 'PHONE'; // phone
    WEB_PARAM_EMAIL = 'EMAIL'; // email
    WEB_PARAM_ID = 'ID'; // id
    WEB_PARAM_STATUS = 'STATUS'; // status
    WEB_PARAM_COMMENT = 'COMMENT'; // comment
    WEB_PARAM_COLOR = 'COLOR'; // color
    WEB_PARAM_PASS_MAIN = 'PASS_MAIN'; // main password
    WEB_PARAM_PASS_INVESTOR = 'PASS_INVESTOR'; // invest paswword
    WEB_PARAM_PASS_API = 'PASS_API'; // API password
    WEB_PARAM_PASS_PHONE = 'PASS_PHONE'; // phone password
    WEB_PARAM_LEVERAGE = 'LEVERAGE'; // leverage
    WEB_PARAM_RIGHTS = 'RIGHTS'; // rights
    WEB_PARAM_BALANCE = 'BALANCE'; // balance
    WEB_PARAM_PASSWORD = 'PASSWORD'; // password
    WEB_PARAM_TICKET = 'TICKET'; // ticket
    WEB_PARAM_OFFSET = 'OFFSET'; // offset for page requests
    WEB_PARAM_FROM = 'FROM'; // from time
    WEB_PARAM_TO = 'TO'; // to time
    WEB_PARAM_TRANS_ID = 'TRANS_ID'; // trans id
    WEB_PARAM_SUBJECT = 'SUBJECT'; // subject
    WEB_PARAM_CATEGORY = 'CATEGORY'; // category
    WEB_PARAM_PRIORITY = 'PRIORITY'; // priority
    WEB_PARAM_BODYTEXT = 'BODY_TEXT'; // big text
    WEB_PARAM_CHECK_MARGIN = 'CHECK_MARGIN'; // check margin
    // --- crypt
    WEB_PARAM_CRYPT_METHOD = 'CRYPT_METHOD'; // method of crypt
    WEB_PARAM_CRYPT_RAND = 'CRYPT_RAND'; // random string for crypt
    // --- group
    WEB_CMD_GROUP_TOTAL = 'GROUP_TOTAL'; // get count groups
    WEB_CMD_GROUP_NEXT = 'GROUP_NEXT'; // get next group
    WEB_CMD_GROUP_GET = 'GROUP_GET'; // get info about group
    WEB_CMD_GROUP_ADD = 'GROUP_ADD'; // group add
    WEB_CMD_GROUP_DELETE = 'GROUP_DELETE'; // group delete
    // --- symbols
    WEB_CMD_SYMBOL_TOTAL = 'SYMBOL_TOTAL'; // get count symbols
    WEB_CMD_SYMBOL_NEXT = 'SYMBOL_NEXT'; // get next symbol
    WEB_CMD_SYMBOL_GET = 'SYMBOL_GET'; // get info about symbol
    WEB_CMD_SYMBOL_GET_GROUP = 'SYMBOL_GET_GROUP'; // get info about symbol group
    WEB_CMD_SYMBOL_ADD = 'SYMBOL_ADD'; // symbol add
    WEB_CMD_SYMBOL_DELETE = 'SYMBOL_DELETE'; // symbol delete
    // --- user
    WEB_CMD_USER_ADD = 'USER_ADD'; // add new user
    WEB_CMD_USER_UPDATE = 'USER_UPDATE'; // update user
    WEB_CMD_USER_DELETE = 'USER_DELETE'; // delete user
    WEB_CMD_USER_GET = 'USER_GET'; // get user information
    WEB_CMD_USER_PASS_CHECK = 'USER_PASS_CHECK'; // user check
    WEB_CMD_USER_PASS_CHANGE = 'USER_PASS_CHANGE'; // password change
    WEB_CMD_USER_ACCOUNT_GET = 'USER_ACCOUNT_GET'; // account info get
    WEB_CMD_USER_USER_LOGINS = 'USER_LOGINS'; // users logins get
    // --- password type
    WEB_VAL_USER_PASS_MAIN = 'MAIN';
    WEB_VAL_USER_PASS_INVESTOR = 'INVESTOR';
    WEB_VAL_USER_PASS_API = 'API';
    // --- crypts
    WEB_VAL_CRYPT_NONE = 'NONE';
    WEB_VAL_CRYPT_AES256OFB = 'AES256OFB';
    // --- trade command
    WEB_CMD_USER_DEPOSIT_CHANGE = 'USER_DEPOSIT_CHANGE'; // deposit change
    // --- work with order
    WEB_CMD_ORDER_GET = 'ORDER_GET'; // get order
    WEB_CMD_ORDER_GET_TOTAL = 'ORDER_GET_TOTAL'; // get count orders
    WEB_CMD_ORDER_GET_PAGE = 'ORDER_GET_PAGE'; // get order from history
    // --- work with position
    WEB_CMD_POSITION_GET = 'POSITION_GET'; // get position
    WEB_CMD_POSITION_GET_TOTAL = 'POSITION_GET_TOTAL'; // get count positions
    WEB_CMD_POSITION_GET_PAGE = 'POSITION_GET_PAGE'; // get positions
    // --- work with deal
    WEB_CMD_DEAL_GET = 'DEAL_GET'; // get deal
    WEB_CMD_DEAL_GET_TOTAL = 'DEAL_GET_TOTAL'; // get count deals
    WEB_CMD_DEAL_GET_PAGE = 'DEAL_GET_PAGE'; // get list of deals
    // --- work with history
    WEB_CMD_HISTORY_GET = 'HISTORY_GET'; // get history
    WEB_CMD_HISTORY_GET_TOTAL = 'HISTORY_GET_TOTAL'; // get count of history order
    WEB_CMD_HISTORY_GET_PAGE = 'HISTORY_GET_PAGE'; // get list of history
    // --- work with ticks
    WEB_CMD_TICK_LAST = 'TICK_LAST'; // get tick
    WEB_CMD_TICK_LAST_GROUP = 'TICK_LAST_GROUP'; // get tick by group name
    WEB_CMD_TICK_STAT = 'TICK_STAT'; // tick stat
    // --- mail
    WEB_CMD_MAIL_SEND = 'MAIL_SEND';
    // --- news
    WEB_CMD_NEWS_SEND = 'NEWS_SEND';
    // --- ping
    WEB_CMD_PING = 'PING';
    // --- trade
    WEB_CMD_TRADE_BALANCE = 'TRADE_BALANCE';
    // --- server restart
    WEB_CMD_SERVER_RESTART = 'SERVER_RESTART';
  end;

implementation

uses
  System.SysUtils, System.Classes;

{ TMTHeaderProtocol }

constructor TMTHeaderProtocol.Create(ASizeBody, ANumberPacket, AFlag: Integer);
begin
  FSizeBody := ASizeBody;
  FFlag := AFlag;
  FNumberPacket := ANumberPacket;
end;

class function TMTHeaderProtocol.GetHeader(AHeaderData: TArray<Byte>): TMTHeaderProtocol;
var
  LSizeBody: Integer;
  LNumberPacket: Integer;
  LFlag: Integer;
  LMTHeaderProtocol: TMTHeaderProtocol;
begin
  Result := nil;
  if (Length(AHeaderData) < HEADER_LENGTH) then
    Exit(nil);

  try
    LSizeBody := TMTUtils.HexToInt((TMTUtils.BytesToStr(Copy(AHeaderData, 0, 4))));
    LNumberPacket := TMTUtils.HexToInt((TMTUtils.BytesToStr(Copy(AHeaderData, 4, 4)))); // TMTUtils.HexToInt(TEncoding.ASCII.GetString(AHeaderData, 4, 4));
    LFlag := TMTUtils.HexToInt((TMTUtils.BytesToStr(Copy(AHeaderData, 8, 1)))); // Ord(TEncoding.ASCII.GetString(AHeaderData, 8, 1).Chars[0]);
    LMTHeaderProtocol := TMTHeaderProtocol.Create(LSizeBody, LNumberPacket, LFlag);
    Result := LMTHeaderProtocol;
  except

  end;

end;

end.
