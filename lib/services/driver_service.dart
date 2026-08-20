import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Gère le document livreurs/{uid} — MÊME collection Firestore que le
/// dashboard admin (davidstore-admin/src/services/livreurService.ts).
/// Statuts autorisés (alignés sur types/livreur.ts côté admin) :
/// disponible | en_livraison | hors_ligne (rien d'autre).
class DriverService {
  final _livreurs = FirebaseFirestore.instance.collection('livreurs');
  final _storage = FirebaseStorage.instance;

  /// Crée le profil livreur juste après l'inscription Firebase Auth.
  /// Utilise l'uid comme ID de document (contrairement à addLivreur côté
  /// admin qui génère un ID aléatoire) pour que le compte créé dans l'app
  /// soit le même livreur que celui vu par l'admin.
  Future<void> createDriverProfile({
    required String uid,
    required String name,
    required String phone,
    String? photoUrl,
  }) async {
    await _livreurs.doc(uid).set({
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl ?? '',
      'status': 'hors_ligne',
      'rating': 0,
      // Champs additionnels utiles à l'app, ignorés sans risque par le
      // typage TypeScript admin (extra fields), n'entrent pas en conflit
      // avec le schéma partagé.
      'vehicle': '',
      'plateNumber': '',
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
    final ref = _storage.ref().child('livreurs/$uid/profile.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDriver(String uid) {
    return _livreurs.doc(uid).snapshots();
  }

  /// status doit être 'disponible', 'en_livraison' ou 'hors_ligne'.
  Future<void> updateStatus(String uid, String status) async {
    await _livreurs.doc(uid).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLocation(String uid, double lat, double lng) async {
    await _livreurs.doc(uid).update({
      'location': GeoPoint(lat, lng),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
