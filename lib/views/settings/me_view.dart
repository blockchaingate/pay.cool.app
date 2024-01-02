import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:paycool/widgets/shared/will_pop_scope.dart';
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

  Map<String, String>? versionInfo;
  String? versionName;
  String? buildNumber;

  @override
  void initState() {
    getAppVersion();
    super.initState();
  }

  getAppVersion() async {
    versionInfo = await sharedService.getLocalAppVersion();

    setState(() {
      versionName = versionInfo!['name'].toString();
      buildNumber = versionInfo!['buildNumber'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        return WillPopScopeWidget().onWillPop(context);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/new-design/me_bg.png"),
                  fit: BoxFit.cover),
            ),
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UIHelper.verticalSpaceLarge,
                UIHelper.verticalSpaceMedium,
                Text(
                  FlutterI18n.translate(context, "me"),
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: black),
                ),
                UIHelper.verticalSpaceLarge,
                InkWell(
                  onTap: () {
                    navigationService.navigateTo(clubDashboardViewRoute);
                  },
                  child: Container(
                    width: size.width,
                    height: 80,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/new-design/club_icon.png",
                          scale: 3,
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              FlutterI18n.translate(context, "inviteOnce"),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black38),
                            ),
                            Text(
                              "${FlutterI18n.translate(context, "invitation")} 100  ${FlutterI18n.translate(context, "bonus")} \$100,00",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: black),
                            ),
                          ],
                        ),
                        Expanded(child: SizedBox()),
                        Icon(Icons.arrow_forward_ios, color: black, size: 14)
                      ],
                    ),
                  ),
                ),
                UIHelper.verticalSpaceMedium,
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        navigationService.navigateTo(WalletManagementViewRoute);
                      },
                      child: Container(
                        width: size.width,
                        height: 60,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
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
                              FlutterI18n.translate(
                                  context, "walletManagement"),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: black),
                            ),
                            Expanded(child: SizedBox()),
                            Icon(Icons.arrow_forward_ios,
                                color: black, size: 14)
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 0.1,
                      endIndent: 20,
                      indent: 20,
                      color: Colors.grey,
                    ),
                    InkWell(
                      onTap: () async {
                        // when i use sharedService.navigateWithAnimation it gives me error (FlutterError (Looking up a deactivated widget's ancestor is unsafe)

                        kycService.setPrimaryColor(primaryColor);

                        if (storageService.bondToken.isEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KycLogin(
                                onFormSubmit: onLoginFormSubmit,
                              ),
                            ),
                          );
                        } else {
                          kycService.xAccessToken.value =
                              storageService.bondToken;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const KycStatus(),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: size.width,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10),
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
                              "KYC",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: black),
                            ),
                            Expanded(child: SizedBox()),
                            Icon(Icons.arrow_forward_ios,
                                color: black, size: 14)
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 0.1,
                      endIndent: 20,
                      indent: 20,
                      color: Colors.grey,
                    ),
                    InkWell(
                      onTap: () {
                        navigationService.navigateTo(SettingViewRoute);
                      },
                      child: Container(
                        width: size.width,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10),
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
                            Icon(Icons.arrow_forward_ios,
                                color: black, size: 14)
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 0.1,
                      endIndent: 20,
                      indent: 20,
                      color: Colors.grey,
                    ),
                    InkWell(
                      onTap: () {
                        navigationService.navigateTo(AboutViewRoute);
                      },
                      child: Container(
                        width: size.width,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(10),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10),
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
                            Icon(Icons.arrow_forward_ios,
                                color: black, size: 14)
                          ],
                        ),
                      ),
                    ),
                    UIHelper.verticalSpaceLarge,
                    // Version Code
                    SizedBox(
                      height: 40,
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'v $versionName.$buildNumber',
                            style: headText6.copyWith(color: black),
                          ),
                          if (!isProduction)
                            const Text(' Debug', style: TextStyle(color: grey))
                        ],
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
