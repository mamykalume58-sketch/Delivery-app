import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/tab_navigation.dart';

class NouvelleLivraisonScreen extends StatefulWidget {
  const NouvelleLivraisonScreen({super.key});

  @override
  State<NouvelleLivraisonScreen> createState() => _NouvelleLivraisonScreenState();
}

class _NouvelleLivraisonScreenState extends State<NouvelleLivraisonScreen> {
  final _orderService = OrderService();
  final Set<String> _acceptingIds = {};
  final Set<String> _acceptedIds = {};
  final Map<String, OrderModel> _pinnedOrders = {};

  Map<String, String> _statusLabels(AppLocalizations l10n) => {
        'preparing': l10n.mesLivraisonsScreen_statusPreparing,
        'shipped': l10n.mesLivraisonsScreen_statusShipped,
        'in_transit': l10n.mesLivraisonsScreen_statusInTransit,
        'out_for_delivery': l10n.mesLivraisonsScreen_statusOutForDelivery,
      };

  Future<void> _acceptOrder(OrderModel order) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _acceptingIds.add(order.id));
    try {
      await _orderService.acceptOrder(order.id);
      if (!mounted) return;
      setState(() {
        _acceptingIds.remove(order.id);
        _acceptedIds.add(order.id);
        _pinnedOrders[order.id] = order;
      });
      Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _acceptedIds.remove(order.id);
          _pinnedOrders.remove(order.id);
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _acceptingIds.remove(order.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nouvelleLivraisonScreen_acceptError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final statusLabels = _statusLabels(l10n);
    final uid = AuthService().currentUser?.uid;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(l10n.homeScreen_newDelivery, style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: uid == null
          ? Center(child: Text(l10n.historiqueScreen_sessionExpired, style: TextStyle(color: colors.textGrey)))
          : StreamBuilder<List<OrderModel>>(
              stream: _orderService.watchAssignedOrders(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final streamOrders = snapshot.data ?? [];
                final orders = <OrderModel>[
                  ..._pinnedOrders.values.where((o) => !streamOrders.any((s) => s.id == o.id)),
                  ...streamOrders,
                ];
                if (orders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 56, color: colors.textGrey),
                          const SizedBox(height: 16),
                          Text(
                            l10n.nouvelleLivraisonScreen_noOrders,
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
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final isAccepted = _acceptedIds.contains(order.id);
                    final isAccepting = _acceptingIds.contains(order.id);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.local_shipping_outlined, color: colors.interface, size: 18),
                                  const SizedBox(width: 8),
                                  Text(l10n.historiqueScreen_orderNumber(order.orderNumber), style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary, fontSize: 15)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: colors.interface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  statusLabels[order.status] ?? order.status,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.interface),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 15, color: colors.textGrey),
                              const SizedBox(width: 6),
                              Text(order.clientName, style: TextStyle(fontSize: 13, color: colors.primary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined, size: 15, color: colors.textGrey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${order.address}, ${order.city}',
                                  style: TextStyle(fontSize: 13, color: colors.textGrey),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (isAccepted || isAccepting) ? null : () => _acceptOrder(order),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isAccepted ? colors.success : colors.interface,
                                disabledBackgroundColor: isAccepted ? colors.success : colors.interface.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: isAccepting
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(
                                      isAccepted ? l10n.nouvelleLivraisonScreen_acceptedSuccess : l10n.nouvelleLivraisonScreen_accept,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        onTap: (index) => navigateToTab(context, index),
      ),
    );
  }
}
