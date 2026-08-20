import 'package:cloud_firestore/cloud_firestore.dart';

/// Reflète drivers/{uid} — même collection lue par le dashboard admin.
class DriverModel {
  final String name;
  final String phone;
  final String? photo;
  final String status; // available | delivering | offline
  final String vehicle;
  final String plateNumber;
  final double rating;
  final int reviewCount;
  final int earnings;
  final String? currentOrderId;

  const DriverModel({
    required this.name,
    required this.phone,
    this.photo,
    required this.status,
    required this.vehicle,
    required this.plateNumber,
    required this.rating,
    required this.reviewCount,
    required this.earnings,
    this.currentOrderId,
  });

  bool get isAvailable => status == 'available';

  factory DriverModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DriverModel(
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      photo: data['photo'] as String?,
      status: data['status'] as String? ?? 'offline',
      vehicle: data['vehicle'] as String? ?? '',
      plateNumber: data['plateNumber'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      earnings: (data['earnings'] as num?)?.toInt() ?? 0,
      currentOrderId: data['currentOrderId'] as String?,
    );
  }
}
