import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /* ============================================================
     🔔 ANDROID CHANNEL
     ============================================================ */
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDesc = 'Used for important notifications';

  /* ============================================================
     🔔 INITIALIZE
     ============================================================ */
  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // ✅ ANDROID CHANNEL
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /* ============================================================
     🔔 SHOW FROM FCM (DATA-ONLY)
     ============================================================ */
  Future<void> showFromFCM(RemoteMessage message) async {
    final data = message.data;
    if (data.isEmpty) return;

    final title = data['title'] ?? 'Notification';
    final body = data['body'] ?? '';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: jsonEncode(data),
    );
  }

  /* ============================================================
     📲 TAP HANDLER
     ============================================================ */
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;

    try {
      final Map<String, dynamic> data =
          jsonDecode(response.payload!) as Map<String, dynamic>;

      debugPrint('🔔 Notification tapped: $data');

      // ❗ DO NOT NAVIGATE HERE
      // Navigation is handled by FCMListener
    } catch (e) {
      debugPrint('❌ Invalid notification payload');
    }
  }
}
