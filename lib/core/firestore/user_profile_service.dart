import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ CREATE USER PROFILE ONLY IF IT DOES NOT EXIST
  /// Call this AFTER:
  /// - Sign Up
  /// - Sign In
  Future<void> createUserProfileIfNotExists({
    required String name,
    required String email,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'name': name.isNotEmpty ? name : 'User',
        'email': email,
        'photoUrl': '',
        'notificationsEnabled': true, // 🔔 DEFAULT ON
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// 🔥 REAL-TIME USER PROFILE STREAM (SAFE & NULL-PROOF)
  Stream<Map<String, dynamic>?> userProfileStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
          if (!doc.exists) return null;
          return doc.data();
        })
        .handleError((_) {
          // 🔇 Prevent stream crash when offline
          return null;
        });
  }

  /// ✏️ UPDATE USER NAME
  Future<void> updateName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🖼 UPDATE PROFILE IMAGE URL
  Future<void> updatePhotoUrl(String url) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'photoUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🔔 UPDATE NOTIFICATION PREFERENCE
  Future<void> updateNotificationPreference(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'notificationsEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
