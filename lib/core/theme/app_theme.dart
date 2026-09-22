import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final textTheme = AppTypography.textTheme(false);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.pistachio,
        onSecondary: Colors.white,
        tertiary: AppColors.saffronGold,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        outline: AppColors.borderLight,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.borderRadiusLg,
          side: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight, size: 20),
        shape: const Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMutedLight),
        border: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, AppTokens.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadiusMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
          minimumSize: const Size(0, AppTokens.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: const BorderSide(color: AppColors.borderLight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadiusMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, AppTokens.buttonHeightSm),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadiusSm,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondaryLight,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.borderLight,
        labelStyle: textTheme.labelLarge,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.borderRadiusXl,
          side: BorderSide(color: AppColors.borderLight),
        ),
        elevation: 8,
      ),
    );
  }

  static ThemeData dark() {
    final textTheme = AppTypography.textTheme(true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.primaryContainer,
        secondary: AppColors.pistachio,
        onSecondary: Colors.white,
        tertiary: AppColors.saffronGold,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        outline: AppColors.borderDark,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.borderRadiusLg,
          side: BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark, size: 20),
        shape: const Border(bottom: BorderSide(color: AppColors.borderDark, width: 1)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMutedDark),
        border: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, AppTokens.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadiusMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryDark,
          minimumSize: const Size(0, AppTokens.buttonHeightMd),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: const BorderSide(color: AppColors.borderDark),
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadiusMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          minimumSize: const Size(0, AppTokens.buttonHeightSm),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: AppTokens.borderRadiusSm,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.textSecondaryDark,
        indicatorColor: AppColors.primaryLight,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.borderDark,
        labelStyle: textTheme.labelLarge,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.borderRadiusXl,
          side: BorderSide(color: AppColors.borderDark),
        ),
        elevation: 8,
      ),
    );
  }
}
