import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../models/driver_model.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _uploading = false;

  Future<void> _pickAndUpload(ImageSource source) async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final url = await DriverService().uploadIdDocument(uid, File(picked.path));
      await DriverService().updateIdDocument(uid, url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'envoi du document. Réessaie.")),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showSourcePicker(AppColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: colors.interface),
              title: Text('Prendre une photo', style: TextStyle(color: colors.primary)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: colors.interface),
              title: Text('Choisir depuis la galerie', style: TextStyle(color: colors.primary)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _buildDocumentImage(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:image')) {
      try {
        final base64Str = url.split(',').last;
        return MemoryImage(base64Decode(base64Str));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final uid = AuthService().currentUser?.uid;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text('Documents', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: uid == null
          ? Center(child: Text('Session expirée.', style: TextStyle(color: colors.textGrey)))
          : StreamBuilder<DriverModel>(
              stream: DriverService().watchDriver(uid).map(DriverModel.fromDoc),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final driver = snapshot.data!;
                final image = _buildDocumentImage(driver.idDocumentUrl);

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pièce d'identité",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Une photo claire et lisible de votre pièce d'identité.",
                        style: TextStyle(fontSize: 13, color: colors.textGrey),
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1.6,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.divider),
                            image: image != null ? DecorationImage(image: image, fit: BoxFit.cover) : null,
                          ),
                          child: image == null
                              ? Center(
                                  child: Icon(Icons.badge_outlined, size: 48, color: colors.textGrey),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _uploading ? null : () => _showSourcePicker(colors),
                          icon: _uploading
                              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colors.interface))
                              : Icon(Icons.upload_outlined, color: colors.interface),
                          label: Text(
                            image == null ? 'Ajouter le document' : 'Remplacer le document',
                            style: TextStyle(color: colors.interface),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.interface),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
