import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

/// Gère la collection notifications/ — créée par le dashboard admin,
/// consultée et gérée (suppression) par le livreur concerné.
class NotificationService {
  final _notifications = FirebaseFirestore.instance.collection('notifications');

  /// Notifications d'un livreur, les plus récentes en premier.
  Stream<List<NotificationModel>> watchNotifications(String driverId) {
    return _notifications
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(NotificationModel.fromDoc).toList());
  }

  Future<void> deleteNotification(String id) async {
    await _notifications.doc(id).delete();
  }

  /// Supprime toutes les notifications d'un livreur (suppression en masse).
  Future<void> deleteAll(String driverId) async {
    final snapshot = await _notifications.where('driverId', isEqualTo: driverId).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
