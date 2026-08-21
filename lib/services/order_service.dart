import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

/// Interroge la collection orders/ partagée avec My-DavidSTORE et le
/// dashboard admin, filtrée par driverId pour ne montrer que les commandes
/// assignées à ce livreur précis.
class OrderService {
  final _orders = FirebaseFirestore.instance.collection('orders');

  /// Commandes assignées à ce livreur, pas encore livrées ni annulées.
  Stream<List<OrderModel>> watchAssignedOrders(String driverId) {
    return _orders
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: [
          'preparing', 'shipped', 'in_transit', 'out_for_delivery',
        ])
        .snapshots()
        .map((snapshot) => snapshot.docs.map(OrderModel.fromDoc).toList());
  }

  /// Historique complet (toutes les commandes déjà assignées à ce livreur,
  /// y compris livrées et annulées).
  Stream<List<OrderModel>> watchOrderHistory(String driverId) {
    return _orders
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(OrderModel.fromDoc).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orders.doc(orderId).update({'status': status});
  }

  /// Écrit le code de vérification (PIN 4 chiffres) sur la commande, si pas
  /// déjà présent. Utilisé pour l'écran Vérification (QR + PIN).
  Future<void> setVerificationCode(String orderId, String code) async {
    await _orders.doc(orderId).update({'verificationCode': code});
  }

  /// Écoute une commande précise en temps réel (utilisé par l'écran
  /// Vérification pour détecter le passage à 'delivered').
  Stream<OrderModel> watchOrder(String orderId) {
    return _orders.doc(orderId).snapshots().map(OrderModel.fromDoc);
  }
}
