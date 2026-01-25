import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'local_notification_service.dart';
import 'notification_manager.dart';
import '../features/home/furniture_details_screen.dart';
import '../features/home/demo_products.dart';
import '../features/notifications/notifications_screen.dart';

class FCMListener {
  FCMListener._();

  static Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    final messaging = FirebaseMessaging.instance;

    /* ================= FOREGROUND ================= */
    FirebaseMessaging.onMessage.listen((message) async {
      await _storeAndWait(message);
      await LocalNotificationService.instance.showFromFCM(message);
    });

    /* ================= BACKGROUND TAP ================= */
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      await _storeAndWait(message);
      _navigate(message, navigatorKey);
    });

    /* ================= TERMINATED ================= */
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      await _storeAndWait(initialMessage);
      _navigate(initialMessage, navigatorKey);
    }
  }

  /* ================= STORE (AWAITED) ================= */

  static Future<void> _storeAndWait(RemoteMessage message) async {
    final data = message.data;
    if (data.isEmpty) return;

    await NotificationManager.instance.add(
      title: data['title'] ?? 'Notification',
      body: data['body'] ?? '',
      data: data,
    );
  }

  /* ================= NAVIGATION ================= */

  static void _navigate(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    final data = message.data;

    if (data['type'] == 'product' && data['productId'] != null) {
      final product = demoProducts.firstWhere(
        (p) => p.id == data['productId'],
        orElse: () => demoProducts.first,
      );

      nav.push(
        MaterialPageRoute(
          builder: (_) => FurnitureDetailsScreen(item: product),
        ),
      );
    } else {
      nav.push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    }
  }
}
