import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/driver_service.dart';
import '../models/order_model.dart';
import 'arrive_client_screen.dart';

class EnCoursScreen extends StatefulWidget {
  final OrderModel order;

  const EnCoursScreen({super.key, required this.order});

  @override
  State<EnCoursScreen> createState() => _EnCoursScreenState();
}

class _EnCoursScreenState extends State<EnCoursScreen> {
  StreamSubscription<Position>? _positionSub;
  LatLng? _currentPosition;
  String? _error;
  bool _updatingStatus = false;
  bool _nearbyEmailSent = false;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _startTracking() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      setState(() => _error = 'Active la localisation du téléphone.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() => _error = 'Permission de localisation refusée.');
      return;
    }

    final uid = AuthService().currentUser?.uid;

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((position) {
      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _error = null;
      });
      if (uid != null) {
        DriverService().updateLocation(uid, position.latitude, position.longitude);
        _checkDriverNearby(position);
      }
    });
  }

  Future<void> _checkDriverNearby(Position position) async {
    if (_nearbyEmailSent) return;
    final lat = widget.order.deliveryLatitude;
    final lng = widget.order.deliveryLongitude;
    if (lat == null || lng == null) return;

    final distance = Geolocator.distanceBetween(
      position.latitude, position.longitude, lat, lng,
    );

    if (distance <= 500) {
      _nearbyEmailSent = true;
      try {
        await http.post(
          Uri.parse('https://davidstore-payment.vercel.app/api/orders/${widget.order.id}/notify-driver-nearby'),
        );
      } catch (_) {
        // Ne bloque jamais le suivi si l'email echoue
      }
    }
  }

  Future<void> _openInGoogleMaps() async {
    final query = Uri.encodeComponent('${widget.order.address}, ${widget.order.city}');
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$query');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir Google Maps.')),
        );
      }
    }
  }

  Future<void> _callClient() async {
    final url = Uri.parse('tel:${widget.order.clientPhone}');
    await launchUrl(url);
  }

  Future<void> _markArrived() async {
    setState(() => _updatingStatus = true);
    try {
      await OrderService().updateOrderStatus(widget.order.id, 'out_for_delivery');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ArriveClientScreen(order: widget.order)),
      );
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text('Commande #${widget.order.orderNumber}', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _currentPosition == null
                ? Center(
                    child: _error != null
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: colors.error)),
                          )
                        : const CircularProgressIndicator(),
                  )
                : FlutterMap(
                    options: MapOptions(initialCenter: _currentPosition!, initialZoom: 15),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                        userAgentPackageName: 'com.davidstore.davidstore_livreur',
                      ),
                      if (widget.order.deliveryLatitude != null && widget.order.deliveryLongitude != null)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [
                                _currentPosition!,
                                LatLng(widget.order.deliveryLatitude!, widget.order.deliveryLongitude!),
                              ],
                              strokeWidth: 4,
                              color: colors.interface,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentPosition!,
                            width: 40,
                            height: 40,
                            child: Icon(Icons.motorcycle, color: colors.interface, size: 32),
                          ),
                          if (widget.order.deliveryLatitude != null && widget.order.deliveryLongitude != null)
                            Marker(
                              point: LatLng(widget.order.deliveryLatitude!, widget.order.deliveryLongitude!),
                              width: 40,
                              height: 40,
                              child: Icon(Icons.location_on, color: colors.error, size: 36),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: colors.textGrey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(widget.order.clientName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.primary))),
                        IconButton(
                          onPressed: _callClient,
                          icon: Icon(Icons.phone, color: colors.success),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: colors.textGrey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.order.address}, ${widget.order.city}',
                            style: TextStyle(fontSize: 13, color: colors.textGrey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openInGoogleMaps,
                        icon: Icon(Icons.map_outlined, color: colors.interface),
                        label: Text('Ouvrir dans Google Maps', style: TextStyle(color: colors.interface)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.interface),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updatingStatus ? null : _markArrived,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.success,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _updatingStatus
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("J'y suis arrivé", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
