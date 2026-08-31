import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../models/driver_model.dart';
import '../l10n/app_localizations.dart';

class ModifierProfilScreen extends StatefulWidget {
  final DriverModel driver;

  const ModifierProfilScreen({super.key, required this.driver});

  @override
  State<ModifierProfilScreen> createState() => _ModifierProfilScreenState();
}

class _ModifierProfilScreenState extends State<ModifierProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _vehicleController;
  late final TextEditingController _plateController;

  File? _pickedPhoto;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver.name);
    _phoneController = TextEditingController(text: widget.driver.phone);
    _vehicleController = TextEditingController(text: widget.driver.vehicle);
    _plateController = TextEditingController(text: widget.driver.plateNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) {
      setState(() => _pickedPhoto = File(picked.path));
    }
  }

  ImageProvider? _currentAvatar() {
    if (_pickedPhoto != null) return FileImage(_pickedPhoto!);
    final url = widget.driver.photoUrl;
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _saving = true);
    try {
      String? photoUrl;
      if (_pickedPhoto != null) {
        photoUrl = await DriverService().uploadProfilePhoto(uid, _pickedPhoto!);
      }
      await DriverService().updateProfile(
        uid: uid,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        vehicle: _vehicleController.text.trim(),
        plateNumber: _plateController.text.trim(),
        photoUrl: photoUrl,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.modifierProfilScreen_saveError)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final avatar = _currentAvatar();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(l10n.modifierProfilScreen_title, style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: colors.divider,
                      backgroundImage: avatar,
                      child: avatar == null ? Icon(Icons.person, size: 48, color: colors.textGrey) : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.interface,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.surface, width: 2),
                        ),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(l10n.modifierProfilScreen_name, style: TextStyle(fontSize: 13, color: colors.textGrey)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.modifierProfilScreen_nameRequired : null,
            ),
            const SizedBox(height: 16),
            Text(l10n.profilScreen_phone, style: TextStyle(fontSize: 13, color: colors.textGrey)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.modifierProfilScreen_phoneRequired : null,
            ),
            const SizedBox(height: 16),
            Text(l10n.profilScreen_vehicle, style: TextStyle(fontSize: 13, color: colors.textGrey)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _vehicleController,
              decoration: InputDecoration(border: const OutlineInputBorder(), hintText: l10n.modifierProfilScreen_vehicleHint),
            ),
            const SizedBox(height: 16),
            Text(l10n.profilScreen_plate, style: TextStyle(fontSize: 13, color: colors.textGrey)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _plateController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.interface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(l10n.modifierProfilScreen_save, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
