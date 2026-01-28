import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cloudinary_service.dart';

class ProfileImageService {
  /// Upload profile image
  /// ✔ Upload new image to Cloudinary
  /// ✔ Delete old image from Cloudinary
  /// ✔ Update Firestore
  static Future<String?> uploadProfileImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    // 1️⃣ Get existing profile image publicId
    final snapshot = await userRef.get();
    final oldPublicId = snapshot.data()?['profileImagePublicId'];

    // 2️⃣ Upload new image to Cloudinary (URL + publicId)
    final uploaded = await CloudinaryService.uploadProfileImageWithPublicId(
      imageFile,
    );

    final imageUrl = uploaded['url'];
    final newPublicId = uploaded['publicId'];

    if (imageUrl == null || newPublicId == null) {
      throw Exception('Cloudinary upload failed');
    }

    // 3️⃣ Delete old image from Cloudinary (safe)
    if (oldPublicId != null && oldPublicId.toString().isNotEmpty) {
      try {
        await CloudinaryService.deleteImage(oldPublicId);
      } catch (_) {
        // Never block user
      }
    }

    // 4️⃣ Update Firestore
    await userRef.update({
      'profileImage': imageUrl,
      'profileImagePublicId': newPublicId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return imageUrl;
  }
}
