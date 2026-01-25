import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cloudinary_service.dart';

class ProfileImageService {
  /// Upload image to Cloudinary + save URL in Firestore
  static Future<String?> uploadProfileImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // 1️⃣ Upload to Cloudinary
    final imageUrl = await CloudinaryService.uploadProfileImage(imageFile);

    if (imageUrl == null) {
      throw Exception('Cloudinary upload failed');
    }

    // 2️⃣ Save URL to Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'profileImage': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return imageUrl;
  }
}
