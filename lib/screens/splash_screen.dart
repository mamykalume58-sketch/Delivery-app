import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildLogo(colors),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildIllustration(colors),
                      const SizedBox(height: 24),
                      _buildSlogan(colors),
                      const SizedBox(height: 12),
                      _buildSubtext(colors),
                      const SizedBox(height: 28),
                      _buildBenefit(
                        colors: colors,
                        icon: Icons.location_on_rounded,
                        title: 'Livraison en temps réel',
                        subtitle:
                            'Recevez et gérez vos livraisons facilement.',
                      ),
                      const SizedBox(height: 16),
                      _buildBenefit(
                        colors: colors,
                        icon: Icons.map_rounded,
                        title: 'Navigation GPS intégrée',
                        subtitle: "Trouvez l'itinéraire le plus rapide.",
                      ),
                      const SizedBox(height: 16),
                      _buildBenefit(
                        colors: colors,
                        icon: Icons.shield_rounded,
                        title: 'Sécurisé & fiable',
                        subtitle:
                            'Livraison confirmée avec QR Code et PIN unique.',
                      ),
                    ],
                  ),
                ),
              ),
              _buildStartButton(context, colors),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(AppColors colors) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.gold,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.local_shipping_rounded,
            color: colors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DavidSTORE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
            Text(
              'Application Livreur',
              style: TextStyle(fontSize: 12, color: colors.textGrey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIllustration(AppColors colors) {
    // Image fournie par l'utilisateur : assets/images/splash_illustration.png
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        'assets/images/splash_illustration.png',
        height: 220,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Repli si l'image n'est pas encore présente
          return Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.two_wheeler_rounded,
              size: 72,
              color: colors.interface,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlogan(AppColors colors) {
    return Text(
      'Livrez plus.\nGagnez plus.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: colors.primary,
        height: 1.2,
      ),
    );
  }

  Widget _buildSubtext(AppColors colors) {
    return Text(
      'Votre outil professionnel pour gérer vos livraisons rapidement et efficacement.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14, color: colors.textGrey, height: 1.4),
    );
  }

  Widget _buildBenefit({
    required AppColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.interface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colors.interface, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  color: colors.textGrey,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context, AppColors colors) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
        child: const Text(
          'Commencer',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
