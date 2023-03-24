/* ---------------------------------------------------------------------
                          Base Url's
---------------------------------------------------------------------- */

import 'package:paycool/environments/environment.dart';
import 'package:paycool/environments/environment_type.dart';

class ApiRoutes {
  static final String maticmBaseUrl = environment["endpoints"]["maticm"];
  static final String bnbBaseUrl = environment["endpoints"]["bnb"];
}

const String baseBlockchainGateV2Url = isProduction
    ? 'https://api.blockchaingate.com/v2/'
    : 'https://test.blockchaingate.com/v2/';

const String baseKanbanUrl = isProduction
    ? 'https://kanbanprod.fabcoinapi.com/'
    : 'https://kanbantest.fabcoinapi.com/';

const String paycoolBaseUrl =
    isProduction ? 'https://api.pay.cool/api/' : 'https://fabtest.info/api/';

const String tronBaseApiUrl = 'https://api.trongrid.io/';
const String kanbanApiRoute = 'kanban/';
const String exchangilyUrl = 'https://www.exchangily.com/';

// General
const String coinPoolAddressRoute = 'exchangily/getCoinPoolAddress';

const String paycoolWebsiteUrl = "https://www.pay.cool/";
/*----------------------------------------------------------------------
                        Pay.cool Club
----------------------------------------------------------------------*/

const String clubDashboardUrl = "${paycoolBaseUrl}userreferral/v2/user/";

const String baseProjectPackageUrl = "${paycoolBaseUrl}projectpackage/v2/";

const String clubProjectsUrl = "${paycoolBaseUrl}project/v2/";
const String clubProjectDetailsUrl = "${baseProjectPackageUrl}project/";

const String paycoolRef = '7star-ref';
const String campaignListUrl = '${baseBlockchainGateV2Url}campaigns';
const String campaignEntryStatusUrl =
    '${baseBlockchainGateV2Url}7star-order/address-campaign/';

const String payCoolClubCreateOrderUrl =
    '${baseBlockchainGateV2Url}7star-order/create';

const String payCoolClubSaveOrderUrl =
    '$baseBlockchainGateV2Url$paycoolRef/savePayment';
const String isValidPaidReferralCodeUrl =
    '$baseBlockchainGateV2Url$paycoolRef/isValid/';

/*----------------------------------------------------------------------
                        Pay.cool Pay
----------------------------------------------------------------------*/

// valid Referralcode
String isValidPaycoolMemberUrl = '${paycoolBaseUrl}userreferral/isValid/';
// https://fabtest.info/api/userreferral/user/myVKCpWKSpMDvpZZRS69re3KmSta29ZFnK
const String isValidPaycoolReferralRoute = "userreferral/user/";

// Get downline (count / pagenumber)
// https://fabtest.info/api/userreferral/user/myVKCpWKSpMDvpZZRS69re3KmSta29ZFnK/10/0

// Get total referral count
// https://fabtest.info/api/userreferral/user/myVKCpWKSpMDvpZZRS69re3KmSta29ZFnK/totalCount
const String totalCountRoute = "/totalCount";

const String paymentRewardUrl = '${paycoolBaseUrl}payreward/v2/project/0/user/';
const String paymentTransactionHistoryUrl = '${paycoolBaseUrl}charge/v2/user/';

// ** https://api.blockchaingate.com/v2/stores/feeChargerSmartContractAddress/0x1e89b7d555fe1b68c048b68eb28724950e1051f2
const String storeInfoPayCoolUrl =
    '${baseBlockchainGateV2Url}stores/feeChargerSmartContractAddress/';

// https://test.blockchaingate.com/v2/7star-agent/smartContractAdd/0xb0dbab271cd9b9e53adc4cbe4e333aa3e06d2a9e09ea6b376dfa04f7b3989202

const String regionalAgentStarPayUrl =
    '${baseBlockchainGateV2Url}7star-agent/smartContractAdd/';

// old
// const String isValidPaycoolMemberUrl =
//     baseBlockchainGateV2Url + paycoolRef + '/' + 'isValidMember/';

const String paycoolTextApiRoute = "7starpay";
const String chargeTextApiRoute = "charge";
const String ordersTextApiRoute = "orders/";

const String payOrderApiRoute = "${ordersTextApiRoute}code/";

const String payCoolApiRoute = '${kanbanApiRoute}coders/encodeFunctionCall';

const String payCoolCreateReferralUrl =
    '$baseBlockchainGateV2Url$paycoolRef/create';

const String payCoolDecodeAbiUrl =
    '$baseKanbanUrl${kanbanApiRoute}coders/decodeParams';

const String payCoolEncodeAbiUrl =
    '$baseKanbanUrl${kanbanApiRoute}coders/encodeParams';

const String paycoolParentAddressUrl =
    '$baseBlockchainGateV2Url$paycoolRef/parents/';

/*----------------------------------------------------------------------
                        Wallet
----------------------------------------------------------------------*/
const String appVersionUrl =
    "https://api.coinranklist.com/app-update/7starpay-app-version";
const String getScarAddressApiRoute = 'getScarAddress';
const String GetTransactionCountApiRoute = 'getTransactionCount/';
const String GetBalanceApiRoute = 'getBalance/';
const String ResubmitDepositApiRoute = 'resubmitDeposit';
const String SendRawTxApiRoute = 'sendRawTransaction';
const String sendRawTxApiRouteV2 = 'sendRawTransactionPromise';
const String DepositerrApiRoute = 'depositerr/';
const String SubmitDepositApiRoute = 'submitDeposit';

const String TronUsdtAccountBalanceUrl =
    "${tronBaseApiUrl}wallet/triggerconstantcontract";
const String TronGetAccountUrl = "${tronBaseApiUrl}wallet/getaccount";
//  const requestURL = `${TRON_API_ENDPOINT}/wallet/getaccount`;
// const requestBody = {
//   address,
//   visible: true
// };

const String BroadcasrTronTransactionUrl =
    "${tronBaseApiUrl}wallet/broadcasthex";
const String GetTronLatestBlockUrl = '${tronBaseApiUrl}wallet/getnowblock';

const String WalletBalancesApiRoute = 'walletBalances';
const String SingleWalletBalanceApiRoute = 'singleCoinWalletBalance';
const String WalletCoinsLogoUrl = "https://www.exchangily.com/assets/coins/";

// Transaction history explorer URL's for prod
const String ExchangilyExplorerUrl =
    "https://exchangily.com/explorer/tx-detail/";
const String BitcoinExplorerUrl = "https://live.blockcypher.com/btc/tx/";
const String EthereumExplorerUrl = "https://etherscan.io/tx/";
const String TestnetEthereumExplorerUrl = "https://ropsten.etherscan.io/tx/";
const String FabExplorerUrl = "https://fabexplorer.info/#/transactions/";
const String LitecoinExplorerUrl = "https://live.blockcypher.com/ltx/tx/";
const String DogeExplorerUrl = "https://dogechain.info/tx/";
const String BitcoinCashExplorerUrl = "https://explorer.bitcoin.com/bch/tx/";
const String TronExplorerUrl = "https://tronscan.org/#/transaction/";

// Free Fab
const String getFreeFabUrl =
    '${baseBlockchainGateV2Url}airdrop/getQuestionair/';
const String postFreeFabUrl =
    '${baseBlockchainGateV2Url}airdrop/answerQuestionair/';

// USD Coin Price
const String GetUsdCoinPriceUrl =
    'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,fabcoin,tether&vs_currencies=usd';

// Get Usd Price for token and currencies like btc, exg, rmb, cad, usdt
const String CoinCurrencyUsdValueApiRoute = 'USDvalues';

// Get App Version
const String GetAppVersionRoute = 'getappversion';

// Get Token List, Decimal config, checkstatus
const String GetTokenListApiRoute = 'exchangily/getTokenList';
const String GetDecimalPairConfigApiRoute = 'kanban/getpairconfig';
//final String pairDecimalConfigRoute = 'kanban/getpairconfig';
const String WithDrawDepositTxHistoryApiRoute = 'getTransactionHistoryEvents';
// route for getting history for withdraw and deposits
const String BindpayTxHHistoryApiRoute = 'getTransferHistoryEvents';
// route for LightningRemit transfers

const String RedepositCheckStatusApiRoute = 'checkstatus/';
// Add wallet Hex Fab address or kanban address in the end
const String WithdrawTxStatusApiRoute = 'withdrawrequestsbyaddress/';
const String DepositTxStatusApiRoute = 'getdepositrequestsbyaddress/';

const String GetUtxosApiRoute = 'getutxos/';
const String GetNonceApiRoute = 'getnonce/';
const String PostRawTxApiRoute = 'postrawtransaction';
const String GetTokenListUpdatesApiRoute = 'tokenListUpdates';

/*----------------------------------------------------------------------
                            Exchange
----------------------------------------------------------------------*/

// banner
const String BannerApiUrl =
    'https://api.blockchaingate.com/v2/banners/app/5b6a8688905612106e976a69';

// /ordersbyaddresspaged/:address/:start?/:count?/:status?
// /getordersbytickernamepaged/:address/:tickerName/:start?/:count?/:status?

// Below is the address type which is used in ordersPaged
// convert base58 fab address to hex. trim the first two and last 8 chars.
// then put a 0x in front

final String btcBaseUrl = environment["endpoints"]["btc"];
final String ltcBaseUrl = environment["endpoints"]["ltc"];
final String bchBaseUrl = environment["endpoints"]["bch"];
final String dogeBaseUrl = environment["endpoints"]["doge"];
final String fabBaseUrl = environment["endpoints"]["fab"];
final String ethBaseUrl = environment["endpoints"]["eth"];
final String eventsUrl = environment["eventInfo"];

const String txStatusStatusRoute = 'kanban/explorer/getTransactionStatus';

// Websockets

const String AllPricesWSRoute = 'allPrices';
const String TradesWSRoute = 'trades@';
const String OrdersWSRoute = 'orders@';
const String TickerWSRoute = 'ticker@';

// My Orders

const String GetOrdersByAddrApiRoute = 'ordersbyaddresspaged/';
const String GetOrdersByTickerApiRoute = 'getordersbytickernamepaged/';

// Exchange Balance

/// https://kanbantest.fabcoinapi.com/exchangily/getBalance/
/// 0xb754f9c8b706c59646a4e97601a0ad81067e1cf9/HOT
const String GetSingleCoinExchangeBalApiRoute = 'exchangily/getBalance/';
const String AssetsBalanceApiRoute = 'exchangily/getBalances/';

const String OrdersByAddrApiRoute = 'ordersbyaddress/';
