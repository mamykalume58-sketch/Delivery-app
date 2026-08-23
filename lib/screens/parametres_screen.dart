import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/theme_service.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Français';

  static const _languages = ['Français', 'English', 'Kiswahili'];
  static const _themeLabels = {
    ThemeMode.system: 'Système',
    ThemeMode.light: 'Clair',
    ThemeMode.dark: 'Sombre',
  };

  void _pickLanguage(AppColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final lang in _languages)
              ListTile(
                title: Text(lang, style: TextStyle(color: colors.primary)),
                trailing: lang == _selectedLanguage ? Icon(Icons.check, color: colors.interface) : null,
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _pickTheme(AppColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in _themeLabels.entries)
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

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text('Paramètres', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
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
                label: 'Notifications',
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
                    label: 'Thème',
                    colors: colors,
                    trailing: Text(_themeLabels[themeMode] ?? '', style: TextStyle(fontSize: 13, color: colors.textGrey)),
                    onTap: () => _pickTheme(colors),
                  );
                },
              ),
              Divider(height: 1, color: colors.divider),
              _settingRow(
                icon: Icons.language_rounded,
                label: 'Langue',
                colors: colors,
                trailing: Text(_selectedLanguage, style: TextStyle(fontSize: 13, color: colors.textGrey)),
                onTap: () => _pickLanguage(colors),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
