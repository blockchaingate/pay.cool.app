import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_utils/qr_code_utils.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/coins.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/shared/pair_decimal_config_model.dart';
import 'package:paycool/models/wallet/exchange_balance_model.dart';
import 'package:paycool/models/wallet/transaction_history.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';

import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/coin_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/transaction_history_database_service.dart';
import 'package:paycool/services/db/user_settings_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/abi_util.dart';
import 'package:paycool/utils/barcode_util.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';
import 'package:paycool/views/paycool/models/merchant_model.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../environments/environment.dart';
import '../../services/config_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/local_dialog_service.dart';
import 'models/pay_order_model.dart';
import 'models/payment_rewards_model.dart';

class PayCoolViewmodel extends FutureViewModel {
  final log = getLogger('PayCoolViewmodel');

  final addressController = TextEditingController();
  ApiService apiService = locator<ApiService>();
  SharedService sharedService = locator<SharedService>();
  NavigationService navigationService = locator<NavigationService>();
  TokenListDatabaseService tokenListDatabaseService =
      locator<TokenListDatabaseService>();
  LocalStorageService storageService = locator<LocalStorageService>();
  TransactionHistoryDatabaseService transactionHistoryDatabaseService =
      locator<TransactionHistoryDatabaseService>();
  WalletDatabaseService walletDataBaseService =
      locator<WalletDatabaseService>();
  final dialogService = locator<LocalDialogService>();
  WalletService walletService = locator<WalletService>();
  final paycoolService = locator<PayCoolService>();
  ConfigService configService = locator<ConfigService>();
  final payCoolClubService = locator<PayCoolClubService>();
  final userSettingsDatabaseService = locator<UserSettingsDatabaseService>();
  String tickerName = '';
  double quantity = 0.0;
  GlobalKey globalKey = GlobalKey();
  ScrollController? scrollController;
  String loadingStatus = '';

  // var barcodeRes = [];
  //var barcodeRes2;
  var walletBalancesBody;
  // bool isShowBottomSheet = false;

  List<TransactionHistory> transactionHistory = [];
  String? abiHex;
  var seed = [];
  bool? isMember = false;
  bool? isAutoStartPaycoolScan;
  Decimal amountPayable = Decimal.zero;
  Decimal taxAmount = Decimal.zero;
  String coinPayable = '';
  final referralController = TextEditingController();

  String fabAddress = '';
  var apiRes;
  List<PairDecimalConfig> pairDecimalConfigList = [];
  final coinService = locator<CoinService>();
  // ScanToPayModel scanToPayModel = ScanToPayModel();
  var pasteRes;

  List<ExchangeBalanceModel> exchangeBalances = [];
  //var decodedData;

  String lang = '';
  bool isPaying = false;
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int decimalLimit = 8;
  var fabUtils = FabUtils();
  PaymentRewardsModel? rewardInfoModel = PaymentRewardsModel();
  String orderId = '';
  MerchantModel? merchantModel = MerchantModel();
  String? orderIdFromCreateStoreOrder = '';
  bool isScanningImage = false;
  bool isServerDown = false;
  Decimal gasBalance = Constants.decimalZero;
  PayOrder payOrder = PayOrder();

/*----------------------------------------------------------------------
                    Default Future to Run
----------------------------------------------------------------------*/
  @override
  Future futureToRun() async => await apiService.getAssetsBalance('');

/*----------------------------------------------------------------------
                          INIT
----------------------------------------------------------------------*/

  init() async {
    isAutoStartPaycoolScan = storageService.autoStartPaycoolScan;
    // await userSettingsDatabaseService.getById(1).then((res) {
    //   if (res != null) {
    //     lang = res.language ?? "en";
    //     log.i('user settings db not null');
    //   }
    // });
    if (lang.isEmpty) {
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
        var res =
            await coinService.getSingleTokenData('', coinType: wallet.coinType);

        //storageService.tokenList.forEach((newToken){

        // var json = jsonDecode(newToken);
        // Token token = Token.fromJson(json);
        // if (token.tokenType == element.coinType){ debugPrint(token.tickerName);

        wallet.ticker = res!.tickerName.toString(); //}

//element.ticker =tradeService.setTickerNameByType(element.coinType);
        debugPrint('exchanageBalanceModel tickerName ${wallet.ticker}');
      }
      if (wallet.unlockedAmount > 0.0) {
        exchangeBalances.add(wallet);
      }
    });
    setBusyForObject(exchangeBalances, false);
    setBusyForObject(tickerName, true);

    if (exchangeBalances.isNotEmpty) {
      tickerName = exchangeBalances[0].ticker;

      quantity = exchangeBalances[0].unlockedAmount;
    }

    setBusyForObject(tickerName, false);

    log.e('tickerName $tickerName');

    fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();

    await isValidMember();
    await getGas();
    setBusy(false);
  }

  getGas() async {
    String address = await sharedService.getExgAddressFromCoreWalletDatabase();
    await walletService.gasBalance(address).then((data) {
      gasBalance = Decimal.parse(data.toString());
    }).catchError((onError) => log.e(onError));
    log.w('gas amount $gasBalance');
  }

  scanImageFile() async {
    // Pick an image
    setBusyForObject(isScanningImage, true);
    String _qrcodeFile = '';
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      _qrcodeFile = image.path;
      log.w(_qrcodeFile);
    }
    try {
      var barcodeScanData = await QrCodeUtils.decodeFrom(_qrcodeFile);
      log.i(barcodeScanData);
      orderDetails(barcodeScanData: barcodeScanData);
    } catch (err) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(sharedService.context, "validationError"));
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
      await payCoolClubService.isValidMember(fabAddress).then((value) {
        isMember = value;

        if (isMember! && isAutoStartPaycoolScan!) {
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

  createAccount() async {
    setBusy(true);
    bool isValidReferralAddress = false;
    if (referralController.text.isEmpty) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(sharedService.context, "invalidReferralCode"));
      setBusy(false);
      return;
    }
    // check gas balance
    await getGas();
    if (gasBalance == Constants.decimalZero) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(sharedService.context, "notice"),
          subtitle: FlutterI18n.translate(
              sharedService.context, "insufficientGasAmount"));
      setBusy(false);
      return;
    }
    await payCoolClubService
        .isValidMember(referralController.text)
        .then((value) {
      if (value != null) {
        log.w('isValid paymember: $value');

        isValidReferralAddress = value;
      }
    });
    if (!isValidReferralAddress) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(sharedService.context, "invalidReferralCode"));
      setBusy(false);
      return;
    }

    var seed = await walletService.getSeedDialog(sharedService.context);

    try {
      var paycoolReferralAddress =
          environment['addresses']['smartContract']['PaycoolReferralAddress'];

      var abiHex = generateGenericAbiHex(
          Constants.payCoolCreateAccountAbiCode, referralController.text);
      var res = await paycoolService.signSendTx(
          seed!, abiHex, paycoolReferralAddress);

      if (res != null && res != '') {
        if (res == '0x1') {
          sharedService.alertDialog(
              FlutterI18n.translate(sharedService.context, "newAccountCreated"),
              '${FlutterI18n.translate(sharedService.context, "newAccountNote")} ${FlutterI18n.translate(sharedService.context, "waitForNewAccountSetUp")}',
              path: PayCoolViewRoute);
        } else if (res == '0x0') {
          sharedService.sharedSimpleNotification(
              FlutterI18n.translate(sharedService.context, "failed"));
        }
      } else {
        sharedService.sharedSimpleNotification(
            FlutterI18n.translate(sharedService.context, "failed"));
        apiRes = apiRes["message"] ?? '';
      }
    } catch (err) {
      log.e('create ref CATCH $err');
      setBusy(false);
    }

    setBusy(false);
  }

  makePayment() async {
    setBusy(true);
    isPaying = true;
    if (merchantModel!.status == 0) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(sharedService.context, "storeNotApproved"));
      isPaying = false;
      setBusy(false);
      return;
    }
    String exgAddress =
        await sharedService.getExgAddressFromCoreWalletDatabase();
    var gasAmount = await walletService.gasBalance(exgAddress);
    if (gasAmount == 0.0) {
      sharedService.sharedSimpleNotification(FlutterI18n.translate(
          sharedService.context, "insufficientGasAmount"));
      setBusy(false);
      return;
    }
    String selectedCoinAddress =
        await coinService.getCoinWalletAddress(tickerName, tokenType: 'ETH');
    List<WalletBalance>? walletBalanceRes;
    await apiService
        .getSingleWalletBalance(fabAddress, tickerName, selectedCoinAddress)
        .then((walletBalance) {
      if (walletBalance != null) {
        walletBalanceRes = walletBalance;
      }
    });

    if (walletBalanceRes![0].unlockedExchangeBalance! <
        (amountPayable + taxAmount).toDouble()) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(sharedService.context, "insufficientBalance"),
          isError: true);
      setBusy(false);
      return;
    }
    //displayAbiHexinReadableFormat(scanToPayModel.datAbiHex);
    try {
      var seed = await walletService.getSeedDialog(sharedService.context);
      var res;
      for (var param in rewardInfoModel!.params!) {
        res = await paycoolService.signSendTx(seed!, param.data!, param.to!);
      }
      if (res == '0x1') {
        payOrderConfirmationPopup();
      } else if (res == '0x0') {
        sharedService.sharedSimpleNotification(
            FlutterI18n.translate(sharedService.context, "failed"),
            isError: true);
      }
    } catch (err) {
      log.e('CATCH signtx v2 failed $err');
    }

    isPaying = false;
    setBusy(false);
  }

  payOrderConfirmationPopup() async {
    await dialogService
        .showBasicDialog(
      title: FlutterI18n.translate(
          sharedService.context, "placeOrderTransactionSuccessful"),
      buttonTitle: FlutterI18n.translate(sharedService.context, "checkRewards"),
    )
        .then((res) {
      if (res.confirmed) {
        navigationService.navigateTo(PayCoolRewardsViewRoute);
      }
    });
  }

  // launch url
  openExplorer(String txId) async {
    String exchangilyExplorerUrl = ExchangilyExplorerUrl + txId;
    log.i(
        'LightningRemit open explorer - explorer url - $exchangilyExplorerUrl');
    if (await canLaunch(exchangilyExplorerUrl)) {
      await launch(exchangilyExplorerUrl);
    }
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
    MerchantModel storeMerchantModel,
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
                                            .bodyMedium),
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
                            storeOrderCurrencytickerName = newValue.toString();
                          },
                          items: exchangeBalances.map(
                            (coin) {
                              return DropdownMenuItem(
                                value: coin.ticker,
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
                    orderIdFromCreateStoreOrder!.isNotEmpty
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
                                if (orderIdFromCreateStoreOrder!.isNotEmpty) {
                                  Navigator.of(context).pop(false);
                                  getOrderDetailsById(
                                      orderIdFromCreateStoreOrder!);
                                } else {
                                  Navigator.of(context).pop(false);
                                }
                              }
                            },
                          ),
                          UIHelper.horizontalSpaceSmall,
                          orderIdFromCreateStoreOrder!.isEmpty
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
                                      Map<String, dynamic> body = {};
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

                                      var orderId = await paycoolService
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
          "rebateRate": merchantModel!.rebateRate,
          "taxRate": 0,
          "lockedDays": merchantModel!.lockedDays,
          "price": amount,
          "quantity": 1
        }
      ],
      "merchantId": merchantModel!.sId,
    };

    return body;
  }

  showMerchantDetails() {
    showDialog(
        context: sharedService.context,
        builder: (context) {
          return AlertDialog(
            titleTextStyle: headText3.copyWith(
              color: black,
            ),
            title: Text(
              FlutterI18n.translate(context, "merchantDetails"),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              height: 200,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                UIHelper.verticalSpaceMedium,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                          child: Text(
                            FlutterI18n.translate(context, "title"),
                            style: headText5,
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          payOrder.title.toString(),
                          style: headText5,
                        ))
                  ],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.divider,
                UIHelper.verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                          child: Text(
                            FlutterI18n.translate(context, "taxRate"),
                            style: headText5,
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          payOrder.tax.toString(),
                          style: headText5,
                        ))
                  ],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.divider,
                UIHelper.verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                          child: Text(
                            FlutterI18n.translate(context, "price"),
                            style: headText5,
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          payOrder.price.toString(),
                          style: headText5,
                        ))
                  ],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.divider,
                UIHelper.verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                          child: Text(
                            FlutterI18n.translate(context, "quantity"),
                            style: headText5,
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          payOrder.qty.toString(),
                          style: headText5,
                        ))
                  ],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.divider,
                UIHelper.verticalSpaceSmall,
                payOrder.rebateRate != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, bottom: 3),
                                child: Text(
                                  FlutterI18n.translate(context, "rebateRate"),
                                  style: headText5,
                                ),
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                payOrder.rebateRate.toString(),
                                style: headText5,
                              ))
                        ],
                      )
                    : Container(),
              ]),
            ),
          );
        });
  }

  showOrderDetails() {
    showDialog(
        context: sharedService.context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: white,
            titleTextStyle: headText3.copyWith(
              color: black,
            ),
            title: Text(
              FlutterI18n.translate(context, "orderDetails"),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              height: 200,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                UIHelper.verticalSpaceMedium,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                          child: Text(
                            FlutterI18n.translate(context, "title"),
                            style: headText5,
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          payOrder.title.toString(),
                          style: headText5,
                        ))
                  ],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.divider,
                UIHelper.verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                          child: Text(
                            FlutterI18n.translate(context, "taxRate"),
                            style: headText5,
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          payOrder.tax.toString(),
                          style: headText5,
                        ))
                  ],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.divider,
                UIHelper.verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                          child: Text(
                            FlutterI18n.translate(context, "price"),
                            style: headText5,
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          payOrder.price.toString(),
                          style: headText5,
                        ))
                  ],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.divider,
                UIHelper.verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 3),
                          child: Text(
                            FlutterI18n.translate(context, "quantity"),
                            style: headText5,
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(
                          payOrder.qty.toString(),
                          style: headText5,
                        ))
                  ],
                ),
                UIHelper.verticalSpaceSmall,
                UIHelper.divider,
                UIHelper.verticalSpaceSmall,
                payOrder.rebateRate != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, bottom: 3),
                                child: Text(
                                  FlutterI18n.translate(context, "rebateRate"),
                                  style: headText5,
                                ),
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                payOrder.rebateRate.toString(),
                                style: headText5,
                              ))
                        ],
                      )
                    : Container(),
              ]),
            ),
          );
        });
  }

  orderDetails({String? barcodeScanData}) async {
    String scannedOrderId = '';

    String scannedTemplateId = '';
    String charToCompare = barcodeScanData![0];
    debugPrint('charToCompare $charToCompare');
    loadingStatus =
        FlutterI18n.translate(sharedService.context, "gettingOrderDetails");
    if (charToCompare == "i") {
      scannedOrderId = extractId(barcodeScanData);
      log.i('scanRes $scannedOrderId');
      await getOrderDetailsById(scannedOrderId);
    } else if (charToCompare == "t") {
      scannedTemplateId = extractId(barcodeScanData);
      orderIdFromCreateStoreOrder =
          await paycoolService.createTemplateById(scannedTemplateId.toString());
      getOrderDetailsById(orderIdFromCreateStoreOrder!);
    } else {
      sharedService.sharedSimpleNotification('Incorrect data format');
    }
  }

  void scanBarcodeV2({
    String addressType = Constants.MerchantAddressText,
  }) async {
    resetVariables();
    try {
      setBusy(true);
      log.w('setbusy 1 $isBusy');

      String? barcodeScanData = '';
      payOrder = PayOrder();
      barcodeScanData = await BarcodeUtils().majaScan(sharedService.context);

      if (addressType == Constants.ReferralAddressText) {
        debugPrint('in 1st if-- barcode res-- $barcodeScanData');

        referralController.text = barcodeScanData!;
      }
      if (addressType == Constants.MerchantAddressText) {
        if (barcodeScanData != null) {
          log.w('setbusy 1.2 $isBusy');
          await orderDetails(barcodeScanData: barcodeScanData);
          log.w('setbusy 1.3 $isBusy');
        } else if (barcodeScanData == '-1') {
          sharedService.sharedSimpleNotification(
            FlutterI18n.translate(sharedService.context, "scanCancelled"),
          );
          setBusy(false);
          return;
        }
      }
    } on PlatformException catch (e) {
      if (e.code == "PERMISSION_NOT_GRANTED") {
        setBusy(false);
        sharedService.sharedSimpleNotification(
          FlutterI18n.translate(sharedService.context, "userAccessDenied"),
        );
        // receiverWalletAddressTextController.text =
        //     FlutterI18n.translate(context, "userAccessDenied");
      } else {
        // setBusy(true);
        sharedService.sharedSimpleNotification(
          FlutterI18n.translate(sharedService.context, "unknownError $e"),
        );
      }
    } on FormatException {
      log.e('scan barcode func: FormatException');
      sharedService.sharedSimpleNotification(
        FlutterI18n.translate(sharedService.context, "scanCancelled"),
      );
    } catch (e) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(sharedService.context, "unknownError"),
          isError: true);
      log.e('barcode scan catch $e');
    }
    log.w('setbusy 2 $isBusy');
    setBusy(false);
    log.w('setbusy 3 $isBusy');
  }

  invalidScanData(error) {
    log.e('catch error $error');
    String t = error.toString();
    loadingStatus = t;
    setBusy(false);
  }

  Future<void> getOrderDetailsById(String scanRes) async {
    //setBusy(true);
    loadingStatus = '';
    orderId = scanRes;
    try {
      await paycoolService
          .getPayOrderInfo(scanRes)
          .then((order) => payOrder = order!);
    } catch (err) {
      invalidScanData(err);
      return;
    }
    await paycoolService
        .getPayOrderInfoWithRewards(scanRes)
        .then((value) => rewardInfoModel = value)
        .catchError((err) {
      invalidScanData(err);
    });

    merchantModel = await paycoolService
        .getMerchantInfo(rewardInfoModel!.merchantId.toString());
    coinPayable = newCoinTypeMap[rewardInfoModel!.paidCoin].toString();
    if (coinPayable.isEmpty || coinPayable == "null") {
      var nullToken = await coinService.getSingleTokenData('',
          coinType: rewardInfoModel!.paidCoin!);
      coinPayable = nullToken!.tickerName!;
    }
    // ignore: iterable_contains_unrelated_type
    final v =
        exchangeBalances.indexWhere((element) => element.ticker == coinPayable);
    if (v.isNegative) {
      dialogService.showBasicDialog(
          title:
              "$coinPayable ${FlutterI18n.translate(sharedService.context, "insufficientBalanceForPayment")}",
          description: FlutterI18n.translate(
              sharedService.context, "PaycoolInsufficientBalanceDesc"),
          buttonTitle: FlutterI18n.translate(sharedService.context, "close"));
      resetVariables();
      setBusy(false);
      return;
    }
    try {
      await coinService
          .getSingleTokenData(coinPayable, coinType: rewardInfoModel!.paidCoin!)
          .then((t) {
        decimalLimit = t!.decimal!;
        log.i('decimalLimit $decimalLimit');
      });
    } catch (err) {
      if (decimalLimit == null || decimalLimit == 0) decimalLimit = 8;
      log.e('Decimal limit CATCH in barcode scan: $err');
    }
    amountPayable = rewardInfoModel!.totalAmount!;

    taxAmount = rewardInfoModel!.totalTax!;

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
    loadingStatus = '';
    // setBusy(false);
  }

  resetVariables() {
    payOrder = PayOrder();
    rewardInfoModel = PaymentRewardsModel();
    merchantModel = MerchantModel();
    amountPayable = Constants.decimalZero;
    taxAmount = Constants.decimalZero;
    coinPayable = '';
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

  updateSelectedTickernameIOS(int index, double updatedQuantity,
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
    await apiService.getSingleCoinExchangeBalance(tickerName).then((res) {
      exchangeBalances.firstWhere((element) {
        if (element.ticker == tickerName) {
          element.unlockedAmount = res!.unlockedAmount;
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
      String kbAddress =
          walletService.toKbPaymentAddress(coin!.address.toString());
      debugPrint('KBADDRESS $kbAddress');
      showDialog(
        context: sharedService.context,
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
                                          .writeAsBytes(byteData!.toList())
                                          .then((onFile) {
                                        Share.share(onFile.path,
                                            subject: kbAddress);
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
                                  file
                                      .writeAsBytes(byteData!.toList())
                                      .then((onFile) {
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

  Future contentPaste({String? addressType}) async {
    setBusy(true);
    await Clipboard.getData('text/plain').then((res) {
      pasteRes = res;
      if (addressType == Constants.ReferralAddressText) {
        referralController.text = '';
        referralController.text = res!.text.toString();
      }
      if (addressType == Constants.MerchantAddressText) {
        addressController.text = res!.text.toString();
      }
    });
    setBusy(false);
  }

  copyAddress(String txId) {
    Clipboard.setData(ClipboardData(text: txId));
    showSimpleNotification(
        Center(
            child: Text(
                FlutterI18n.translate(
                    sharedService.context, "copiedSuccessfully"),
                style: headText5)),
        position: NotificationPosition.bottom,
        background: primaryColor);
  }

  showJSBottomSheet() {}
}
