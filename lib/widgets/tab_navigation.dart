import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/carte_screen.dart';
import '../screens/mes_gains_screen.dart';
import '../screens/profil_screen.dart';

/// Centralise la navigation entre les 4 onglets de BottomNav.
void navigateToTab(BuildContext context, int index) {
  Widget? target;
  switch (index) {
    case 0:
      target = const HomeScreen();
      break;
    case 1:
      target = const CarteScreen();
      break;
    case 2:
      target = const MesGainsScreen();
      break;
    case 3:
      target = const ProfilScreen();
      break;
  }
  if (target != null) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => target!),
      (route) => false,
    );
  }
}
