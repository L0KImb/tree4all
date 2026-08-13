import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette "fantasy médiéval" — portée depuis le prototype web.
class AppColors {
  static const night = Color(0xFF170F2B);
  static const nightDeep = Color(0xFF0D0A1C);
  static const arcane = Color(0xFF4C2A7A);
  static const arcaneLight = Color(0xFF7B52AD);
  static const forestDeep = Color(0xFF163A2C);
  static const forest = Color(0xFF2D6A4F);
  static const mossLight = Color(0xFFCFEAD9);
  static const gold = Color(0xFFC9A961);
  static const goldBright = Color(0xFFFFD166);
  static const glow = Color(0xFFFFE9A8);
  static const parchment = Color(0xFFF2E6CC);
  static const parchmentDark = Color(0xFFE7D6AE);
  static const ink = Color(0xFF2B2015);
  static const inkSoft = Color(0xFF5B4D3A);
}

class AppTheme {
  static TextStyle title({double size = 20, FontWeight weight = FontWeight.w700, Color? color}) =>
      GoogleFonts.cinzel(fontSize: size, fontWeight: weight, color: color ?? AppColors.night);

  static TextStyle titleDecorative({double size = 22, Color? color}) =>
      GoogleFonts.cinzelDecorative(fontSize: size, fontWeight: FontWeight.w700, color: color ?? AppColors.glow);

  static TextStyle body({double size = 15, Color? color, FontStyle? fontStyle}) =>
      GoogleFonts.ebGaramond(fontSize: size, color: color ?? AppColors.ink, fontStyle: fontStyle);

  static TextStyle ui({double size = 13, FontWeight weight = FontWeight.w600, Color? color}) =>
      GoogleFonts.nunito(fontSize: size, fontWeight: weight, color: color ?? AppColors.ink);

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.arcane,
        brightness: Brightness.light,
        primary: AppColors.arcane,
        secondary: AppColors.goldBright,
        surface: AppColors.parchment,
      ),
      scaffoldBackgroundColor: AppColors.nightDeep,
      fontFamily: GoogleFonts.nunito().fontFamily,
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.nightDeep,
        foregroundColor: AppColors.glow,
        titleTextStyle: titleDecorative(size: 18),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldBright,
          foregroundColor: AppColors.night,
          textStyle: title(size: 15),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

const Map<String, String> kTypeLabels = {
  'permis': '🌱 Permis de végétaliser',
  'naturelle': '🌲 Zone naturelle',
  'association': '🤝 Jardin / événement associatif',
};

const Map<String, String> kCategoryLabels = {
  'arbre': '🌳 Arbres',
  'arbuste': '🌿 Arbustes',
  'fleur': '🌸 Fleurs',
  'legume-fruit': '🍅 Légumes & Fruits',
};
