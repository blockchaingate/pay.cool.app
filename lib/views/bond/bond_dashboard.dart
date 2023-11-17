import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/models/bond/vm/me_model.dart';
import 'package:paycool/service_locator.dart';
import 'package:paycool/services/api_service.dart';
import 'package:paycool/services/local_storage_service.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:paycool/views/bond/buyBond/bond_symbol_view.dart';
import 'package:paycool/views/bond/login/login_view.dart';
import 'package:paycool/views/bond/personalInfo/personal_view.dart';
import 'package:paycool/views/bond/register/bond_register_view.dart';
import 'package:paycool/views/bond/txHistory/bond_history_view.dart';
import 'package:paycool/views/bond/walletConncet/wallet_connect_view.dart';

class BondDashboard extends StatefulWidget {
  const BondDashboard({super.key});

  @override
  State<BondDashboard> createState() => _BondDashboardState();
}

class _BondDashboardState extends State<BondDashboard> {
  ApiService apiService = locator<ApiService>();
  BondMeModel bondMeVm = BondMeModel();

  @override
  void initState() {
    getUserBondMeData();
    super.initState();
  }

  Future<void> getUserBondMeData() async {
    await apiService.getBondMe().then((value) {
      if (value != null) {
        bondMeVm = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/bgImage.png"),
                fit: BoxFit.cover),
          ),
          child: Column(
            children: [
              bondMeVm.email == null
                  ? SizedBox(
                      height: size.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          UIHelper.verticalSpaceLarge,
                          SizedBox(
                            width: size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: IconButton(
                                    alignment: Alignment.topRight,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const WalletConnectView()));
                                    },
                                    icon: Image.asset(
                                      "assets/images/walletconnect.png",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            "assets/images/salvador.png",
                            height: 200,
                          ),
                          UIHelper.verticalSpaceMedium,
                          Text(
                            FlutterI18n.translate(context, "elSalvadorDigital"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          UIHelper.verticalSpaceLarge,
                          Text(
                            FlutterI18n.translate(context, "youHaveAccount"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w200,
                                color: Colors.white),
                          ),
                          UIHelper.verticalSpaceSmall,
                          Container(
                            width: size.width * 0.9,
                            height: 45,
                            decoration: BoxDecoration(
                              gradient: buttoGradient,
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BondLoginView()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                FlutterI18n.translate(context, "login"),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          UIHelper.verticalSpaceSmall,
                          Text(
                            FlutterI18n.translate(context, "dontHaveAnAccount"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w200,
                                color: Colors.white),
                          ),
                          UIHelper.verticalSpaceSmall,
                          Container(
                            width: size.width * 0.9,
                            height: 45,
                            decoration: BoxDecoration(
                              gradient: buttoGradient,
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BondRegisterView()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                FlutterI18n.translate(context, "register"),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        UIHelper.verticalSpaceLarge,
                        SizedBox(
                          width: size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                alignment: Alignment.topRight,
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          elevation: 10,
                                          titleTextStyle: headText5.copyWith(
                                              fontWeight: FontWeight.bold),
                                          contentTextStyle:
                                              const TextStyle(color: white),
                                          content: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              FlutterI18n.translate(
                                                  context, "doYouLogout"),
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            UIHelper.verticalSpaceSmall,
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: buttoGradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40.0),
                                                  ),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shadowColor:
                                                          Colors.transparent,
                                                    ),
                                                    child: Text(
                                                      FlutterI18n.translate(
                                                          context, "no"),
                                                      style: headText5,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                  ),
                                                ),
                                                UIHelper.horizontalSpaceMedium,
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: buttoGradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40.0),
                                                  ),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shadowColor:
                                                          Colors.transparent,
                                                    ),
                                                    child: Text(
                                                        FlutterI18n.translate(
                                                            context, "yes"),
                                                        style: const TextStyle(
                                                            color: white,
                                                            fontSize: 12)),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      LocalStorageService()
                                                          .clearToken();
                                                      bondMeVm = BondMeModel();
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                                UIHelper.verticalSpaceSmall,
                                              ],
                                            ),
                                          ],
                                        );
                                      });
                                },
                                icon: Icon(Icons.logout),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: IconButton(
                                      alignment: Alignment.topRight,
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const WalletConnectView()));
                                      },
                                      icon: Image.asset(
                                        "assets/images/walletconnect.png",
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: IconButton(
                                      alignment: Alignment.topRight,
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const BondHistoryView()));
                                      },
                                      icon: Icon(Icons.history),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: IconButton(
                                      alignment: Alignment.topRight,
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const PersonalInfoView()));
                                      },
                                      icon: Icon(Icons.person),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        UIHelper.verticalSpaceLarge,
                        Image.asset(
                          "assets/images/salvador.png",
                          height: 200,
                        ),
                        UIHelper.verticalSpaceLarge,
                        Text(
                          "El Salvador",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        UIHelper.verticalSpaceSmall,
                        Text(
                          FlutterI18n.translate(context, "nationalBondSale"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        UIHelper.verticalSpaceLarge,
                        Container(
                          width: size.width * 0.8,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: buttoGradient,
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BondSembolView(bondMeVm)));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: Text(
                              FlutterI18n.translate(context, "buyNow"),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
