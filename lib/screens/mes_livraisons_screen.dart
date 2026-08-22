import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';
import 'en_cours_screen.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/tab_navigation.dart';

const Map<String, String> _statusLabels = {
  'preparing': 'En préparation',
  'shipped': 'Expédiée',
  'in_transit': 'En transit',
  'out_for_delivery': 'En livraison',
};

class MesLivraisonsScreen extends StatelessWidget {
  const MesLivraisonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final uid = AuthService().currentUser?.uid;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text('En cours', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: uid == null
          ? Center(child: Text('Session expirée.', style: TextStyle(color: colors.textGrey)))
          : StreamBuilder<List<OrderModel>>(
              stream: OrderService().watchInProgressOrders(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 56, color: colors.textGrey),
                          const SizedBox(height: 16),
                          Text(
                            "Aucune livraison en cours pour le moment.",
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
                                  Text('Commande #${order.orderNumber}', style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary, fontSize: 15)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: colors.interface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  _statusLabels[order.status] ?? order.status,
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => EnCoursScreen(order: order)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.interface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Voir les détails', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
