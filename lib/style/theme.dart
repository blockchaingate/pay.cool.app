import 'package:flutter/cupertino.dart';

class Colors {
  const Colors();

  static const Color loginGradientStart = Color(0xFF7F00FF);
  static const Color loginGradientEnd = Color(0xFFE100FF);

  static LinearGradient primaryGradient = LinearGradient(
    colors: const [loginGradientStart, loginGradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
