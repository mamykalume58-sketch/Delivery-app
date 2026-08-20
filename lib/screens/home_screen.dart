import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../models/driver_model.dart';
import '../services/order_service.dart';
import 'nouvelle_livraison_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _driverService = DriverService();
  final _orderService = OrderService();

  // Compteurs de livraisons/gains du jour : à brancher une fois le champ
  // driverId ajouté aux commandes (en attente de validation avec le
  // dashboard admin). En attendant, pas de chiffres inventés — tout à 0.
  final int todayDeliveries = 0;
  final int inProgress = 0;
  final int todayEarnings = 0;
  final int newDeliveriesAvailable = 0;
  final int inProgressDeliveries = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final uid = _authService.currentUser?.uid;

    if (uid == null) {
      // Ne devrait pas arriver (splash redirige vers Login si déconnecté),
      // filet de sécurité seulement.
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: Text('Session expirée. Reconnectez-vous.')),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _driverService.watchDriver(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: colors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: colors.background,
            body: const Center(child: Text('Profil livreur introuvable.')),
          );
        }

        final driver = DriverModel.fromDoc(snapshot.data!);

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(colors),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(colors, driver),
                        const SizedBox(height: 16),
                        _buildStatsCard(colors),
                        const SizedBox(height: 20),
                        StreamBuilder<List<dynamic>>(
                          stream: _orderService.watchAssignedOrders(uid),
                          builder: (context, orderSnapshot) {
                            final count = orderSnapshot.data?.length ?? 0;
                            return _buildMenuCard(
                              colors: colors,
                              icon: Icons.inventory_2_rounded,
                              iconBg: colors.interface.withValues(alpha: 0.1),
                              iconColor: colors.interface,
                              title: 'Nouvelle livraison',
                              subtitle: '$count disponible(s)',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NouvelleLivraisonScreen()),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuCard(
                          colors: colors,
                          icon: Icons.local_shipping_rounded,
                          iconBg: colors.gold.withValues(alpha: 0.15),
                          iconColor: colors.gold,
                          title: 'En cours',
                          subtitle: '$inProgressDeliveries livraison(s)',
                        ),
                        const SizedBox(height: 12),
                        _buildMenuCard(
                          colors: colors,
                          icon: Icons.folder_rounded,
                          iconBg: colors.divider,
                          iconColor: colors.textGrey,
                          title: 'Historique',
                          subtitle: 'Voir vos livraisons',
                        ),
                        const SizedBox(height: 20),
                        _buildStatusCard(colors, uid, driver),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNav(
            currentIndex: 0,
            onTap: (index) {
              // Navigation entre onglets à brancher plus tard
            },
          ),
        );
      },
    );
  }

  Widget _buildAppBar(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.menu_rounded, color: colors.primary),
          Text(
            'Accueil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none_rounded, color: colors.primary),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AppColors colors, DriverModel driver) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: colors.divider,
            backgroundImage:
                (driver.photoUrl != null && driver.photoUrl!.isNotEmpty)
                    ? NetworkImage(driver.photoUrl!)
                    : null,
            child: (driver.photoUrl == null || driver.photoUrl!.isEmpty)
                ? Icon(Icons.person, color: colors.textGrey, size: 28)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            driver.isAvailable ? colors.success : colors.textGrey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      driver.isAvailable ? 'En ligne' : 'Hors ligne',
                      style: TextStyle(fontSize: 13, color: colors.textGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.star_rounded, color: colors.gold, size: 18),
              const SizedBox(width: 2),
              Text(
                '${driver.rating} (${driver.reviewCount})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.interface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Aujourd'hui",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem('$todayDeliveries', 'Livraisons'),
              _statDivider(),
              _statItem('$inProgress', 'En cours'),
              _statDivider(),
              _statItem('${_formatFC(todayEarnings)} FC', 'Gains'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 34,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _buildMenuCard({
    required AppColors colors,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: colors.textGrey),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.textGrey),
        ],
      ),
      ),
    );
  }

  Widget _buildStatusCard(AppColors colors, String uid, DriverModel driver) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statut',
                style: TextStyle(fontSize: 13, color: colors.textGrey),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          driver.isAvailable ? colors.success : colors.textGrey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    driver.isAvailable ? 'Disponible' : 'Hors ligne',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: driver.isAvailable,
            activeColor: colors.success,
            onChanged: (value) {
              _driverService.updateStatus(uid, value ? 'disponible' : 'hors_ligne');
            },
          ),
        ],
      ),
    );
  }

  String _formatFC(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
