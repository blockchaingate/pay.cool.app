import 'package:flutter/widgets.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/transaction_history_database_service.dart';
import 'package:paycool/services/db/user_settings_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/vault_service.dart';
import 'package:paycool/utils/abi_util.dart' as abi_util;
import 'package:shared_preferences/shared_preferences.dart';

class WalletUtil {
  final log = getLogger('WalletUtil');

  final walletDatabaseService = locator<WalletDatabaseService>();
  final storageService = locator<LocalStorageService>();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  final transactionHistoryDatabaseService =
      locator<TransactionHistoryDatabaseService>();
  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  final userSettingsDatabaseService = locator<UserSettingsDatabaseService>();
  final _vaultService = locator<VaultService>();
  final coinService = locator<CoinService>();
  Map<String, String> coinTickerAndNameList = {
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'FAB': 'Fast Access Blockchain',
    'USDT': 'USDT',
    'EXG': 'Exchangily',
    'DUSD': 'DUSD',
    'TRX': 'Tron',
    'BCH': 'Bitcoin Cash',
    'LTC': 'Litecoin',
    'DOGE': 'Dogecoin',
    'INB': 'Insight chain',
    'DRGN': 'Dragonchain',
    'HOT': 'Holo',
    'CEL': 'Celsius',
    'MATIC': 'Matic Network',
    'IOST': 'IOST',
    'MANA': 'Decentraland',
    'WAX': 'Wax',
    'ELF': 'aelf',
    'GNO': 'Gnosis',
    'POWR': 'Power Ledger',
    'WINGS': 'Wings',
    'MTL': 'Metal',
    'KNC': 'Kyber Network',
    'GVT': 'Genesis Vision',
    'USDTX': 'TRON USDT',
    'FABB': 'FAB Binance'
  };

  static List<String> allUsdtTokens = ["USDT", "USDTX", "USDTB", "USDTM"];
  static List<String> allUsdcTokens = ["USDC", "USDCX"];
  List<String> usdtSpecialTokens = ["USDTX", "USDTB", "USDTM"];
  static List<String> fabSpecialTokens = ["FABE", "FABB"];
  List<String> exgSpecialTokens = ["EXGE"];
  List<String> bstSpecialTokens = ["BSTE"];
  List<String> dscSpecialTokens = ["DSCE"];

  static bool isSpecialUsdt(String tickerName) {
    return allUsdtTokens.contains(tickerName);
  }

  static bool isSpecialUsdc(String tickerName) =>
      allUsdcTokens.contains(tickerName);

  static bool isSpecialFab(String tickerName) {
    return fabSpecialTokens.contains(tickerName);
  }

  // get wallet info object with address using single wallet balance
  Future<WalletInfo> getWalletInfoObjFromWalletBalance(WalletBalance wallet,
      {bool requiredAddressOnly = false}) async {
    //FocusScope.of(context).requestFocus(FocusNode());

    // take the tickername and then get the coin type
    // either from token or token updates api/local storage

    String tickerName = wallet.coin!.toUpperCase();
    String walletAddress = '';

    int coinType = await coinService.getCoinTypeByTickerName(tickerName);

    // use coin type to get the token type
    String tokenType = getTokenType(coinType);

    // get wallet address
    if (tickerName == 'ETH' ||
        tokenType == 'ETH' ||
        tickerName == 'MATICM' ||
        tokenType == 'POLYGON' ||
        tickerName == "BNB" ||
        tokenType == "BNB") {
      walletAddress =
          await coreWalletDatabaseService.getWalletAddressByTickerName('ETH');
    } else if (tickerName == 'FAB' || tokenType == 'FAB') {
      walletAddress =
          await coreWalletDatabaseService.getWalletAddressByTickerName('FAB');
    } else if (tickerName == 'TRX' ||
        tickerName == 'TRON' ||
        tokenType == 'TRON' ||
        tokenType == 'TRX') {
      walletAddress =
          await coreWalletDatabaseService.getWalletAddressByTickerName('TRX');
    } else {
      walletAddress = await coreWalletDatabaseService
          .getWalletAddressByTickerName(tickerName);
    }
    String? coinName = '';

    for (var i = 0; i < coinTickerAndNameList.length; i++) {
      if (coinTickerAndNameList.containsKey(wallet.coin)) {
        coinName = coinTickerAndNameList[wallet.coin];
        break;
      }
    }
    var walletInfo = WalletInfo();
    if (requiredAddressOnly) {
      walletInfo = WalletInfo(address: walletAddress);
    } else {
      wallet.balance ??= 0.0;
      wallet.usdValue ??= UsdValue(usd: 0.0);

      // assign address from local DB to walletinfo object
      walletInfo = WalletInfo(
          tickerName: wallet.coin,
          availableBalance: wallet.balance,
          tokenType: tokenType,
          usdValue: wallet.balance! * wallet.usdValue!.usd!.toDouble(),
          inExchange: wallet.unlockedExchangeBalance,
          address: walletAddress,
          name: coinName);
    }
    log.w('routeWithWalletInfoArgs walletInfo ${walletInfo.toJson()}');
    return walletInfo;
  }

/*----------------------------------------------------------------------
                Update special tokens tickername in UI
----------------------------------------------------------------------*/
  static Map<String, String> updateSpecialTokensTickerName(String tickerName) {
    String logoTicker = '';
    if (tickerName.toUpperCase() == 'ETH_BST' ||
        tickerName.toUpperCase() == 'BSTE') {
      tickerName = 'BST(ETH)';
      logoTicker = 'BSTE';
    } else if (tickerName.toUpperCase() == 'ETH_DSC' ||
        tickerName.toUpperCase() == 'DSCE') {
      tickerName = 'DSC(ETH)';
      logoTicker = 'DSCE';
    } else if (tickerName.toUpperCase() == 'ETH_EXG' ||
        tickerName.toUpperCase() == 'EXGE') {
      tickerName = 'EXG(ETH)';
      logoTicker = 'EXGE';
    } else if (tickerName.toUpperCase() == 'ETH_FAB' ||
        tickerName.toUpperCase() == 'FABE') {
      tickerName = 'FAB(ETH)';
      logoTicker = 'FABE';
    } else if (tickerName.toUpperCase() == 'TRON_USDT' ||
        tickerName.toUpperCase() == 'USDTX') {
      tickerName = 'USDT(TRX)';
      logoTicker = 'USDTX';
    } else if (tickerName.toUpperCase() == 'USDT') {
      tickerName = 'USDT(ETH)';
      logoTicker = 'USDT';
    } else if (tickerName.toUpperCase() == 'TRON_USDC' ||
        tickerName.toUpperCase() == 'USDCX') {
      tickerName = 'USDC(TRX)';
      logoTicker = 'USDCX';
    } else if (tickerName.toUpperCase() == 'MATICM') {
      tickerName = 'MATIC(POLYGON)';
      logoTicker = 'MATICM';
    } else if (tickerName.toUpperCase() == 'USDTM') {
      tickerName = 'USDT(POLYGON)';
      logoTicker = 'USDTM';
    } else if (tickerName.toUpperCase() == 'FABB') {
      tickerName = 'FAB(BNB)';
      logoTicker = 'FABB';
    } else if (tickerName.toUpperCase() == 'MATIC') {
      tickerName = 'MATIC(ETH)';
      logoTicker = 'MATIC';
    } else if (tickerName.toUpperCase() == 'USDTB') {
      tickerName = 'USDT(BNB)';
      logoTicker = 'USDT';
    } else if (tickerName.toUpperCase() == 'EXGB') {
      tickerName = 'EXG(BNB)';
      logoTicker = 'EXG';
    } else if (tickerName.toUpperCase() == 'GETB') {
      tickerName = 'GET(BNB)';
      logoTicker = 'GET';
    } else if (tickerName.toUpperCase() == 'FETB') {
      tickerName = 'FET(BNB)';
      logoTicker = 'FET';
    } else {
      logoTicker = tickerName;
    }
    return {"tickerName": tickerName, "logoTicker": logoTicker};
  }

// Delete wallet
  Future deleteWallet() async {
    log.w('deleting wallet');
    try {
      await walletDatabaseService
          .deleteDb()
          .whenComplete(() => log.e('wallet database deleted!!'))
          .catchError((err) => log.e('wallet database CATCH $err'));

      await transactionHistoryDatabaseService
          .deleteDb()
          .whenComplete(() => log.e('trnasaction history database deleted!!'))
          .catchError((err) => log.e('tx history database CATCH $err'));

      await _vaultService
          .deleteEncryptedData()
          .whenComplete(() => log.e('encrypted data deleted!!'))
          .catchError((err) => log.e('delete encrypted CATCH $err'));

      await coreWalletDatabaseService
          .deleteDb()
          .whenComplete(() => log.e('coreWalletDatabaseService data deleted!!'))
          .catchError((err) => log.e('coreWalletDatabaseService  CATCH $err'));

      await tokenListDatabaseService
          .deleteDb()
          .whenComplete(() => log.e('Token list database deleted!!'))
          .catchError((err) => log.e('token list database CATCH $err'));

      await userSettingsDatabaseService
          .deleteDb()
          .whenComplete(() => log.e('User settings database deleted!!'))
          .catchError((err) => log.e('user setting database CATCH $err'));

      storageService.walletBalancesBody = '';
      storageService.isShowCaseView = true;
      storageService.clearStorage();
      debugPrint(
          'Checking has verified key value after clearing local storage : ${storageService.hasWalletVerified.toString()}');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      log.e('before wallet removal, local storage has ${prefs.getKeys()}');
      prefs.clear();
    } catch (err) {
      log.e('deleteWallet CATCH -- wallet delete failed: $err');
      throw Exception(['Wallet deletion failed $err']);
    }
  }

  // get token type

  // coin type(int) to token type(String)
  String getTokenType(int coinType) {
    String tokenType = '';
// 0001 = BTC
// 0002 = FAB
// 0003 = ETH
// 0004 - BCH
// 0005 - LTC
// 0006 - DOGE
// 0007 = TRON

// CEL
// cointype 196612
// converts to 00030004
// so we know that this is an eth token since 0003 = eth chain and 4 !=0

    String hexCoinType =
        abi_util.fix8LengthCoinType(coinType.toRadixString(16));
    String firstHalf = hexCoinType.substring(0, 4);
    String secondHalf = hexCoinType.substring(4, 8);

    log.i('hexCoinType $hexCoinType - ');
    if (secondHalf == '0000') {
      tokenType = '';
    } else if (firstHalf == '0001' && secondHalf != '0000') {
      tokenType = 'BTC';
    } else if (firstHalf == '0002' && secondHalf != '0000') {
      tokenType = 'FAB';
    } else if (firstHalf == '0003' && secondHalf != '0000') {
      tokenType = 'ETH';
    } else if (firstHalf == '0004' && secondHalf != '0000') {
      tokenType = 'BCH';
    } else if (firstHalf == '0005' && secondHalf != '0000') {
      tokenType = 'LTC';
    } else if (firstHalf == '0006' && secondHalf != '0000') {
      tokenType = 'DOGE';
    } else if (firstHalf == '0007' && secondHalf != '0000') {
      tokenType = 'TRX';
    } else if (firstHalf == '0009' && secondHalf != '0000') {
      tokenType = 'POLYGON';
    } else if (firstHalf == '0008' && secondHalf != '0000') {
      tokenType = 'BNB';
    }
    log.i('hexCoinType $hexCoinType - tokenType $tokenType');
    return tokenType;
  }
}
