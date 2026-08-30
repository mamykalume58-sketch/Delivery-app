import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

/// Télécharge l'APK depuis downloadUrl (asset public d'une GitHub Release)
/// et déclenche l'installation via l'intent système Android.
class UpdateDownloadService {
  static const int _maxAttempts = 3;

  /// Télécharge le fichier en écrivant directement sur disque (pas de
  /// buffer mémoire complet, important pour un APK de ~60 Mo sur réseau
  /// mobile instable). Retente jusqu'à _maxAttempts fois en cas de coupure
  /// réseau avant d'abandonner. Vérifie le status HTTP et l'intégrité
  /// (taille reçue vs attendue) avant de retourner le fichier.
  Future<File> downloadApk(
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    Object? lastError;

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      final client = http.Client();
      IOSink? sink;
      File? file;
      try {
        final request = http.Request('GET', Uri.parse(url));
        final response = await client.send(request);

        if (response.statusCode != 200) {
          throw Exception('Téléchargement échoué (HTTP ${response.statusCode})');
        }

        final total = response.contentLength ?? 0;
        var received = 0;

        final dir = await getApplicationDocumentsDirectory();
        file = File('${dir.path}/delivery_app_update.apk');
        sink = file.openWrite();

        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) onProgress?.call(received / total);
        }
        await sink.flush();
        await sink.close();
        sink = null;

        if (total > 0 && received != total) {
          throw Exception('Fichier incomplet ($received/$total octets)');
        }

        return file;
      } catch (e) {
        lastError = e;
        try {
          await sink?.close();
        } catch (_) {}
        try {
          if (file != null && await file.exists()) await file.delete();
        } catch (_) {}
        if (attempt < _maxAttempts) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } finally {
        client.close();
      }
    }

    throw Exception('Échec après $_maxAttempts tentatives : $lastError');
  }

  /// Demande la permission d'installer des sources inconnues si besoin,
  /// puis ouvre l'APK téléchargé pour déclencher l'installation système.
  Future<void> installApk(File apkFile) async {
    final status = await Permission.requestInstallPackages.status;
    if (!status.isGranted) {
      await Permission.requestInstallPackages.request();
    }
    await OpenFilex.open(apkFile.path);
  }
}
