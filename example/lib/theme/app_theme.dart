import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const primaryColor = Color(0xFF1A237E);
  static const secondaryColor = Color(0xFFFF6F00);
  static const surfaceColor = Color(0xFFF5F5F5);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          secondary: secondaryColor,
          surface: surfaceColor,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
        ),
        navigationRailTheme: const NavigationRailThemeData(
          indicatorColor: Color(0x331A237E),
        ),
      );

  static const defaultBorderRadius = BorderRadius.all(Radius.circular(12));
  static const buttonRadius = BorderRadius.all(Radius.circular(8));
}
