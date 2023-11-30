import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/token_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/multisig_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:stacked/stacked.dart';

class AddWalletTokenWidgetViewModel extends ReactiveViewModel {
  final String chainName;

  AddWalletTokenWidgetViewModel({required this.chainName});
  final log = getLogger('AddWalletTokenWidgetViewModel');

  final sharedService = locator<SharedService>();
  final storageService = locator<LocalStorageService>();
  final multisigService = locator<MultiSigService>();
  final apiService = locator<ApiService>();
  List<TokenModel> selectedTokens = [];
  List<TokenModel> ethTokens = [];
  List<TokenModel> bscTokens = [];
  List<TokenModel> kanbanTokens = [];

  init() async {
    await getTokenList();
    if (chainName == 'ETH') {
      selectedTokens = TokenModelList.fromJson(
              jsonDecode(storageService.multisigEthWalletTokens))
          .tokens;
    }
    // if (chainName == 'KANBAN') {
    //   selectedTokens = TokenModelList.fromJson(
    //           jsonDecode(storageService.multisigKanbanWalletTokens))
    //       .tokens;
    // }
    else {
      selectedTokens = TokenModelList.fromJson(
              jsonDecode(storageService.multisigBscWalletTokens))
          .tokens;
    }
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [multisigService];

  getTokenList() async {
    var allTokens = await apiService.getTokenListUpdates();
    if (chainName == 'ETH') {
      ethTokens = allTokens
          .where((element) => element.chainName!.toUpperCase() == chainName)
          .toList();
      log.i('$chainName Tokens length ${ethTokens.length}');
    }
    if (chainName == 'KANBAN') {
      kanbanTokens = allTokens
          .where((element) => element.chainName!.toUpperCase() == "FAB")
          .toList();
      log.i('$chainName Tokens length ${kanbanTokens.length}');
    } else {
      bscTokens = allTokens
          .where((element) => element.chainName!.toUpperCase() == chainName)
          .toList();
      log.i('$chainName Tokens length ${bscTokens.length}');
    }
  }

  showAddTokensBottomSheet(BuildContext context) async {
    var tokenList = chainName == 'ETH' ? ethTokens : bscTokens;

    String? isMatched;
    if (tokenList.isNotEmpty) {
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
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    padding: const EdgeInsets.all(5),
                    //  height: 500,
                    child: ListView.builder(
                        itemCount: tokenList.length,
                        itemBuilder: (context, index) {
                          try {
                            isMatched = selectedTokens
                                .firstWhere((element) =>
                                    element.coinType ==
                                    tokenList[index].coinType)
                                .tickerName;

                            // ignore: avoid_print
                            debugPrint(
                                '${tokenList[index].tickerName} -- is in the selectedTokens list ? $isMatched match found -- with token id ${ethTokens[index].coinType}');
                          } catch (err) {
                            isMatched = null;
                            log.w(
                                'no match found in storage ${tokenList[index].tickerName} with cointype ${tokenList[index].coinType}');
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
                                        Text(tokenList[index].tickerName!,
                                            style: const TextStyle(
                                              color: primaryColor,
                                              fontSize: 12,
                                            )),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2.0, right: 10),
                                          child: Text(
                                              tokenList[index].contract!,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: grey,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
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
                                                    fontSize: 12, color: black
                                                    // isMatched == null
                                                    //     ? green
                                                    //     : red
                                                    )),
                                          ),
                                          // Icon(
                                          //   isMatched == null
                                          //       ? Icons.add_box_rounded
                                          //       : Icons.cancel_outlined,
                                          //   color:
                                          //       isMatched == null ? green : red,
                                          //   size: 14,
                                          // )
                                        ],
                                      ),
                                      onPressed: () {
                                        int tokenIndexToRemove = selectedTokens
                                            .indexWhere((element) =>
                                                element.coinType ==
                                                tokenList[index].coinType);
                                        setBusyForObject(selectedTokens, true);

                                        if (tokenIndexToRemove.isNegative) {
                                          setState(() => selectedTokens
                                              .add(tokenList[index]));
                                        } else {
                                          if (selectedTokens.isNotEmpty) {
                                            log.w(
                                                'last item ${selectedTokens.last.toJson()}');
                                          }
                                          log.i(
                                              'selectedTokens - length before removing token ${selectedTokens.length}');
                                          setState(() => selectedTokens
                                              .removeAt(tokenIndexToRemove));

                                          log.e(
                                              'selectedTokens - length --selectedTokens.length => removed token ${tokenList[index].tickerName}');
                                        }
                                        setBusyForObject(selectedTokens, false);

                                        log.i(
                                            'tokenList - length ${selectedTokens.length}');
                                        var jsonString = [];
                                        jsonString = selectedTokens
                                            .map((cToken) =>
                                                jsonEncode(cToken.toJson()))
                                            .toList();
                                        if (chainName == 'ETH') {
                                          storageService
                                              .multisigEthWalletTokens = '';
                                          storageService
                                                  .multisigEthWalletTokens =
                                              jsonString.toString();
                                        } else {
                                          storageService
                                              .multisigBscWalletTokens = '';
                                          storageService
                                                  .multisigBscWalletTokens =
                                              jsonString.toString();
                                        }
                                        multisigService
                                            .hasUpdatedTokenListFunc(true);
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
