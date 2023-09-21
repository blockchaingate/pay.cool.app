import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/multisig_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/coin_util.dart';
import 'package:paycool/utils/exaddr.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/views/multisig/dashboard/multisig_balance_model.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';
import 'package:paycool/views/multisig/transfer/multisig_transaction_hash_model.dart';
import 'package:stacked/stacked.dart';
import 'package:hex/hex.dart';

class MultisigTransferViewModel extends BaseViewModel {
  final log = getLogger('MultisigTransferViewmodel');

  final walletService = locator<WalletService>();
  final multisigService = locator<MultiSigService>();

  TextEditingController toController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController nonceController = TextEditingController();
  String smartContractAddress = '';
  int decimals = 18;

  getSmartContractAddress(String ticker) {
    try {
      smartContractAddress = environment['addresses']['smartContract'][ticker];
      log.w('smart contract address $smartContractAddress');
    } catch (e) {
      log.e('getSmartContractAddress error $e');
    }
  }

  transfer(Tokens token, MultisigWalletModel multisigWallet,
      BuildContext context) async {
    log.i('transfer');
    log.w('smart contract address $smartContractAddress');
    int nonce = await multisigService.getTransferNonce(multisigWallet.address!);
    log.w('nonce $nonce');
    String toHex = toController.text;
    if (multisigWallet.chain!.toLowerCase() == 'kanban') {
      var la = toLegacyAddress(toHex);
      toHex = FabUtils().fabToExgAddress(la);
    }
    var tokenId = multisigWallet.chain!.toLowerCase() == 'kanban'
        ? environment['chains']['KANBAN']['chainId'].toString()
        : environment['addresses']['smartContract'][token.tickers![0]];
    log.i('tokenId $tokenId');
    // Fill mutlisigTransactionHashModel
    var body = MultisigTransactionHashModel(
        to: toHex,
        amount: Decimal.parse(amountController.text),
        nonce: nonce,
        decimals: int.parse(token.decimals![0]),
        chain: multisigWallet.chain,
        address: multisigWallet.address,
        //  inkanban, it's cointype
        // in eth or bnb, it's token smart contract address
        tokenId: tokenId);
    log.e('body ${body.toJson()}');
    // then call multisigService.multisigtransferTxHash
    var res = await multisigService.multisigtransferTxHash(body);
    log.w('res $res');
    var seed = await walletService.getSeedDialog(context);
    var root = walletService.generateBip32Root(seed!);
    final ethCoinChild =
        root.derivePath("m/44'/${environment["CoinType"]["ETH"]}'/0'/0/0");
    final privateKey = ethCoinChild.privateKey;
    log.e('hash ${res['hash']}');
    log.i('privateKey $privateKey');
    var signature = signMessageWithPrivateKey(
        Uint8List.fromList(res['hash'].toString().codeUnits), privateKey!);
    log.w('signature $signature');
  }
}
