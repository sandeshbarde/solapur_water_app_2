import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.teal,
            surface: AppColors.cardDark,
            error: AppColors.critical,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: AppColors.textPrimaryDark,
            onError: Colors.white,
          )
        : const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.teal,
            surface: AppColors.cardLight,
            error: AppColors.critical,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: AppColors.textPrimaryLight,
            onError: Colors.white,
          );

    final textTheme = AppTypography.getTextTheme().apply(
      bodyColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      displayColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.bgDark : AppColors.background,

      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
      ),

      cardTheme: CardThemeData(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape:
              RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surface2Dark : AppColors.cardLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide:
              BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide:
              BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.surface2Dark : AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.pillRadius,
          side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.cardDark : AppColors.cardLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        indicatorColor: AppColors.primary,
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardRadius),
        backgroundColor:
            isDark ? AppColors.cardDark : AppColors.cardLight,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        shape: AppRadius.sheetShape,
        backgroundColor:
            isDark ? AppColors.cardDark : AppColors.cardLight,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
