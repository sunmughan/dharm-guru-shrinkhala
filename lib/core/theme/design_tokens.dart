import 'package:flutter/material.dart';

/// Design tokens for Dharm Guru Shrinkhala.
/// Exact values from design/DESIGN-SYSTEM.md, which takes every
/// token from the presentation. Use the token name in code,
/// never a raw hex value in a screen file.
/// Light tokens are the default. Dark tokens are listed for
/// the system dark mode follow up in a later phase.
class AppColors {
  AppColors._();

  static const Color bg = Color(0xFFFFF7E8);
  static const Color bg2 = Color(0xFFFDEBD0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFFFF3DE);
  static const Color ink = Color(0xFF211712);
  static const Color ink2 = Color(0xFF5B4A3A);
  static const Color ink3 = Color(0xFF8A7460);
  static const Color saffron = Color(0xFFD96C00);
  static const Color saffron2 = Color(0xFFB45309);
  static const Color maroon = Color(0xFF7C2D12);
  static const Color gold = Color(0xFFC99A2E);
  static const Color line = Color(0xFFEBD9BC);
  static const Color line2 = Color(0xFFDCC49A);
  static const Color good = Color(0xFF2F7D4F);

  /// Short aliases kept for readability in older call sites.
  static const Color cream = bg;
  static const Color cardWhite = surface;
  static const Color deepInk = ink;
  static const Color deepSaffron = saffron2;
  static const Color textPrimary = ink;
  static const Color textSecondary = ink2;
  static const Color textOnSaffron = Color(0xFFFFFFFF);
  static const Color divider = line;
  static const Color success = good;
  static const Color premiumGold = gold;
}

class AppTextStyles {
  AppTextStyles._();

  /// Headings use a serif family, Georgia preferred.
  static const String serifFamily = 'Georgia';

  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFamily: serifFamily,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  static const TextStyle title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: serifFamily,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    fontFamily: serifFamily,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: serifFamily,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static const TextStyle listTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.55,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.ink3,
    height: 1.4,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.08 * 11,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnSaffron,
    height: 1.2,
  );

  static const TextStyle chartRashi = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.ink2,
    height: 1.3,
  );

  static const TextStyle chartPlanet = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.deepInk,
    height: 1.3,
  );

  static const TextStyle chartDegree = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );
}

class AppSpacing {
  AppSpacing._();

  /// Base unit is 4. All spacing uses multiples of 4.
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double cardRadius = 18;
  static const double smallRadius = 14;
  static const double pillRadius = 999;
  static const double buttonRadius = pillRadius;
  static const double buttonHeight = 52;
  static const double screenPadding = 16;
  static const double tabBarHeight = 64;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.saffron,
      colorScheme: const ColorScheme.light(
        primary: AppColors.saffron,
        secondary: AppColors.saffron2,
        surface: AppColors.surface,
        onPrimary: AppColors.textOnSaffron,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        centerTitle: false,
        titleTextStyle: AppTextStyles.cardTitle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.saffron,
          foregroundColor: AppColors.textOnSaffron,
          textStyle: AppTextStyles.button,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppSpacing.cardRadius),
          ),
          side: BorderSide(color: AppColors.line),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.saffron,
        unselectedItemColor: AppColors.ink3,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
