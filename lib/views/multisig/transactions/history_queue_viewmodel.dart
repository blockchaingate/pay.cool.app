import 'package:flutter/widgets.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/views/multisig/multisig_util.dart';
import 'package:stacked/stacked.dart';
import 'package:bip32/bip32.dart' as bip32;
import '../../../services/multisig_service.dart';

class MultisigHistoryQueueViewModel extends FutureViewModel {
  final String address;
  MultisigHistoryQueueViewModel({required this.address});

  final sharedService = locator<SharedService>();
  final walletService = locator<WalletService>();
  List history = [];
  List queue = [];

  final log = getLogger('HistoryQueueViewModel');
  final multisigService = locator<MultiSigService>();
  String exgAddress = '';
  String ethAddress = '';
  @override
  Future futureToRun() async =>
      await multisigService.getmultisigTransactions(address);

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
    var multisigData = currentQueue['multisig'];
    var signaturesData = currentQueue['signatures'];
    for (var walletOwner in multisigData['owners']) {
      if (walletOwner['address'] == exgAddress) {
        for (var signature in signaturesData) {
          if (signature['signer'] == exgAddress) {
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
  approveTransaction(currentQueue, BuildContext context) async {
    setBusy(true);
    var multisigData = currentQueue['multisig'];
    var signaturesData = currentQueue['signatures'] as List;
    var transaction = currentQueue['transaction'];

    var seed = await walletService.getSeedDialog(context);

    bip32.BIP32 root = walletService.generateBip32Root(seed!);
    var ss =
        await MultisigUtil.signature(currentQueue["transactionHash"], root);

    String chain = multisigData['chain'];
    String signerAddress =
        chain.toLowerCase() == 'kanban' ? exgAddress : ethAddress;
    var sig = await multisigService.adjustVInSignature(
      signingMethod: 'eth_sign',
      signature: ss,
      signerAddress: signerAddress,
    );
    var body = {
      "_id": currentQueue["_id"],
      "signer": signerAddress,
      "data": sig
    };

    var approveProposalResult = await multisigService.approveProposal(body);
    log.w('approveProposalResult $approveProposalResult');
    var approvedSignatures = [1, 2];
    // approveProposalResult['signatures'];
    // check if confirmations <= signatures length then submit transaction to blockchain
    if (multisigData['confirmations'] <= approvedSignatures.length) {
      String signatures = '0x';
      for (var signature in signaturesData) {
        String data = signature['data'];
        signatures += data.substring(2);
      }
      var abiHex = MultisigUtil.transferABI(transaction, signatures);

      String gasPriceString =
          environment['chains'][chain]['gasPrice'].toString();

      BigInt gasPriceBig = BigInt.parse(gasPriceString);

      if (chain.toUpperCase() != 'KANBAN') {
        gasPriceBig = gasPriceBig * BigInt.from(10).pow(9);
      }

      log.w('Gas Price Big int: $gasPriceBig');
      var txParam = {
        "to": multisigData["address"],
        "nonce": '0x' + nonce.toString(16),
        "value": '0x0',
        "data": abiHex,
        "gasPrice": '0x' + gasPriceBig.toRadixString(16),
        "gas": environment['chains'][chain]['gasLimitToken'].toString()
      };

      var bodyExecute = {
        "_id": currentQueue["_id"],
        "chain": chain,
        "rawTx": rawTx
      };
      // var submitTransactionResult =
      //     await multisigService.submitMultisigTransaction(bodyExecute);
      // log.w('submitTransactionResult $submitTransactionResult');
    }
    setBusy(false);
  }
}
