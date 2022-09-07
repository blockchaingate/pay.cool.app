import 'dart:io';
import 'dart:typed_data';
import 'package:exchangily_core/exchangily_core.dart';
import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paycool/constants/paycool_api_routes.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/utils/barcode_util.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';
import 'package:paycool/views/paycool/models/paycool_store_model.dart';
import 'package:paycool/views/paycool/models/paycool_model.dart';
import 'package:paycool/views/paycool/models/store_and_merchant_model.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';

import '../../constants/paycool_constants.dart';

class PayCoolViewmodel extends FutureViewModel {
  final log = getLogger('PayCoolViewmodel');

  final addressController = TextEditingController();
  ApiService apiService = localLocator<ApiService>();
  NavigationService navigationService = localLocator<NavigationService>();
  TokenDatabaseService tokenListDatabaseService =
      localLocator<TokenDatabaseService>();
  SharedService sharedService = localLocator<SharedService>();
  LocalStorageService storageService = localLocator<LocalStorageService>();
  TransactionHistoryDatabaseService transactionHistoryDatabaseService =
      localLocator<TransactionHistoryDatabaseService>();
  WalletDatabaseService walletDataBaseService =
      localLocator<WalletDatabaseService>();
  final dialogService = localLocator<DialogService>();
  WalletService walletService = localLocator<WalletService>();
  final payCoolService = localLocator<PayCoolService>();
  final payCoolClubService = localLocator<PayCoolClubService>();
  final userSettingsDatabaseService =
      localLocator<UserSettingsDatabaseService>();
  final environmentService = locator<EnvironmentService>();
  final tokenService = locator<TokenService>();

  String tickerName = '';
  BuildContext context;
  Decimal quantity = Constants.decimalZero;
  GlobalKey globalKey = GlobalKey();
  ScrollController scrollController;
  String loadingStatus = '';

  // var barcodeRes = [];
  //var barcodeRes2;
  var walletBalancesBody;
  // bool isShowBottomSheet = false;

  List<TransactionHistory> transactionHistory = [];
  String abiHex;
  var seed = [];
  bool isMember = false;
  bool isAutoStartPaycoolScan;
  Decimal amountPayable = Constants.decimalZero;
  Decimal taxAmount = Constants.decimalZero;
  String coinPayable = '';
  final referralController = TextEditingController();

  String fabAddress = '';
  var apiRes;
  // ScanToPayModel scanToPayModel = ScanToPayModel();
  var pasteRes;

  List<ExchangeBalanceModel> exchangeBalances = [];
  //var decodedData;
  StoreInfoModel storeInfoModel = StoreInfoModel();
  String lang = '';
  bool isPaying = false;
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int decimalLimit = 8;
  var fabUtils = FabUtils();
  ScanToPayModelV2 scanToPayModelV2 = ScanToPayModelV2();
  String orderId = '';
  StoreMerchantModel storeMerchangeModel = StoreMerchantModel();
  String orderIdFromCreateStoreOrder = '';
  bool isScanningImage = false;
  bool isServerDown = false;

/*----------------------------------------------------------------------
                    Default Future to Run
----------------------------------------------------------------------*/
  @override
  Future futureToRun() async =>
      await apiService.getAssetsBalance(environmentService.kanbanBaseUrl(), '');

/*----------------------------------------------------------------------
                          INIT
----------------------------------------------------------------------*/

  init() async {
    sharedService.context = context;

    storageService.autoStartPaycoolScan == null
        ? isAutoStartPaycoolScan = false
        : isAutoStartPaycoolScan = storageService.autoStartPaycoolScan;
    await userSettingsDatabaseService.getById(1).then((res) {
      if (res != null) {
        lang = res.language ?? "en";
        log.i('user settings db not null');
      }
    });
    if (lang == null || lang.isEmpty) {
      lang = "en";
    }
  }

/*----------------------------------------------------------------------
                  After Future Data is ready
----------------------------------------------------------------------*/
  @override
  void onData(data) async {
    setBusy(true);
    setBusyForObject(exchangeBalances, true);

    exchangeBalances = [];
    data.forEach((ExchangeBalanceModel wallet) async {
      log.w('onData func - ${wallet.toJson().toString()}');
      if (wallet.ticker.isEmpty) {
        tokenListDatabaseService
            .getTickerNameByCoinType(wallet.coinType)
            .then((ticker) {
          //storageService.tokenList.forEach((newToken){
          debugPrint(ticker);
          // var json = jsonDecode(newToken);
          // Token token = Token.fromJson(json);
          // if (token.tokenType == element.coinType){ debugPrint(token.tickerName);

          wallet.ticker = ticker; //}
        });
//element.ticker =tradeService.setTickerNameByType(element.coinType);
        debugPrint('exchanageBalanceModel tickerName ${wallet.ticker}');
      }
      if (wallet.unlockedAmount > Constants.decimalZero) {
        exchangeBalances.add(wallet);
      }
    });
    setBusyForObject(exchangeBalances, false);
    setBusyForObject(tickerName, true);

    if (exchangeBalances != null && exchangeBalances.isNotEmpty) {
      tickerName = exchangeBalances[0].ticker;

      quantity = exchangeBalances[0].unlockedAmount;
    }

    setBusyForObject(tickerName, false);

    log.e('tickerName $tickerName');

    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();

    await isValidMember();

    setBusy(false);
  }

  scanImageFile() async {
    // Pick an image
    setBusyForObject(isScanningImage, true);
    String _qrcodeFile = '';
    final File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _qrcodeFile = image.path;
      log.w(_qrcodeFile);
    }
    try {
      var barcodeScanData = await QrCodeToolsPlugin.decodeFrom(_qrcodeFile);
      log.i(barcodeScanData);
      orderDetails(barcodeScanData: barcodeScanData);
    } catch (err) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "validationError"));
      log.e('QrCodeToolsPlugin Catch $err');
    }
    setBusyForObject(isScanningImage, false);
  }

  isValidMember() async {
    setBusy(true);
    isServerDown = false;
    if (fabAddress.isEmpty) {
      fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    }
    try {
      await payCoolClubService
          .isValidReferralCode(fabAddress, isValidStarPayMemeberCheck: true)
          .then((value) {
        isMember = value;

        if (isMember && isAutoStartPaycoolScan) {
          debugPrint("This user is member!");
          debugPrint(
              "isAutoStartPaycoolScan: " + isAutoStartPaycoolScan.toString());

          scanBarcodeV2();
        }
        log.i('isValidMember code(member)  $isMember');
      });
    } catch (err) {
      log.e('isValidMember CATCh $err');
      isServerDown = true;
    }

    setBusy(false);
  }

  createReferral() async {
    setBusy(true);
    bool isValidReferralAddress = false;
    if (referralController.text.isEmpty) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "invalidReferralCode"));
      setBusy(false);
      return;
    }
    await payCoolClubService
        .isValidReferralCode(referralController.text,
            isValidStarPayMemeberCheck: true)
        .then((value) {
      if (value != null) {
        log.w('isValid paymember: $value');

        isValidReferralAddress = value;
      }
    });
    if (!isValidReferralAddress) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "invalidReferralCode"));
      setBusy(false);
      return;
    }

    await dialogService
        .showDialog(
            title: FlutterI18n.translate(context, "enterPassword"),
            description: FlutterI18n.translate(
                context, "dialogManagerTypeSamePasswordNote"),
            buttonTitle: FlutterI18n.translate(context, "confirm"))
        .then((res) async {
      if (res.confirmed) {
        var seed;
        String mnemonic = res.returnedText;

        seed = MnemonicUtils.generateSeed(mnemonic);
        var bodySig;
        var parentIdString = "parentId=${referralController.text}";
        try {
          Uint8List bodySigUint;
          await CoinUtils.signKanbanMessage(
                  Uint8List.fromList(seed), parentIdString)
              .then((res) => bodySigUint = res);
          bodySig = uint8ListToHex(bodySigUint);
          await payCoolService
              .createStarPayReferral(bodySig, referralController.text)
              .then((res) async {
            apiRes = res;
            if (fabAddress == null || fabAddress.isEmpty) {
              fabAddress =
                  await sharedService.getFabAddressFromCoreWalletDatabase();
            }
            if (apiRes["id"] == fabAddress) {
              isMember = true;
            } else {
              sharedService.sharedSimpleNotification(
                  FlutterI18n.translate(context, "failed"));
              apiRes = apiRes["message"] ?? '';
            }
          });
        } catch (err) {
          log.e('create ref CATCH $err');
          setBusy(false);
        }
      } else if (res.returnedText == 'Closed' && !res.confirmed) {
        log.e('Dialog Closed By User');

        setBusy(false);
      } else {
        log.e('Wrong pass');
        setBusy(false);

        sharedService.sharedSimpleNotification(
            FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword"));
      }
    }).catchError((error) {
      log.e(error);

      setBusy(false);
    });
    setBusy(false);
  }

  payOrder() async {
    setBusy(true);
    isPaying = true;
    if (storeInfoModel.status == 0) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "storeNotApproved"));
      isPaying = false;
      setBusy(false);
      return;
    }
    String exgAddress =
        await sharedService.getExgAddressFromCoreWalletDatabase();
    var gasAmount = await walletService.gasBalance(
        environmentService.kanbanBaseUrl(), exgAddress);
    if (gasAmount == Constants.decimalZero) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "insufficientGasAmount"));
      setBusy(false);
      return;
    }
    var walletUtil = WalletUtil();
    String selectedCoinAddress =
        await walletUtil.setWalletAddress(tickerName, tokenType: 'ETH');
    List<WalletBalanceV2> walletBalanceRes;
    await apiService
        .getSingleWalletBalanceV2(environmentService.kanbanBaseUrl(),
            fabAddress, tickerName, selectedCoinAddress)
        .then((walletBalance) {
      if (walletBalance != null) {
        walletBalanceRes = walletBalance;
      }
    });
    if (taxAmount > amountPayable) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "serverError"),
          isError: true);
      setBusy(false);
      return;
    }
    if (walletBalanceRes[0].unlockedExchangeBalance <
        amountPayable + taxAmount) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "insufficientBalance"),
          isError: true);
      setBusy(false);
      return;
    }
    //displayAbiHexinReadableFormat(scanToPayModel.datAbiHex);
    try {
      await signTxV2(scanToPayModelV2.feeChargerSmartContractAddress);
    } catch (err) {
      log.e('CATCH signtx v2 failed $err');
    }

    isPaying = false;
    setBusy(false);
  }

  signTxV2(String contractAddress) async {
    String exgAddress =
        await sharedService.getExgAddressFromCoreWalletDatabase();
    var nonce = await KanbanUtils.getKanbanNonce(
        environmentService.kanbanBaseUrl(), exgAddress);

    //   Web
    String finalAbiHex =
        //  Constants.payCoolSignOrderAbi +
        scanToPayModelV2.abiHex;
    log.i('finalAbiHex $finalAbiHex');
    await dialogService
        .showDialog(
            title: FlutterI18n.translate(context, "enterPassword"),
            description: FlutterI18n.translate(
                context, "dialogManagerTypeSamePasswordNote"),
            buttonTitle: FlutterI18n.translate(context, "confirm"))
        .then((passRes) async {
      if (passRes.confirmed) {
        setBusy(true);
        String mnemonic = passRes.returnedText;
        seed = MnemonicUtils.generateSeed(mnemonic);

        var transactionData = await walletService.assignTransactionData(
            seed, environmentService.envConfigExgKeyPair());

        var txModel = TransactionModel(
            seed: seed,
            abiHex: finalAbiHex,
            nonce: transactionData.nonce,
            privateKey: transactionData.privateKey,
            toAddress: contractAddress,
            kanbanAddress: transactionData.kanbanAddress);

        EnvConfig envConfigKanban = environmentService.kanbanEnvConfig();
        var txKanbanHex;

        try {
          txKanbanHex =
              await AbiUtils.signAbiHexWithPrivateKey(txModel, envConfigKanban);

          log.i('txKanbanHex $txKanbanHex');
        } catch (err) {
          setBusy(false);
          log.e('err $err');
        }
        var appData =
            await sharedService.sharedAppData(Constants.exchangilyAppName);

        var resBody = await KanbanUtils.sendRawKanbanTransaction(
            baseBlockchainGateV2Url, txKanbanHex, appData);
        var res = resBody['_body'];
        var txHash = res['transactionHash'];
        //{"ok":true,"_body":{"transactionHash":"0x855f2d8ec57418670dd4cb27ecb71c6794ada5686e771fe06c48e30ceafe0548","status":"0x1"}}

        debugPrint('res $res');
        if (res['status'] == '0x1') {
          payOrderConfirmationPopup();
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
    setBusy(false);
  }

  payOrderConfirmationPopup() async {
    await dialogService
        .showBasicDialog(
      title: FlutterI18n.translate(context, "placeOrderTransactionSuccessful"),
      buttonTitle: FlutterI18n.translate(context, "checkRewards"),
    )
        .then((res) {
      if (res.confirmed) {
        navigationService.navigateTo(PaycoolConstants.payCoolRewardsViewRoute);
      }
    });
  }

/*----------------------------------------------------------------------
                    Show bottom sheet for coin list
----------------------------------------------------------------------*/
  coinListBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.35,
            // margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: grey.withAlpha(300),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              // boxShadow: [
              //   BoxShadow(
              //       blurRadius: 3, color: Colors.grey[600], spreadRadius: 2)
              // ]
            ),
            child: ListView.separated(
                separatorBuilder: (context, _) => UIHelper.divider,
                itemCount: exchangeBalances.length,
                itemBuilder: (BuildContext context, int index) {
                  //  mainAxisSize: MainAxisSize.max,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  // children: [

                  return Container(
                    decoration: BoxDecoration(
                      // color: grey.withAlpha(300),
                      borderRadius: index == 0
                          ? const BorderRadius.vertical(
                              top: Radius.circular(10))
                          : const BorderRadius.all(Radius.zero),
                      // boxShadow: [
                      //   BoxShadow(
                      //       blurRadius: 3, color: Colors.grey[600], spreadRadius: 2)
                      // ]
                      color: tickerName == exchangeBalances[index].ticker
                          ? primaryColor
                          : Colors.transparent,
                    ),
                    child: InkWell(
                      onTap: () {
                        //  Platform.isIOS
                        updateSelectedTickernameIOS(
                            index, exchangeBalances[index].unlockedAmount,
                            isShowBottomSheet: true);
                        // : updateSelectedTickername(coins[index]['tickerName'],
                        //     coins[index]['quantity'].toDouble());
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(exchangeBalances[index].ticker,
                                textAlign: TextAlign.center, style: headText5),
                            UIHelper.horizontalSpaceSmall,
                            Text(
                                exchangeBalances[index]
                                    .unlockedAmount
                                    .toString(),
                                style: headText5),
                            const Divider(
                              color: Colors.white,
                              height: 1,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
        });
  }

  onBackButtonPressed() async {
    await sharedService.onBackButtonPressed('/dashboard');
  }

  createStoreOrderDialogWidget(
    StoreMerchantModel storeMerchantModel,
    BuildContext context,
  ) async {
    orderIdFromCreateStoreOrder = '';
    TextEditingController amountController = TextEditingController();
    TextEditingController memoController = TextEditingController();
    bool isCreatingOrder = false;
    String storeOrderCurrencytickerName = exchangeBalances[0].ticker;
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            titlePadding: const EdgeInsets.all(0),
            actionsPadding: const EdgeInsets.all(0),
            elevation: 5,
            backgroundColor: walletCardColor.withOpacity(0.95),
            title: Container(
              alignment: Alignment.center,
              color: primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.all(10),
              child: Text(
                FlutterI18n.translate(context, "createStoreOrder"),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            titleTextStyle: headText5,
            contentTextStyle: const TextStyle(color: grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    UIHelper.verticalSpaceMedium,
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      child: Text(
                          // add here cupertino widget to check in these small widgets first then the entire app
                          FlutterI18n.translate(
                              context, "fillAllTheFieldsAndSubmit"),
                          textAlign: TextAlign.center,
                          style: headText5),
                    ),
                    UIHelper.verticalSpaceMedium,
                    // select currency dropdown

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      height: 45,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(100.0),
                        border: Border.all(
                            color: exchangeBalances.isEmpty
                                ? Colors.transparent
                                : primaryColor,
                            style: BorderStyle.solid,
                            width: 0.50),
                      ),
                      child: DropdownButton(
                          underline: const SizedBox.shrink(),
                          elevation: 5,
                          isExpanded: true,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                          ),
                          iconEnabledColor: primaryColor,
                          iconDisabledColor:
                              exchangeBalances.isEmpty ? secondaryColor : grey,
                          iconSize: 24,
                          hint: Padding(
                            padding: exchangeBalances.isEmpty
                                ? const EdgeInsets.all(0)
                                : const EdgeInsets.only(left: 10.0),
                            child: exchangeBalances.isEmpty
                                ? ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      Icons.account_balance_wallet,
                                      color: red,
                                      size: 18,
                                    ),
                                    title: Text(
                                        FlutterI18n.translate(
                                            context, "noCoinBalance"),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2),
                                    subtitle: Text(
                                        FlutterI18n.translate(context,
                                            "transferFundsToExchangeUsingDepositButton"),
                                        style: subText2))
                                : Text(
                                    FlutterI18n.translate(
                                        context, "selectCoin"),
                                    textAlign: TextAlign.start,
                                    style: headText4,
                                  ),
                          ),
                          value: storeOrderCurrencytickerName,
                          onChanged: (newValue) {
                            setState(() {});
                            storeOrderCurrencytickerName = newValue;
                          },
                          items: exchangeBalances.map(
                            (coin) {
                              return DropdownMenuItem(
                                child: Container(
                                  height: 40,
                                  color: primaryColor,
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Row(
                                    children: [
                                      Text(coin.ticker.toString(),
                                          textAlign: TextAlign.center,
                                          style: headText5),
                                      UIHelper.horizontalSpaceSmall,
                                      Text(
                                        coin.unlockedAmount.toString(),
                                        style: headText6.copyWith(
                                            // color: grey,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                                value: coin.ticker,
                              );
                            },
                          ).toList()),
                    ),
                    UIHelper.verticalSpaceSmall,
                    // amount textfield
                    TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: const BorderSide(
                                    color: primaryColor, width: 1)),
                            hintText:
                                FlutterI18n.translate(context, "enterAmount"),
                            hintStyle: headText5),
                        controller: amountController,
                        style: headText5.copyWith(fontWeight: FontWeight.bold)),
                    UIHelper.verticalSpaceSmall,
                    // memo textfield

                    TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: const BorderSide(
                                    color: primaryColor, width: 1)),
                            hintText:
                                FlutterI18n.translate(context, "enterMemo"),
                            hintStyle: headText5),
                        controller: memoController,
                        style: headText5.copyWith(fontWeight: FontWeight.bold)),
                    UIHelper.verticalSpaceSmall,
                    // disply further payment instructions by showing the order id
                    orderIdFromCreateStoreOrder.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text(
                                  'Order Id: $orderIdFromCreateStoreOrder',
                                  style: const TextStyle(color: white),
                                ),
                                UIHelper.verticalSpaceSmall,
                                Text(FlutterI18n.translate(
                                    context, "paycoolStoreOrderCreatedAndPay"))
                              ],
                            ),
                          )
                        : Container(),

                    // action buttons
                    Container(
                      margin: const EdgeInsetsDirectional.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(red),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.all(0)),
                            ),
                            child: Text(
                              FlutterI18n.translate(context, "close"),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                            onPressed: () {
                              if (!isCreatingOrder) {
                                if (orderIdFromCreateStoreOrder.isNotEmpty) {
                                  Navigator.of(context).pop(false);
                                  getOrderDetailsById(
                                      orderIdFromCreateStoreOrder);
                                } else {
                                  Navigator.of(context).pop(false);
                                }
                              }
                            },
                          ),
                          UIHelper.horizontalSpaceSmall,
                          orderIdFromCreateStoreOrder.isEmpty
                              ? OutlinedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            primaryColor),
                                    padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                        const EdgeInsets.all(0)),
                                  ),
                                  child: isCreatingOrder
                                      ? sharedService.loadingIndicator()
                                      : Text(
                                          FlutterI18n.translate(
                                              context, "Submit"),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                  onPressed: () async {
                                    if (!isCreatingOrder) {
                                      setState(() {
                                        isCreatingOrder = true;
                                      });
                                      // set state locally
                                      var body = {};
                                      try {
                                        body = createStoreOrderBody(
                                            memoController.text,
                                            amountController.text,
                                            storeOrderCurrencytickerName);
                                      } catch (err) {
                                        log.e(
                                            'CATCH createStoreOrderBody $err');
                                        setBusy(false);
                                        return;
                                      }
                                      // call paycool pay service and create store order

                                      var orderId = await payCoolService
                                          .createStoreMerchantOrder(body);
                                      setState(() {
                                        orderIdFromCreateStoreOrder = orderId;
                                        isCreatingOrder = false;
                                      });
                                    } else {
                                      debugPrint('isCreatingOrder');
                                    }
                                    // display result and close this dialog
                                  },
                                )
                              : Container(),
                        ],
                      ),
                    )
                  ]);
            }),
          );
        });
  }

  String extractId(String scannedString) {
    int index = scannedString.indexOf("=") + 1;

    return scannedString.substring(index);
  }

  createStoreOrderBody(String memo, String amount, String currency) {
    Map<String, dynamic> body;
    // need to calculate tax either calculate in double or big number
    body = {
      "currency": currency,
      "items": [
        {
          "title": memo,
          "giveAwayRate": storeMerchangeModel.giveAwayRate,
          "taxRate": 0,
          "lockedDays": storeMerchangeModel.lockedDays,
          "price": amount,
          "quantity": 1
        }
      ],
      "store": storeMerchangeModel.sId,
      "totalSale": amount,
      "totalTax": 0
    };

    return body;
  }

  orderDetails({String barcodeScanData}) async {
    String scannedOrderId = '';
    String scannedStoreId = '';
    String scannedTemplateId = '';
    String charToCompare = barcodeScanData[0];
    debugPrint('charToCompare $charToCompare');
    loadingStatus = FlutterI18n.translate(context, "gettingOrderDetails");
    if (charToCompare == "i") {
      //jsonDecode(scanResult.rawContent)["i"];
      scannedOrderId = extractId(barcodeScanData);
      log.i('scanRes $scannedOrderId');
      await getOrderDetailsById(scannedOrderId);
    } else if (charToCompare == "s") {
      scannedStoreId =
          extractId(barcodeScanData); // jsonDecode(scanResult.rawContent)["s"];
      storeMerchangeModel =
          await payCoolService.getStoreMerchantInfo(scannedStoreId);

      createStoreOrderDialogWidget(storeMerchangeModel, context);
    } else if (charToCompare == "t") {
      scannedTemplateId = extractId(barcodeScanData);
      orderIdFromCreateStoreOrder =
          await payCoolService.createTemplateById(scannedTemplateId);
      getOrderDetailsById(orderIdFromCreateStoreOrder);
    } else {
      sharedService.sharedSimpleNotification('Incorrect data format');
    }
  }

  void scanBarcodeV2({
    String addressType = PaycoolConstants.merchantAddressText,
  }) async {
    try {
      setBusy(true);
      ScanResult scanResult;
      String barcodeScanData = '';

      scanResult = await BarcodeUtils().scanBarcode(context);
      barcodeScanData = scanResult.rawContent;

      if (addressType == PaycoolConstants.referralAddressText) {
        debugPrint('in 1st if-- barcode res-- ${scanResult.rawContent}');

        referralController.text = scanResult.rawContent;
      }
      if (addressType == PaycoolConstants.merchantAddressText) {
        if (scanResult != null) {
          orderDetails(barcodeScanData: barcodeScanData);
        } else if (scanResult.rawContent == '-1') {
          sharedService.sharedSimpleNotification(
            FlutterI18n.translate(context, "scanCancelled"),
          );
          setBusy(false);
          return;
        }
      }
      setBusy(false);
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_NOT_GRANTED") {
        setBusy(false);
        sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "userAccessDenied"),
        );
        // receiverWalletAddressTextController.text =
        //     FlutterI18n.translate(context, "userAccessDenied");
      } else {
        // setBusy(true);
        sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "unknownError $e"),
        );
      }
    } on FormatException {
      log.e('scan barcode func: FormatException');
      sharedService.sharedSimpleNotification(
        FlutterI18n.translate(context, "scanCancelled"),
      );
    } catch (e) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "unknownError"),
          isError: true);
      log.e('barcode scan catch $e');
    }
    setBusy(false);
  }

  Future<void> getOrderDetailsById(String scanRes) async {
    setBusy(true);
    orderId = scanRes;
    bool isFailed = false;

    await payCoolService
        .scanToPayV2Info(scanRes)
        .then((value) => scanToPayModelV2 = value)
        .catchError((onError) {
      debugPrint('catch error $onError');
      log.e('getOrderDetailsById func -- Catch scan to pay model $onError',
          onError);
      String t = onError.toString();
      debugPrint('t $t');
      dialogService.showBasicDialog(
          title: FlutterI18n.translate(context, "invalidScanData"),
          description: t,
          buttonTitle: FlutterI18n.translate(context, "close"));
      loadingStatus = '';
      setBusy(false);

      isFailed = true;
    });
    if (isFailed) {
      setBusy(false);
      return;
    }
    coinPayable = scanToPayModelV2.currency;
    final v =
        exchangeBalances.indexWhere((element) => element.ticker == coinPayable);
    if (v.isNegative) {
      dialogService.showBasicDialog(
          title:
              "$coinPayable ${FlutterI18n.translate(context, "insufficientBalanceForPayment")}",
          description:
              FlutterI18n.translate(context, "PaycoolInsufficientBalanceDesc"),
          buttonTitle: FlutterI18n.translate(context, "close"));
      setBusy(false);
      return;
    }
    try {
      await tokenService
          .getSingleTokenData(scanToPayModelV2.currency)
          .then((t) {
        decimalLimit = t.decimal;
        log.i('decimalLimit $decimalLimit');
      });
    } catch (err) {
      if (decimalLimit == null || decimalLimit == 0) decimalLimit = 8;
      log.e('Decimal limit CATCH in barcode scan: $err');
    }
    amountPayable = NumberUtil.decimalLimiter(scanToPayModelV2.totalAmount,
        decimalPrecision: decimalLimit);
    taxAmount = NumberUtil.decimalLimiter(scanToPayModelV2.totalTax,
        decimalPrecision: decimalLimit);

    if (Platform.isIOS) {
      updateSelectedTickernameIOS(
          exchangeBalances
              .indexWhere((element) => element.ticker == coinPayable),
          exchangeBalances
              .firstWhere((element) => element.ticker == coinPayable)
              .unlockedAmount);
    } else {
      updateSelectedTickername(coinPayable);
    }
    loadingStatus = FlutterI18n.translate(context, "fetchingStoreInfo");
    await payCoolService
        .getStoreInfo(scanToPayModelV2.feeChargerSmartContractAddress)
        .then((value) => storeInfoModel = value);
    loadingStatus = '';
    setBusy(false);
  }

  void scanBarcode(
      {String addressType = PaycoolConstants.merchantAddressText}) async {
    try {
      setBusy(true);
      var barcodeRes = [];
      ScanResult scanResult;
      var options = ScanOptions(strings: {
        "cancel": FlutterI18n.translate(context, "cancel"),
        "flash_on": FlutterI18n.translate(context, "flashOn"),
        "flash_off": FlutterI18n.translate(context, "flashOff"),
      });

      scanResult = await BarcodeScanner.scan(options: options);
      // await BarcodeUtils().scanQR(context);
      log.i('barcode res ${scanResult.toString()}');
      if (addressType == PaycoolConstants.referralAddressText) {
        debugPrint('in 1st if-- barcode res-- ${scanResult.rawContent}');

        referralController.text = scanResult.rawContent;
      }
      if (addressType == PaycoolConstants.merchantAddressText) {
        if (scanResult != null) {
          var scanToPayModel;
          //    ScanToPayModel.fromJson(jsonDecode(scanResult.rawContent));
          debugPrint('payCoolModel ${scanToPayModel.toJson()}');
          barcodeRes.add(scanToPayModel.toJson());
          addressController.text = scanToPayModel.toAddress;
          String data = scanToPayModel.datAbiHex.toString();
          List<String> res;
          await payCoolService
              .decodeScannedAbiHex(data.substring(10, data.length))
              .then((value) => res = value);
          log.w('barcode scan decodeScannedAbiHex res $res');

          int ct = int.parse(res[1]);
          coinPayable = Constants.coinTypeWithTicker[ct];
          try {
            await tokenService
                .getSingleTokenData(tickerName, coinType: ct)
                .then((t) {
              decimalLimit = t.decimal;
              log.i('decimalLimit $decimalLimit');
            });
          } catch (err) {
            if (decimalLimit == null || decimalLimit == 0) decimalLimit = 8;
            log.e('Decimal limit CATCH in barcode scan: $err');
          }
          // amountPayable = bigNumToDouble(res[2], decimalLength: decimalLimit);
          // taxAmount = bigNumToDouble(res[3], decimalLength: decimalLimit);
          // if (Platform.isAndroid) updateSelectedTickername(coinPayable);
          // tickerName = coinPayable;
          if (Platform.isIOS) {
            updateSelectedTickernameIOS(
                exchangeBalances
                    .indexWhere((element) => element.ticker == coinPayable),
                exchangeBalances
                    .firstWhere((element) => element.ticker == coinPayable)
                    .unlockedAmount);
          } else {
            updateSelectedTickername(coinPayable);
          }
          var decodedData = res;
          //  payCool();
          await payCoolService
              .getStoreInfo(scanToPayModel.toAddress)
              .then((value) => storeInfoModel = value);
        } else if (scanResult.rawContent == '-1') {
          sharedService.sharedSimpleNotification(
            FlutterI18n.translate(context, "scanCancelled"),
          );
          setBusy(false);
          return;
        }
      }
      setBusy(false);
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_NOT_GRANTED") {
        setBusy(false);
        sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "userAccessDenied"),
        );
        // receiverWalletAddressTextController.text =
        //     FlutterI18n.translate(context, "userAccessDenied");
      } else {
        // setBusy(true);
        sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "unknownError $e"),
        );
      }
    } on FormatException {
      log.e('scan barcode func: FormatException');
      sharedService.sharedSimpleNotification(
        FlutterI18n.translate(context, "scanCancelled"),
      );
    } catch (e) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "unknownError"),
          isError: true);
      log.e('barcode scan catch $e');
    }
    setBusy(false);
  }

/*----------------------------------------------------------------------
                    Update Selected Tickername
----------------------------------------------------------------------*/
  updateSelectedTickername(
    String name,
  ) {
    tickerName = name;
    debugPrint('tickerName 1 $tickerName');
    notifyListeners();
  }

  updateSelectedTickernameIOS(int index, Decimal updatedQuantity,
      {bool isShowBottomSheet = false}) {
    setBusy(true);
    debugPrint(
        'INDEX ${index + 1} ---- coins length ${exchangeBalances.length}');
    if (index + 1 <= exchangeBalances.length) {
      tickerName = exchangeBalances.elementAt(index).ticker;
    }
    quantity = updatedQuantity;
    debugPrint('IOS tickerName $tickerName --- quantity $quantity');
    setBusy(false);
    if (isShowBottomSheet) navigationService.goBack();
    // changeBottomSheetStatus();
  }

/*----------------------------------------------------------------------
              Show dialog popup for receive address and barcode
----------------------------------------------------------------------*/

/*----------------------------------------------------------------------
                    Refresh Balance
----------------------------------------------------------------------*/
  refreshBalance() async {
    setBusyForObject(exchangeBalances, true);
    var exgAddress = await sharedService.getExgAddressFromCoreWalletDatabase();
    await apiService
        .getSingleCoinExchangeBalance(
            environmentService.kanbanBaseUrl(), tickerName, exgAddress)
        .then((res) {
      exchangeBalances.firstWhere((element) {
        if (element.ticker == tickerName) {
          element.unlockedAmount = res.unlockedAmount;
        }
        log.w('udpated balance check ${element.unlockedAmount}');
        return true;
      });
    });
    setBusyForObject(exchangeBalances, false);
  }

/*----------------------------------------------------------------------
                      Show barcode
----------------------------------------------------------------------*/

  showBarcode() {
    setBusy(true);
    walletDataBaseService.getWalletBytickerName('FAB').then((coin) {
      String kbAddress = walletService.toKbPaymentAddress(coin.address);
      debugPrint('KBADDRESS $kbAddress');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Container(
                    child: Center(
                        child: Text(
                            FlutterI18n.translate(context, "receiveAddress"))),
                  ),
                  content: Column(
                    children: [
                      Row(
                        children: [
                          UIHelper.horizontalSpaceSmall,
                          Expanded(
                            child: Text(
                                // add here cupertino widget to check in these small widgets first then the entire app
                                kbAddress,
                                textAlign: TextAlign.left,
                                style: headText6),
                          ),
                          CupertinoButton(
                              child: const Icon(
                                FontAwesomeIcons.copy,
                                //  CupertinoIcons.,
                                color: primaryColor,
                                size: 16,
                              ),
                              onPressed: () {
                                sharedService.copyAddress(context, kbAddress)();
                              })
                        ],
                      ),
                      // UIHelper.verticalSpaceLarge,
                      Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          width: 250,
                          height: 250,
                          child: Center(
                            child: Container(
                              child: RepaintBoundary(
                                key: globalKey,
                                child: QrImage(
                                    backgroundColor: white,
                                    data: kbAddress,
                                    version: QrVersions.auto,
                                    size: 300,
                                    gapless: true,
                                    errorStateBuilder: (context, err) {
                                      return Container(
                                        child: Center(
                                          child: Text(
                                              FlutterI18n.translate(context,
                                                  "somethingWentWrong"),
                                              textAlign: TextAlign.center),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          )),
                    ],
                  ),
                  actions: <Widget>[
                    // QR image share button
                    Container(
                      margin: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CupertinoButton(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: Center(
                                  child: Text(
                                FlutterI18n.translate(context, "share"),
                                style: headText5.copyWith(color: primaryColor),
                              )),
                              onPressed: () {
                                String receiveFileName =
                                    'Lightning-remit-kanban-receive-address.png';
                                getApplicationDocumentsDirectory().then((dir) {
                                  String filePath =
                                      "${dir.path}/$receiveFileName";
                                  File file = File(filePath);
                                  Future.delayed(
                                      const Duration(milliseconds: 30), () {
                                    sharedService
                                        .capturePng(globalKey: globalKey)
                                        .then((byteData) {
                                      file
                                          .writeAsBytes(byteData)
                                          .then((onFile) {
                                        Share.shareFiles([onFile.path],
                                            text: kbAddress);
                                      });
                                    });
                                  });
                                });
                              }),
                          CupertinoButton(
                            padding: const EdgeInsets.only(left: 5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            child: Text(
                              FlutterI18n.translate(context, "close"),
                              style: headText5,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              // Android Alert Dialog
              : AlertDialog(
                  titlePadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.zero,
                  insetPadding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  elevation: 5,
                  backgroundColor: walletCardColor.withOpacity(0.85),
                  title: Container(
                    padding: const EdgeInsets.all(10.0),
                    color: secondaryColor.withOpacity(0.5),
                    child: Center(
                        child: Text(
                            FlutterI18n.translate(context, "receiveAddress"))),
                  ),
                  titleTextStyle:
                      headText4.copyWith(fontWeight: FontWeight.bold),
                  contentTextStyle: const TextStyle(color: grey),
                  content: Column(
                    children: [
                      UIHelper.verticalSpaceLarge,
                      Row(
                        children: [
                          UIHelper.horizontalSpaceSmall,
                          Expanded(
                            child: Center(
                              child: Text(
                                  // add here cupertino widget to check in these small widgets first then the entire app
                                  kbAddress,
                                  style: headText6),
                            ),
                          ),
                          IconButton(
                              icon: const Icon(
                                Icons.content_copy,
                                color: primaryColor,
                                size: 16,
                              ),
                              onPressed: () {
                                sharedService.copyAddress(context, kbAddress)();
                              })
                        ],
                      ),
                      // UIHelper.verticalSpaceLarge,
                      Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          width: 250,
                          height: 250,
                          child: Center(
                            child: Container(
                              child: RepaintBoundary(
                                key: globalKey,
                                child: QrImage(
                                    backgroundColor: white,
                                    data: kbAddress,
                                    version: QrVersions.auto,
                                    size: 300,
                                    gapless: true,
                                    errorStateBuilder: (context, err) {
                                      return Container(
                                        child: Center(
                                          child: Text(
                                              FlutterI18n.translate(context,
                                                  "somethingWentWrong"),
                                              textAlign: TextAlign.center),
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          )),
                    ],
                  ),
                  actions: <Widget>[
                    // QR image share button

                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                          child: Text(FlutterI18n.translate(context, "share"),
                              style: headText6),
                          onPressed: () {
                            String receiveFileName =
                                'paycool-payment-address.png';
                            getApplicationDocumentsDirectory().then((dir) {
                              String filePath = "${dir.path}/$receiveFileName";
                              File file = File(filePath);

                              Future.delayed(const Duration(milliseconds: 30),
                                  () {
                                sharedService
                                    .capturePng(globalKey: globalKey)
                                    .then((byteData) {
                                  file.writeAsBytes(byteData).then((onFile) {
                                    Share.shareFiles(onFile.readAsLinesSync(),
                                        text: kbAddress);
                                  });
                                });
                              });
                            });
                          }),
                    ),
                    OutlinedButton(
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(
                              const BorderSide(color: primaryColor)),
                          backgroundColor:
                              MaterialStateProperty.all(primaryColor),
                          textStyle: MaterialStateProperty.all(
                              const TextStyle(color: Colors.white))),
                      child: Text(
                        FlutterI18n.translate(context, "close"),
                        style: headText6,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                );
        },
      );
    });
    setBusy(false);
  }

/*----------------------------------------------------------------------
                            Transfer
----------------------------------------------------------------------*/

  transfer() async {
    setBusy(true);
  }

/*----------------------------------------------------------------------
              Content Paste Button in receiver address textfield
----------------------------------------------------------------------*/

  Future contentPaste({String addressType}) async {
    setBusy(true);
    await Clipboard.getData('text/plain').then((res) {
      pasteRes = res;
      if (addressType == PaycoolConstants.referralAddressText) {
        referralController.text = '';
        referralController.text = res.text;
      }
      if (addressType == PaycoolConstants.merchantAddressText) {
        addressController.text = res.text;
      }
    });
    setBusy(false);
  }

  copyAddress(String txId) {
    Clipboard.setData(ClipboardData(text: txId));
    showSimpleNotification(
        Center(
            child: Text(FlutterI18n.translate(context, "copiedSuccessfully"),
                style: headText5)),
        position: NotificationPosition.bottom,
        background: primaryColor);
  }

  showJSBottomSheet() {}
}
