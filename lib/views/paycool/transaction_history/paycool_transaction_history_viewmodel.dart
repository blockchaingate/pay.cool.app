import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/environments/environment.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/abi_util.dart';
import 'package:paycool/utils/kanban.util.dart';
import 'package:paycool/utils/keypair_util.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:paycool/views/paycool/transaction_history/paycool_transaction_history_model.dart';
import 'package:stacked/stacked.dart';
import 'package:hex/hex.dart';
import 'dart:typed_data';

class PayCoolTransactionHistoryViewModel extends FutureViewModel {
  final log = getLogger('PayCoolTransactionHistoryViewmodel');
  final payCoolService = locator<PayCoolService>();
  final sharedService = locator<SharedService>();
  final dialogService = locator<LocalDialogService>();
  WalletService walletService = locator<WalletService>();
  BuildContext context;
  String fabAddress = '';
  List<PayCoolTransactionHistoryModel> transactions = [];
  final bool _isShowRefundButton = false;
  bool get isShowRefundButton => _isShowRefundButton;
  String selectedTxOrderId = '';
  var apiRes;
  bool isProcessingAction = false;
  int decimalLimit = 8;

  @override
  Future futureToRun() async {
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    return await payCoolService.getPayTransactionDetails(fabAddress);
  }

  @override
  void onData(data) {
    transactions = data;
    if (transactions.isNotEmpty) log.w('data ${transactions[0].toJson()}');
  }

  showRefundButton(String orderId) {
    setBusy(true);
    selectedTxOrderId = '';
    // _isShowRefundButton = !_isShowRefundButton;
    selectedTxOrderId = orderId;
    log.w('order id $selectedTxOrderId');
    setBusy(false);
  }

/*----------------------------------------------------------------------
                      Request refund /  Cancel refund Reqesut 
----------------------------------------------------------------------*/

  txAction(String orderId, String smartContractAddress,
      {bool isCancel = false}) async {
    setBusy(true);
    isProcessingAction = true;
    log.i(
        'requestRefund orderId $orderId -- smart contract Address $smartContractAddress');
    String abiHex = isCancel
        ? constructPaycoolCancelAbiHex(orderId)
        : constructPaycoolRefundAbiHex(orderId);
    log.i('abi hex $abiHex');
    await dialogService
        .showDialog(
            title: FlutterI18n.translate(context, "enterPassword"),
            description: FlutterI18n.translate(
                context, "dialogManagerTypeSamePasswordNote"),
            buttonTitle: FlutterI18n.translate(context, "confirm"))
        .then((passRes) async {
      if (passRes.confirmed) {
        String mnemonic = passRes.returnedText;

        var seed = walletService.generateSeed(mnemonic);
        var keyPairKanban = getExgKeyPair(Uint8List.fromList(seed));
        debugPrint('keyPairKanban $keyPairKanban');
        int kanbanGasPrice = environment["chains"]["KANBAN"]["gasPrice"];
        int kanbanGasLimit = environment["chains"]["KANBAN"]["gasLimit"];
        var txKanbanHex;
        String exgAddress =
            await sharedService.getExgAddressFromCoreWalletDatabase();
        var nonce = await getNonce(exgAddress);
        try {
          txKanbanHex = await signAbiHexWithPrivateKey(
              abiHex,
              HEX.encode(keyPairKanban["privateKey"]),
              smartContractAddress,
              nonce,
              kanbanGasPrice,
              kanbanGasLimit);

          log.i('txKanbanHex $txKanbanHex');
        } catch (err) {
          setBusy(false);
          log.e('err $err');
        }

        var resBody = await sendPayCoolRawTransaction(txKanbanHex);
        var res = resBody['_body'];
        var txHash = res['transactionHash'];
        //{"ok":true,"_body":{"transactionHash":"0x855f2d8ec57418670dd4cb27ecb71c6794ada5686e771fe06c48e30ceafe0548","status":"0x1"}}

        debugPrint('res $res');
        if (res['status'] == '0x1') {
          sharedService.sharedSimpleNotification(
              FlutterI18n.translate(context, "success"),
              isError: false);
          if (!isCancel) {
            var selectedTxToUpdate =
                transactions.singleWhere((t) => t.id == orderId);
            selectedTxToUpdate.status = 2;
          } else if (isCancel) {
            var selectedTxToUpdate =
                transactions.singleWhere((t) => t.id == orderId);
            selectedTxToUpdate.status = 1;
          }
          //  await futureToRun();
        } else if (res['status'] == '0x0') {
          sharedService.sharedSimpleNotification(
              FlutterI18n.translate(context, "failed"),
              isError: true);
        }
        var errMsg = res['errMsg'];
        // if (txHash != null && txHash != '') {
        //   setBusy(true);
        //   apiRes = txHash;
        //   setBusy(false);
        //   showSimpleNotification(
        //       Text(
        //           FlutterI18n.translate(context, "placeOrderTransactionSuccessful")),
        //       position: NotificationPosition.bottom);
        // }
      } else if (passRes.returnedText == 'Closed' && !passRes.confirmed) {
        log.e('Dialog Closed By User');

        setBusy(false);
      } else {
        log.e('Wrong pass');
        setBusy(false);

        sharedService.sharedSimpleNotification(
            FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword"),
            isError: true);
      }
    });
    isProcessingAction = false;
    setBusy(false);
  }
}
