import 'package:material_ui/material_ui.dart';

/// Design tokens for Dharm Guru Shrinkhala.
/// Exact values from design/DESIGN-SYSTEM.md, which takes every
/// token from the presentation. Use the token name in code,
/// never a raw hex value in a screen file.
/// Light tokens are the default. Dark tokens are the dark
/// set, used when the system is in dark mode.
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

  /// Pick the light or dark value for the current brightness.
  /// Used for surfaces and borders set explicitly in build
  /// methods instead of coming from the theme.
  static Color resolve(BuildContext context, Color light, Color dark) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

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
}

/// Dark colour tokens from design/DESIGN-SYSTEM.md section 2.
/// Same token names as the light set, dark values. Used by
/// AppTheme.dark and by AppTextStyles.themed.
class AppColorsDark {
  AppColorsDark._();

  static const Color bg = Color(0xFF14100C);
  static const Color bg2 = Color(0xFF1D1710);
  static const Color surface = Color(0xFF201913);
  static const Color surface2 = Color(0xFF2A2118);
  static const Color ink = Color(0xFFF7EBD7);
  static const Color ink2 = Color(0xFFD8C4A6);
  static const Color ink3 = Color(0xFFA68F73);
  static const Color saffron = Color(0xFFF59E0B);
  static const Color saffron2 = Color(0xFFFBBF24);
  static const Color maroon = Color(0xFFFDBA74);
  static const Color gold = Color(0xFFE3B94E);
  static const Color line = Color(0xFF3A2E20);
  static const Color line2 = Color(0xFF54432C);
  static const Color good = Color(0xFF7BC796);
  static const Color phonebg = Color(0xFF1B1510);
}

class AppTextStyles {
  AppTextStyles._();

  /// Resolve a text style for the current brightness. The const
  /// styles below are the light set; in dark mode the style
  /// colour is mapped to the matching dark token so text stays
  /// readable. Every style use is wrapped in themed().
  static TextStyle themed(BuildContext context, TextStyle style) {
    if (Theme.of(context).brightness == Brightness.light) {
      return style;
    }
    final Color? color = style.color;
    if (color == null) {
      return style;
    }
    return style.copyWith(color: _darkColor(color));
  }

  /// Map one light text colour to its dark token. Colours not
  /// listed here are left unchanged.
  static Color _darkColor(Color light) {
    if (light == AppColors.textPrimary || light == AppColors.deepInk) {
      return AppColorsDark.ink;
    }
    if (light == AppColors.textSecondary || light == AppColors.ink2) {
      return AppColorsDark.ink2;
    }
    if (light == AppColors.ink3) {
      return AppColorsDark.ink3;
    }
    if (light == AppColors.textOnSaffron) {
      return AppColorsDark.bg;
    }
    if (light == AppColors.saffron || light == AppColors.deepSaffron) {
      return AppColorsDark.saffron;
    }
    if (light == AppColors.saffron2) {
      return AppColorsDark.saffron2;
    }
    if (light == AppColors.maroon) {
      return AppColorsDark.maroon;
    }
    if (light == AppColors.gold) {
      return AppColorsDark.gold;
    }
    if (light == AppColors.good) {
      return AppColorsDark.good;
    }
    return light;
  }

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
  /// Names follow the spec tokens: xs is space.1, sm is
  /// space.2, space3 is space.3, md is space.4, space5 is
  /// space.5, lg is space.6, xl is space.8, xxl is space.12.
  static const double xs = 4;
  static const double sm = 8;
  static const double space3 = 12;
  static const double md = 16;
  static const double space5 = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double cardRadius = 18;
  static const double smallRadius = 14;
  static const double pillRadius = 999;
  static const double chartRadius = 16;
  static const double sheetRadius = 24;
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

  /// Dark theme from the spec dark tokens. Primary buttons use
  /// saffron #F59E0B fill with #14100C text, never white text,
  /// because white on #F59E0B is weak contrast.
  /// Text styles are brightness aware through
  /// AppTextStyles.themed, so themeMode follows the system.
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColorsDark.bg,
      primaryColor: AppColorsDark.saffron,
      colorScheme: const ColorScheme.dark(
        primary: AppColorsDark.saffron,
        secondary: AppColorsDark.saffron2,
        surface: AppColorsDark.surface,
        onPrimary: AppColorsDark.bg,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsDark.surface,
        foregroundColor: AppColorsDark.ink,
        centerTitle: false,
        titleTextStyle: AppTextStyles.cardTitle.copyWith(
          color: AppColorsDark.ink,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.saffron,
          foregroundColor: AppColorsDark.bg,
          textStyle: AppTextStyles.button.copyWith(
            color: AppColorsDark.bg,
          ),
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
        color: AppColorsDark.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppSpacing.cardRadius),
          ),
          side: BorderSide(color: AppColorsDark.line),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColorsDark.surface,
        selectedItemColor: AppColorsDark.saffron,
        unselectedItemColor: AppColorsDark.ink3,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
