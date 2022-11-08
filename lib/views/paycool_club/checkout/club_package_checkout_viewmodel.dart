import 'package:decimal/decimal.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/constants.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/models/wallet/wallet_balance.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/wallet_service.dart';
import 'package:paycool/utils/wallet/wallet_util.dart';
import 'package:paycool/views/paycool/paycool_service.dart';
import 'package:paycool/views/paycool_club/club_projects/club_package_checkout_model.dart';
import 'package:paycool/views/paycool_club/club_projects/club_project_model.dart';
import 'package:stacked/stacked.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/navigation_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/paycool_club/paycool_club_service.dart';

class ClubPackageCheckoutViewModel extends FutureViewModel {
  final String packageId;
  final String ticker;
  ClubPackageCheckoutViewModel(this.packageId, this.ticker);

  final log = getLogger('ClubProjectDetailsViewModel');
  final navigationService = locator<NavigationService>();
  final clubService = locator<PayCoolClubService>();
  final paycoolService = locator<PayCoolService>();
  final sharedService = locator<SharedService>();
  final storageService = locator<LocalStorageService>();
  final dialogService = locator<LocalDialogService>();
  final walletService = locator<WalletService>();
  final apiService = locator<ApiService>();
  String selectedTicker = '';
  ClubPackageCheckout clubPackageCheckout = ClubPackageCheckout();
  ClubProject clubProject = ClubProject();
  Decimal exchangeBalance = Decimal.zero;
  Decimal gasBalance = Constants.decimalZero;

  BuildContext context;
  String title = '';
  String desc = '';

  @override
  Future futureToRun() async =>
      await clubService.getPackageCheckoutDetails(packageId, ticker);

  @override
  void onData(data) async {
    clubPackageCheckout = data;
    title = storageService.language == 'en'
        ? clubProject.name.en
        : clubProject.name.sc;
    desc = storageService.language == 'en'
        ? clubProject.description.en
        : clubProject.description.sc;
    await getExchangeBalance();
  }

  getGasBalance() async {
    String exgAddress =
        await sharedService.getExgAddressFromCoreWalletDatabase();
    var res = await walletService.gasBalance(exgAddress);
    gasBalance = Decimal.parse(res.toString());
  }

  showCheckoutDialog(ClubProject selectedPackage) async {
    clubPackageCheckout = await clubService.getPackageCheckoutDetails(
        selectedPackage.sId, selectedTicker);

    dialogService.showBasicDialog(
        title: title, description: desc, buttonTitle: 'Pay');
  }

  getExchangeBalance() async {
    setBusy(true);
    await getGasBalance();
    var fabAddress = await sharedService.getFabAddressFromCoreWalletDatabase();
    var walletUtil = WalletUtil();
    String walletAddress = '';
    await walletUtil
        .getWalletInfoObjFromWalletBalance(WalletBalance(coin: ticker))
        .then((wallet) {
      walletAddress = wallet.address;
    });

    log.i('selected ticker walletAddress $walletAddress');

    // Get single wallet balance

    await apiService
        .getSingleWalletBalance(fabAddress, ticker, walletAddress)
        .then((res) async {
      if (res != null && !res[0].unlockedExchangeBalance.isNegative) {
        log.w(res[0].unlockedExchangeBalance);
        //  walletBalance[0].unlockedExchangeBalance;
        exchangeBalance =
            Decimal.parse(res.first.unlockedExchangeBalance.toString());
      }
    }).catchError((err) {
      log.e(err);
      setBusy(false);
      throw Exception(err);
    });

    setBusy(false);
  }

  buyPackage() async {
    if (gasBalance == Decimal.zero) {
      sharedService.sharedSimpleNotification(
          FlutterI18n.translate(context, "insufficientGasAmount"));
      setBusy(false);
      return;
    }
    await getExchangeBalance();
    if (clubProject.joiningFee > exchangeBalance) {
      sharedService.sharedSimpleNotification(ticker,
          subtitle: FlutterI18n.translate(context, "insufficientBalance"));
      setBusy(false);
      return;
    }
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

        var seed = walletService.generateSeed(mnemonic);
        var res = await paycoolService.signSendTx(
            seed, clubPackageCheckout.clubParams);

        if (res == '0x1') {
          payOrderConfirmationPopup();
        } else if (res == '0x0') {
          sharedService.sharedSimpleNotification(
              FlutterI18n.translate(context, "failed"),
              isError: true);
        }
        // var errMsg = res['errMsg'];
      } else if (passRes.returnedText == 'Closed' && !passRes.confirmed) {
        log.e('Dialog Closed By User');

        setBusy(false);
      } else {
        log.e('Wrong pass');

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
      buttonTitle: FlutterI18n.translate(context, "visitDashboard"),
    )
        .then((res) {
      if (res.confirmed) {
        navigationService.navigateTo(PayCoolClubDashboardViewRoute);
      }
    });
  }
}
