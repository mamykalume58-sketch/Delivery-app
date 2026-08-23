import 'package:cloud_firestore/cloud_firestore.dart';

/// Reflète livreurs/{uid} — même collection Firestore lue par le dashboard
/// admin (davidstore-admin/src/types/livreur.ts). Statuts autorisés :
/// disponible | en_livraison | hors_ligne.
class DriverModel {
  final String name;
  final String phone;
  final String? photoUrl;
  final String status;
  final String vehicle;
  final String plateNumber;
  final double rating;
  final int reviewCount;
  final int earnings;
  final String? currentOrderId;
  final String? idDocumentUrl;

  const DriverModel({
    required this.name,
    required this.phone,
    this.photoUrl,
    required this.status,
    required this.vehicle,
    required this.plateNumber,
    required this.rating,
    required this.reviewCount,
    required this.earnings,
    this.currentOrderId,
    this.idDocumentUrl,
  });

  bool get isAvailable => status == 'disponible';

  factory DriverModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DriverModel(
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      status: data['status'] as String? ?? 'hors_ligne',
      vehicle: data['vehicle'] as String? ?? '',
      plateNumber: data['plateNumber'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      earnings: (data['earnings'] as num?)?.toInt() ?? 0,
      currentOrderId: data['currentOrderId'] as String?,
      idDocumentUrl: data['idDocumentUrl'] as String?,
    );
  }
}
