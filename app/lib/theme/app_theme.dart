import 'package:flutter/material.dart';

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
  // Cinzel/EB Garamond sont embarquées en assets/fonts (voir pubspec.yaml) —
  // plus de dépendance réseau au runtime (google_fonts téléchargeait ces
  // polices à la volée, ce qui échouait silencieusement sans connexion).
  static TextStyle title({double size = 20, FontWeight weight = FontWeight.w700, Color? color}) =>
      TextStyle(fontFamily: 'Cinzel', fontSize: size, fontWeight: weight, color: color ?? AppColors.night);

  static TextStyle titleDecorative({double size = 22, Color? color}) =>
      TextStyle(fontFamily: 'Cinzel Decorative', fontSize: size, fontWeight: FontWeight.w700, color: color ?? AppColors.glow);

  static TextStyle body({double size = 15, Color? color, FontStyle? fontStyle}) =>
      TextStyle(fontFamily: 'EB Garamond', fontSize: size, color: color ?? AppColors.ink, fontStyle: fontStyle);

  // Police système (Roboto/San Francisco) pour les libellés d'UI : lisible à
  // toute graisse sans avoir à embarquer 5 poids d'une police supplémentaire.
  static TextStyle ui({double size = 13, FontWeight weight = FontWeight.w600, Color? color}) =>
      TextStyle(fontSize: size, fontWeight: weight, color: color ?? AppColors.ink);

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
