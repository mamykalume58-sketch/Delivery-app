import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';

/// Gère le document livreurs/{uid} — MÊME collection Firestore que le
/// dashboard admin (davidstore-admin/src/services/livreurService.ts).
/// Statuts autorisés (alignés sur types/livreur.ts côté admin) :
/// disponible | en_livraison | hors_ligne (rien d'autre).
class DriverService {
  final _livreurs = FirebaseFirestore.instance.collection('livreurs');

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

  /// Convertit la photo de profil en base64 et la retourne directement.
  /// Firebase Storage n'est pas disponible sur le plan Spark (Blaze requis).
  /// Même contournement que My-DavidSTORE : stockage base64 dans le document
  /// Firestore lui-même plutôt que dans Storage. La photo est compressée et
  /// redimensionnée en amont (voir register_screen.dart, maxWidth/maxHeight)
  /// pour rester largement sous la limite de 1 Mo par document Firestore.
  Future<String> uploadProfilePhoto(String uid, File file) async {
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64Str';
  }

  /// Convertit la pièce d'identité en base64, comme uploadProfilePhoto.
  Future<String> uploadIdDocument(String uid, File file) async {
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64Str';
  }

  /// Écrit l'URL (base64) de la pièce d'identité sur le document livreur.
  Future<void> updateIdDocument(String uid, String idDocumentUrl) async {
    await _livreurs.doc(uid).update({
      'idDocumentUrl': idDocumentUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Met à jour les informations modifiables du profil (nom, téléphone,
  /// véhicule, plaque) et éventuellement la photo (déjà en base64 via
  /// uploadProfilePhoto si changée).
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
    required String vehicle,
    required String plateNumber,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'phone': phone,
      'vehicle': vehicle,
      'plateNumber': plateNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (photoUrl != null) {
      data['photoUrl'] = photoUrl;
    }
    await _livreurs.doc(uid).update(data);
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

  /// Écoute tous les livreurs actifs (disponible ou en_livraison) ayant une
  /// position GPS connue — utilisé par l'écran Carte pour afficher tous les
  /// livreurs sur une carte commune.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> watchActiveDrivers() {
    return _livreurs
        .where('status', whereIn: ['disponible', 'en_livraison'])
        .snapshots()
        .map((snapshot) => snapshot.docs.where((doc) => doc.data()['location'] != null).toList());
  }

  /// Enregistre/actualise le token FCM du livreur pour l'envoi de
  /// notifications push (voir server/index.js: sendPushToDriver).
  Future<void> updateFcmToken(String uid, String token) async {
    await _livreurs.doc(uid).update({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
