import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/tab_navigation.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../models/driver_model.dart';
import '../services/order_service.dart';
import 'nouvelle_livraison_screen.dart';
import 'historique_screen.dart';
import 'mes_livraisons_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../models/order_model.dart';
import '../services/version_service.dart';
import '../widgets/update_dialog.dart';
import '../l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _registerFcmToken();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _registerFcmToken() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    final token = await messaging.getToken();
    if (token != null) {
      await _driverService.updateFcmToken(uid, token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _driverService.updateFcmToken(uid, newToken);
    });
  }

  Future<void> _checkForUpdate() async {
    try {
      final info = await VersionService().checkForUpdate();
      if (info != null && mounted) {
        showUpdateDialog(context, info: info);
      }
    } catch (_) {
      // Vérification silencieuse : pas de blocage si Firestore/réseau échoue.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final uid = _authService.currentUser?.uid;

    if (uid == null) {
      // Ne devrait pas arriver (splash redirige vers Login si déconnecté),
      // filet de sécurité seulement.
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: Text(l10n.homeScreen_sessionExpired)),
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
            body: Center(child: Text(l10n.homeScreen_driverProfileNotFound)),
          );
        }

        final driver = DriverModel.fromDoc(snapshot.data!);

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(colors, uid),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(colors, l10n, driver),
                        const SizedBox(height: 16),
                        _buildStatsCard(colors, l10n, uid),
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
                              title: l10n.homeScreen_newDelivery,
                              subtitle: l10n.homeScreen_availableCount(count),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NouvelleLivraisonScreen()),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<List<OrderModel>>(
                          stream: _orderService.watchInProgressOrders(uid),
                          builder: (context, inProgressSnapshot) {
                            final inProgressCount = inProgressSnapshot.data?.length ?? 0;
                            return _buildMenuCard(
                              colors: colors,
                              icon: Icons.local_shipping_rounded,
                              iconBg: colors.gold.withValues(alpha: 0.15),
                              iconColor: colors.gold,
                              title: l10n.homeScreen_inProgress,
                              subtitle: l10n.homeScreen_deliveryCount(inProgressCount),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MesLivraisonsScreen()),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuCard(
                          colors: colors,
                          icon: Icons.folder_rounded,
                          iconBg: colors.divider,
                          iconColor: colors.textGrey,
                          title: l10n.homeScreen_history,
                          subtitle: l10n.homeScreen_viewDeliveries,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HistoriqueScreen()),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildStatusCard(colors, l10n, uid, driver),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNav(
            currentIndex: 0,
            onTap: (index) => navigateToTab(context, index),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(AppColors colors, String uid) {
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
          StreamBuilder<List<NotificationModel>>(
            stream: NotificationService().watchNotifications(uid),
            builder: (context, snapshot) {
              final hasNotifications = (snapshot.data?.isNotEmpty ?? false);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.notifications_none_rounded, color: colors.primary),
                    if (hasNotifications)
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
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildProfileCard(AppColors colors, AppLocalizations l10n, DriverModel driver) {
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
            backgroundImage: _buildProfileImage(driver.photoUrl),
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
                      driver.isAvailable ? l10n.homeScreen_online : l10n.homeScreen_offline,
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

  Widget _buildStatsCard(AppColors colors, AppLocalizations l10n, String uid) {
    return StreamBuilder<List<OrderModel>>(
      stream: _orderService.watchOrderHistory(uid),
      builder: (context, historySnapshot) {
        final delivered = historySnapshot.data ?? [];
        final now = DateTime.now();
        final todayOrders = delivered.where((o) {
          final d = o.deliveredAt;
          return d != null && d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList();
        final todayDeliveries = todayOrders.length;
        final todayEarnings = todayOrders.fold<int>(0, (sum, o) => sum + o.fraisLivraison);

        return StreamBuilder<List<OrderModel>>(
          stream: _orderService.watchInProgressOrders(uid),
          builder: (context, inProgressSnapshot) {
            final inProgress = inProgressSnapshot.data?.length ?? 0;

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
                  Text(
                    l10n.homeScreen_today,
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
                      _statItem('$todayDeliveries', l10n.homeScreen_deliveries),
                      _statDivider(),
                      _statItem('$inProgress', l10n.homeScreen_inProgress),
                      _statDivider(),
                      _statItem('${_formatFC(todayEarnings)} FC', l10n.navGains),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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

  Widget _buildStatusCard(AppColors colors, AppLocalizations l10n, String uid, DriverModel driver) {
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
                l10n.homeScreen_status,
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
                    driver.isAvailable ? l10n.homeScreen_availableStatus : l10n.homeScreen_offline,
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

  /// Gère les deux formats de photoUrl possibles : une chaîne base64
  /// (data:image/...;base64,...) écrite par uploadProfilePhoto, ou une
  /// vraie URL http/https si ce mode est utilisé un jour.
  ImageProvider? _buildProfileImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    if (photoUrl.startsWith('data:image')) {
      try {
        final base64Str = photoUrl.split(',').last;
        return MemoryImage(base64Decode(base64Str));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(photoUrl);
  }
}
