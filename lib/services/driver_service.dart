import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Gère le document drivers/{uid} — même collection que le dashboard admin
/// utilise pour afficher les livreurs en temps réel. Statuts autorisés :
/// available | delivering | offline (rien d'autre).
class DriverService {
  final _drivers = FirebaseFirestore.instance.collection('drivers');
  final _storage = FirebaseStorage.instance;

  /// Crée le profil livreur juste après l'inscription Firebase Auth.
  Future<void> createDriverProfile({
    required String uid,
    required String name,
    required String phone,
    String? photoUrl,
  }) async {
    await _drivers.doc(uid).set({
      'name': name,
      'phone': phone,
      'photo': photoUrl,
      'status': 'offline',
      'vehicle': '',
      'plateNumber': '',
      'rating': 0,
      'earnings': 0,
      'reviewCount': 0,
      'currentOrderId': null,
      'location': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Upload la photo de profil vers Firebase Storage et retourne son URL.
  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage.ref().child('drivers/$uid/profile.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDriver(String uid) {
    return _drivers.doc(uid).snapshots();
  }

  Future<void> updateStatus(String uid, String status) async {
    await _drivers.doc(uid).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLocation(String uid, double lat, double lng) async {
    await _drivers.doc(uid).update({
      'location': GeoPoint(lat, lng),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
