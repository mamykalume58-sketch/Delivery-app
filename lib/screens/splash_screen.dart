import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Image.asset(
            'assets/images/splash_illustration.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Repli si l'image n'est pas encore présente
              return Icon(
                Icons.local_shipping_rounded,
                size: 96,
                color: colors.primary,
              );
            },
          ),
        ),
      ),
    );
  }
}
