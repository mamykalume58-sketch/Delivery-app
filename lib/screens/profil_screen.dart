import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/driver_model.dart';
import '../services/auth_service.dart';
import '../services/driver_service.dart';
import '../widgets/bottom_nav.dart';
import 'auth/login_screen.dart';
import 'dart:convert';
import 'dart:typed_data';

Uint8List _decodeBase64Image(String data) {
  final cleaned = data.contains(',') ? data.split(',').last : data;
  return base64Decode(cleaned);
}

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Vous devrez vous reconnecter pour accéder à votre compte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _infoRow(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: colors.textGrey)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.primary)),
        ],
      ),
    );
  }

  Widget _menuLink(BuildContext context, IconData icon, String label, AppColors colors, {Color? color}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? colors.textGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, color: color ?? colors.primary)),
            ),
            Icon(Icons.chevron_right, size: 18, color: colors.textGrey),
          ],
        ),
      ),
    );
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
        title: Text('Profil', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: uid == null
          ? Center(child: Text('Non connecté', style: TextStyle(color: colors.textGrey)))
          : StreamBuilder<DriverModel>(
              stream: DriverService().watchDriver(uid).map(DriverModel.fromDoc),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final driver = snapshot.data!;
                final isOnline = driver.status != 'hors_ligne';

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: colors.divider,
                        backgroundImage: (driver.photoUrl != null && driver.photoUrl!.isNotEmpty)
                            ? MemoryImage(_decodeBase64Image(driver.photoUrl!))
                            : null,
                        child: (driver.photoUrl == null || driver.photoUrl!.isEmpty)
                            ? Icon(Icons.person, size: 44, color: colors.textGrey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        driver.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOnline ? Icons.circle : Icons.circle_outlined,
                            size: 8,
                            color: isOnline ? colors.success : colors.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnline ? 'En ligne' : 'Hors ligne',
                            style: TextStyle(fontSize: 12, color: colors.textGrey),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.star, size: 14, color: colors.gold),
                          const SizedBox(width: 2),
                          Text(
                            '${driver.rating.toStringAsFixed(1)} (${driver.reviewCount})',
                            style: TextStyle(fontSize: 12, color: colors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.divider),
                      ),
                      child: Column(
                        children: [
                          Text('Informations', style: TextStyle(fontSize: 12, color: colors.textGrey)),
                          const Divider(height: 20),
                          _infoRow('Téléphone', driver.phone, colors),
                          _infoRow('Véhicule', driver.vehicle.isEmpty ? '—' : driver.vehicle, colors),
                          _infoRow('Plaque', driver.plateNumber.isEmpty ? '—' : driver.plateNumber, colors),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.divider),
                      ),
                      child: Column(
                        children: [
                          _menuLink(context, Icons.description_outlined, 'Documents', colors),
                          Divider(height: 1, color: colors.divider),
                          _menuLink(context, Icons.settings_outlined, 'Paramètres', colors),
                          Divider(height: 1, color: colors.divider),
                          _menuLink(context, Icons.help_outline, 'Aide & Support', colors),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.divider),
                      ),
                      child: InkWell(
                        onTap: () => _confirmSignOut(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.logout, size: 20, color: Colors.red),
                              const SizedBox(width: 12),
                              const Text('Déconnexion', style: TextStyle(fontSize: 14, color: Colors.red)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: BottomNav(
        currentIndex: 4,
        onTap: (index) {
          // Navigation entre onglets à brancher plus tard
        },
      ),
    );
  }
}
