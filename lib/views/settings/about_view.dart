import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/api_routes.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/services/shared_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  final sharedService = locator<SharedService>();
  final storageService = locator<LocalStorageService>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: white,
      resizeToAvoidBottomInset: false,
      appBar: customAppBarWithIcon(
        title: FlutterI18n.translate(context, "about"),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset(
                "assets/images/new-design/darkLogo.png",
                scale: 5,
              ),
              UIHelper.verticalSpaceMedium,
              Container(
                width: size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: bgGrey,
                ),
                padding: EdgeInsets.all(20),
                child: Text(
                  "Pay.cool is a decentralized cryptocurrency payment network built on Fast Access Blockchain (FAB). This application coincides with a revolutionary business model, which enables Pay.cool to be classified as a merchant-to-customer, with a reputation for turning consumption into investment. Fast Access Blockchain (FAB) is cutting-edge technology on a scalable solution for a public blockchain. Pay.cool enables consumers to earn money while simultaneously using the application to make payments. Pay.cool relies on a rebate-rewards model, which is represented through all tiers including consumers, merchants, merchant's referral and consumer's multi-level referral system. Our platform Pay.cool is operated by eXchangily LLC., which is a decentralized cryptocurrency exchange which is registered within the United States. Decentralized cryptocurrency exchanges are a new generation of peer-to-peer (P2P) platforms that will be more transparent in operations and fees than the centralized exchange model.",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              ),
              UIHelper.verticalSpaceSmall,
              InkWell(
                onTap: () {
                  sharedService.launchInBrowser(Uri.parse(
                      '$paycoolWebsiteUrl${storageService.langCodeSC}/privacy'));
                },
                child: Container(
                  width: size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bgGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        FlutterI18n.translate(context, "privacyPolicy"),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: black),
                      ),
                      Expanded(child: SizedBox()),
                      Icon(Icons.arrow_forward_ios, color: black, size: 14)
                    ],
                  ),
                ),
              ),
              UIHelper.verticalSpaceSmall,
              InkWell(
                onTap: () {
                  sharedService.launchInBrowser(Uri.parse(
                      '$paycoolWebsiteUrl${storageService.langCodeSC}'));
                },
                child: Container(
                  width: size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bgGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/new-design/web_icon.png",
                        width: 24,
                        height: 24,
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Text(
                        FlutterI18n.translate(context, "website"),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: black),
                      ),
                      Expanded(child: SizedBox()),
                      Text(
                        "https://pay.cool",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: black),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 3,
              ),
              InkWell(
                onTap: () async {
                  Uri email = Uri(
                    scheme: 'mailto',
                    path: "marketing@pay.cool",
                    queryParameters: {'subject': "Pay.cool Email"},
                  );
                  await launchUrl(email);
                },
                child: Container(
                  width: size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bgGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/new-design/email_icon.png",
                        width: 24,
                        height: 24,
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Text(
                        FlutterI18n.translate(context, "email"),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: black),
                      ),
                      Expanded(child: SizedBox()),
                      Text(
                        "marketing@pay.cool",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
