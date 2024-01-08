import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/string_util.dart';
import 'package:paycool/views/multisig/multisig_util.dart';
import 'package:paycool/views/multisig/transactions/history_queue_view.dart';
import 'package:paycool/views/settings/setting_view.dart';
import 'package:paycool/widgets/shimmer_layouts/shimmer_layout.dart';
import 'package:paycool/widgets/wallet/add_wallet_token/add_wallet_token_widget.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'multisig_dashboard_viewmodel.dart';

class MultisigDashboardView extends StatelessWidget {
  final String data;
  const MultisigDashboardView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MultisigDashboardViewModel>.reactive(
      viewModelBuilder: () =>
          MultisigDashboardViewModel(context: context, data: data),
      onViewModelReady: (model) => model.init(),
      builder: (
        BuildContext context,
        MultisigDashboardViewModel model,
        Widget? child,
      ) {
        return Scaffold(
            backgroundColor: white,
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    UIHelper.verticalSpaceMedium,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: AlignmentDirectional.center,
                          child: Stack(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.settings,
                                  color: primaryColor,
                                ),
                                onPressed: () {
                                  model.navigationService
                                      .navigateWithTransition(SettingsView());
                                },
                              ),
                              Positioned(
                                top: 5,
                                left: 12,
                                child: Text(
                                  FlutterI18n.translate(context, 'settings'),
                                  style: headText6.copyWith(fontSize: 6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.logout,
                              color: red,
                              size: 22,
                            ),
                            onPressed: () {
                              model.logout();
                            },
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpaceMedium,

                    // wallet name and switch wallet arrow
                    DropdownButton(
                        underline: const SizedBox.shrink(),
                        elevation: 15,
                        isExpanded: false,
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: black,
                          ),
                        ),
                        iconEnabledColor: primaryColor,
                        iconDisabledColor: model.multisigWallets.isEmpty
                            ? secondaryColor
                            : grey,
                        iconSize: 30,
                        value: model.multisigWallet.address,
                        onChanged: (newValue) async {
                          await model.importWallet(
                            data: newValue.toString(),
                          );
                          await model.getBalance();
                        },
                        items: model.multisigWallets.map(
                          (wallet) {
                            return DropdownMenuItem(
                              value: wallet.address,
                              child: Container(
                                color: secondaryColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    customText(
                                        text: wallet.name.toString(),
                                        textAlign: TextAlign.center,
                                        letterSpace: 1.2,
                                        style: headText4.copyWith(
                                            fontWeight: FontWeight.bold)),
                                    customText(
                                        text: '(${wallet.chain.toString()})',
                                        textAlign: TextAlign.center,
                                        style: headText6.copyWith(
                                          fontSize: 8,
                                        )),
                                    Container(
                                      width: 5,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ).toList()),
                    // chain name
                    UIHelper.verticalSpaceMedium,
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: roundedBoxDecoration(
                          color: Colors.grey[200]!, radius: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.multisigWallet.chain.toString(),
                            style:
                                headText5.copyWith(fontWeight: FontWeight.bold),
                          ),
                          UIHelper.verticalSpaceSmall,
                          // wallet address and copy button,qr code and exchangily tx on blockchain button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              model.busy(model.multisigWallet) || model.isBusy
                                  ? Text(
                                      FlutterI18n.translate(context, 'address'),
                                      style: headText5,
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          StringUtils.showPartialData(
                                              data: model.displayWalletAddress),
                                          style: headText5.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        UIHelper.horizontalSpaceSmall,
                                        InkWell(
                                          onTap: () => model.sharedService
                                              .copyAddress(context,
                                                  model.displayWalletAddress),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: const Icon(
                                              Icons.copy,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            model.generateQrCode(context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: const Icon(
                                              Icons.qr_code,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              InkWell(
                                onTap: () {
                                  model.openLinkInBrowser();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Icon(
                                    Icons.open_in_browser_outlined,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // transaction history and transaction queue button
                    UIHelper.verticalSpaceSmall,
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        gradient: LinearGradient(
                          colors: const [Colors.blue, Colors.green],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        textColor: black,
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.history,
                              color: white,
                            ),
                          ],
                        ),
                        title: Text(
                            FlutterI18n.translate(context, 'transactions')),
                        titleTextStyle:
                            headText4.copyWith(fontWeight: FontWeight.bold),
                        subtitle: Text(
                            FlutterI18n.translate(context, 'historyQueue')),
                        subtitleTextStyle: headText5,
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: white,
                        ),
                        onTap: () => model.navigationService
                            .navigateWithTransition(
                                MultisigHistoryQueueView(
                                    address: model.multisigWallet.address
                                        .toString()),
                                transitionStyle: Transition.downToUp),
                      ),
                    ),

                    Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            customText(
                                text: FlutterI18n.translate(context, 'assets')),
                            model.multisigService.hasUpdatedTokenList
                                ? model.refreshBalanceWidget()
                                : model.refreshBalanceWidget()
                          ],
                        )),

                    // asset balance and asset name

                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: roundedBoxDecoration(
                          color: Colors.grey[100]!, radius: 10),
                      child: Column(children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 2,
                              child: customText(
                                  text: FlutterI18n.translate(context, 'name'),
                                  style: headText5.copyWith(
                                      fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              flex: 2,
                              child: customText(
                                  text:
                                      FlutterI18n.translate(context, 'balance'),
                                  style: headText5.copyWith(
                                      fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(),
                            )
                          ],
                        )
                      ]),
                    ),

                    Container(
                      child: model.busy(model.multisigBalance) || model.isBusy
                          ? SizedBox(
                              height: 400,
                              child: const ShimmerLayout(
                                layoutType: 'walletDashboard',
                                count: 5,
                              ),
                            )
                          : Column(
                              children: [
                                UIHelper.verticalSpaceMedium,
                                InkWell(
                                  onTap: () => model.canTransferAssets
                                      ? model.navigateToTransferView(-1)
                                      : debugPrint('Incorrect Owner'),
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(bottom: 5),
                                    decoration: roundedBoxDecoration(
                                        color: Colors.grey[200]!, radius: 10),
                                    padding: const EdgeInsets.only(
                                        left: 10, bottom: 20.0, top: 20),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          width: 30,
                                          height: 30,
                                          child: CachedNetworkImage(
                                            imageUrl: MultisigUtil
                                                    .isChainKanban(model
                                                        .multisigWallet.chain!)
                                                ? '${WalletCoinsLogoUrl}fab.png'
                                                : '${WalletCoinsLogoUrl}eth.png',
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            fit: BoxFit.cover,
                                            fadeInDuration: const Duration(
                                                milliseconds: 500),
                                            fadeOutDuration: const Duration(
                                                milliseconds: 500),
                                            fadeOutCurve: Curves.easeOut,
                                            fadeInCurve: Curves.easeIn,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    FadeInImage(
                                              placeholder: const AssetImage(
                                                  'assets/images/launcher/paycool-logo.png'),
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                model.multisigWallet.chain!,
                                                style: headText5.copyWith())),
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                model.multisigBalance.native
                                                    .toString(),
                                                style: headText5.copyWith())),
                                        Expanded(
                                            flex: 1,
                                            child: model.canTransferAssets
                                                ? TextButton(
                                                    onPressed: () => model
                                                            .canTransferAssets
                                                        ? model
                                                            .navigateToTransferView(
                                                                -1)
                                                        : debugPrint(
                                                            'Incorrect Owner'),
                                                    child: Text(
                                                      FlutterI18n.translate(
                                                          context, 'send'),
                                                      style: headText5.copyWith(
                                                          color: primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ))
                                                : Container())
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 300,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount:
                                        model.multisigBalance.tokens == null
                                            ? 0
                                            : model.multisigBalance.tokens!.ids!
                                                .length,
                                    shrinkWrap: true,
                                    itemBuilder: ((context, index) {
                                      return InkWell(
                                        onTap: () => model.canTransferAssets
                                            ? model
                                                .navigateToTransferView(index)
                                            : debugPrint('Incorrect Owner'),
                                        child: Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(bottom: 5),
                                          decoration: roundedBoxDecoration(
                                              color: Colors.grey[200]!,
                                              radius: 10),
                                          padding: const EdgeInsets.only(
                                              left: 10, bottom: 20.0, top: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                //asset('assets/images/wallet-page/$tickerName.png'),
                                                width: 30,
                                                height: 30,
                                                // decoration: BoxDecoration(
                                                //     color: walletCardColor,
                                                //     borderRadius: BorderRadius.circular(50),
                                                //     boxShadow: const [
                                                //       BoxShadow(
                                                //           color: fabLogoColor,
                                                //           offset: Offset(1.0, 5.0),
                                                //           blurRadius: 10.0,
                                                //           spreadRadius: 1.0),
                                                //     ]),

                                                // Todo Error handling when image not found or url not found
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      '$WalletCoinsLogoUrl${model.multisigBalance.tokens!.tickers![index].toLowerCase()}.png',
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                  fit: BoxFit.cover,
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 500),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 500),
                                                  fadeOutCurve: Curves.easeOut,
                                                  fadeInCurve: Curves.easeIn,
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      FadeInImage(
                                                    placeholder: const AssetImage(
                                                        'assets/images/launcher/paycool-logo.png'),
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                      model
                                                          .multisigBalance
                                                          .tokens!
                                                          .tickers![index],
                                                      style: headText5.copyWith(
                                                          color: black))),
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                      model
                                                          .multisigBalance
                                                          .tokens!
                                                          .balances![index]
                                                          .toString(),
                                                      style: headText5
                                                          .copyWith())),
                                              Expanded(
                                                  flex: 1,
                                                  child: model.canTransferAssets
                                                      ? TextButton(
                                                          onPressed: () => model
                                                                  .canTransferAssets
                                                              ? model
                                                                  .navigateToTransferView(
                                                                      index)
                                                              : debugPrint(
                                                                  'Incorrect Owner'),
                                                          child: Text(
                                                            FlutterI18n
                                                                .translate(
                                                                    context,
                                                                    'send'),
                                                            style: headText5.copyWith(
                                                                color:
                                                                    primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ))
                                                      : Container())
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                UIHelper.verticalSpaceMedium,
                              ],
                            ),
                    ),
                    UIHelper.verticalSpaceMedium,
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: MultisigUtil.isChainKanban(
                        model.multisigWallet.chain!) ||
                    model.isBusy
                ? Container()
                : AddWalletTokenWidget(chainName: model.multisigWallet.chain!));
      },
    );
  }
}
