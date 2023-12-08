import 'package:flutter/material.dart';
import 'package:paycool/models/wallet/wallet.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/providers/app_state_provider.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/wallet/wallet_util.dart';
import 'package:paycool/widgets/coin_list_widget.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';

class TransferViewModel extends BaseViewModel {
  BuildContext? context;
  late AppStateProvider appStateProvider;
  final walletUtil = WalletUtil();
  final walletService = WalletService();
  WalletInfo? selectedCoin;

  List<WalletBalance> wallets = [];
  WalletInfo? get selectedWallet => walletService.walletInfoDetails;

  final amountTextController = TextEditingController(text: ("0.5"));
  final gasPriceTextController = TextEditingController(text: ("90"));
  final gasLimitTextController = TextEditingController(text: ("21000"));
  final kanbanGasPriceTextController = TextEditingController(text: ("5000000"));
  final kanbanGasLimitTextController = TextEditingController(text: ("2000000"));

  String fromText = "Wallet";
  String toText = "Exchangily";

  double gasPrice = 0.0;
  double gasLimit = 0.0;
  double transFee = 0.0;
  String feeUnit = '';

  initState() async {
    appStateProvider = Provider.of<AppStateProvider>(context!, listen: false);
    getWalletInfo();
  }

  Future<void> getWalletInfo() async {
    wallets = appStateProvider.getWalletBalances;
    notifyListeners();
  }

  goToCoinList(size) async {
    showModalBottomSheet(
      context: context!,
      isScrollControlled: true,
      builder: (BuildContext context) =>
          coinListBottomSheet(context, size, wallets),
    ).then((value) async {
      if (value != null) {
        selectedCoin =
            await walletUtil.getWalletInfoObjFromWalletBalance(value);
        notifyListeners();
      }
    });
  }
}
