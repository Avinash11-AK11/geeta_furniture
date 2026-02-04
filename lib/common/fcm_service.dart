import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _tokenListenerAttached = false;
  bool _enabled = false;

  /* ============================================================
     INIT (CALL ONCE AFTER LOGIN)
     ============================================================ */

  Future<void> init() async {
    if (_tokenListenerAttached) return;
    _tokenListenerAttached = true;

    // iOS foreground notification presentation
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = _auth.currentUser;
      if (user == null) return;

      if (kDebugMode) {
        debugPrint('🔄 FCM TOKEN REFRESHED');
        debugPrint(newToken);
      }

      try {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmToken': newToken,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('❌ Failed to save refreshed token: $e');
      }
    });
  }

  /* ============================================================
     ENABLE NOTIFICATIONS
     ============================================================ */

  Future<void> enable() async {
    if (_enabled) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _enabled = true;

      // Request permission (non-web)
      if (!kIsWeb) {
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
          debugPrint('❌ Notification permission denied');
          _enabled = false;
          return;
        }
      }

      // Get token
      final token = await _messaging.getToken();
      if (token == null) {
        debugPrint('❌ Failed to get FCM token');
        _enabled = false;
        return;
      }

      if (kDebugMode) {
        debugPrint('🔥 FCM TOKEN 🔥');
        debugPrint(token);
      }

      // Save token to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'notificationsEnabled': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Optional topic (safe to keep)
      await _messaging.subscribeToTopic('all_users');

      // Init refresh listener
      await init();
    } catch (e) {
      _enabled = false;
      debugPrint('❌ Failed to enable notifications: $e');
    }
  }

  /* ============================================================
     DISABLE NOTIFICATIONS
     ============================================================ */

  Future<void> disable() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _enabled = false;

    try {
      await _messaging.unsubscribeFromTopic('all_users');
      await _messaging.deleteToken();

      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': FieldValue.delete(),
        'notificationsEnabled': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        debugPrint('🔕 Push notifications disabled');
      }
    } catch (e) {
      debugPrint('❌ Failed to disable notifications: $e');
    }
  }

  /* ============================================================
     DEBUG ONLY
     ============================================================ */

  /// Use for Firebase Console test messages
  Future<void> printTokenForDebug() async {
    final token = await _messaging.getToken();
    debugPrint('=========== FCM TOKEN ===========');
    debugPrint(token);
    debugPrint('================================');
  }
}
