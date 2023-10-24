import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/utils/number_util.dart';
import 'package:paycool/views/paycool_club/checkout/club_package_checkout_viewmodel.dart';
import 'package:paycool/views/paycool_club/club_projects/models/club_project_model.dart';
import 'package:stacked/stacked.dart';

class ClubPackageCheckoutView extends StatelessWidget {
  final Map<String, dynamic>? packageWithPaymentCoin;
  const ClubPackageCheckoutView({Key? key, this.packageWithPaymentCoin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ClubPackageCheckoutViewModel>.reactive(
      onViewModelReady: (model) {
        model.context = context;
        model.clubProject = packageWithPaymentCoin!['package'];
        //model.init();
      },
      viewModelBuilder: () => ClubPackageCheckoutViewModel(
          packageWithPaymentCoin!['package'].projectId,
          packageWithPaymentCoin!['paymentCoin']),
      builder: (
        BuildContext context,
        ClubPackageCheckoutViewModel model,
        Widget? child,
      ) {
        ClubProject package = packageWithPaymentCoin!['package'];
        return Scaffold(
          body: Stack(
            children: [
              !model.dataReady || model.isBusy
                  ? Positioned(
                      top: 100,
                      bottom: 100,
                      left: 25,
                      right: 25,
                      child: Container(
                          decoration: roundedBoxDecoration(
                              color: primaryColor.withAlpha(155)),
                          height: MediaQuery.of(context).size.height - 100,
                          width: MediaQuery.of(context).size.width - 100,
                          child: model.sharedService.loadingIndicator(
                              isCustomWidthHeight: true,
                              height: 40,
                              width: 40)))
                  : Container(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    FlutterI18n.translate(context, "checkout"),
                    style: headText1.copyWith(color: primaryColor),
                  ),
                  UIHelper.verticalSpaceLarge,
                  model.dataReady &&
                          (model.clubPackageCheckout.clubParams == null ||
                              model.clubPackageCheckout.clubParams!.isEmpty)
                      ? Center(
                          child: Column(
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                FlutterI18n.translate(
                                    context, "checkoutPackageError"),
                              ),
                            ),
                            UIHelper.verticalSpaceMedium,
                            SizedBox(
                              height: 45,
                              width: 200,
                              child: OutlinedButton(
                                  style: outlinedButtonStyles2,
                                  onPressed: () => !model.isBusy
                                      ? model.navigationService.back()
                                      : model.log.e('model busy'),
                                  child: Text(
                                    FlutterI18n.translate(context, "cancel"),
                                  )),
                            ),
                          ],
                        ))
                      : Center(
                          child: Container(
                            // height: 300,
                            width: 350,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            // decoration: roundedBoxDecoration(color: primaryColor),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                checkoutFields(
                                    FlutterI18n.translate(
                                        context, "exchangeBalance"),
                                    model.exchangeBalance.toString(),
                                    context),
                                UIHelper.verticalSpaceSmall,
                                checkoutFields(
                                    '${FlutterI18n.translate(context, "gas")} ${FlutterI18n.translate(context, "balance")}',
                                    NumberUtil.decimalLimiter(model.gasBalance,
                                            decimalPlaces: 12)
                                        .toString(),
                                    context),
                                UIHelper.verticalSpaceSmall,
                                UIHelper.verticalSpaceSmall,
                                UIHelper.divider,
                                UIHelper.verticalSpaceSmall,
                                checkoutFields(
                                    FlutterI18n.translate(context, "name"),
                                    model.title,
                                    context),

                                // checkoutFields(
                                //     FlutterI18n.translate(context, "description"),
                                //     model.desc.toString(),
                                //     context),
                                UIHelper.verticalSpaceSmall,
                                checkoutFields(
                                    FlutterI18n.translate(
                                        context, "packageValue"),
                                    '${package.joiningFee} ' +
                                        packageWithPaymentCoin!['paymentCoin'],
                                    context),
                                UIHelper.verticalSpaceLarge,
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 45,
                                      width: 200,
                                      child: ElevatedButton(
                                          style: generalButtonStyle1.copyWith(),
                                          onPressed: () => !model.isBusy
                                              ? model.buyPackage()
                                              : model.log.e('model busy'),
                                          child: Text(
                                            FlutterI18n.translate(
                                                context, "stakeToEarn"),
                                          )),
                                    ),
                                    UIHelper.verticalSpaceSmall,
                                    SizedBox(
                                      height: 45,
                                      width: 200,
                                      child: OutlinedButton(
                                          style: outlinedButtonStyles2,
                                          onPressed: () => !model.isBusy
                                              ? model.navigationService.back()
                                              : model.log.e('model busy'),
                                          child: Text(
                                            FlutterI18n.translate(
                                                context, "cancel"),
                                          )),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Row checkoutFields(String title, String value, BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            textAlign: TextAlign.left,
            style: headText5.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: headText5.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
