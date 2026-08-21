import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/order_model.dart';
import 'home_screen.dart';

class LivraisonTermineeScreen extends StatelessWidget {
  final OrderModel order;

  const LivraisonTermineeScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: colors.success, size: 64),
              ),
              const SizedBox(height: 20),
              Text(
                'Livraison confirmée !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                'Merci pour votre excellent travail.',
                style: TextStyle(fontSize: 13, color: colors.textGrey),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.divider),
                ),
                child: Column(
                  children: [
                    _detailRow('Commande', '#${order.orderNumber}', colors),
                    const SizedBox(height: 10),
                    _detailRow('Client', order.clientName, colors),
                    const SizedBox(height: 10),
                    _detailRow('Montant', '${order.total} FC', colors),
                    const SizedBox(height: 10),
                    _detailRow('Paiement', order.paymentMethod, colors),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.interface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Terminer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: colors.textGrey)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.primary)),
      ],
    );
  }
}
