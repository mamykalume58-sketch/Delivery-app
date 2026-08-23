import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pilote le ThemeMode de l'app (Clair/Sombre/Système) et le persiste via
/// shared_preferences pour qu'il survive au redémarrage de l'app.
class ThemeService {
  static const _prefsKey = 'theme_mode';

  /// Notifier global écouté par MaterialApp pour rebuild au changement.
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  /// À appeler une fois au démarrage (avant runApp) pour charger la
  /// préférence sauvegardée.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    switch (saved) {
      case 'light':
        mode.value = ThemeMode.light;
        break;
      case 'dark':
        mode.value = ThemeMode.dark;
        break;
      default:
        mode.value = ThemeMode.system;
    }
  }

  static Future<void> setMode(ThemeMode newMode) async {
    mode.value = newMode;
    final prefs = await SharedPreferences.getInstance();
    final value = switch (newMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_prefsKey, value);
  }
}
