import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/shared/ui_helpers.dart';
import 'package:stacked/stacked.dart';

import 'wallet_management_viewmodel.dart';

class WalletManagementView extends StatelessWidget {
  const WalletManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ViewModelBuilder<WalletManagementViewModel>.reactive(
      onViewModelReady: (model) {
        model.context = context;
      },
      viewModelBuilder: () => WalletManagementViewModel(),
      builder: (context, model, _) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: bgGrey,
          appBar: customAppBarWithIcon(
            title: FlutterI18n.translate(context, "walletManagement"),
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
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
                    await model.displayMnemonic();
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
                          FlutterI18n.translate(context, "displayMnemonic"),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: black),
                        ),
                        Expanded(child: SizedBox()),
                        model.isMnemonicVisible
                            ? Transform.rotate(
                                angle: 90 * 3.14 / 180,
                                child: Icon(Icons.arrow_forward_ios,
                                    color: black, size: 14),
                              )
                            : Icon(Icons.arrow_forward_ios,
                                color: black, size: 14)
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
                    await model.deleteWallet();
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
                          FlutterI18n.translate(context, "deleteWallet"),
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
        ),
      ),
    );
  }

  getContainer(int index, String word) {
    return Container(
      decoration: BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            index.toString(),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          Text(
            word,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          SizedBox()
        ],
      ),
    );
  }
}
