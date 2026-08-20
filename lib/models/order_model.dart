import 'package:cloud_firestore/cloud_firestore.dart';

/// Reflète orders/{id} — même collection que My-DavidSTORE et le dashboard
/// admin. Modèle simplifié pour les besoins de l'app livreur (pas tous les
/// champs, seulement ceux utiles au parcours de livraison).
class OrderItemModel {
  final String name;
  final int quantity;

  const OrderItemModel({required this.name, required this.quantity});

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      name: map['name']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final List<OrderItemModel> items;
  final Map<String, dynamic> deliveryAddress;
  final int total;
  final String paymentMethod;
  final String paymentStatus;
  final String? qrCode;
  final String? pin;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    this.orderNumber = '',
    this.status = 'pending',
    this.items = const [],
    this.deliveryAddress = const {},
    this.total = 0,
    this.paymentMethod = '',
    this.paymentStatus = '',
    this.qrCode,
    this.pin,
    this.createdAt,
  });

  String get clientName => deliveryAddress['name']?.toString() ?? '';
  String get clientPhone => deliveryAddress['phone']?.toString() ?? '';
  String get address => deliveryAddress['address']?.toString() ?? '';
  String get city => deliveryAddress['city']?.toString() ?? '';

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? {};
    return OrderModel(
      id: doc.id,
      orderNumber: map['orderNumber']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      items: (map['items'] as List?)
              ?.map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      deliveryAddress: (map['deliveryAddress'] as Map?)?.cast<String, dynamic>() ?? const {},
      total: (map['total'] as num?)?.toInt() ?? 0,
      paymentMethod: map['paymentMethod']?.toString() ?? '',
      paymentStatus: map['paymentStatus']?.toString() ?? '',
      qrCode: map['qrCode']?.toString(),
      pin: map['pin']?.toString(),
      createdAt: (map['createdAt'] is Timestamp) ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }
}
