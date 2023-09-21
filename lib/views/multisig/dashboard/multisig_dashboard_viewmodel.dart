import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/exchange_balance_model.dart';
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
  final String txid;
  final BuildContext? context;
  MultisigDashboardViewModel({this.context, required this.txid});
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

  init() async {
    sharedService.context = context!;
    multisigWallets = await hiveService.getAllMultisigWallets();
    log.i(
        'init MultisigDashboardViewModel multisigWallets ${multisigWallets.length}');
    await getWalletByTxid(value: txid);
    setBusyForObject(multisigBalance, true);

    Future.delayed(Duration(milliseconds: 500), () {
      getBalance();
    });
  }

  navigateToTransferView(int index) {
    var data = MultisigBalanceModel(
      tokens: Tokens(
          ids: index == -1 ? [] : [multisigBalance.tokens!.ids![index]],
          balances: index == -1
              ? [multisigBalance.native.toString()]
              : [multisigBalance.tokens!.balances![index]],
          tickers: index == -1
              ? ['Kanban']
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

  getWalletByTxid({required String value}) async {
    var walletByTxid = hiveService.findMultisigWalletByTxid(value);
    if (walletByTxid.txid != null && walletByTxid.txid!.isNotEmpty) {
      multisigWallet = walletByTxid;
    } else {
      getWalletDataFromApi(value);
    }
  }

  // get txid data
  getWalletDataFromApi(String value) async {
    var data = await multisigService.getWalletData(value, isTxid: true);
    multisigWallet = data;
    log.w('multisigWallet ${multisigWallet.toJson()}');
  }
}
