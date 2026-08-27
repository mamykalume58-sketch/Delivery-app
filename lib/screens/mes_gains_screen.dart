import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/order_model.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/tab_navigation.dart';

class MesGainsScreen extends StatefulWidget {
  const MesGainsScreen({super.key});

  @override
  State<MesGainsScreen> createState() => _MesGainsScreenState();
}

class _MesGainsScreenState extends State<MesGainsScreen> {
  Stream<List<OrderModel>>? _historyStream;

  @override
  void initState() {
    super.initState();
    final uid = AuthService().currentUser?.uid;
    if (uid != null) {
      _historyStream = OrderService().watchOrderHistory(uid);
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
        title: Text('Mes gains', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: uid == null || _historyStream == null
          ? Center(child: Text('Non connecté', style: TextStyle(color: colors.textGrey)))
          : StreamBuilder<List<OrderModel>>(
              stream: _historyStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Erreur: ${snapshot.error}',
                        style: TextStyle(color: colors.error, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final delivered = snapshot.data!.where((o) => o.status == 'delivered').toList();

                final now = DateTime.now();
                final todayOrders = delivered.where((o) {
                  final d = o.createdAt;
                  return d != null && d.year == now.year && d.month == now.month && d.day == now.day;
                }).toList();
                final todayGains = todayOrders.fold<int>(0, (sum, o) => sum + o.fraisLivraison);

                final Map<String, int> gainsByDay = {};
                for (final o in delivered) {
                  final d = o.createdAt;
                  if (d == null) continue;
                  final key = DateFormat('dd MMMM yyyy', 'fr_FR').format(d);
                  gainsByDay[key] = (gainsByDay[key] ?? 0) + o.fraisLivraison;
                }
                final sortedDays = gainsByDay.keys.toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.interface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gains du jour', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(
                            '$todayGains FC',
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${todayOrders.length} livraison${todayOrders.length > 1 ? 's' : ''}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Historique des gains', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.primary)),
                    const SizedBox(height: 10),
                    if (sortedDays.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text('Aucune livraison terminée pour le moment.', style: TextStyle(color: colors.textGrey))),
                      )
                    else
                      ...sortedDays.map((day) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(day, style: TextStyle(fontSize: 13, color: colors.primary)),
                              Text(
                                '${gainsByDay[day]} FC',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.success),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                );
              },
            ),
      bottomNavigationBar: BottomNav(
        currentIndex: 2,
        onTap: (index) => navigateToTab(context, index),
      ),
    );
  }
}
