import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileStorage {
  static const _imagePathKey = 'profile_image_path';

  static Future<void> saveProfileImage(File? image) async {
    final prefs = await SharedPreferences.getInstance();

    if (image == null) {
      await prefs.remove(_imagePathKey);
    } else {
      await prefs.setString(_imagePathKey, image.path);
    }
  }

  static Future<File?> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_imagePathKey);

    if (path != null && File(path).existsSync()) {
      return File(path);
    }
    return null;
  }
}
