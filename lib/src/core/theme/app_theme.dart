import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colors matching the Explore mockup.
abstract final class AppColors {
  static const brand = Color(0xFF1B5E4A);
  static const brandSoft = Color(0xFFE8F2EE);
  static const surfaceMuted = Color(0xFFF2F3F5);
  static const textMuted = Color(0xFF8A8F98);
}

/// Light and dark Material 3 themes with the mockup seed color.
abstract final class AppTheme {
  static const _seed = AppColors.brand;

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      primary: brightness == Brightness.light ? AppColors.brand : null,
    );
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor:
          brightness == Brightness.light ? Colors.white : null,
    );
    final textTheme = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: GoogleFonts.interTextTheme(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: const ChipThemeData(
        showCheckmark: false,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
