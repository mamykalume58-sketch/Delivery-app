// Généré manuellement (flutterfire indisponible sans Dart local en Termux)
// à partir de android/app/google-services.json — projet Firebase davidstore-757d8,
// partagé avec My-DavidSTORE.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions non configuré pour le web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions non configuré pour cette plateforme.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyACjuaBKzSJESZv3lUTz-L7hjd9swC5f9E',
    appId: '1:27947559228:android:6262849591bd6827911639',
    messagingSenderId: '27947559228',
    projectId: 'davidstore-757d8',
    storageBucket: 'davidstore-757d8.firebasestorage.app',
  );
}
