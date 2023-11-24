import 'package:exchangily_ui/exchangily_ui.dart' show kTextField;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/multisig/create_multisig_wallet/create_multisig_wallet_view.dart';
import 'package:paycool/views/multisig/dashboard/multisig_dashboard_view.dart';
import 'package:paycool/views/multisig/import_multisig_wallet/import_multisig_viewmodel.dart';
import 'package:paycool/views/multisig/multisig_util.dart';
import 'package:paycool/views/settings/settings_view.dart';
import 'package:stacked/stacked.dart';

class ImportMultisigView extends StatelessWidget {
  const ImportMultisigView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ImportMultisigViewmodel>.reactive(
        disposeViewModel: true,
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
                            FlutterI18n.translate(
                                context, "welcomeToMultisigWallet"),
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
                                  '${model.multisigWallets.length} ${FlutterI18n.translate(context, "existingWallets")}',
                                  textAlign: TextAlign.center,
                                  style: headText4.copyWith(color: grey),
                                ),
                              ),
                        UIHelper.verticalSpaceSmall,
                        model.multisigWallets.isEmpty
                            ? Container()
                            : !model.dataReady || model.isBusy
                                ? model.sharedService.loadingIndicator()
                                : SizedBox(
                                    height: model.multisigWallets.length == 1
                                        ? 150
                                        : model.multisigWallets.length == 2
                                            ? 270
                                            : 350,
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
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(model
                                                        .multisigWallets[index]
                                                        .name
                                                        .toString()),
                                                    Text(' - '),
                                                    Text(
                                                      model
                                                          .multisigWallets[
                                                              index]
                                                          .chain
                                                          .toString(),
                                                      style: headText6.copyWith(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: black
                                                              .withAlpha(100)),
                                                    ),
                                                  ],
                                                ),
                                                subtitle: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      model
                                                              .multisigWallets[
                                                                  index]
                                                              .isAddressEmpty()
                                                          ? StringUtils.showPartialData(
                                                              data: model
                                                                  .multisigWallets[
                                                                      index]
                                                                  .txid
                                                                  .toString())
                                                          : StringUtils.showPartialData(
                                                              data: MultisigUtil.displayWalletAddress(
                                                                  model
                                                                      .multisigWallets[
                                                                          index]
                                                                      .address!,
                                                                  model
                                                                      .multisigWallets[
                                                                          index]
                                                                      .chain!)),
                                                      style: headText6.copyWith(
                                                          color: white),
                                                    ),
                                                    model.copyData(
                                                        model
                                                            .multisigWallets[
                                                                index]
                                                            .txid!,
                                                        context,
                                                        isTxid: model
                                                            .multisigWallets[
                                                                index]
                                                            .isAddressEmpty())
                                                  ],
                                                ),
                                                trailing: TextButton(
                                                  child: Text(model
                                                          .multisigWallets[
                                                              index]
                                                          .isAddressEmpty()
                                                      ? FlutterI18n.translate(
                                                          context, "pending")
                                                      : FlutterI18n.translate(
                                                          context, "select")),
                                                  onPressed: () => model
                                                                  .multisigWallets[
                                                                      index]
                                                                  .address ==
                                                              null ||
                                                          model
                                                              .multisigWallets[
                                                                  index]
                                                              .address!
                                                              .isEmpty
                                                      ? {}
                                                      : model.navigationService
                                                          .navigateWithTransition(
                                                              MultisigDashboardView(
                                                                  data: model
                                                                      .multisigWallets[
                                                                          index]
                                                                      .address!),
                                                              opaque: true,
                                                              popGesture: true),
                                                ),
                                              ))),
                                    ),
                                  ),
                        UIHelper.verticalSpaceMedium,
                        Center(
                          child: Text(
                            '',
                            textAlign: TextAlign.center,
                            style: headText5.copyWith(color: black),
                          ),
                        ),
                        UIHelper.verticalSpaceSmall,
                        Container(
                          child: kTextField(
                              controller: model.importWalletController,
                              contentPadding: 5,
                              labelText: FlutterI18n.translate(
                                  context, "importWallet"),
                              hintText: FlutterI18n.translate(
                                  context, "typeOrPasteMultisigAddress"),
                              labelStyle: headText5.copyWith(color: grey),
                              cursorColor: green,
                              cursorHeight: 14,
                              fillColor: Colors.transparent,
                              isDense: true,
                              focusBorderColor: primaryColor,
                              enabledBorderColor: white,
                              leadingWidget: SizedBox(
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
                                FlutterI18n.translate(context, "import"),
                                style: headText4.copyWith(color: black),
                              ),
                            )),
                        UIHelper.verticalSpaceMedium,
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
                                  FlutterI18n.translate(
                                      context, "createMultsigWallet"),
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
                                    FlutterI18n.translate(context, "create"),
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
