import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final textTheme = GoogleFonts.manropeTextTheme().copyWith(
    headlineMedium: GoogleFonts.manrope(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: kInkColor,
    ),
    titleLarge: GoogleFonts.manrope(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: kInkColor,
    ),
    titleMedium: GoogleFonts.manrope(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: kInkColor,
    ),
    bodyLarge: GoogleFonts.manrope(
      fontSize: 16,
      color: kInkColor,
    ),
    bodyMedium: GoogleFonts.manrope(
      fontSize: 14,
      color: kInkColor,
    ),
    labelLarge: GoogleFonts.manrope(
      fontWeight: FontWeight.w600,
    ),
    labelSmall: GoogleFonts.manrope(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: kBrandColor),
    scaffoldBackgroundColor: kSurfaceColor,
    appBarTheme: AppBarTheme(
      backgroundColor: kSurfaceColor,
      foregroundColor: kInkColor,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ),
    textTheme: textTheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kBrandColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kBrandColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kBrandColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: kInkColor),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.fixed,
      backgroundColor: kInkColor,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      actionTextColor: kBrandColor,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: kBrandColor.withOpacity(0.14),
      labelTextStyle: WidgetStateProperty.all(
        textTheme.labelSmall?.copyWith(color: kInkColor) ??
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kInkColor,
            ),
      ),
    ),
  );
}
