import 'package:paycool/constants/route_names.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class BackupMnemonicViewModel extends BaseViewModel {
  List<String> randomMnemonicList = [];
  int count = 12;
  WalletService walletService = locator<WalletService>();
  final navigationService = locator<NavigationService>();

  init() {
    setBusy(true);

    final randomMnemonicString = walletService.getRandomMnemonic();
    // convert string to list to iterate and display single word in a textbox
    randomMnemonicList = randomMnemonicString.split(" ").toList();

    setBusy(false);
  }

  onBackButtonPressed() {
    navigationService.navigateTo(WalletSetupViewRoute);
  }
}
