import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/models/wallet/custom_token_model.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/coin_util.dart';
import 'package:stacked_services/stacked_services.dart';

class AddTokenCustomView extends StatefulWidget {
  const AddTokenCustomView({super.key});

  @override
  State<AddTokenCustomView> createState() => _AddTokenState();
}

class _AddTokenState extends State<AddTokenCustomView> {
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  final navigationService = locator<NavigationService>();
  final sharedService = locator<SharedService>();
  final walletDatabaseService = locator<WalletDatabaseService>();
  final storageService = locator<LocalStorageService>();
  final apiService = locator<ApiService>();

  List<CustomTokenModel>? customTokens = [];
  List<CustomTokenModel>? selectedCustomTokens = [];

  static const String emptyWalletLocalUrl =
      'assets/images/paycool/Waves_01_4-2.png';

  @override
  void initState() {
    getList();
    super.initState();
  }

  Future<void> getList() async {
    customTokens = await apiService.getCustomTokens();
    await getBalanceForSelectedCustomTokens();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: customAppBarWithIcon(
        title: FlutterI18n.translate(context, "customTokens"),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton.icon(
                icon: Icon(Icons.arrow_circle_up),
                label: selectedCustomTokens!.isNotEmpty
                    ? Text(
                        ' ${FlutterI18n.translate(context, "editTokenList")}',
                        style: const TextStyle(
                            color: white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      )
                    : Text(' ${FlutterI18n.translate(context, "addToken")}',
                        style: const TextStyle(
                            color: white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                onPressed: () {
                  showCustomTokensBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: buttonGreen,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SizedBox(
          width: size.width,
          height: size.height,
          child: selectedCustomTokens!.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      emptyWalletLocalUrl,
                      color: Colors.grey,
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(height: 5),
                    Text(FlutterI18n.translate(context, "customTokens"),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                )
              : Column(
                  children: [
                    UIHelper.verticalSpaceSmall,
                    // symbol balance action text row
                    Container(
                      color: white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Row(
                        children: [
                          Text(
                            FlutterI18n.translate(context, "logo"),
                            style: const TextStyle(
                                color: black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          UIHelper.horizontalSpaceMedium,
                          Expanded(
                              flex: 1,
                              child: Text(
                                  FlutterI18n.translate(context, "symbol"),
                                  style: const TextStyle(
                                      color: black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600))),
                          Expanded(
                              flex: 2,
                              child: Text(
                                FlutterI18n.translate(context, "balance"),
                                style: const TextStyle(
                                    color: black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                                //  textAlign: TextAlign.center,
                              )),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  FlutterI18n.translate(context, "action"),
                                  style: const TextStyle(
                                      color: black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)))
                        ],
                      ),
                    ),

                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 10),
                        child: ListView.builder(
                            padding: const EdgeInsets.only(top: 0),
                            shrinkWrap: true,
                            itemCount: selectedCustomTokens!.length,
                            itemBuilder: (BuildContext context, int index) {
                              var customToken = selectedCustomTokens![index];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 1),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(9)),
                                padding: const EdgeInsets.all(3),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // logo
                                    Container(
                                      width: 25,
                                      height: 25,
                                      margin: const EdgeInsets.only(left: 10),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                '${baseBlockchainGateV2Url}issuetoken/${customToken.tokenId}/logo',
                                              ),
                                              fit: BoxFit.cover),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                    ),
                                    UIHelper.horizontalSpaceMedium,

                                    // Symbol and name
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        customToken.symbol!.toUpperCase(),
                                        style: const TextStyle(
                                            color: grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    UIHelper.horizontalSpaceMedium,
                                    UIHelper.horizontalSpaceSmall,
                                    // Balance
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        customToken.balance.toString(),
                                        style: const TextStyle(color: white),
                                      ),
                                    ),
                                    //  Action
                                    Container(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            padding: EdgeInsetsDirectional.zero,
                                            onPressed: () async {
                                              var wi = WalletInfo(
                                                  address:
                                                      await coreWalletDatabaseService
                                                          .getWalletAddressByTickerName(
                                                              'FAB'));
                                              navigationService.navigateTo(
                                                  ReceiveViewRoute,
                                                  arguments: wi);
                                            },
                                            icon: Column(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .download_for_offline_rounded,
                                                  color: green,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                      FlutterI18n.translate(
                                                          context, "receive"),
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: white)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            padding: EdgeInsetsDirectional.zero,
                                            onPressed: () {
                                              routeCustomToken(customToken);
                                            },
                                            icon: Column(
                                              children: [
                                                const Icon(
                                                  Icons.send_rounded,
                                                  color: primaryColor,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                      FlutterI18n.translate(
                                                          context, "send"),
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: white)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: IconButton(
                                              padding:
                                                  EdgeInsetsDirectional.zero,
                                              onPressed: () {
                                                routeCustomToken(customToken,
                                                    isSend: false);
                                              },
                                              icon: const Icon(
                                                Icons.history_rounded,
                                                color: yellow,
                                                size: 24,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                )),
    );
  }

  // Get EXG address from wallet database
  Future<String> getExgAddressFromWalletDatabase() async {
    String address = '';
    await walletDatabaseService
        .getWalletBytickerName('EXG')
        .then((res) => address = res!.address!);
    return address;
  }

  // Send custom token
  routeCustomToken(CustomTokenModel customTokenModel,
      {bool isSend = true}) async {
    var wallet = WalletInfo(
        tickerName: customTokenModel.symbol,
        tokenType: 'FAB',
        address: await getExgAddressFromWalletDatabase(),
        availableBalance: customTokenModel.balance);
    storageService.customTokenData = jsonEncode(customTokenModel.toJson());
    navigationService.navigateTo(
        isSend ? SendViewRoute : TransactionHistoryViewRoute,
        arguments: wallet);
  }

  // get balance for Selected custom tokens

  Future getBalanceForSelectedCustomTokens() async {
    selectedCustomTokens!.clear();
    String selectedCustomTokensJson = storageService.customTokens;
    if (selectedCustomTokensJson != '') {
      List<CustomTokenModel>? customTokensFromStorage =
          CustomTokenModelList.fromJson(jsonDecode(selectedCustomTokensJson))
              .customTokens;

      selectedCustomTokens = customTokensFromStorage;
      if (selectedCustomTokens!.isNotEmpty) {
        for (var token in selectedCustomTokens!) {
          var balance = await fabUtils.getFabTokenBalanceForABI(
              Constants.customTokenSignatureAbi,
              token.tokenId!,
              await getExgAddressFromWalletDatabase(),
              token.decimal);

          token.balance = balance;
        }
      }
    }
  }

  // addCustomToken
  showCustomTokensBottomSheet(BuildContext context) async {
    String? isMatched;
    if (customTokens!.isNotEmpty) {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          context: context,
          builder: (BuildContext context) => FractionallySizedBox(
                heightFactor: 0.9,
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 15),
                    padding: const EdgeInsets.all(5),
                    child: ListView.builder(
                        itemCount: customTokens!.length,
                        itemBuilder: (context, index) {
                          try {
                            isMatched = selectedCustomTokens!
                                .firstWhere((element) =>
                                    element.tokenId ==
                                    customTokens![index].tokenId)
                                .symbol;
                          } catch (err) {
                            isMatched = null;
                          }
                          return Container(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Text(
                                              customTokens![index]
                                                  .symbol!
                                                  .toUpperCase(),
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Text(customTokens![index].name!,
                                            style: const TextStyle(
                                              color: primaryColor,
                                              fontSize: 12,
                                            ))
                                      ],
                                    ),
                                  ),
                                  // Total supply
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 3.0),
                                          child: Text(
                                              FlutterI18n.translate(
                                                  context, "totalSupply"),
                                              style: const TextStyle(
                                                  color: primaryColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Text(customTokens![index].totalSupply!,
                                            style: const TextStyle(
                                                color: grey, fontSize: 12))
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: OutlinedButton(
                                      style: ButtonStyle(
                                        side: MaterialStateProperty.all(
                                            (const BorderSide(
                                                color: primaryColor,
                                                width: 1))),
                                        shape: MaterialStateProperty.all(
                                            const StadiumBorder(
                                          side: BorderSide(
                                              color: primaryColor, width: 1),
                                        )),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 2.0),
                                            child: Text(
                                                isMatched == null
                                                    ? FlutterI18n.translate(
                                                        context, "add")
                                                    : FlutterI18n.translate(
                                                        context, "remove"),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: black)),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        int tokenIndexToRemove =
                                            selectedCustomTokens!.indexWhere(
                                                (element) =>
                                                    element.tokenId ==
                                                    customTokens![index]
                                                        .tokenId);

                                        if (tokenIndexToRemove.isNegative) {
                                          setState(() => selectedCustomTokens!
                                              .add(customTokens![index]));
                                        } else {
                                          if (selectedCustomTokens!
                                              .isNotEmpty) {
                                            log.w(
                                                'last item ${selectedCustomTokens!.last.toJson()}');
                                          }
                                          log.i(
                                              'selectedCustomTokens - length before removing token ${selectedCustomTokens!.length}');
                                          setState(() => selectedCustomTokens!
                                              .removeAt(tokenIndexToRemove));

                                          log.e(
                                              'selectedCustomTokens - length --selectedCustomTokens.length => removed token ${customTokens![index].symbol}');
                                        }

                                        log.i(
                                            'customTokens - length ${selectedCustomTokens!.length}');
                                        var jsonString = [];
                                        jsonString = selectedCustomTokens!
                                            .map((cToken) =>
                                                jsonEncode(cToken.toJson()))
                                            .toList();
                                        storageService.customTokens = '';
                                        storageService.customTokens =
                                            jsonString.toString();
                                      },
                                    ),
                                  ),
                                ]),
                          );
                        }),
                  );
                }),
              ));
    } else {
      log.e('Issue token list empty');
    }
  }
}
