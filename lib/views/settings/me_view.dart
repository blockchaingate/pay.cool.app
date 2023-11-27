import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:kyc/kyc.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/environments/environment_type.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/widgets/bottom_nav.dart';
import 'package:stacked_services/stacked_services.dart';

class MeView extends StatefulWidget {
  @override
  State<MeView> createState() => _MeViewState();
}

class _MeViewState extends State<MeView> {
  final navigationService = locator<NavigationService>();
  final kycService = locator<KycBaseService>();
  final storageService = locator<LocalStorageService>();
  final sharedService = locator<SharedService>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: customAppBarWithIcon(
        title: FlutterI18n.translate(context, "Me"),
      ),
      bottomNavigationBar: BottomNavBar(count: 4),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigationService.navigateTo(PayCoolViewRoute);
        },
        elevation: 1,
        backgroundColor: Colors.transparent,
        child: Image.asset(
          "assets/images/new-design/pay_cool_icon.png",
          fit: BoxFit.cover,
        ),
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UIHelper.verticalSpaceMedium,
            InkWell(
              onTap: () {
                navigationService.navigateTo(WalletManagementViewRoute);
              },
              child: Container(
                width: size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/images/new-design/me_wallet_icon.png",
                      width: 24,
                      height: 24,
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Text(
                      FlutterI18n.translate(context, "walletManagement"),
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
                kycService.setPrimaryColor(primaryColor);
                if (storageService.bondToken.isEmpty) {
                  await sharedService.navigateWithAnimation(
                      KycLogin(onFormSubmit: onLoginFormSubmit));
                  return;
                } else {
                  kycService.xAccessToken.value = storageService.bondToken;

                  navigationService.navigateToView(const KycStatus());
                }
              },
              child: Container(
                width: size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/images/new-design/me_kyc_icon.png",
                      width: 24,
                      height: 24,
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Text(
                      FlutterI18n.translate(context, "kyc"),
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
              onTap: () {
                navigationService.navigateTo(NewSettingViewRoute);
              },
              child: Container(
                width: size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/images/new-design/me_setting_icon.png",
                      width: 24,
                      height: 24,
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Text(
                      FlutterI18n.translate(context, "settings"),
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
              onTap: () {
                navigationService.navigateTo(AboutViewRoute);
              },
              child: Container(
                width: size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/images/new-design/me_about_icon.png",
                      width: 24,
                      height: 24,
                    ),
                    UIHelper.horizontalSpaceSmall,
                    Text(
                      FlutterI18n.translate(context, "aboutPayCool"),
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

  onLoginFormSubmit(UserLoginModel user) async {
    try {
      final kycService = locator<KycBaseService>();

      String url =
          isProduction ? KycConstants.prodBaseUrl : KycConstants.testBaseUrl;
      final Map<String, dynamic> res;

      if (user.email!.isNotEmpty && user.password!.isNotEmpty) {
        res = await kycService.login(url, user);
        if (res['success']) {
          storageService.bondToken = res['data']['token'];
        }
      } else {
        res = {
          'success': false,
          'error': FlutterI18n.translate(
              context, 'pleaseFillAllTheTextFieldsCorrectly')
        };
      }
      return res;
    } catch (e) {
      debugPrint('CATCH error $e');
    }
  }
}
