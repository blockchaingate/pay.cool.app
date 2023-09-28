import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/logger.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/multisig_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/views/multisig/create_multisig_wallet/create_multisig_wallet_view.dart';
import 'package:paycool/views/multisig/dashboard/multisig_dashboard_view.dart';
import 'package:stacked_services/stacked_services.dart';

class WelcomeMultisigView extends StatefulWidget {
  const WelcomeMultisigView({super.key});

  @override
  State<WelcomeMultisigView> createState() => _WelcomeMultisigViewState();
}

class _WelcomeMultisigViewState extends State<WelcomeMultisigView> {
  TextEditingController importWalletController = TextEditingController();
  final navigationService = locator<NavigationService>();
  final sharedService = locator<SharedService>();
  final log = getLogger('WelcomeMultisigView');
  final multiSigService = locator<MultiSigService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UIHelper.verticalSpaceLarge,
            Text(
              'Welcome to MultiSig Wallet',
              style: headText2,
            ),
            Container(
              child: kTextField(
                  controller: importWalletController,
                  contentPadding: 5,
                  labelText: 'Import Wallet',
                  hintText: 'Type or paste wallet address',
                  labelStyle: headText5.copyWith(color: grey),
                  cursorColor: green,
                  cursorHeight: 14,
                  fillColor: Colors.transparent,
                  isDense: true,
                  focusBorderColor: primaryColor,
                  enabledBorderColor: white,
                  leadingWidget: IconButton(
                      onPressed: () async {
                        var data = await sharedService.pasteClipboardData();
                        setState(() {
                          importWalletController.text = data;
                        });
                      },
                      icon: Icon(
                        FontAwesomeIcons.paste,
                        color: black,
                      )),
                  suffixWidget: importWalletController.text.isEmpty
                      ? Container()
                      : IconButton(
                          onPressed: () async {
                            var res =
                                await multiSigService.importMultisigWallet(
                              importWalletController.text,
                            );

                            if (res.txid!.isNotEmpty) {
                              navigationService
                                  .navigateWithTransition(MultisigDashboardView(
                                data: res.address!,
                              ));
                            }
                          },
                          icon: Icon(
                            Icons.check_box,
                            color: green,
                            size: 28,
                          )),
                  onChanged: (value) => debugPrint('Name VALUE $value'),
                  onTap: () => debugPrint('Name VALUE')),
            ),
            UIHelper.verticalSpaceSmall,
            Center(
                child: Text(
              'OR',
              style:
                  headText2.copyWith(color: black, fontWeight: FontWeight.bold),
            )),
            UIHelper.verticalSpaceMedium,
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10)),
                    backgroundColor: MaterialStateProperty.all(primaryColor)),
                onPressed: () => navigationService
                    .navigateWithTransition(CreateMultisigWalletView()),
                child: Text(
                  "Create Wallet",
                  style: headText3.copyWith(color: white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
