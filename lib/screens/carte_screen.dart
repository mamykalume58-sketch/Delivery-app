import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../services/driver_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/tab_navigation.dart';

class CarteScreen extends StatelessWidget {
  const CarteScreen({super.key});

  static const LatLng _defaultCenter = LatLng(-11.6609, 27.4794);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text('Carte des livreurs', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: DriverService().watchActiveDrivers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final drivers = snapshot.data!;
          final markers = <Marker>[];

          for (final doc in drivers) {
            final data = doc.data();
            final geo = data['location'] as GeoPoint?;
            if (geo == null) continue;
            final name = data['name']?.toString() ?? 'Livreur';

            markers.add(
              Marker(
                point: LatLng(geo.latitude, geo.longitude),
                width: 90,
                height: 50,
                child: Column(
                  children: [
                    Icon(Icons.motorcycle, color: colors.interface, size: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.divider),
                      ),
                      child: Text(
                        name,
                        style: TextStyle(fontSize: 10, color: colors.primary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final center = markers.isNotEmpty ? markers.first.point : _defaultCenter;

          return FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.davidstore.davidstore_livreur',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        onTap: (index) => navigateToTab(context, index),
      ),
    );
  }
}
