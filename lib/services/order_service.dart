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
        .where('acceptedByDriver', isEqualTo: false)
        .where('status', whereIn: [
          'preparing', 'shipped', 'in_transit', 'out_for_delivery',
        ])
        .snapshots()
        .map((snapshot) => snapshot.docs.map(OrderModel.fromDoc).toList());
  }

  /// Marque la commande comme acceptée par ce livreur (bouton "Accepter"
  /// sur l'écran Nouvelle livraison). Ne change pas le statut de la
  /// commande, seulement ce flag.
  Future<void> acceptOrder(String orderId) async {
    await _orders.doc(orderId).update({'acceptedByDriver': true});
  }

  /// Commandes acceptées par ce livreur, pas encore livrées ni annulées.
  Stream<List<OrderModel>> watchInProgressOrders(String driverId) {
    return _orders
        .where('driverId', isEqualTo: driverId)
        .where('acceptedByDriver', isEqualTo: true)
        .where('status', whereIn: [
          'preparing', 'shipped', 'in_transit', 'out_for_delivery',
        ])
        .snapshots()
        .map((snapshot) => snapshot.docs.map(OrderModel.fromDoc).toList());
  }

  /// Marque la commande comme livrée avec la date/heure réelle de livraison
  /// (utilisé pour la fenêtre de 4 jours de l'Historique). Le statut
  /// 'delivered' lui-même est déjà écrit côté client (My-DavidSTORE) au
  /// moment de la validation PIN/QR ; ceci ajoute seulement deliveredAt.
  Future<void> markDelivered(String orderId) async {
    await _orders.doc(orderId).update({'deliveredAt': FieldValue.serverTimestamp()});
  }

  /// Historique : commandes livrées avec succès dans les 4 derniers jours
  /// (basé sur deliveredAt, pas createdAt).
  Stream<List<OrderModel>> watchOrderHistory(String driverId) {
    final cutoff = DateTime.now().subtract(const Duration(days: 4));
    return _orders
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'delivered')
        .where('deliveredAt', isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy('deliveredAt', descending: true)
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

  /// Récupération ponctuelle (pas de stream) — utilisée pour la navigation
  /// au tap sur une notification push (voir main.dart _handleNotificationTap).
  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromDoc(doc);
  }
}
