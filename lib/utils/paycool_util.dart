import 'package:exchangily_core/exchangily_core.dart';

import '../constants/paycool_constants.dart';

class PaycoolUtil {
  static final log = getLogger('PaycoolUtil');

  static getPayCoolClubFuncABI(
      int coinType, String walletAddr, String referralAddr) {
    log.i(
        'coinType $coinType -- walletAddress $walletAddr -- referralAddr $referralAddr');
    var abiHex = PaycoolConstants.payCoolClubSignatureAbi;
    abiHex +=
        fixLength(trimHexPrefix(FabUtils.fabToExgAddress(walletAddr)), 64);
    abiHex += referralAddr.startsWith('0x')
        ? fixLength(trimHexPrefix(referralAddr), 64)
        : fixLength(trimHexPrefix(FabUtils.fabToExgAddress(referralAddr)), 64);
    abiHex += fixLength(coinType.toRadixString(16), 64);
    log.i('getPayCoolClubFuncABI abi $abiHex');
    return abiHex;
  }

  static getPayCoolFuncABI(int coinType, amount, String abi) {
    var abiHex = abi;

    abiHex += fixLength(coinType.toRadixString(16), 64);
    var amountHex = amount.toRadixString(16);
    abiHex += fixLength(trimHexPrefix(amountHex), 64);
    return abiHex;
  }

  static String constructPaycoolRefundAbiHex(String orderId) {
    String abiHex = PaycoolConstants.payCoolRefundAbi +
        fixLength(trimHexPrefix(orderId), 64);
    // 0x775274a17266776165667761726165617700000000000000000000000000000000000000
    return abiHex;
  }

  static String constructPaycoolCancelAbiHex(String orderId) {
    String abiHex = PaycoolConstants.payCoolCancelAbi +
        fixLength(trimHexPrefix(orderId), 64);
    // 0x775274a17266776165667761726165617700000000000000000000000000000000000000
    return abiHex;
  }

  static displayAbiHexinReadableFormat(String abiHex) {
    //0xdca68eb0666177656661776566610000000000000000000000000000000000
    int totalLen = abiHex.length;
    String abiWithoutCode = abiHex.substring(10, totalLen - 10);
    int len = abiWithoutCode.length;
    var divisble = len / 64;
    //var remainder =
    int dividedRes = divisble.truncate();
    int start = 0;
    int bytesLen = 64;
    List<String> keys = [
      "orderId",
      "coinType",
      "totalAmount",
      "rewardBeneficiary",
      "",
      "",
      ""
    ];
    log.i('abi code: ${abiHex.substring(0, 10)}');
    for (var i = 0; i < dividedRes; i++) {
      var data = abiWithoutCode.substring(start, start + bytesLen);
      log.i('${keys[i]}: $data');
      start += bytesLen;
      if (i == 2) {
        // 000000000000000000000000000000000000000000000000a688906bd8b00000
        //double amount = NumberUtil.hexToDouble(data);
        //   debugPrint('amount $amount');
      }
    }
    var remainder = len - (bytesLen * dividedRes);
    log.i(abiWithoutCode.substring(start, start + remainder));

    // Web3.ContractAbi contractAbi =
    //     new Web3.ContractAbi.fromJson(abiWithoutCode, 'chargeFundsWithFee');
    // // contractAbi.
    // debugPrint(contractAbi);

    // Web3.DecodingResult dR = new Web3.DecodingResult().data;
    // var res = dR.data(abiWithoutCode);
    // debugPrint(res);

    // Web3.ContractFunction f = new Web3.ContractFunction({});
    // var dec = f.decodeReturnValues(abiHex);
    // debugPrint('dec $dec');
    // var enc = f.encodeCall(dec);
    // debugPrint('enc $enc');
  }

/*--------------------------------------------------------
                    Extract referral address
--------------------------------------------------------*/

  static extractWalletAddressFromAbiHex(String abiHex, EnvConfig envConfig) {
    String abi = abiHex.substring(0, 10);
    log.i(abi.toString());
    // String orderIdHex = abiHex.substring(10, 74);
    // debugPrint('orderIdHex $orderIdHex');
    String walletAddressHex = abiHex.substring(11, 74);
    String removeZerosFromHex =
        walletAddressHex.substring(23, walletAddressHex.length);
    log.i(
        'removeZerosFromHex $removeZerosFromHex -- length ${removeZerosFromHex.length}');
    String walletAddress = '';
    if (removeZerosFromHex.length == 40) {
      walletAddress =
          FabUtils.exgToFabAddress('0x' + removeZerosFromHex, envConfig.isProd);
    }
    log.i('wallet address $walletAddress');

    return {'walletAddress': walletAddress};
  }
/*--------------------------------------------------------
                    Extract referral address
--------------------------------------------------------*/

  static extractReferralAddressFromAbiHex(String abiHex, EnvConfig envConfig) {
    String abi = abiHex.substring(0, 10);
    log.i(abi.toString());
    // String orderIdHex = abiHex.substring(10, 74);
    // debugPrint('orderIdHex $orderIdHex');
    String referralAddressHex = abiHex.substring(75, 138);
    String removeZerosFromHex =
        referralAddressHex.substring(23, referralAddressHex.length);
    log.i(
        'removeZerosFromHex $removeZerosFromHex -- length ${removeZerosFromHex.length}');
    String referralAddress = '';
    if (removeZerosFromHex.length == 40) {
      referralAddress =
          FabUtils.exgToFabAddress('0x' + removeZerosFromHex, envConfig.isProd);
    }
    log.i('referral address $referralAddress');

    return {'referralAddress': referralAddress};
  }

/*--------------------------------------------------------
                    Extract data from abihex
--------------------------------------------------------*/

  extractDataFromAbiHex(String abiHex) {
    String abi = abiHex.substring(0, 10);
    log.i(abi);
    // String orderIdHex = abiHex.substring(10, 74);
    // debugPrint('orderIdHex $orderIdHex');
    String coinTypeHex = abiHex.substring(74, 138);
    int coinType = NumberUtil.hexToInt(coinTypeHex);
    log.i('coin type $coinType');
    var amountHex = abiHex.substring(138, abiHex.length);
    double amount = NumberUtil.hexToDouble(amountHex);
    // StringUtils.hexToAscii(orderIdHex);
    return {'coinType': coinType};
  }
}
