import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/coin_service.dart';
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
  final coinService = locator<CoinService>();
  TextEditingController toController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController nonceController = TextEditingController();
  String smartContractAddress = '';
  int decimals = 18;
  String ethAddress = '';
  String exgAddress = '';

  init(String ticker) async {
    try {
      smartContractAddress = environment['addresses']['smartContract'][ticker];
      log.w('smart contract address $smartContractAddress');
    } catch (e) {
      log.e('getSmartContractAddress error $e');
    }
    ethAddress =
        await coreWalletDatabaseService.getWalletAddressByTickerName('ETH');
    exgAddress = await sharedService.getExgAddressFromCoreWalletDatabase();
  }

  onPaste() async {
    toController.text = await sharedService.pasteClipboardData();
    rebuildUi();
  }

  tokenIdValue(Tokens tokens, MultisigWalletModel multisigWallet) async {
    String tokenId = '';
    //  USDT and FAB -- use cointype as tokenid for kanban wallet
    //  For transfer Kanban gas from kanban wallet then use KANBAN as tokenId

    //  USDT, FAB smartcontract address for eth,bnb wallet
    //    transfer Kanban gas in ETH or BNB wallet, will use
    //    tokenId: "BNB".  tokenId: "ETH"
    String tickerName = tokens.tickers![0];
    int cointype = await coinService.getCoinTypeByTickerName(tickerName);
    if (multisigWallet.chain!.toLowerCase() == 'kanban') {
      if (tickerName.toLowerCase() == 'kanban') {
        tokenId = 'KANBAN';
      } else {
        tokenId = cointype.toString();
      }
    } else if (multisigWallet.chain!.toLowerCase() == 'eth' ||
        multisigWallet.chain!.toLowerCase() == 'bnb') {
      if (tickerName.toLowerCase() == 'kanban') {
        tokenId = multisigWallet.chain!.toUpperCase();
      } else {
        tokenId = cointype.toString();
      }
    }
    log.i('tokenId $tokenId');
    return tokenId;
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
      var legacyAddress = toLegacyAddress(toHex);
      toHex = FabUtils().fabToExgAddress(legacyAddress);
    }
    String tokenId = await tokenIdValue(token, multisigWallet);
    var amountDecimal = Decimal.parse(amountController.text);
    // Fill mutlisigTransactionHashModel
    var body = MultisigTransactionHashModel(
        to: toHex,
        amount: amountDecimal,
        nonce: nonce,
        decimals: int.parse(token.decimals![0]),
        chain: multisigWallet.chain,
        address: multisigWallet.address,
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

    var coinType = environment["CoinType"]["FAB"];
    final fabCoinChild = root.derivePath("m/44'/$coinType'/0'/0/0");
    var privateKey = fabCoinChild.privateKey;

    var chainId = environment["chains"]["ETH"]["chainId"];

    debugPrint('chainId==$chainId');

    var signedMess = await signPersonalMessageWith(
        Constants.EthMessagePrefix, privateKey!, stringToUint8List(hash),
        chainId: chainId);
    String ss = HEX.encode(signedMess);

    var sig = await multisigService.adjustVInSignature(
      signingMethod: 'eth_sign',
      signature: ss,
      signerAddress: multisigWallet.chain!.toLowerCase() == 'kanban'
          ? exgAddress
          : ethAddress,
    );
    log.e('sig $sig');
// create purposal
    var purposalBody = {
      "from": multisigWallet.chain!.toLowerCase() == 'kanban'
          ? exgAddress
          : ethAddress,
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
        {
          "signer": multisigWallet.chain!.toLowerCase() == 'kanban'
              ? exgAddress
              : ethAddress,
          "data": sig
        }
      ]
    };
    log.w('purposalBody $purposalBody');
    await multisigService.createProposal(purposalBody).then((res) {
      log.i('createProposal res $res');
      if (res) {
        sharedService.sharedSimpleNotification('Proposal created successfully');
      }
    }).catchError((e) {
      log.e('createProposal error $e');
    });

    setBusy(false);
  }
}
