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
import 'package:paycool/utils/fab_util.dart';
import 'package:paycool/views/multisig/multisig_wallet_model.dart';
import 'package:stacked/stacked.dart';

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

  List<ExchangeBalanceModel> exchangeBalances = [];
  List<MultisigWalletModel> multisigWallets = [];
  MultisigWalletModel multisigWallet = MultisigWalletModel();
  final fabUtils = FabUtils();

  getBalance() async {
    setBusyForObject(exchangeBalances, true);
    var data =
        await apiService.getAssetsBalance(multisigWallet.address.toString());

    exchangeBalances = data!;
    for (var element in exchangeBalances) {
      debugPrint(element.toJson().toString());
      if (element.ticker.isEmpty) {
        tokenListDatabaseService
            .getTickerNameByCoinType(element.coinType)
            .then((ticker) {
          debugPrint(ticker);

          element.ticker = ticker;
        });

        debugPrint('exchanageBalanceModel tickerName ${element.ticker}');
      }
    }
    setBusyForObject(exchangeBalances, false);
  }

  init() async {
    sharedService.context = context!;
    multisigWallets = await hiveService.getAllMultisigWallets();
    log.i(
        'init MultisigDashboardViewModel multisigWallets ${multisigWallets.length}');
    await getWalletByTxid(value: txid);
    setBusyForObject(exchangeBalances, true);
    Future.delayed(Duration(milliseconds: 500), () {
      getBalance();
    });
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
    var data = await multisigService.getTxidData(value);
    multisigWallet = data;
    log.w('multisigWallet ${multisigWallet.toJson()}');
  }
}
