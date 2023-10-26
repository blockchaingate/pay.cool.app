import 'package:flutter/widgets.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/abi_util.dart';
import 'package:paycool/utils/coin_util.dart';
import 'package:paycool/utils/keypair_util.dart';
import 'package:paycool/views/multisig/multisig_util.dart';
import 'package:stacked/stacked.dart';
import 'package:bip32/bip32.dart' as bip32;
import '../../../services/multisig_service.dart';
import 'package:hex/hex.dart';

class MultisigHistoryQueueViewModel extends FutureViewModel {
  final String address;
  MultisigHistoryQueueViewModel({required this.address});

  final sharedService = locator<SharedService>();
  final walletService = locator<WalletService>();
  List history = [];
  List queue = [];
  bool pendingExecution = false;

  final log = getLogger('HistoryQueueViewModel');
  final multisigService = locator<MultiSigService>();
  String exgAddress = '';
  String ethAddress = '';
  @override
  Future futureToRun() async =>
      await multisigService.getmultisigTransactions(address, pageSize: 30);

  @override
  void onData(data) async {
    history = data;
    log.i('history $history');
    exgAddress = await sharedService.getExgAddressFromCoreWalletDatabase();
    ethAddress =
        await sharedService.getCoinAddressFromCoreWalletDatabase('ETH');
  }

  onTap(int index) async {
    log.i('onTap $index');
    if (index == 0) {
      await futureToRun();
    } else {
      await getQueueTransactions();
    }
    notifyListeners();
  }

  // show confirmed by me if current wallet is one of the owners and also the signer
  bool hasConfirmedByMe(currentQueue) {
    pendingExecution = false;
    var multisigData = currentQueue['multisig'];
    var signaturesData = currentQueue['signatures'] as List;
    for (var walletOwner in multisigData['owners']) {
      if (walletOwner['address'] == exgAddress) {
        for (var signature in signaturesData) {
          if (signature['signer'] == exgAddress) {
            if (signaturesData.length == multisigData['confirmations'] &&
                signaturesData.last['signer'] == exgAddress) {
              pendingExecution = true;
            }
            return true;
          }
        }
      }
    }

    return false;
  }

  // show approve button if current wallet is one of the owners  and not the signer
  bool isShowApproveButton(currentQueue) {
    var multisigData = currentQueue['multisig'];
    var signaturesData = currentQueue['signatures'];
    for (var walletOwner in multisigData['owners']) {
      if (walletOwner['address'] == exgAddress) {
        for (var signature in signaturesData) {
          if (signature['signer'] != exgAddress) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // get queue transactions
  getQueueTransactions() async {
    setBusy(true);
    queue = await multisigService.getQueuetransaction(address);
    // log.i(
    //     'getQueueTransactions length ${queue.length} -- data ${queue[0]['request']['amount']}');

    setBusy(false);
  }

  // approve transaction
  approveTransaction(currentQueue, BuildContext context,
      {bool requiredExecution = false}) async {
    setBusy(true);
    var multisigData = currentQueue['multisig'];
    String chain = multisigData['chain'];
    var signaturesData = currentQueue['signatures'] as List;
    var transaction = currentQueue['transaction'];

    var seed = await walletService.getSeedDialog(context);
    if (seed == null) {
      setBusy(false);
      return;
    }
    bip32.BIP32 root = walletService.generateBip32Root(seed);
    var customHash = hashMultisigMessage(currentQueue["transactionHash"]);
    var ss = await MultisigUtil.signature(customHash, root);

    String signerAddress =
        MultisigUtil.isChainKanban(chain) ? exgAddress : ethAddress;
    var sig = MultisigUtil.adjustVInSignature(
      signingMethod: 'eth_sign',
      signature: ss,
      signerAddress: signerAddress,
    );
    var body = {
      "_id": currentQueue["_id"],
      "signer": signerAddress,
      "data": sig
    };

    var approvedSignatures = [];
    if (!requiredExecution) {
      try {
        var approveProposalResult = await multisigService.approveProposal(body);

        approvedSignatures = approveProposalResult['signatures'];
        log.w('approvedSignatures $approvedSignatures');

        sharedService.sharedSimpleNotification(
            'Transaction approved successfully',
            isError: false);
        queue = await getQueueTransactions();
        if (queue.first['_id'] == approveProposalResult['_id']) {
          log.i('latest queue ID matched');
          approvedSignatures = queue.first['signatures'] as List;
        }
      } catch (e) {
        log.e('approveProposalResult $e');
        sharedService.sharedSimpleNotification(
            'Transaction approved failed, please try again');
        setBusy(false);
        return;
      }
    }
// refactor execute code
    var finalSig = requiredExecution ? signaturesData : approvedSignatures;
    log.e('requiredExecution $requiredExecution');
    log.w('finalSig $finalSig');
    // check if confirmations <= signatures length then submit transaction to blockchain
    if (multisigData['confirmations'] <= finalSig.length) {
      String signatures = '0x';
      for (var signature in finalSig.reversed) {
        String data = signature['data'];
        signatures += data.substring(2);
      }
      log.w('signatures $signatures');

      var abiHex = MultisigUtil.encodeContractCall(transaction, signatures);
      if (true) {
        setBusy(false);
        return;
      }
      String gasPriceString =
          environment['chains'][chain]['gasPrice'].toString();

      BigInt gasPriceBig = BigInt.parse(gasPriceString);

      if (MultisigUtil.isChainKanban(chain)) {
        gasPriceBig = gasPriceBig * BigInt.from(10).pow(9);
      }

      log.w('Gas Price Big int: $gasPriceBig');
      var gas = environment['chains'][chain]['gasLimitToken'] ??
          environment['chains'][chain]['gasLimit'];
      var nonceAddress =
          MultisigUtil.isChainKanban(chain) ? exgAddress : ethAddress;
      var nonce = await multisigService.getChainNonce(
          chain.toLowerCase(), nonceAddress);
      // var txParam = {
      //   "to": multisigData["address"],
      //   "nonce": '0x' + nonce.toString(16),
      //   "value": '0x0',
      //   "gasPrice": '0x' + gasPriceBig.toRadixString(16),
      //   "gas": gas.toString(),
      //   "data": abiHex,
      // };
      // log.i('txParam $txParam');

      var keyPairKanban = getExgKeyPair(seed);
      var txKanbanHex = await signAbiHexWithPrivateKey(
        abiHex,
        HEX.encode(keyPairKanban["privateKey"]),
        environment["chains"][chain.toUpperCase()]["Safes"]["SafeProxyFactory"],
        nonce,
        int.parse(gasPriceString),
        gas,
      );

      var executionBody = {
        "_id": currentQueue["_id"],
        "chain": chain,
        "rawtx": txKanbanHex
      };

      var submitTransactionResult =
          await multisigService.submitMultisigTransaction(executionBody);
      log.w('submitTransactionResult $submitTransactionResult');
      var txid = submitTransactionResult['txid'];
      if (txid != null) {
        log.w('txid $txid');
        sharedService.sharedSimpleNotification(
            'Transaction submitted successfully',
            isError: false);
        onTap(1);
      } else {
        sharedService.sharedSimpleNotification('Transaction submitted failed');
      }
    } else {
      log.e(
          'confirmations <= finalSig.length -- ${multisigData['confirmations']} <= ${finalSig.length}');
      log.i('Not enough signatures to submit transaction');
    }
    setBusy(false);
  }
}
