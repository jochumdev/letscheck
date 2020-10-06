import 'package:flutter/material.dart';

// Nice to get colors: https://icolorpalette.com/color/101920

const Color checkMKIconColor = Color(0xFF13D389);

ThemeData buildLightTheme() {
  const Color primaryColor = Colors.black;
  const Color secondaryColor = Color(0xFF101920);

  final ColorScheme colorScheme = const ColorScheme.light().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
  );
  final ThemeData base = ThemeData(
    appBarTheme: AppBarTheme(
      color: checkMKIconColor,
      textTheme: Typography.material2018().white,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    primaryTextTheme: Typography.material2018().white,
    textTheme: Typography.material2018().black,
    brightness: Brightness.light,
    accentColorBrightness: Brightness.dark,
    colorScheme: colorScheme,
    primaryColor: primaryColor,
    cardColor: checkMKIconColor,
    buttonColor: primaryColor,
    indicatorColor: Colors.white,
    toggleableActiveColor: secondaryColor,
    splashColor: Colors.white24,
    splashFactory: InkRipple.splashFactory,
    accentColor: secondaryColor,
    canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: checkMKIconColor,
    errorColor: const Color(0xFFB00020),
    buttonTheme: ButtonThemeData(
      colorScheme: colorScheme,
      textTheme: ButtonTextTheme.primary,
    ),
    fontFamily: "Open Sans",
  );
  return base;
}

ThemeData buildDarkTheme() {
  const Color primaryColor = Colors.white;
  const Color secondaryColor = checkMKIconColor;

  final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
  );
  final ThemeData base = ThemeData(
    appBarTheme: AppBarTheme(
      color: secondaryColor,
      textTheme: Typography.material2018().white,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    brightness: Brightness.dark,
    accentColorBrightness: Brightness.dark,
    primaryColor: primaryColor,
    cardColor: const Color(0xFF1B2A36),
    primaryColorDark: primaryColor,
    primaryColorLight: secondaryColor,
    buttonColor: primaryColor,
    indicatorColor: Colors.white,
    toggleableActiveColor: secondaryColor,
    accentColor: secondaryColor,
    canvasColor: const Color(0xFF101920),
    scaffoldBackgroundColor: const Color(0xFF101920),
    backgroundColor: const Color(0xFF101920),
    errorColor: const Color(0xFFB00020),
    buttonTheme: ButtonThemeData(
      colorScheme: ColorScheme.dark().copyWith(
        primary: secondaryColor,
        secondary: primaryColor,
      ),
      textTheme: ButtonTextTheme.primary,
    ),
    fontFamily: "Open Sans",
  );
  return base;
}