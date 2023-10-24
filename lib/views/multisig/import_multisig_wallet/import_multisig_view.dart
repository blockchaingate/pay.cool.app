import 'package:exchangily_ui/exchangily_ui.dart' show kTextField;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/multisig/create_multisig_wallet/create_multisig_wallet_view.dart';
import 'package:paycool/views/multisig/dashboard/multisig_dashboard_view.dart';
import 'package:paycool/views/multisig/import_multisig_wallet/import_multisig_viewmodel.dart';
import 'package:paycool/views/multisig/multisig_util.dart';
import 'package:paycool/views/settings/settings_view.dart';
import 'package:stacked/stacked.dart';

class WelcomeMultisigView extends StatelessWidget {
  const WelcomeMultisigView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ImportMultisigViewmodel>.reactive(
        viewModelBuilder: () => ImportMultisigViewmodel(),
        builder: (
          BuildContext context,
          ImportMultisigViewmodel model,
          Widget? child,
        ) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UIHelper.verticalSpaceLarge,
                        Center(
                          child: Text(
                            'Welcome to MultiSig Wallet',
                            textAlign: TextAlign.center,
                            style: headText2.copyWith(
                                color: black, fontWeight: FontWeight.bold),
                          ),
                        ),
                        UIHelper.verticalSpaceMedium,
                        model.multisigWallets.isEmpty
                            ? Container()
                            : Center(
                                child: Text(
                                  'Select from existing wallets',
                                  textAlign: TextAlign.center,
                                  style: headText4.copyWith(color: grey),
                                ),
                              ),
                        model.multisigWallets.isEmpty
                            ? Container()
                            : !model.dataReady
                                ? model.sharedService.loadingIndicator()
                                : SizedBox(
                                    height: model.multisigWallets.length == 1
                                        ? 150
                                        : 250,
                                    child: ListView.builder(
                                      itemCount: model.multisigWallets.length,
                                      itemBuilder: ((context, index) =>
                                          Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              decoration:
                                                  rectangularGradientBoxDecoration(
                                                      colorOne: primaryColor,
                                                      colorTwo: secondaryColor),
                                              child: ListTile(
                                                title: Text(model
                                                    .multisigWallets[index].name
                                                    .toString()),
                                                subtitle: Text(MultisigUtil
                                                    .exgToBinpdpayAddress(model
                                                        .multisigWallets[index]
                                                        .address
                                                        .toString())),
                                                trailing: TextButton(
                                                  child: Text('Select'),
                                                  onPressed: () => model
                                                      .navigationService
                                                      .navigateWithTransition(
                                                          MultisigDashboardView(
                                                              data: model
                                                                  .multisigWallets[
                                                                      index]
                                                                  .address!)),
                                                ),
                                              ))),
                                    ),
                                  ),
                        UIHelper.verticalSpaceMedium,
                        UIHelper.verticalSpaceLarge,
                        Center(
                          child: Text(
                            'You can import an existing wallet by typing/pasting the address below',
                            textAlign: TextAlign.center,
                            style: headText5.copyWith(color: black),
                          ),
                        ),
                        UIHelper.verticalSpaceSmall,
                        Container(
                          child: kTextField(
                              controller: model.importWalletController,
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
                              leadingWidget: Container(
                                width: 50,
                                child: IconButton(
                                    onPressed: () async {
                                      var data = await model.sharedService
                                          .pasteClipboardData();

                                      model.importWalletController.text = data;
                                      model.rebuildUi();
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.paste,
                                      color: black,
                                    )),
                              ),
                              onTap: () => debugPrint('Name VALUE')),
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: OutlinedButton(
                              style: kOutlinedButtonStyles(
                                  borderColor: black,
                                  hPadding: 30,
                                  vPadding: 10,
                                  radius: 8),
                              onPressed: () async {
                                var res = await model.multiSigService
                                    .importMultisigWallet(
                                  model.importWalletController.text,
                                );

                                if (res.txid!.isNotEmpty) {
                                  model.navigationService
                                      .navigateWithTransition(
                                          MultisigDashboardView(
                                    data: res.address!,
                                  ));
                                }
                              },
                              child: Text(
                                'Import',
                                style: headText4.copyWith(color: black),
                              ),
                            )),
                        UIHelper.verticalSpaceMedium,
                        UIHelper.verticalSpaceLarge,
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: roundedBoxDecoration(
                            color: green.withOpacity(0.2),
                            radius: 10,
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: Text(
                                  'If you don\'t have a wallet or just want to create another one, you can create one by tapping the button below',
                                  textAlign: TextAlign.center,
                                  style: headText5.copyWith(color: black),
                                ),
                              ),
                              UIHelper.verticalSpaceSmall,
                              Container(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 10)),
                                      backgroundColor:
                                          MaterialStateProperty.all(white)),
                                  onPressed: () => model.navigationService
                                      .navigateWithTransition(
                                          CreateMultisigWalletView()),
                                  child: Text(
                                    "Create",
                                    style: headText3.copyWith(color: black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 10,
                    child: IconButton(
                        onPressed: () => model.navigationService
                            .navigateWithTransition(SettingsView()),
                        icon: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: black,
                        )),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
