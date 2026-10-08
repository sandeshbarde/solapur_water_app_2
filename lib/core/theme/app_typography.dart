import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme getTextTheme() {
    final fontFamily = GoogleFonts.inter().fontFamily;
    final displayFamily = GoogleFonts.poppins().fontFamily;

    return TextTheme(
      displayLarge: TextStyle(fontFamily: displayFamily, fontSize: 40, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(fontFamily: displayFamily, fontSize: 32, fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(fontFamily: displayFamily, fontSize: 24, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontFamily: displayFamily, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontFamily: displayFamily, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400),
      labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400),
    );
  }
}
