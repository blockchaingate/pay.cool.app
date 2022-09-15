import 'dart:io';

import 'package:exchangily_core/exchangily_core.dart';
import 'package:exchangily_ui/exchangily_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';
import 'package:paycool/constants/paycool_styles.dart';
import 'package:paycool/routes.dart';
import 'package:paycool/service_locator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  final String defaultLocale = Platform.localeName;
  debugPrint("defaultLocale: " + defaultLocale);
  final String shortLocale = defaultLocale.substring(0, 2);
  debugPrint("shortLocale: " + shortLocale);

  //init i18n setting
  FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
        useCountryCode: false,
        fallbackFile: 'en',
        basePath: 'assets/i18n',
        forcedLocale: [
          'en',
          'zh',
        ].contains(defaultLocale)
            ? Locale(shortLocale)
            : const Locale("en")),
  );
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    // statusBarColor: Colors.blue, //or set color with: Color(0xFF0000FF)
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
  ));
  try {
    await serviceLocator();
    await customServiceLocator();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Logger.level = Level.info;

    SystemChannels.textInput
        .invokeMethod('TextInput.hide'); // Hides keyboard initially
    runApp(MyApp(flutterI18nDelegate, packageInfo));
  } catch (err) {
    debugPrint('main.dart (Catch) Locator setup has failed $err');
  }
}

class MyApp extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  final FlutterI18nDelegate flutterI18nDelegate;
  final PackageInfo packageInfo;
  const MyApp(this.flutterI18nDelegate, this.packageInfo);

  @override
  Widget build(BuildContext context) {
    final environmentService = locator<EnvironmentService>();
    environmentService.setAppName(Constants.paycoolAppName);
    return OverlaySupport(
      child: MaterialApp(
        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        navigatorKey: locator<NavigationService>().navigatorKey,
        builder: (context, widget) => Stack(
          children: [
            Navigator(
                key: locator<DialogService>().navigatorKey,
                onGenerateRoute: (settings) => MaterialPageRoute(
                    builder: (context) => DialogManager(
                          child: MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(textScaleFactor: 1.0),
                              child: widget),
                        ))),
            Positioned(
                bottom: 120,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      // 'v ',
                      'v ${packageInfo.version}.${packageInfo.buildNumber}',
                      style: const TextStyle(
                          fontSize: 10, color: Color(0x44ffffff)),
                    ),
                  ),
                ))
          ],
        ),
        title: 'PayCool',
        localizationsDelegates: [
          // AppLocalizationsDelegate(),
          flutterI18nDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        onGenerateTitle: (BuildContext context) =>
            FlutterI18n.translate(context, "title"),
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: '/',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // added unselectedWidgetColor to update inactive radio button's color
          appBarTheme: const AppBarTheme(
              actionsIconTheme: IconThemeData(color: white),
              iconTheme: IconThemeData(color: white),
              systemOverlayStyle: SystemUiOverlayStyle.light),
          unselectedWidgetColor: white,
          disabledColor: grey.withAlpha(100),
          primaryColor: PaycoolColors.primaryColor,
          secondaryHeaderColor: PaycoolColors.secondaryColor,
          backgroundColor: PaycoolColors.secondaryColor,
          cardColor: PaycoolColors.walletCardColor,
          canvasColor: PaycoolColors.secondaryColor,
          //iconTheme: IconThemeData(color: PaycoolColors.ic),
          //  brightness: Brightness.dark,
          buttonTheme: const ButtonThemeData(
              minWidth: double.infinity,
              buttonColor: PaycoolColors.primaryColor,
              padding: EdgeInsets.all(15),
              shape: StadiumBorder(),
              textTheme: ButtonTextTheme.primary),
          fontFamily: 'WorkSans',
          textTheme: const TextTheme(
              button: TextStyle(fontSize: 14, color: white),
              headline1: TextStyle(
                  fontSize: 22,
                  color: white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.25),
              headline2: TextStyle(
                  fontSize: 18, color: white, fontWeight: FontWeight.w300),
              headline3: TextStyle(fontSize: 16, color: white),
              headline4: TextStyle(
                  fontSize: 15, color: white, fontWeight: FontWeight.w300),
              subtitle1: TextStyle(
                  fontSize: 14, color: white, fontWeight: FontWeight.w300),
              headline5: TextStyle(
                  fontSize: 12.5, color: white, fontWeight: FontWeight.w400),
              subtitle2: TextStyle(
                  fontSize: 10.3, color: grey, fontWeight: FontWeight.w400),
              bodyText1: TextStyle(
                  fontSize: 13, color: white, fontWeight: FontWeight.w400),
              bodyText2: TextStyle(fontSize: 13, color: red),
              headline6: TextStyle(
                  fontSize: 10.5, color: white, fontWeight: FontWeight.w500)),
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: PaycoolColors.secondaryColor),
        ),
      ),
    );
  }
}
