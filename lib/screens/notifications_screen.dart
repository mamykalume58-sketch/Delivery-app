import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/order_service.dart';
import '../models/notification_model.dart';
import 'order_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();
  Stream<List<NotificationModel>>? _notificationsStream;
  bool _openingOrder = false;

  @override
  void initState() {
    super.initState();
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
      _notificationsStream = _notificationService.watchNotifications(uid);
    }
  }

  Future<void> _confirmDeleteAll(String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tout supprimer ?'),
        content: const Text('Toutes tes notifications seront définitivement supprimées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _notificationService.deleteAll(uid);
    }
  }

  Future<void> _openOrder(NotificationModel notif) async {
    if (_openingOrder) return;
    setState(() => _openingOrder = true);
    try {
      final order = await OrderService().watchOrder(notif.orderId).first;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir cette commande.")),
        );
      }
    } finally {
      if (mounted) setState(() => _openingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final uid = AuthService().currentUser?.uid;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text('Notifications', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
        actions: [
          if (uid != null)
            TextButton(
              onPressed: () => _confirmDeleteAll(uid),
              child: Text('Tout supprimer', style: TextStyle(color: colors.error, fontSize: 13)),
            ),
        ],
      ),
      body: uid == null || _notificationsStream == null
          ? Center(child: Text('Session expirée.', style: TextStyle(color: colors.textGrey)))
          : StreamBuilder<List<NotificationModel>>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notifications = snapshot.data!;
                if (notifications.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none_rounded, size: 56, color: colors.textGrey),
                          const SizedBox(height: 16),
                          Text(
                            "Aucune notification pour le moment.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.textGrey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return Dismissible(
                      key: ValueKey(notif.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: colors.error,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      onDismissed: (_) => _notificationService.deleteNotification(notif.id),
                      child: InkWell(
                        onTap: () => _openOrder(notif),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.divider),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colors.interface.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.local_shipping_outlined, color: colors.interface, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notif.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.primary)),
                                    const SizedBox(height: 2),
                                    Text(notif.body, style: TextStyle(fontSize: 12, color: colors.textGrey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
