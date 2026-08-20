import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Barre de navigation basse fixe : Accueil / Livraisons / Carte / Gains / Profil
/// [currentIndex] : 0=Accueil, 1=Livraisons, 2=Carte, 3=Gains, 4=Profil
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(icon: Icons.home_rounded, label: 'Accueil'),
    _NavItemData(icon: Icons.inventory_2_rounded, label: 'Livraisons'),
    _NavItemData(icon: Icons.map_rounded, label: 'Carte'),
    _NavItemData(icon: Icons.account_balance_wallet_rounded, label: 'Gains'),
    _NavItemData(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
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
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final bool active = index == currentIndex;
              final Color color =
                  active ? AppColors.interface : AppColors.textGrey;

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
