import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationStore {
  NotificationStore._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /* ============================================================
     SAVE NOTIFICATION (DATA-ONLY FCM)
     ============================================================ */

  static Future<void> save(RemoteMessage message) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final data = message.data;
    if (data.isEmpty) return;

    // Generate stable ID to avoid duplicates
    final String notificationId =
        data['id'] ?? '${DateTime.now().millisecondsSinceEpoch}_${user.uid}';

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .set({
            'title': data['title'] ?? 'Notification',
            'body': data['body'] ?? '',
            'type': data['type'] ?? 'notification',
            'data': data,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to save notification: $e');
      }
    }
  }

  /* ============================================================
     MARK AS READ
     ============================================================ */

  static Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  /* ============================================================
     CLEAR ALL NOTIFICATIONS
     ============================================================ */

  static Future<void> clearAll() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
