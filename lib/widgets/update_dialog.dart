import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/update_download_service.dart';
import '../services/version_service.dart';

/// Affiche le bottom sheet de mise à jour (style Telegram) et gère le
/// téléchargement + installation directement depuis l'app.
Future<void> showUpdateDialog(
  BuildContext context, {
  required UpdateInfo info,
}) {
  return showModalBottomSheet(
    context: context,
    isDismissible: !info.forceUpdate,
    enableDrag: !info.forceUpdate,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _UpdateSheet(info: info),
  );
}

class _UpdateSheet extends StatefulWidget {
  final UpdateInfo info;
  const _UpdateSheet({required this.info});

  @override
  State<_UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<_UpdateSheet> {
  final _downloadService = UpdateDownloadService();
  bool _downloading = false;
  double _progress = 0;

  Future<void> _startDownload() async {
    setState(() => _downloading = true);
    try {
      final file = await _downloadService.downloadApk(
        widget.info.downloadUrl,
        onProgress: (p) => setState(() => _progress = p),
      );
      await _downloadService.installApk(file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du téléchargement : $e')),
      );
      setState(() => _downloading = false);
    }
  }

  String get _sizeLabel {
    final mb = widget.info.sizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      canPop: !widget.info.forceUpdate,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.interface.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.system_update_rounded,
                  color: colors.interface, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'Mettre à jour Delivery App',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 19, fontWeight: FontWeight.bold, color: colors.primary),
            ),
            const SizedBox(height: 6),
            Text(
              'Version ${widget.info.latestVersionName} • $_sizeLabel',
              style: TextStyle(fontSize: 13, color: colors.textGrey),
            ),
            const SizedBox(height: 16),
            Text(
              widget.info.message?.isNotEmpty == true
                  ? widget.info.message!
                  : 'Une nouvelle version de Delivery App est disponible. Vous pouvez la télécharger maintenant.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colors.textGrey, height: 1.4),
            ),
            const SizedBox(height: 24),
            if (_downloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 8,
                  backgroundColor: colors.divider,
                  color: colors.interface,
                ),
              ),
              const SizedBox(height: 8),
              Text('${(_progress * 100).toStringAsFixed(0)} %',
                  style: TextStyle(fontSize: 12, color: colors.textGrey)),
              const SizedBox(height: 16),
            ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.interface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Télécharger maintenant',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                ),
              ),
            if (!widget.info.forceUpdate && !_downloading) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Me le rappeler plus tard',
                    style: TextStyle(color: colors.interface)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
