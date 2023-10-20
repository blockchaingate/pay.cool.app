import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:pagination_widget/pagination_widget.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/coin_util.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:paycool/views/paycool/transaction_history/paycool_transaction_history_model.dart';
import 'package:stacked/stacked.dart';

class PayCoolTransactionHistoryViewModel extends FutureViewModel {
  final log = getLogger('PayCoolTransactionHistoryViewmodel');
  final payCoolService = locator<PayCoolService>();
  final sharedService = locator<SharedService>();
  final dialogService = locator<LocalDialogService>();
  WalletService walletService = locator<WalletService>();
  final tokenService = locator<TokenListDatabaseService>();
  BuildContext? context;
  String fabAddress = '';
  List<PayCoolTransactionHistory> transactions = [];
  bool _isShowRefundButton = false;
  bool get isShowRefundButton => _isShowRefundButton;
  String selectedTxOrderId = '';
  var apiRes;
  bool isProcessingAction = false;
  int decimalLimit = 8;
  final coinService = locator<CoinService>();
  PaginationModel paginationModel = PaginationModel();

  int pageNumber = 1;
  int pageSize = 10;
  int _totalTransactionsCount = 0;
  String prevId = '';

  @override
  Future futureToRun() async {
    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    return await payCoolService.getTransactionHistory(fabAddress,
        pageSize: paginationModel.pageSize,
        pageNumber: paginationModel.pageNumber);
  }

  @override
  void onData(data) async {
    transactions = data;
    if (transactions.isNotEmpty) log.w('data ${transactions[0].toJson()}');
    for (var transaction in transactions) {
      if (transaction.tickerName!.isEmpty) {
        var res = await tokenService.getByCointype(transaction.coinType);
        transaction.tickerName = res!.coinName!.toUpperCase();
        log.w('missing tickername acquired ${transaction.tickerName}');
      }
    }
    _totalTransactionsCount =
        await payCoolService.getTransactionHistoryCount(fabAddress);
    paginationModel.totalPages =
        (_totalTransactionsCount / paginationModel.pageSize).ceil();
    paginationModel.pages = [];
    paginationModel.pages.addAll(transactions);
    log.i('paginationModel ${paginationModel.toString()}');
    setBusy(false);
    notifyListeners();
  }

  Future<String?> getCt(int coinType) async {
    var res = await coinService.getSingleTokenData('', coinType: coinType);
    return res!.coinName;
  }

  showRefundButton(String orderId) {
    prevId = selectedTxOrderId;

    selectedTxOrderId = orderId;

    //
    if (prevId == selectedTxOrderId) _isShowRefundButton = !_isShowRefundButton;
    if (prevId != selectedTxOrderId) _isShowRefundButton = true;
    log.w(
        'order id $selectedTxOrderId --_isShowRefundButton $_isShowRefundButton ');
    rebuildUi();
  }

  getPaginationRewards(int pageNumber) async {
    setBusy(true);
    paginationModel.pageNumber = pageNumber;
    var paginationResults = await futureToRun();
    transactions = paginationResults;

    setBusy(false);
  }

/*----------------------------------------------------------------------
                      Request refund /  Cancel refund Reqesut 
----------------------------------------------------------------------*/

  refund(String orderId, String smartContractAddress,
      {bool isCancel = false}) async {
    setBusy(true);
    isProcessingAction = true;
    log.i(
        'requestRefund orderId $orderId -- smart contract Address $smartContractAddress');
    String randomId = StringUtils.generateRandomHexString();
    log.i('randomId $randomId');
    //var id = "89d7e2530fc14714db77bc40b53c65ec27e4c39544278c90f4355a1e10dd8376";

    var hash = hashCustomMessage(randomId);
    log.w('hashKanbanMessage $hash');

    await dialogService
        .showDialog(
            title: FlutterI18n.translate(context!, "enterPassword"),
            description: FlutterI18n.translate(
                context!, "dialogManagerTypeSamePasswordNote"),
            buttonTitle: FlutterI18n.translate(context!, "confirm"))
        .then((passRes) async {
      if (passRes.confirmed) {
        String mnemonic = passRes.returnedText;

        var seed = walletService.generateSeed(mnemonic);
        Map<String, String> signature = {};
        // var keyPairKanban = getExgKeyPair(Uint8List.fromList(seed));
        // debugPrint('keyPairKanban $keyPairKanban');
        // int kanbanGasPrice = environment["chains"]["KANBAN"]["gasPrice"];
        // int kanbanGasLimit = environment["chains"]["KANBAN"]["gasLimit"];

        // String exgAddress =
        //     await sharedService.getExgAddressFromCoreWalletDatabase();
        //  var nonce = await getNonce(exgAddress);
        try {
          signature =
              await signHashKanbanMessage(seed, hash, isMsgSignatureType: true);

          log.i(' KanbanHex signature $signature');
        } catch (err) {
          setBusy(false);
          log.e('err $err');
        }

        var res =
            await payCoolService.applyRefund(orderId, randomId, signature);
        // await sendKanbanRawTransaction(baseBlockchainGateV2Url, signature);
        // var res = resBody['_body'];
        // var txHash = res['transactionHash'];
        //{"ok":true,"_body":{"transactionHash":"0x855f2d8ec57418670dd4cb27ecb71c6794ada5686e771fe06c48e30ceafe0548","status":"0x1"}}

        log.w('refund post res $res');

        if (res!.refunds!.isNotEmpty) {
          for (var tx in transactions) {
            if (tx.orderId == res.id) {
              tx.refunds = res.refunds;
              rebuildUi();
            }
          }
          sharedService.sharedSimpleNotification(
              FlutterI18n.translate(context!, "success"),
              isError: false);
        } else {
          sharedService.sharedSimpleNotification(
              FlutterI18n.translate(context!, "failed"),
              isError: true);
        }

        // if (res['status'] == '0x1') {
        //   sharedService.sharedSimpleNotification(
        //       FlutterI18n.translate(context, "success"),
        //       isError: false);
        //   if (!isCancel) {
        //     var selectedTxToUpdate =
        //         transactions.singleWhere((t) => t.id == orderId);
        //     selectedTxToUpdate.status = 2;
        //   } else if (isCancel) {
        //     var selectedTxToUpdate =
        //         transactions.singleWhere((t) => t.id == orderId);
        //     selectedTxToUpdate.status = 1;
        //   }
        //   //  await futureToRun();
        // } else if (res['status'] == '0x0') {
        //   sharedService.sharedSimpleNotification(
        //       FlutterI18n.translate(context, "failed"),
        //       isError: true);
        // }
        // var errMsg = res['errMsg'];
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
            FlutterI18n.translate(context!, "pleaseProvideTheCorrectPassword"),
            isError: true);
      }
    });
    isProcessingAction = false;
    setBusy(false);
  }
}
