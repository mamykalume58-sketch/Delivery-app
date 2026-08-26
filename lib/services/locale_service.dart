import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pilote la langue de l'app (fr/en/sw) et la persiste via
/// shared_preferences, comme ThemeService pour le thème.
class LocaleService {
  static const _prefsKey = 'locale_code';

  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('fr'));

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      locale.value = Locale(saved);
    }
  }

  static Future<void> setLocale(String code) async {
    locale.value = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
  }
}
