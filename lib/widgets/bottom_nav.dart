import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

/// Barre de navigation basse fixe : Accueil / Carte / Gains / Profil
/// [currentIndex] : 0=Accueil, 1=Carte, 2=Gains, 3=Profil
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  List<_NavItemData> _items(AppLocalizations l10n) => [
        _NavItemData(icon: Icons.home_rounded, label: l10n.navAccueil),
        _NavItemData(icon: Icons.map_rounded, label: l10n.navCarte),
        _NavItemData(icon: Icons.account_balance_wallet_rounded, label: l10n.navGains),
        _NavItemData(icon: Icons.person_rounded, label: l10n.navProfil),
      ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final items = _items(l10n);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final bool active = index == currentIndex;
              final Color color = active ? colors.interface : colors.textGrey;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap?.call(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: color, size: 24),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}
