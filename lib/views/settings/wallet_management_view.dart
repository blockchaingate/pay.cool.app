import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/dialog/dialog_response.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/db/core_wallet_database_service.dart';
import 'package:paycool/services/db/token_list_database_service.dart';
import 'package:paycool/services/db/transaction_history_database_service.dart';
import 'package:paycool/services/db/user_settings_database_service.dart';
import 'package:paycool/services/db/wallet_database_service.dart';
import 'package:paycool/services/local_dialog_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/vault_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletManagementView extends StatefulWidget {
  const WalletManagementView({super.key});

  @override
  State<WalletManagementView> createState() => _WalletManagementViewState();
}

class _WalletManagementViewState extends State<WalletManagementView> {
  final dialogService = locator<LocalDialogService>();
  final storageService = locator<LocalStorageService>();
  final transactionHistoryDatabaseService =
      locator<TransactionHistoryDatabaseService>();
  final tokenListDatabaseService = locator<TokenListDatabaseService>();
  final vaultService = locator<VaultService>();
  final walletDatabaseService = locator<WalletDatabaseService>();
  final coreWalletDatabaseService = locator<CoreWalletDatabaseService>();
  final userSettingsDatabaseService = locator<UserSettingsDatabaseService>();

  //delete wallet
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: customAppBarWithIcon(
        title: FlutterI18n.translate(context, "walletManagement"),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            )),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UIHelper.verticalSpaceMedium,
            if (errorMessage != null)
              Container(
                width: size.width,
                height: 50,
                color: bgLightRed,
                child: Center(
                    child: Text(
                  errorMessage!,
                  style: TextStyle(color: textRed, fontWeight: FontWeight.w500),
                )),
              ),
            UIHelper.verticalSpaceSmall,
            InkWell(
              onTap: () async {
                await displayMnemonic();
              },
              child: Container(
                width: size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      FlutterI18n.translate(context, "displayMnemonic"),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: black),
                    ),
                    Expanded(child: SizedBox()),
                    Icon(Icons.arrow_forward_ios, color: black, size: 14)
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey[100],
              thickness: 1,
            ),
            InkWell(
              onTap: () async {
                await deleteWallet();
              },
              child: Container(
                width: size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      FlutterI18n.translate(context, "deleteWallet"),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: black),
                    ),
                    Expanded(child: SizedBox()),
                    Icon(Icons.arrow_forward_ios, color: black, size: 14)
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey[100],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }

  Future<DialogResponse?> shohPasswordDilaog() async {
    return await dialogService.showDialog(
        title: FlutterI18n.translate(context, "enterPassword"),
        description:
            FlutterI18n.translate(context, "dialogManagerTypeSamePasswordNote"),
        buttonTitle: FlutterI18n.translate(context, "confirm"));
  }

  Future deleteWallet() async {
    errorMessage = null;
    await shohPasswordDilaog().then((res) async {
      if (res!.confirmed) {
        await coreWalletDatabaseService
            .deleteDb()
            .whenComplete(() => debugPrint('core wallet database deleted!!'))
            .catchError(
                (err) => debugPrint('Catch not able to delete core db'));

        await walletDatabaseService
            .deleteDb()
            .whenComplete(() => debugPrint('wallet database deleted!!'))
            .catchError(
                (err) => debugPrint('Catch not able to delete wallet db'));

        await transactionHistoryDatabaseService
            .deleteDb()
            .whenComplete(
                () => debugPrint('trnasaction history database deleted!!'))
            .catchError((err) =>
                debugPrint('Catch not able to delete transaction history db'));

        await vaultService
            .deleteEncryptedData()
            .whenComplete(() => debugPrint('encrypted data deleted!!'))
            .catchError(
                (err) => debugPrint('Catch not able to delete vault db'));

        await tokenListDatabaseService
            .deleteDb()
            .whenComplete(() => debugPrint('Token list database deleted!!'))
            .catchError(
                (err) => debugPrint('Catch not able to delete token db'));

        await userSettingsDatabaseService
            .deleteDb()
            .whenComplete(() => debugPrint('User settings database deleted!!'))
            .catchError(
                (err) => debugPrint('Catch not able to delete user db'));

        storageService.walletBalancesBody = '';
        storageService.isShowCaseView = true;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();

        storageService.clearStorage();
        storageService.showPaycoolClub = false;
        storageService.showPaycool = true;
        try {
          await _deleteCacheDir();
          await _deleteAppDir();
        } catch (err) {
          debugPrint('delete cache dir err $err');
        }

        Navigator.pushNamed(context, '/');
      } else if (res.returnedText == 'Closed' && !res.confirmed) {
        setState(() {
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage =
              FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword");
        });
      }
    }).catchError((error) {
      setState(() {
        errorMessage = error.toString();
      });
    });
  }

  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  Future displayMnemonic() async {
    errorMessage = null;

    await shohPasswordDilaog().then((res) async {
      if (res!.confirmed) {
        showMnemonicDialog(res.returnedText);
      } else if (res.returnedText == 'Closed') {
        setState(() {
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage =
              FlutterI18n.translate(context, "pleaseProvideTheCorrectPassword");
        });
      }
    }).catchError((error) {
      setState(() {
        errorMessage = error.toString();
      });
    });
  }

  showMnemonicDialog(String? mnemonic) {
    List<String> resultList = mnemonic!.split(' ');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Size size = MediaQuery.of(context).size;
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            insetPadding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: size.height * 0.5,
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FlutterI18n.translate(context, "mnemonic"),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: black),
                  ),
                  UIHelper.verticalSpaceMedium,
                  Expanded(
                    child: GridView.builder(
                        itemCount: resultList.length,
                        itemBuilder: (context, index) {
                          return getContainer(index + 1, resultList[index]);
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 4 / 2)),
                  ),
                  SizedBox(
                    width: size.width,
                    child: Text(
                      "Please ensure that mnemonics are not leaked.",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: black,
                      ),
                    ),
                  ),
                  UIHelper.verticalSpaceMedium,
                  Container(
                      height: 50,
                      width: size.width * 0.4,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: buttonPurple,
                        ),
                        child: Text(
                          FlutterI18n.translate(context, "close"),
                        ),
                      )),
                ],
              ),
            ),
          );
        });
  }

  getContainer(int index, String word) {
    return Container(
      decoration: BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            index.toString(),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          Text(
            word,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          SizedBox()
        ],
      ),
    );
  }
}
