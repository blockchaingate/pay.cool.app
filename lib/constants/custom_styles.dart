import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

TextStyle largeText1 = const TextStyle(
    fontSize: 26,
    color: black,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5);

TextStyle headText1 = const TextStyle(
    fontSize: 22,
    color: white,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.25);
TextStyle headText2 =
    const TextStyle(fontSize: 18, color: black, fontWeight: FontWeight.w300);
TextStyle headText3 = const TextStyle(fontSize: 16, color: black);
TextStyle headText4 =
    const TextStyle(fontSize: 15, color: black, fontWeight: FontWeight.w300);
TextStyle buttonText =
    const TextStyle(fontSize: 15, color: white, fontWeight: FontWeight.bold);
TextStyle subText1 =
    const TextStyle(fontSize: 14, color: black, fontWeight: FontWeight.w300);
TextStyle subText2 =
    const TextStyle(fontSize: 10.3, color: grey, fontWeight: FontWeight.w400);
TextStyle headText5 =
    const TextStyle(fontSize: 13, color: black, fontWeight: FontWeight.w400);
const TextStyle bodyText1 =
    TextStyle(fontSize: 13, color: black, fontWeight: FontWeight.w400);
TextStyle bodyText2 = const TextStyle(fontSize: 13, color: red);
TextStyle headText6 =
    const TextStyle(fontSize: 11.5, color: black, fontWeight: FontWeight.w500);

TextStyle bondText1 = TextStyle(color: Colors.white);

// appbar
AppBar customAppBar({Color color = primaryColor}) => AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: color,
      toolbarHeight: 2.0,
    );
AppBar customAppBarWithTitle(String title, {Color color = primaryColor}) =>
    AppBar(
      title: Text(
        title,
        style: headText3.copyWith(color: secondaryColor),
      ),
      automaticallyImplyLeading: true,
      backgroundColor: color,
      centerTitle: true,
    );

AppBar customAppBarWithTitleNB(String title,
        {String subTitle = '', Widget? trailing}) =>
    AppBar(
      iconTheme: const IconThemeData(color: black),
      actions: [
        trailing ??
            Container(
              width: 0,
            )
      ],
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: headText3.copyWith(color: black),
          ),
          subTitle.isEmpty
              ? Container()
              : Text(
                  subTitle,
                  style: headText4.copyWith(color: black),
                ),
        ],
      ),
      automaticallyImplyLeading: true,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      elevation: 0,
    );

buttonRoundShape(Color color) {
  var shapeRoundBorder = MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
          side: BorderSide(color: color)));
  return shapeRoundBorder;
}

ButtonStyle generalButtonStyle(Color color,
    {double horizontalPadding = 15, double vPadding = 5}) {
  return ButtonStyle(
      padding: MaterialStateProperty.all(EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: vPadding)),
      backgroundColor: MaterialStateProperty.all(color),
      elevation: MaterialStateProperty.all(10),
      shape: buttonRoundShape(color));
}

DecorationImage blurBackgroundImage() {
  return const DecorationImage(
      fit: BoxFit.cover,
      image: AssetImage("assets/images/shared/blur-background.png"));
}

var shapeRoundBorder = MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
        side: const BorderSide(color: primaryColor)));

var buttonPadding15 =
    MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(15));

var buttonBackgroundColor = MaterialStateProperty.all<Color>(primaryColor);

var generalButtonStyle1 = ButtonStyle(
    shape: shapeRoundBorder,
    backgroundColor: buttonBackgroundColor,
    padding: buttonPadding15);

var outlinedButtonStyles1 = OutlinedButton.styleFrom(
  side: const BorderSide(color: primaryColor),
  padding: const EdgeInsets.all(15.0),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25.0),
      side: const BorderSide(color: primaryColor)),
  textStyle: const TextStyle(color: Colors.white),
);
kOutlinedButtonStyles(
        {double radius = 10,
        Color borderColor = primaryColor,
        double borderWidth = 2,
        double hPadding = 10,
        double vPadding = 10}) =>
    OutlinedButton.styleFrom(
      side: BorderSide(color: borderColor, width: borderWidth),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: green)),
      textStyle: const TextStyle(color: Colors.white),
    );

var outlinedButtonStyles2 = OutlinedButton.styleFrom(
  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
  side: const BorderSide(color: primaryColor, width: 0.5),
  textStyle: const TextStyle(color: Colors.white),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25.0),
      side: const BorderSide(color: primaryColor)),
);

AutoSizeText customText(
    {required String text,
    double size = 12,
    bool isCustomFont = false,
    TextStyle style = bodyText1,
    double letterSpace = 0.0,
    FontWeight weight = FontWeight.normal,
    bool isBold = false,
    bool isUnderline = false,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.visible,
    Color color = black}) {
  return AutoSizeText(
    text,
    textAlign: textAlign,
    style: style.copyWith(
        color: color,
        fontSize: isCustomFont ? size : style.fontSize,
        fontWeight: isBold ? FontWeight.bold : style.fontWeight,
        letterSpacing: letterSpace,
        overflow: overflow,
        decoration:
            isUnderline ? TextDecoration.underline : TextDecoration.none),
  );
}

ButtonStyle outlinedButtonStyle(
    {Color sideColor = primaryColor,
    double radius = 25.0,
    double vPadding = 8,
    Color backgroundColor = white,
    Color textColor = black,
    double elevation = 8,
    double hPadding = 8}) {
  return OutlinedButton.styleFrom(
    backgroundColor: backgroundColor,
    elevation: elevation,
    padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
    side: BorderSide(color: sideColor, width: 0.5),
    textStyle: TextStyle(color: textColor),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: sideColor)),
  );
}

Decoration circularGradientBoxDecoration() {
  return const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(25)),
    gradient: LinearGradient(
      colors: [Colors.redAccent, Colors.yellow],
      begin: FractionalOffset.topLeft,
      end: FractionalOffset.bottomRight,
    ),
  );
}

Decoration rectangularGradientBoxDecoration(
    {Color colorOne = Colors.redAccent,
    Color colorTwo = Colors.yellow,
    double radius = 10}) {
  return BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    gradient: LinearGradient(
      colors: [colorOne, colorTwo],
      begin: FractionalOffset.topLeft,
      end: FractionalOffset.bottomRight,
    ),
  );
}

Decoration roundedBoxDecoration(
    {Color color = primaryColor, double radius = 25.0}) {
  return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.all(
        Radius.circular(radius),
      ));
}

Decoration customContainerDecoration(
    {Color bgColor = primaryColor,
    Color borderColor = Colors.transparent,
    double radius = 25.0,
    String path = '',
    double bgOpacity = 1,
    BlendMode blendMode = BlendMode.color,
    BorderStyle borderStyle = BorderStyle.solid,
    double borderWidth = 0.5,
    Color colorOne = Colors.redAccent,
    Color colorTwo = Colors.yellow,
    bool isGradient = false,
    BoxFit fit = BoxFit.cover}) {
  return BoxDecoration(
      // gradient: LinearGradient(
      //   colors: isGradient
      //       ? [colorOne, colorTwo]
      //       : [white.withOpacity(0), white.withOpacity(0)],
      //   begin: FractionalOffset.topLeft,
      //   end: FractionalOffset.bottomRight,
      // ),
      color: bgColor.withOpacity(bgOpacity),
      backgroundBlendMode: blendMode,
      image: path.isEmpty
          ? null
          : DecorationImage(fit: fit, image: AssetImage(path)),
      border: Border.all(
          color: borderColor, style: borderStyle, width: borderWidth),
      borderRadius: BorderRadius.all(
        Radius.circular(radius),
      ));
}

DecorationImage imageBackground({String path = '', BoxFit fit = BoxFit.cover}) {
  if (path.isEmpty) {
    path = "assets/images/shared/blur-background.png";
  }
  return DecorationImage(fit: fit, image: AssetImage(path));
}

Decoration roundedTopLeftRightBoxDecoration(
    {Color color = primaryColor, double radius = 15}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radius), topRight: Radius.circular(radius)),
  );
}
