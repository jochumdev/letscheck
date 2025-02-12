import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

// Nice to get colors: https://icolorpalette.com/color/101920

// Scheme builder: https://rydmike.com/flexcolorscheme/themesplayground-v8-0/

const Color checkMKIconColor = Color(0xFF13D389);

/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
///
/// Use in [MaterialApp] like this:
///
/// MaterialApp(
///  theme: AppTheme.light,
///  darkTheme: AppTheme.dark,
///  :
/// );
sealed class AppTheme {
  // The defined light theme.
  static ThemeData lightBase = FlexThemeData.light(
    scheme: FlexScheme.greenM3,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    keyColors: const FlexKeyColors(),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
  static ThemeData light = lightBase.copyWith(
    appBarTheme: AppBarTheme(
      color: checkMKIconColor,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: GoogleFonts.latoTextTheme(lightBase.textTheme),
  );

  // The defined dark theme.
  static ThemeData darkBase = FlexThemeData.dark(
    scheme: FlexScheme.greenM3,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    keyColors: const FlexKeyColors(),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
  static ThemeData dark = darkBase.copyWith(
    appBarTheme: AppBarTheme(
      color: checkMKIconColor,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: GoogleFonts.latoTextTheme(darkBase.textTheme),
  );

}
