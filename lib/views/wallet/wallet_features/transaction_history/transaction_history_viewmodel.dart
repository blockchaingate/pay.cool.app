import 'dart:io';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/transaction_history.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/transaction_history_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/utils/wallet/wallet_util.dart';
import 'package:paycool/widgets/pagination/pagination_model.dart';

import 'package:stacked/stacked.dart';
import 'package:paycool/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/services/db/user_settings_database_service.dart';

import 'package:overlay_support/overlay_support.dart';

class TransactionHistoryViewmodel extends FutureViewModel {
  final String? tickerName;
  final String success = 'success';
  final String lightningRemit = 'Lightning Remit';
  final String send = 'send';
  final String pending = 'pending';
  final String withdraw = 'withdraw';
  final String deposit = 'deposit';
  final String rejected = 'rejected or failed';

  TransactionHistoryViewmodel({this.tickerName});
  final log = getLogger('TransactionHistoryViewmodel');
  late BuildContext context;
  List<TransactionHistory> transactionsToDisplay = [];
  TransactionHistoryDatabaseService transactionHistoryDatabaseService =
      locator<TransactionHistoryDatabaseService>();
  WalletDatabaseService walletDataBaseService =
      locator<WalletDatabaseService>();
  final walletService = locator<WalletService>();
  final apiService = locator<ApiService>();
  SharedService sharedService = locator<SharedService>();
  final navigationService = locator<NavigationService>();
  final userSettingsDatabaseService = locator<UserSettingsDatabaseService>();
  final coinService = locator<CoinService>();
  PaginationModel paginationModel = PaginationModel();
  WalletInfo walletInfo = WalletInfo();
  bool isChinese = false;
  bool isDialogUp = false;
  int decimalLimit = 8;

  @override
  Future futureToRun() async =>
      // tickerName.isEmpty ?
      await transactionHistoryDatabaseService.getByName(tickerName!);

/*----------------------------------------------------------------------
                  After Future Data is ready
----------------------------------------------------------------------*/
  @override
  void onData(data) async {
    setBusy(true);
    log.i('tx length ${data.length}');
    List<TransactionHistory> txHistoryFromDb = [];
    List<TransactionHistory> txHistoryEvents = [];
    txHistoryFromDb = data;
    txHistoryEvents = await apiService.getTransactionHistoryEvents();
    if (txHistoryEvents.isNotEmpty) {
      for (var txFromApi in txHistoryEvents) {
        if (txFromApi.tickerName == tickerName) {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'ETH_DSC' &&
            tickerName == 'DSCE') {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'ETH_BST' &&
            tickerName == 'BSTE') {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'ETH_FAB' &&
            tickerName == 'FABE') {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'ETH_EXG' &&
            tickerName == 'EXGE') {
          // element.tickerName = 'EXG(ERC20)';
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'TRON_USDT' &&
            tickerName == 'USDTX') {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'TRON_USDC' &&
            tickerName == 'USDCX') {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'BNB_USDT' &&
            tickerName == 'USDTB') {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'MATIC_USDT' &&
            tickerName == 'USDTM') {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'BNB_FAB' &&
            tickerName == 'FABB') {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'BNB_GET' &&
            tickerName == 'GETB') {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'BNB_FET' &&
            tickerName == 'FETB') {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'POLYGON_MATIC' &&
            tickerName == 'MATICM') {
          transactionsToDisplay.add(txFromApi);
        } else if (txFromApi.tickerName.toUpperCase() == 'POLYGON_USDT' &&
            tickerName == 'USDTM') {
          transactionsToDisplay.add(txFromApi);
        }
      }
    }
    for (var t in txHistoryFromDb) {
      if (t.tag == 'send' && t.tickerName == tickerName) {
        transactionsToDisplay.add(t);
      }
    }

    transactionsToDisplay.sort(
        (a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    try {
      await userSettingsDatabaseService.getLanguage().then((value) {
        if (value == 'zh') isChinese = true;
      });
    } catch (err) {
      log.e('CATCH failed to get lang from user settings db');
    }
    decimalLimit = await coinService
        .getSingleTokenData(tickerName!)
        .then((res) => res!.decimal!);
    if (decimalLimit == 0) decimalLimit = 8;
    setBusy(false);
    // debugPrint(transactionHistoryToShowInView.first.toJson());
  }

  getPaginationTransactions(int pageNumber) async {
    setBusy(true);
    paginationModel.pageNumber = pageNumber;
    await futureToRun();

    setBusy(false);
  }

  reloadTransactions() async {
    clearLists();
    await futureToRun();
    onData(data);
  }

  clearLists() {
    transactionsToDisplay = [];
  }

/*----------------------------------------------------------------------
                  Update special tokens ticker
----------------------------------------------------------------------*/
  updateTickers(String ticker) {
    return WalletUtil.updateSpecialTokensTickerName(ticker)['tickerName'];
  }

/*----------------------------------------------------------------------
                  Get transaction
----------------------------------------------------------------------*/
  getTransaction(String tickerName) async {
    setBusy(true);
    transactionsToDisplay = [];
    await transactionHistoryDatabaseService
        .getByNameOrderByDate(tickerName)
        .then((data) async {
      transactionsToDisplay = data;
      await sharedService
          .getSinglePairDecimalConfig(tickerName)
          .then((decimalConfig) => decimalConfig = decimalConfig);

      for (var t in transactionsToDisplay) {
        log.e(t.toJson);
        if (t.tag.startsWith('sent')) {
          await walletService.checkTxStatus(t);
        }
      }
      transactionsToDisplay.sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
      for (var t in transactionsToDisplay) {
        log.w(t.toJson);
      }
      setBusy(false);
    }).catchError((onError) {
      setBusy(false);
      log.e(onError);
    });
  }

/*----------------------------------------------------------------------
                  Copy Address
----------------------------------------------------------------------*/
  copyAddress(String txId) {
    Clipboard.setData(ClipboardData(text: txId));
    showSimpleNotification(
        Center(
            child: Text(FlutterI18n.translate(context, "copiedSuccessfully"),
                style: headText5)),
        position: NotificationPosition.bottom,
        background: primaryColor);
  }

/*----------------------------------------------------------------------
                Tx Detail Dialog
----------------------------------------------------------------------*/
  showTxDetailDialog(TransactionHistory transactionHistory) {
    setBusy(true);
    isDialogUp = true;
    log.i('showTxDetailDialog isDialogUp $isDialogUp');
    setBusy(false);
    if (transactionHistory.chainName.isEmpty) {
      transactionHistory.chainName = (walletInfo.tokenType!.isEmpty
          ? walletInfo.tickerName
          : walletInfo.tokenType)!;
      log.i(
          'transactionHistory.chainName empty so showing wallet token type ${walletInfo.tokenType}');
    }
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? Theme(
                  data: ThemeData.light(),
                  child: CupertinoAlertDialog(
                    title: Container(
                      child: Center(
                          child: Text(
                        FlutterI18n.translate(context, "transactionDetails"),
                        style: headText4.copyWith(
                            color: primaryColor, fontWeight: FontWeight.w500),
                      )),
                    ),
                    content: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          UIHelper.verticalSpaceSmall,
                          transactionHistory.tag != send
                              ? Text(
                                  '${FlutterI18n.translate(context, "kanban")} ${FlutterI18n.translate(context, "transactionId")}',
                                  style: headText5,
                                )
                              : Container(),
                          transactionHistory.tag != send
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: RichText(
                                          text: TextSpan(
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                launchUrl(
                                                    transactionHistory
                                                        .kanbanTxId,
                                                    transactionHistory
                                                        .chainName,
                                                    true);
                                              },
                                            text: transactionHistory
                                                    .kanbanTxId!.isEmpty
                                                ? transactionHistory
                                                        .kanbanTxStatus!.isEmpty
                                                    ? FlutterI18n.translate(
                                                        context, "inProgress")
                                                    : firstCharToUppercase(
                                                        transactionHistory
                                                            .kanbanTxStatus)
                                                : transactionHistory.kanbanTxId
                                                    .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ),
                                    transactionHistory.kanbanTxId.isEmpty
                                        ? Container()
                                        : CupertinoButton(
                                            child: const Icon(
                                                FontAwesomeIcons.copy,
                                                color: black,
                                                size: 16),
                                            onPressed: () => copyAddress(
                                                transactionHistory.kanbanTxId),
                                          )
                                  ],
                                )
                              : Container(),
                          UIHelper.verticalSpaceMedium,
                          Text(
                            //FlutterI18n.translate(context, "quantity"),FlutterI18n.translate(context, "quantity")
                            '${transactionHistory.chainName} ${FlutterI18n.translate(context, "chain")} ${FlutterI18n.translate(context, "transactionId")}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: RichText(
                                    text: TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launchUrl(
                                              transactionHistory
                                                  .tickerChainTxId!,
                                              transactionHistory.chainName,
                                              false);
                                        },
                                      text: transactionHistory
                                              .tickerChainTxId!.isEmpty
                                          ? transactionHistory
                                                  .tickerChainTxStatus!.isEmpty
                                              ? FlutterI18n.translate(
                                                  context, "inProgress")
                                              : transactionHistory
                                                  .tickerChainTxStatus
                                          : transactionHistory.tickerChainTxId
                                              .toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ),
                              transactionHistory.tickerChainTxId!.isEmpty
                                  ? Container()
                                  : CupertinoButton(
                                      child: const Icon(FontAwesomeIcons.copy,
                                          color: black, size: 16),
                                      onPressed: () => copyAddress(
                                          transactionHistory.tickerChainTxId!),
                                    )
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CupertinoButton(
                              padding: const EdgeInsets.only(left: 5),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: Text(
                                FlutterI18n.translate(context, "close"),
                                style: headText5.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : AlertDialog(
                  titlePadding: EdgeInsets.zero,
                  contentPadding: const EdgeInsets.all(5.0),
                  elevation: 5,
                  backgroundColor: secondaryColor,
                  title: Container(
                    padding: const EdgeInsets.all(10.0),
                    color: secondaryColor.withOpacity(0.5),
                    child: Center(
                        child: Text(FlutterI18n.translate(
                            context, "transactionDetails"))),
                  ),
                  titleTextStyle:
                      headText4.copyWith(fontWeight: FontWeight.bold),
                  contentTextStyle: const TextStyle(color: grey),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      transactionHistory.tag != send
                          ? Text(
                              //FlutterI18n.translate(context, "t")).,
                              '${FlutterI18n.translate(context, "kanban")} ${FlutterI18n.translate(context, "transactionId")}',
                              style: headText5,
                            )
                          : Container(),
                      transactionHistory.tag != send
                          ? Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 8.0),
                                    child: RichText(
                                      text: TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launchUrl(
                                                transactionHistory.kanbanTxId,
                                                transactionHistory.chainName,
                                                true);
                                          },
                                        text: transactionHistory
                                                .kanbanTxId.isEmpty
                                            ? transactionHistory
                                                    .kanbanTxStatus.isEmpty
                                                ? FlutterI18n.translate(
                                                    context, "inProgress")
                                                : firstCharToUppercase(
                                                    transactionHistory
                                                        .kanbanTxStatus)
                                            : transactionHistory.kanbanTxId
                                                .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                ),
                                transactionHistory.kanbanTxId.isEmpty
                                    ? Container()
                                    : IconButton(
                                        icon: const Icon(Icons.copy_outlined,
                                            color: black, size: 16),
                                        onPressed: () => copyAddress(
                                            transactionHistory.kanbanTxId),
                                      )
                              ],
                            )
                          : Container(),
                      UIHelper.verticalSpaceMedium,
                      Text(
                        //FlutterI18n.translate(context, "quantity"),FlutterI18n.translate(context, "quantity")
                        '${transactionHistory.chainName} ${FlutterI18n.translate(context, "chain")} ${FlutterI18n.translate(context, "transactionId")}',
                        style: headText5,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 8.0),
                              child: RichText(
                                text: TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(
                                          transactionHistory.tickerChainTxId!,
                                          transactionHistory.chainName,
                                          false);
                                    },
                                  text: transactionHistory
                                          .tickerChainTxId!.isEmpty
                                      ? transactionHistory
                                              .tickerChainTxStatus!.isEmpty
                                          ? FlutterI18n.translate(
                                              context, "inProgress")
                                          : transactionHistory
                                              .tickerChainTxStatus
                                      : transactionHistory.tickerChainTxId
                                          .toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(color: Colors.blue),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_outlined,
                                color: black, size: 16),
                            onPressed: () => copyAddress(
                                transactionHistory.tickerChainTxId!),
                          )
                        ],
                      ),
                      UIHelper.verticalSpaceMedium,
                      TextButton(
                        onPressed: () {
                          setBusy(true);
                          Navigator.of(context).pop();
                          isDialogUp = false;
                          setBusy(false);
                        },
                        child: Text(
                          FlutterI18n.translate(context, "close"),
                          style: const TextStyle(color: red),
                        ),
                      )
                    ],
                  ));
        });
  }

/*----------------------------------------------------------------------
                  Launch URL
----------------------------------------------------------------------*/
  launchUrl(String txId, String chain, bool isKanban) async {
    // copyAddress(txId);
    if (isKanban) {
      String exchangilyExplorerUrl = ExchangilyExplorerUrl + txId;
      log.i('Kanban - explorer url - $exchangilyExplorerUrl');
      openExplorer(exchangilyExplorerUrl);
    } else if (chain.toUpperCase() == 'FAB') {
      String fabExplorerUrl = FabExplorerUrl + txId;
      log.i('FAB - chainame $chain explorer url - $fabExplorerUrl');
      openExplorer(fabExplorerUrl);
    } else if (chain.toUpperCase() == 'BTC') {
      String bitcoinExplorerUrl = BitcoinExplorerUrl + txId;
      log.i('BTC - chainame $chain explorer url - $bitcoinExplorerUrl');
      openExplorer(bitcoinExplorerUrl);
    } else if (chain.toUpperCase() == 'ETH') {
      String ethereumExplorerUrl = isProduction
          ? EthereumExplorerUrl + txId
          : TestnetEthereumExplorerUrl + txId;
      log.i('ETH - chainame $chain explorer url - $ethereumExplorerUrl');
      openExplorer(ethereumExplorerUrl);
    } else if (chain.toUpperCase() == 'BNB') {
      log.i('chainame $chain explorer url - ${bnbExplorerUrl + txId}');
      openExplorer(bnbExplorerUrl + txId);
    } else if (chain.toUpperCase() == 'MATICM' ||
        chain.toUpperCase() == 'POLYGON') {
      log.i('chainame $chain explorer url - ${maticmExplorerUrl + txId}');
      openExplorer(maticmExplorerUrl + txId);
    } else if (chain.toUpperCase() == 'LTC') {
      String litecoinExplorerUrl = LitecoinExplorerUrl + txId;
      log.i('LTC - chainame $chain explorer url - $litecoinExplorerUrl');
      openExplorer(litecoinExplorerUrl);
    } else if (chain.toUpperCase() == 'DOGE') {
      String dogeExplorerUrl = DogeExplorerUrl + txId;
      log.i('doge - chainame $chain explorer url - $dogeExplorerUrl');
      openExplorer(dogeExplorerUrl);
    } else if (chain.toUpperCase() == 'TRON' || chain.toUpperCase() == 'TRX') {
      if (txId.startsWith('0x')) {
        txId = txId.substring(2);
      }
      String tronExplorerUrl = TronExplorerUrl + txId;
      log.i('tron - chainame $chain explorer url - $tronExplorerUrl');
      openExplorer(tronExplorerUrl);
    } else if (chain.toUpperCase() == 'BCH') {
      String bitcoinCashExplorerUrl = BitcoinCashExplorerUrl + txId;
      log.i('BCH - chainame $chain explorer url - $bitcoinCashExplorerUrl');
      openExplorer(bitcoinCashExplorerUrl);
    } else {
      throw 'Could not launch';
    }
  }

  // launch url
  openExplorer(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
