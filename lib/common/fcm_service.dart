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

    // Token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = _auth.currentUser;
      if (user == null) return;

      debugPrint('🔄 FCM TOKEN REFRESHED');
      debugPrint(newToken);

      try {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmToken': newToken,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('❌ Failed to update refreshed token: $e');
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

    _enabled = true;

    try {
      // Web does not support permissions this way
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
        debugPrint('🔥🔥🔥 FCM TOKEN START 🔥🔥🔥');
        debugPrint(token);
        debugPrint('🔥🔥🔥 FCM TOKEN END 🔥🔥🔥');
      }

      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'notificationsEnabled': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Subscribe to global topic
      await _messaging.subscribeToTopic('all_users');

      // Attach refresh listener
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
      // Unsubscribe from topics
      await _messaging.unsubscribeFromTopic('all_users');

      // Delete token locally
      await _messaging.deleteToken();

      // Update Firestore
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

  /// Use only for Firebase Console testing
  Future<void> printTokenForDebug() async {
    final token = await _messaging.getToken();
    debugPrint('================ FCM TOKEN ================');
    debugPrint(token);
    debugPrint('===========================================');
  }
}
