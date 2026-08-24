import 'package:cloud_firestore/cloud_firestore.dart';

/// Reflète notifications/{id} — créées par le dashboard admin lors de
/// l'assignation d'une commande à un livreur.
class NotificationModel {
  final String id;
  final String driverId;
  final String orderId;
  final String orderNumber;
  final String title;
  final String body;
  final bool read;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.driverId,
    required this.orderId,
    this.orderNumber = '',
    this.title = '',
    this.body = '',
    this.read = false,
    this.createdAt,
  });

  factory NotificationModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? {};
    return NotificationModel(
      id: doc.id,
      driverId: map['driverId']?.toString() ?? '',
      orderId: map['orderId']?.toString() ?? '',
      orderNumber: map['orderNumber']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      read: map['read'] == true,
      createdAt: (map['createdAt'] is Timestamp) ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }
}
