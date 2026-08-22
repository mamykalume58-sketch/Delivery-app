import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'livraison_terminee_screen.dart';

class VerificationScreen extends StatefulWidget {
  final OrderModel order;
  final String verificationCode;

  const VerificationScreen({super.key, required this.order, required this.verificationCode});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _navigated = false;

  void _handleOrder(OrderModel order) {
    if (order.status == 'delivered' && !_navigated) {
      _navigated = true;
      OrderService().markDelivered(order.id);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LivraisonTermineeScreen(order: order)),
        );
      });
    }
  }

  Widget _buildPinDigit(String digit, AppColors colors) {
    return Container(
      width: 56,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.divider),
      ),
      child: Text(
        digit,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final digits = widget.verificationCode.split('');

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text('Vérification', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: StreamBuilder<OrderModel>(
        stream: OrderService().watchOrder(widget.order.id),
        initialData: widget.order,
        builder: (context, snapshot) {
          final order = snapshot.data ?? widget.order;
          _handleOrder(order);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Montrez le QR Code et demandez au client le PIN pour confirmer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: colors.textGrey),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.divider),
                  ),
                  child: Column(
                    children: [
                      Text('QR Code de la commande', style: TextStyle(fontSize: 13, color: colors.textGrey)),
                      const SizedBox(height: 16),
                      QrImageView(
                        data: order.id,
                        size: 180,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        order.orderNumber,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.divider),
                  ),
                  child: Column(
                    children: [
                      Text('PIN unique', style: TextStyle(fontSize: 13, color: colors.textGrey)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final digit in digits) ...[
                            _buildPinDigit(digit, colors),
                            const SizedBox(width: 10),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Le client doit vous donner ce PIN',
                        style: TextStyle(fontSize: 12, color: colors.textGrey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {},
                  child: Text('Aide / Problème', style: TextStyle(color: colors.interface)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
