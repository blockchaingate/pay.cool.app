import 'package:flutter/widgets.dart';

import '../environments/coins.dart';
import '../environments/environment.dart';
import '../logger.dart';
import '../models/wallet/token_model.dart';
import '../service_locator.dart';
import 'api_service.dart';
import 'db/core_wallet_database_service.dart';
import 'db/token_list_database_service.dart';

class CoinService {
  final log = getLogger('CoinService');
  TokenListDatabaseService tokenListDatabaseService =
      locator<TokenListDatabaseService>();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  final apiService = locator<ApiService>();

  Future<String> getCoinWalletAddress(String tickerName,
      {String tokenType = ''}) async {
    String walletAddress = '';
    if (tickerName == 'ETH' || tokenType == 'ETH') {
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
    return walletAddress;
  }

/*----------------------------------------------------------------------
                      Get coin's official address
----------------------------------------------------------------------*/

  getCoinOfficalAddress(String coinName, {String tokenType = ''}) {
    if (tokenType == 'FAB') {
      String fabTokensOfficialAddress =
          environment['addresses']['exchangilyOfficial'][0]['address'];
      debugPrint(
          'fabTokensOfficialAddress $fabTokensOfficialAddress for $coinName');
      return fabTokensOfficialAddress;
    }
    if (tokenType == 'TRX') {
      String trxTokensOfficialAddress =
          environment['addresses']['exchangilyOfficial'][9]['address'];
      debugPrint(
          'TRXTokensOfficialAddress $trxTokensOfficialAddress for $coinName');
      return trxTokensOfficialAddress;
    } else if (coinName == 'ETH' || tokenType == 'ETH') {
      var ethTokenOfficialAddress =
          environment['addresses']['exchangilyOfficial'][3]['address'];

      debugPrint(
          'ethTokenOfficialAddress $ethTokenOfficialAddress for $coinName');
      return ethTokenOfficialAddress;
    } else {
      var address = environment['addresses']['exchangilyOfficial']
          .where((addr) => addr['name'] == coinName)
          .toList();
      String majorsOfficialAddress = address[0]['address'];
      debugPrint(
          'majors official address $majorsOfficialAddress for $coinName');
      return majorsOfficialAddress;
    }
  }

/*----------------------------------------------------------------------
                      Get Token data
----------------------------------------------------------------------*/

  Future<TokenModel> getSingleTokenData(String tickerName,
      {int coinType = 0}) async {
    TokenModel tokenResult;

// first look coin in the local storage
// TODO uncomment code below once save decimaldata in local storage works in wallet service
    // List<Map<String, int>> decimalDataFromStorage =
    //     jsonEncode(storageService.walletDecimalList) as List;
    // decimalDataFromStorage.forEach((decimalDataList) {
    //   if (decimalDataList.containsKey(coinName))
    //     res = decimalDataList[coinName];
    // });
    if (coinType == 0) {
      await getCoinTypeByTickerName(tickerName)
          .then((value) => coinType = value);
    }
    // if res not found in local storage then call old token list api
    //  if (res == null || res == 0) {
    try {
      log.i('res $tokenResult -- coin type $coinType -- ticker $tickerName');
      await apiService.getTokenList().then((tokens) {
        for (var i = 0; i < tokens.length; i++) {
          if (tokens[i].coinType == coinType) {
            tokenResult = tokens[i];
            log.i(
                'getSingleTokenData old tokens list:  res ${tokenResult.toJson()}');
            break;
          }
        }
      });
      //   }
    } catch (err) {
      log.e('getSingleTokenData old token Catch 1 : $err');
    }
    // if res not found in local storage then call new token list api
    if (tokenResult == null) {
      debugPrint(
          'res $tokenResult -- coin type $coinType -- ticker $tickerName');
      await apiService.getTokenListUpdates().then((newTokens) {
        for (var j = 0; j < newTokens.length; j++) {
          if (newTokens[j].tickerName == tickerName) {
            tokenResult = newTokens[j];
            log.i(
                'getSingleTokenData new tokens list:  res ${tokenResult.toJson()}');
            break;
          }
        }
      });
    }

    return tokenResult;
  }

/*--------------------------------------------------------------------------
          Get smart contract address from file or database
------------------------------------------------------------------------- */
  Future<String> getSmartContractAddressByTickerName(String tickerName) async {
    String smartContractAddress = '';
    int ct = 0;
// check hardcoded list
    smartContractAddress =
        environment["addresses"]["smartContract"][tickerName];
    if (smartContractAddress == null) {
      // check local DB
      await getCoinTypeByTickerName(tickerName).then((value) => ct = value);
      debugPrint(
          '$tickerName contract is null so fetching from token database');
      await tokenListDatabaseService
          .getContractAddressByCoinType(ct)
          .then((value) {
        if (value != null) {
          if (!value.startsWith('0x')) {
            smartContractAddress = '0x' + value;
          } else {
            smartContractAddress = value;
          }
        }
      });
    }
    // Get contract address from token list updates api
    // if (smartContractAddress == null || smartContractAddress.isEmpty)
    //   await apiService.getTokenListUpdates().then((tokens) {
    //     tokens.forEach((token) async {
    //       //    await tokenListDatabaseService.insert(token);
    //       if (token.tickerName == tickerName) {
    //         if (!token.contract.startsWith('0x'))
    //           smartContractAddress = '0x' + token.contract;
    //         else
    //           smartContractAddress = token.contract;
    //       }
    //     });
    //   });
    debugPrint('official smart contract address $smartContractAddress');
    return smartContractAddress;
  }

/*----------------------------------------------------------------------
                Get Coin Type By tickerName
----------------------------------------------------------------------*/

  Future<int> getCoinTypeByTickerName(String tickerName) async {
    int coinType = 0;
    MapEntry<int, String> hardCodedCoinList;
    bool isOldToken = newCoinTypeMap.containsValue(tickerName);
    debugPrint('is old token value $isOldToken');
    if (isOldToken) {
      hardCodedCoinList = newCoinTypeMap.entries
          .firstWhere((coinTypeMap) => coinTypeMap.value == tickerName);
    }
    // var coins =
    //     coinList.coin_list.where((coin) => coin['name'] == coinName).toList();
    if (hardCodedCoinList != null) {
      coinType = hardCodedCoinList.key;
    } else {
      await apiService.getTokenListUpdates().then((tokens) {
        for (var token in tokens) {
          if (token.tickerName == tickerName) coinType = token.coinType;
        }
      });
    }
    debugPrint('ticker $tickerName -- coin type $coinType');
    return coinType;
  }
}