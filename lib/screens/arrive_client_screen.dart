import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../l10n/app_localizations.dart';
import 'verification_screen.dart';

class ArriveClientScreen extends StatefulWidget {
  final OrderModel order;

  const ArriveClientScreen({super.key, required this.order});

  @override
  State<ArriveClientScreen> createState() => _ArriveClientScreenState();
}

class _ArriveClientScreenState extends State<ArriveClientScreen> {
  bool _loading = false;

  Future<void> _callClient() async {
    final url = Uri.parse('tel:${widget.order.clientPhone}');
    await launchUrl(url);
  }

  Future<void> _verifierCommande() async {
    setState(() => _loading = true);
    try {
      var code = widget.order.verificationCode;
      if (code == null || code.isEmpty) {
        code = (1000 + Random().nextInt(9000)).toString();
        await OrderService().setVerificationCode(widget.order.id, code);
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(order: widget.order, verificationCode: code!),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final order = widget.order;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          l10n.historiqueScreen_orderNumber(order.orderNumber),
          style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: colors.success, size: 44),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                l10n.arriveClientScreen_youArrived,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                l10n.arriveClientScreen_verifyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: colors.textGrey),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.livraisonTermineeScreen_client, style: TextStyle(fontSize: 12, color: colors.textGrey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.clientName,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.primary),
                        ),
                      ),
                      IconButton(
                        onPressed: _callClient,
                        icon: Icon(Icons.phone, color: colors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.arriveClientScreen_address, style: TextStyle(fontSize: 12, color: colors.textGrey)),
                  const SizedBox(height: 4),
                  Text(
                    '${order.address}, ${order.city}',
                    style: TextStyle(fontSize: 14, color: colors.primary),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verifierCommande,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.interface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        l10n.arriveClientScreen_verifyOrder,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
