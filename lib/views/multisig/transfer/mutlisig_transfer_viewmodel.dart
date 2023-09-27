import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/multisig_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/coin_util.dart';
import 'package:paycool/utils/exaddr.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/multisig/dashboard/multisig_balance_model.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';
import 'package:paycool/views/multisig/transfer/multisig_transaction_hash_model.dart';
import 'package:stacked/stacked.dart';
import 'package:hex/hex.dart';
import 'package:bip32/bip32.dart' as bip32;

class MultisigTransferViewModel extends BaseViewModel {
  final log = getLogger('MultisigTransferViewmodel');

  final walletService = locator<WalletService>();
  final multisigService = locator<MultiSigService>();
  final sharedService = locator<SharedService>();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
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
    setBusy(true);
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
    var amountDecimal = Decimal.parse(amountController.text);
    // Fill mutlisigTransactionHashModel
    var body = MultisigTransactionHashModel(
        to: toHex,
        amount: amountDecimal,
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
    var hash = res['hash'];
    var transaction = res['transaction'];
    log.e('hash ${res['hash']}');

    bip32.BIP32 root = walletService.generateBip32Root(seed!);

    var coinType = environment["CoinType"]["ETH"];
    final ethCoinChild = root.derivePath("m/44'/$coinType'/0'/0/0");
    var privateKey = ethCoinChild.privateKey;
    ethCoinChild.publicKey;

    var chainId = environment["chains"]["ETH"]["chainId"];

    debugPrint('chainId==$chainId');

    var signedMess = await signPersonalMessageWith(
        Constants.EthMessagePrefix, privateKey!, stringToUint8List(hash),
        chainId: chainId);
    String ss = HEX.encode(signedMess);
    //String ss2 = HEX.encode(signedMessOrig);

    var r = ss.substring(0, 64);
    var s = ss.substring(64, 128);
    var v = ss.substring(128);
    log.w({'r': r, 's': s, 'v': v});

    String walletAddress =
        await coreWalletDatabaseService.getWalletAddressByTickerName('ETH');
    var sig = await multisigService.adjustVInSignature(
        signingMethod: 'eth_sign', signature: ss, signerAddress: walletAddress);
    log.e('sig $sig');
    String ethAddress = await getAddressForCoin(root, 'ETH');
// create purposal
    var purposalBody = {
      "from": ethAddress,
      "address": multisigWallet.address,
      "request": {
        "type": "Send",
        "to": toHex,
        "amount": amountDecimal,
        "tokenId": tokenId,
        "tokenName": token.tickers![0],
      },
      "transaction": transaction,
      "transactionHash": hash,
      "signatures": [
        {"signer": ethAddress, "data": sig}
      ]
    };

    await multisigService
        .createProposal(purposalBody)
        .then((res) => {log.i('createProposal res $res')})
        .catchError((e) {
      log.e('createProposal error $e');
    });

    setBusy(false);
  }
}
