import 'package:flutter/material.dart';

/// Jeu de couleurs DavidSTORE Driver, adapté clair/sombre.
/// Accessible via context.colors (voir extension en bas du fichier).
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color interface;
  final Color gold;
  final Color success;
  final Color error;
  final Color background;
  final Color surface; // fond des cartes ("blanc" en clair)
  final Color textGrey;
  final Color divider; // séparateurs / fonds d'icônes clairs

  const AppColors({
    required this.primary,
    required this.interface,
    required this.gold,
    required this.success,
    required this.error,
    required this.background,
    required this.surface,
    required this.textGrey,
    required this.divider,
  });

  /// Palette claire — valeurs exactes du cahier des charges
  static const light = AppColors(
    primary: Color(0xFF0B3D91),
    interface: Color(0xFF1465E8),
    gold: Color(0xFFFFC107),
    success: Color(0xFF16A765),
    error: Color(0xFFDC3545),
    background: Color(0xFFF7F9FC),
    surface: Color(0xFFFFFFFF),
    textGrey: Color(0xFF667085),
    divider: Color(0xFFE8EDF5),
  );

  /// Palette sombre — dérivée pour garder un bon contraste
  static const dark = AppColors(
    primary: Color(0xFF6FA1FF),
    interface: Color(0xFF4C8DFF),
    gold: Color(0xFFFFC107),
    success: Color(0xFF2ED18C),
    error: Color(0xFFFF5A6E),
    background: Color(0xFF0E1420),
    surface: Color(0xFF1A2233),
    textGrey: Color(0xFF9AA5B8),
    divider: Color(0xFF29314A),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? interface,
    Color? gold,
    Color? success,
    Color? error,
    Color? background,
    Color? surface,
    Color? textGrey,
    Color? divider,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      interface: interface ?? this.interface,
      gold: gold ?? this.gold,
      success: success ?? this.success,
      error: error ?? this.error,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textGrey: textGrey ?? this.textGrey,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      interface: Color.lerp(interface, other.interface, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textGrey: Color.lerp(textGrey, other.textGrey, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

/// Raccourci : context.colors.primary au lieu de Theme.of(context)...
extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
