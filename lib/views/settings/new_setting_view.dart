import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:kyc/kyc.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/constants/route_names.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/settings/new_setting_viewmodel.dart';
import 'package:stacked/stacked.dart';

class NewSettingView extends StatelessWidget {
  const NewSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<NewSettingViewModel>.reactive(
      onViewModelReady: (model) async {
        model.context = context;
        await model.init();
      },
      viewModelBuilder: () => NewSettingViewModel(),
      builder: (context, model, _) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: bgGrey,
          resizeToAvoidBottomInset: false,
          appBar: customAppBarWithIcon(
            title: FlutterI18n.translate(context, "settings"),
            leading: IconButton(
                onPressed: () =>
                    model.navigationService.navigateTo(MeViewRoute),
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
                if (model.errorMessage != null)
                  Container(
                    width: size.width,
                    height: 50,
                    color: bgLightRed,
                    child: Center(
                        child: Text(
                      model.errorMessage!,
                      style: TextStyle(
                          color: textRed, fontWeight: FontWeight.w500),
                    )),
                  ),
                UIHelper.verticalSpaceSmall,
                InkWell(
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return ListView.builder(
                          itemCount: model.languages.length,
                          itemBuilder: (context, index) {
                            String languageCode =
                                model.languages.keys.elementAt(index);
                            String languageName =
                                model.languages.values.elementAt(index);

                            return Column(
                              children: [
                                ListTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        KycUtil.generateflag(
                                            isoCode: model.languageWithIsoCode[
                                                    languageCode] ??
                                                ""),
                                        style: const TextStyle(color: black),
                                      ),
                                      UIHelper.horizontalSpaceSmall,
                                      Text(
                                        languageName,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    model.changeWalletLanguage(languageName);
                                  },
                                ),
                                Divider(
                                  color: Colors.grey[100],
                                  thickness: 1,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
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
                          FlutterI18n.translate(
                              context, "Language"), // TODO : Translate
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: black),
                        ),
                        Expanded(child: SizedBox()),
                        Text(
                          model.selectedLanguage!,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: black),
                        ),
                        UIHelper.horizontalSpaceSmall,
                        Icon(Icons.arrow_forward_ios, color: black, size: 14)
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey[100],
                  thickness: 1,
                ),
                Container(
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
                      SizedBox(
                        width: size.width * 0.6,
                        child: Text(
                          FlutterI18n.translate(
                              context, "autoStartPaycoolScan"),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              color: black),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      CupertinoSwitch(
                        value: model.isAutoStartPaycoolScan,
                        onChanged: (bool value) {
                          model.setAutoScanPaycool(value);
                        },
                        activeColor: buttonPurple,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey[100],
                  thickness: 1,
                ),
                Container(
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
                      SizedBox(
                        width: size.width * 0.6,
                        child: Text(
                          FlutterI18n.translate(
                              context, "biometricAuthForPayment"),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              color: black),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      CupertinoSwitch(
                        value: model.storageService.enableBiometricPayment,
                        onChanged: (bool value) {
                          model.toggleBiometricPayment();
                        },
                        activeColor: buttonPurple,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey[100],
                  thickness: 1,
                ),
                Container(
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
                        FlutterI18n.translate(context, "useAsiaNode"),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: black),
                      ),
                      Expanded(child: SizedBox()),
                      CupertinoSwitch(
                        value: model.storageService.isHKServer,
                        onChanged: (bool value) {
                          model.changeBaseAppUrl();
                        },
                        activeColor: buttonPurple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
