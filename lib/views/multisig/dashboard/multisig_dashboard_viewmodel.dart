import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/token_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/hive_multisig_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/multisig_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/views/multisig/dashboard/multisig_balance_model.dart';
import 'package:paycool/views/multisig/import_multisig_wallet/import_multisig_view.dart';
import 'package:paycool/views/multisig/multisig_util.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';
import 'package:paycool/views/multisig/transfer/mutlisig_transfer_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MultisigDashboardViewModel extends ReactiveViewModel {
  final String data;
  final BuildContext? context;
  MultisigDashboardViewModel({this.context, required this.data});
  final log = getLogger('MultisigDashboardViewModel');

  final multisigService = locator<MultiSigService>();
  final hiveService = locator<HiveMultisigService>();
  final sharedService = locator<SharedService>();
  final apiService = locator<ApiService>();
  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  final navigationService = locator<NavigationService>();
  final walletService = locator<WalletService>();
  final storageService = locator<LocalStorageService>();
  MultisigBalanceModel multisigBalance = MultisigBalanceModel();
  List<MultisigWalletModel> multisigWallets = [];
  MultisigWalletModel multisigWallet = MultisigWalletModel();
  final fabUtils = FabUtils();
  double? gasBalance = 0.0;
  String exgAddress = '';
  String ethAddress = '';
  List<TokenModel> selectedTokens = [];
  List<TokenModel> ethTokens = [];
  bool canTransferAssets = false;

  @override
  List<ListenableServiceMixin> get listenableServices => [multisigService];

  init() async {
    setBusy(true);
    sharedService.context = context!;
    ethAddress = await sharedService.getExgAddressFromCoreWalletDatabase();
    exgAddress =
        await sharedService.getCoinAddressFromCoreWalletDatabase('ETH');
    await importWallet(data: data);
    multisigWallets = await hiveService.getAllMultisigWallets();
    multisigWallets.removeWhere(
        (element) => element.address == null || element.address!.isEmpty);
    //Future.delayed(Duration(milliseconds: 500), () {
    await getBalance();
    // });
    setBusy(false);
  }

  navigateToTransferView(int index) {
    var data = MultisigBalanceModel(
      tokens: Tokens(
          ids: index == -1 ? [] : [multisigBalance.tokens!.ids![index]],
          balances: index == -1
              ? [multisigBalance.native.toString()]
              : [multisigBalance.tokens!.balances![index]],
          tickers: index == -1
              ? ['kanban']
              : [multisigBalance.tokens!.tickers![index]],
          decimals: index == -1
              ? ["18"]
              : [multisigBalance.tokens!.decimals![index]]),
    );
    log.i("index $index - data ${data.toJson()}");
    navigationService.navigateWithTransition(MultisigTransferView(
        multisigBalance: data, multisigWallet: multisigWallet));
  }

  Widget refreshBalanceWidget() {
    if (multisigService.hasUpdatedTokenList) {
      multisigService.hasUpdatedTokenListFunc(false);
      getBalance();
    }
    return IconButton(
      icon: Icon(
        Icons.refresh,
        color: primaryColor,
      ),
      onPressed: () {
        getBalance();
      },
    );
  }

  List<String> tokenIds() {
    List<String> tokenIds = [];
    selectedTokens.clear();
    String selectedTokensJson = '';
    if (multisigWallet.chain == 'ETH') {
      selectedTokensJson = storageService.multisigEthWalletTokens;
    } else {
      selectedTokensJson = storageService.multisigBscWalletTokens;
    }

    if (selectedTokensJson != '') {
      List<TokenModel>? tokensFromStorage =
          TokenModelList.fromJson(jsonDecode(selectedTokensJson)).tokens;

      selectedTokens = tokensFromStorage;
      if (selectedTokens.isNotEmpty) {
        log.w('selectedTokens length ${selectedTokens.length}');
        for (var token in selectedTokens) {
          tokenIds.addAll([token.contract.toString()]);
          log.i('token ${token.tickerName} contract ${token.contract}');
        }
      }
    }

    return tokenIds;
  }

  getBalance() async {
    setBusyForObject(multisigBalance, true);

    var data = await multisigService.getBalance(
        multisigWallet.address.toString(),
        chain: multisigWallet.chain!,
        tokenIds: tokenIds());

    multisigBalance = data;
    for (var i = 0; i < multisigBalance.tokens!.ids!.length; i++) {
      debugPrint("id  ${multisigBalance.tokens!.ids![i]}");
      if (MultisigUtil.isChainKanban(multisigWallet.chain!)) {
        int ct = int.parse(multisigBalance.tokens!.ids![i].toString());
        await tokenListDatabaseService
            .getTickerNameByCoinType(ct)
            .then((ticker) {
          debugPrint(ticker);
          multisigBalance.tokens!.tickers![i] = ticker;
        });
      }
      for (var singleToken in selectedTokens) {
        if (singleToken.contract == multisigBalance.tokens!.ids![i]) {
          log.w('assigning token tickerName ${singleToken.tickerName}');
          multisigBalance.tokens!.tickers![i] = singleToken.tickerName!;
        }
      }
    }
    setBusyForObject(multisigBalance, false);
  }

  importWallet({required String data, bool isAddress = true}) async {
    var wallet = MultisigWalletModel();

    setBusyForObject(multisigWallet, true);
    try {
      wallet = isAddress
          ? hiveService.findMultisigWalletByAddress(data)
          : hiveService.findMultisigWalletByTxid(data);
    } catch (e) {
      log.e(
          'CATCH error: Cannot find the address ${multisigWallet.chain} wallet with txid ${multisigWallet.txid} in hive storage -- $e');
    }
    if (wallet.txid != null &&
        wallet.txid!.isNotEmpty &&
        wallet.address != null &&
        wallet.address!.isNotEmpty) {
      multisigWallet = wallet;
    } else {
      if (data == "null") {
        setBusy(false);

        navigationService.navigateWithTransition(ImportMultisigView(),
            transitionStyle: Transition.leftToRightWithFade,
            duration: Duration(milliseconds: 500));

        return;
      }
      multisigWallet =
          await multisigService.importMultisigWallet(data, isTxid: true);

      log.w(
          'multisigWallet from api using txid result ${multisigWallet.toJson()}');
      if (multisigWallet.address == null || multisigWallet.address!.isEmpty) {
        log.e('multisigWallet address is null or empty');
        setBusy(false);

        navigationService.navigateWithTransition(ImportMultisigView(),
            transitionStyle: Transition.leftToRightWithFade,
            duration: Duration(milliseconds: 500));

        return;
      }

      await hiveService.addMultisigWallet(multisigWallet);
    }
    for (var element in multisigWallet.owners!) {
      if (element.address == exgAddress || element.address == ethAddress) {
        canTransferAssets = true;
        return;
      } else {
        canTransferAssets = false;
      }
    }

    setBusyForObject(multisigWallet, false);
    rebuildUi();
  }

  logout() async {
    hiveService.deleteMultisigWalletByAddress(multisigWallet.address!);
    multisigWallets = await hiveService.getAllMultisigWallets();
    importWallet(data: multisigWallets[0].address!);
    rebuildUi();
  }
}
