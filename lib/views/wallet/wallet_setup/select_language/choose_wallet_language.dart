/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:paycool/constants/colors.dart';
import 'package:paycool/constants/custom_styles.dart';
import 'package:paycool/views/wallet/wallet_setup/select_language/choose_wallet_language_viewmodel.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

class ChooseWalletLanguageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return ViewModelBuilder<ChooseWalletLanguageViewModel>.reactive(
      viewModelBuilder: () => ChooseWalletLanguageViewModel(),
      onViewModelReady: (model) async {
        model.context = context;
        await model.walletService.checkLanguage(context);
        //  await model.checkLanguage();
      },
      builder: (context, model, child) => Container(
        padding: orientation == Orientation.portrait
            ? const EdgeInsets.all(40)
            : const EdgeInsets.all(80),
        color: walletCardColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Logo Container
            Container(
              height: orientation == Orientation.portrait ? 50 : 20,
              margin: const EdgeInsets.only(bottom: 10),
              child: Image.asset('assets/images/start-page/logo.png'),
            ),
            // Middle Graphics Container
            Container(
              width: orientation == Orientation.portrait ? 300 : 300,
              padding: const EdgeInsets.all(20),
              child: Image.asset('assets/images/start-page/middle-design.png'),
            ),
            // Language Text and Icon Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.language,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                        FlutterI18n.translate(
                            context, "pleaseChooseTheLanguage"),
                        textAlign: TextAlign.start,
                        style: headText5),
                  )
                ],
              ),
            ),
            // Button Container
            model.isBusy
                ? Shimmer.fromColors(
                    baseColor: primaryColor,
                    highlightColor: white,
                    child: Center(
                      child: Text(
                        '${FlutterI18n.translate(context, "loading")}...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                : SizedBox(
                    // width: 225,
                    height: 120,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          // English Lang Button
                          ElevatedButton(
                            child: Text(
                              'English',
                              style: headText4,
                            ),
                            onPressed: () async {
                              model.setLangauge('en');
                              // AppLocalizations.load(Locale('en', 'US'));
                              await FlutterI18n.refresh(
                                  context, const Locale('en', 'US'));
                              (context as Element).markNeedsBuild();
                              Navigator.of(context).pushNamed('/walletSetup');
                            },
                          ),
                          // Chinese Lang Button
                          ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  const StadiumBorder(
                                      side: BorderSide(
                                          color: primaryColor, width: 2))),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  secondaryColor),
                            ),
                            child: Text('中文', style: headText4),
                            onPressed: () async {
                              model.setLangauge('zh');
                              // AppLocalizations.load(Locale('zh', 'ZH'));
                              await FlutterI18n.refresh(
                                  context, const Locale('zh', 'ZH'));
                              (context as Element).markNeedsBuild();
                              Navigator.of(context).pushNamed('/walletSetup');
                            },
                          )
                        ]),
                  )
          ],
        ),
      ),
    );
  }
}
