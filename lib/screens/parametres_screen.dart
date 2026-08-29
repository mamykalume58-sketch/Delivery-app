import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/theme_service.dart';
import '../services/locale_service.dart';
import '../l10n/app_localizations.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  bool _notificationsEnabled = true;

  static const _languages = {
    'fr': 'Français',
    'en': 'English',
    'sw': 'Kiswahili',
  };

  Map<ThemeMode, String> _themeLabels(AppLocalizations l10n) => {
        ThemeMode.system: l10n.parametresScreen_themeSystem,
        ThemeMode.light: l10n.parametresScreen_themeLight,
        ThemeMode.dark: l10n.parametresScreen_themeDark,
      };

  void _pickLanguage(AppColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in _languages.entries)
              ListTile(
                title: Text(entry.value, style: TextStyle(color: colors.primary)),
                trailing: entry.key == LocaleService.locale.value.languageCode
                    ? Icon(Icons.check, color: colors.interface)
                    : null,
                onTap: () {
                  LocaleService.setLocale(entry.key);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _pickTheme(AppColors colors, AppLocalizations l10n) {
    final themeLabels = _themeLabels(l10n);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in themeLabels.entries)
              ListTile(
                title: Text(entry.value, style: TextStyle(color: colors.primary)),
                trailing: entry.key == ThemeService.mode.value ? Icon(Icons.check, color: colors.interface) : null,
                onTap: () {
                  ThemeService.setMode(entry.key);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String label,
    required AppColors colors,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colors.textGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, color: colors.primary)),
            ),
            trailing ?? Icon(Icons.chevron_right, size: 18, color: colors.textGrey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final themeLabels = _themeLabels(l10n);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(l10n.parametresScreen_title, style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            children: [
              _settingRow(
                icon: Icons.notifications_none_rounded,
                label: l10n.parametresScreen_notifications,
                colors: colors,
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeColor: colors.success,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                ),
              ),
              Divider(height: 1, color: colors.divider),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeService.mode,
                builder: (context, themeMode, _) {
                  return _settingRow(
                    icon: Icons.brightness_6_outlined,
                    label: l10n.parametresScreen_theme,
                    colors: colors,
                    trailing: Text(themeLabels[themeMode] ?? '', style: TextStyle(fontSize: 13, color: colors.textGrey)),
                    onTap: () => _pickTheme(colors, l10n),
                  );
                },
              ),
              Divider(height: 1, color: colors.divider),
              ValueListenableBuilder<Locale>(
                valueListenable: LocaleService.locale,
                builder: (context, locale, _) {
                  return _settingRow(
                    icon: Icons.language_rounded,
                    label: l10n.parametresScreen_language,
                    colors: colors,
                    trailing: Text(_languages[locale.languageCode] ?? '', style: TextStyle(fontSize: 13, color: colors.textGrey)),
                    onTap: () => _pickLanguage(colors),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
