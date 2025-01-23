import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Nice to get colors: https://icolorpalette.com/color/101920

const Color checkMKIconColor = Color(0xFF13D389);

ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      color: checkMKIconColor,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    primaryTextTheme: Typography.material2021().white,
    textTheme: Typography.material2021().black,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: checkMKIconColor),
  );

  return base.copyWith(
    textTheme: GoogleFonts.latoTextTheme(base.textTheme),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      color: checkMKIconColor,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    primaryTextTheme: Typography.material2021().white,
    textTheme: Typography.material2021().white,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
        seedColor: checkMKIconColor, brightness: Brightness.dark),
  );

  return base.copyWith(
    textTheme: GoogleFonts.latoTextTheme(base.textTheme),
  );
}
