import 'package:flutter/material.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/hive_service.dart';
import 'package:paycool/services/multisig_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/views/multisig/dashboard/multisig_balance_model.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';
import 'package:paycool/views/multisig/transfer/mutlisig_transfer_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MultisigDashboardViewModel extends BaseViewModel {
  final String data;
  final BuildContext? context;
  MultisigDashboardViewModel({this.context, required this.data});
  final log = getLogger('MultisigDashboardViewModel');

  final multisigService = locator<MultiSigService>();
  final hiveService = locator<HiveService>();
  final sharedService = locator<SharedService>();
  final apiService = locator<ApiService>();
  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  final navigationService = locator<NavigationService>();
  final walletService = locator<WalletService>();

  MultisigBalanceModel multisigBalance = MultisigBalanceModel();
  List<MultisigWalletModel> multisigWallets = [];
  MultisigWalletModel multisigWallet = MultisigWalletModel();
  final fabUtils = FabUtils();
  double? gasBalance = 0.0;
  String exgAddress = '';
  bool canTransferAssets = false;

  init() async {
    sharedService.context = context!;
    exgAddress = await sharedService.getExgAddressFromCoreWalletDatabase();
    await importWallet(addressOrTxid: data);
    multisigWallets = await hiveService.getAllMultisigWallets();
    log.i(
        'init MultisigDashboardViewModel multisigWallets ${multisigWallets.length}');

    //Future.delayed(Duration(milliseconds: 500), () {
    await getBalance();
    // });
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

  getBalance() async {
    setBusyForObject(multisigBalance, true);

    var data = await multisigService.getBalance(
        multisigWallet.address.toString(),
        chain: multisigWallet.chain!);

    multisigBalance = data;
    for (var i = 0; i < multisigBalance.tokens!.ids!.length; i++) {
      debugPrint("id  ${multisigBalance.tokens!.ids![i]}");
      int ct = int.parse(multisigBalance.tokens!.ids![i].toString());
      await tokenListDatabaseService.getTickerNameByCoinType(ct).then((ticker) {
        debugPrint(ticker);
        multisigBalance.tokens!.tickers![i] = ticker;
        // multisigBalance.tokens!.dec![i] = ticker;
      });
    }
    setBusyForObject(multisigBalance, false);
  }

  importWallet({required String addressOrTxid, bool isAddress = true}) async {
    var wallet = MultisigWalletModel();

    setBusyForObject(multisigWallet, true);
    try {
      wallet = isAddress
          ? hiveService.findMultisigWalletByAddress(addressOrTxid)
          : hiveService.findMultisigWalletByTxid(addressOrTxid);
    } catch (e) {
      log.e('error $e');
    }
    if (wallet.txid != null && wallet.txid!.isNotEmpty) {
      multisigWallet = wallet;
    } else {
      multisigWallet =
          await multisigService.importMultisigWallet(addressOrTxid);

      log.w('multisigWallet ${multisigWallet.toJson()}');

      await hiveService.addMultisigWallet(multisigWallet);
    }
    for (var element in multisigWallet.owners!) {
      if (element.address == exgAddress) {
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
    importWallet(addressOrTxid: multisigWallets[0].address!);
    rebuildUi();
  }
}
