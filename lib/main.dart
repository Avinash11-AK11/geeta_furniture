import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_links/app_links.dart';

import 'features/splash/splash_screen.dart';
import 'features/home/furniture_details_screen.dart';
import 'features/home/demo_products.dart';

import 'common/notification_manager.dart';
import 'common/local_notification_service.dart';
import 'common/fcm_listener.dart';

import 'core/router/app_router.dart';
import 'core/services/admin_session.dart';

/* ============================================================
   🌍 GLOBAL NAVIGATOR KEY
   ============================================================ */
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/* ============================================================
   🔕 BACKGROUND FCM HANDLER
   ============================================================ */
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

/* ============================================================
   🚀 MAIN
   ============================================================ */
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
  }

  await AdminSession.init();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await NotificationManager.instance.loadFromStorage();
  await LocalNotificationService.instance.init();
  await FCMListener.init(navigatorKey);

  runApp(const MyApp());
}

/* ============================================================
   🏠 ROOT APP
   ============================================================ */
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  /* ============================================================
     🔗 DEEP LINKS
     ============================================================ */
  void _initDeepLinks() {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (err) => debugPrint('❌ Deep link error: $err'),
    );
  }

  void _handleUri(Uri uri) {
    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'product') {
      final productId = uri.pathSegments[1];

      final product = demoProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => demoProducts.first,
      );

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => FurnitureDetailsScreen(item: product),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      /* ============================================================
         🎨 GEETA PLY & FURNITURE THEME (IMPORTANT)
         ============================================================ */
      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFFFDF8F4),

        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6B4E3D), // 🟤 Brand brown
          onPrimary: Colors.white,

          primaryContainer: Color(0xFFF1E8DE), // 🟤 Light beige
          onPrimaryContainer: Color(0xFF3E2C23),

          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF2E2E2E),

          background: Color(0xFFFDF8F4),
          onBackground: Color(0xFF2E2E2E),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDF8F4),
          foregroundColor: Color(0xFF2E2E2E),
          elevation: 0,
          centerTitle: false,
        ),

        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E),
          ),
          bodyMedium: TextStyle(color: Color(0xFF2E2E2E)),
        ),
      ),

      // ✅ Splash first
      home: const SplashScreen(),
    );
  }
}
