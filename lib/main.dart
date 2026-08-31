import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/theme_service.dart';
import 'services/locale_service.dart';
import 'services/order_service.dart';
import 'screens/splash_screen.dart';
import 'screens/order_detail_screen.dart';
import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'davidstore_livreur_channel',
  'Notifications Livreur DavidSTORE',
  description: 'Notifications d\'assignation de commandes',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> _handleNotificationTap(RemoteMessage message) async {
  final orderId = message.data['orderId'];
  if (orderId == null) return;
  final order = await OrderService().getOrder(orderId);
  if (order != null) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
    );
  }
}

/// Quand le mode est "Système", on ne se fie pas au réglage Android (peu
/// fiable sur certains téléphones avec programmation horaire), mais on
/// calcule nous-mêmes le thème selon l'heure locale : 6h-18h = clair,
/// le reste = sombre.
ThemeMode _effectiveThemeMode(ThemeMode mode) {
  if (mode != ThemeMode.system) return mode;
  final hour = DateTime.now().hour;
  return (hour >= 6 && hour < 18) ? ThemeMode.light : ThemeMode.dark;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('fr_FR');
  await ThemeService.load();
  await LocaleService.load();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await _localNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationTap(initialMessage);
    });
  }

  runApp(const DavidStoreDriverApp());
}

class DavidStoreDriverApp extends StatefulWidget {
  const DavidStoreDriverApp({super.key});

  @override
  State<DavidStoreDriverApp> createState() => _DavidStoreDriverAppState();
}

class _DavidStoreDriverAppState extends State<DavidStoreDriverApp> {
  Timer? _dayNightTimer;

  @override
  void initState() {
    super.initState();
    // Revérifie toutes les minutes si l'heure a basculé jour/nuit, pour que
    // le mode "Système" change automatiquement sans redémarrer l'app.
    _dayNightTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _dayNightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.mode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LocaleService.locale,
          builder: (context, locale, _) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Delivery App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: _effectiveThemeMode(themeMode),
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
