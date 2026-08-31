import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../l10n/app_localizations.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _accepting = false;
  bool _accepted = false;

  ImageProvider? _decodeImage(String? data) {
    if (data == null || data.isEmpty) return null;
    if (data.startsWith('data:image')) {
      try {
        final base64Str = data.split(',').last;
        return MemoryImage(base64Decode(base64Str));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(data);
  }

  Future<void> _accept() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _accepting = true);
    try {
      await OrderService().acceptOrder(widget.order.id);
      if (mounted) setState(() => _accepted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.nouvelleLivraisonScreen_acceptError)),
        );
      }
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final order = widget.order;
    final alreadyAccepted = order.acceptedByDriver || _accepted;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(l10n.historiqueScreen_orderNumber(order.orderNumber), style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: colors.textGrey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(order.clientName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.primary))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 16, color: colors.textGrey),
                    const SizedBox(width: 8),
                    Text(order.clientPhone, style: TextStyle(fontSize: 13, color: colors.textGrey)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: colors.textGrey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${order.address}, ${order.city}',
                        style: TextStyle(fontSize: 13, color: colors.textGrey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.orderDetailScreen_products, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.primary)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              children: [
                for (int i = 0; i < order.items.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: colors.divider),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: colors.divider,
                            child: _decodeImage(order.items[i].image) != null
                                ? Image(image: _decodeImage(order.items[i].image)!, fit: BoxFit.cover)
                                : Icon(Icons.inventory_2_outlined, color: colors.textGrey, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.items[i].name,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.primary),
                              ),
                              if (order.items[i].color != null && order.items[i].color!.isNotEmpty)
                                Text(order.items[i].color!, style: TextStyle(fontSize: 12, color: colors.textGrey)),
                              Text('x${order.items[i].quantity}', style: TextStyle(fontSize: 12, color: colors.textGrey)),
                            ],
                          ),
                        ),
                        Text(
                          '${order.items[i].price * order.items[i].quantity} FC',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.orderDetailScreen_deliveryFee, style: TextStyle(fontSize: 13, color: colors.textGrey)),
                    Text('${order.fraisLivraison} FC', style: TextStyle(fontSize: 13, color: colors.primary)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.orderDetailScreen_total, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.primary)),
                    Text('${order.total} FC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!alreadyAccepted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _accepting ? null : _accept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.interface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _accepting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(l10n.nouvelleLivraisonScreen_accept, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(l10n.orderDetailScreen_alreadyAccepted, style: TextStyle(color: colors.success, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}
