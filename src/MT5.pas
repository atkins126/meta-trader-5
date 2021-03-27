unit MT5;

interface

uses
  MT5.Protocol, MT5.RetCode,  MT5.Connect, MT5.Api,
  MT5.Order, MT5.Position, MT5.History, MT5.Deal;

type

  TMTHeaderProtocol = MT5.Protocol.TMTHeaderProtocol;
  TMTProtocolConsts = MT5.Protocol.TMTProtocolConsts;
  TMTRetCodeType =  MT5.RetCode.TMTRetCodeType;
  TMTRetCode =  MT5.RetCode.TMTRetCode;
  TMTConnect = MT5.Connect.TMTConnect;
  TMTApi = MT5.Api.TMTApi;

  TMTOrder = MT5.Order.TMTOrder;
  TMTOrderTotalAnswer = MT5.Order.TMTOrderTotalAnswer;
  TMTOrderPageAnswer = MT5.Order.TMTOrderPageAnswer;
  TMTOrderAnswer = MT5.Order.TMTOrderAnswer;
  TMTOrderJson = MT5.Order.TMTOrderJson;
  TMTEnOrderType = MT5.Order.TMTEnOrderType;
  TMTEnOrderFilling = MT5.Order.TMTEnOrderFilling;
  TMTEnOrderTime = MT5.Order.TMTEnOrderTime;
  TMTEnOrderState = MT5.Order.TMTEnOrderState;
  TMTEnOrderActivation = MT5.Order.TMTEnOrderActivation;
  TMTEnOrderReason = MT5.Order.TMTEnOrderReason;
  TMTEnTradeActivationFlags = MT5.Order.TMTEnTradeActivationFlags;
  TMTEnOrderTradeModifyFlags = MT5.Order.TMTEnOrderTradeModifyFlags;

  TMTPosition = MT5.Position.TMTPosition;
  TMTPositionTotalAnswer = MT5.Position.TMTPositionTotalAnswer;
  TMTPositionPageAnswer = MT5.Position.TMTPositionPageAnswer;
  TMTPositionAnswer = MT5.Position.TMTPositionAnswer;
  TMTPositionJson = MT5.Position.TMTPositionJson;
  TMTEnPositionReason = MT5.Position.TMTEnPositionReason;
  TMTEnPositionAction = MT5.Position.TMTEnPositionAction;
  TMTEnActivation = MT5.Position.TMTEnActivation;
  TMTEnPositionTradeActivationFlags = MT5.Position.TMTEnPositionTradeActivationFlags;
  TMTPositionEnTradeModifyFlags = MT5.Position.TMTPositionEnTradeModifyFlags;

  TMTDeal = MT5.Deal.TMTDeal;
  TMTDealTotalAnswer = MT5.Deal.TMTDealTotalAnswer;
  TMTDealPageAnswer = MT5.Deal.TMTDealPageAnswer;
  TMTDealAnswer = MT5.Deal.TMTDealAnswer;
  TMTDealJson = MT5.Deal.TMTDealJson;
  TMTEnDealAction = MT5.Deal.TMTEnDealAction;
  TMTEnEntryFlags = MT5.Deal.TMTEnEntryFlags;
  TMTEnDealReason = MT5.Deal.TMTEnDealReason;
  TMTEnTradeModifyFlags = MT5.Deal.TMTEnTradeModifyFlags;

  TMTHistoryProtocol = MT5.History.TMTHistoryProtocol;
  TMTHistoryTotalAnswer = MT5.History.TMTHistoryTotalAnswer;
  TMTHistoryPageAnswer = MT5.History.TMTHistoryPageAnswer;
  TMTHistoryAnswer = MT5.History.TMTHistoryAnswer;


implementation

end.
