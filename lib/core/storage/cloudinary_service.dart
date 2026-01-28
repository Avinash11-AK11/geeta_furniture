import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  // =========================================================
  // 🔐 CLOUDINARY CONFIG
  // =========================================================
  static const String _cloudName = 'dqp6ow5n3';
  static const String _apiKey = 'YOUR_API_KEY';
  static const String _apiSecret = 'YOUR_API_SECRET';

  // Upload presets
  static const String _profileUploadPreset = 'profile_images';
  static const String _productUploadPreset = 'geeta_products';

  // =========================================================
  // 👤 PROFILE IMAGE — URL ONLY (OLD / SIMPLE)
  // =========================================================
  static Future<String> uploadProfileImage(File imageFile) async {
    final result = await _uploadImage(
      imageFile: imageFile,
      uploadPreset: _profileUploadPreset,
    );
    return result['url']!;
  }

  // =========================================================
  // 👤 PROFILE IMAGE — URL + PUBLIC ID (NEW ✅)
  // =========================================================
  static Future<Map<String, String>> uploadProfileImageWithPublicId(
    File imageFile,
  ) async {
    return _uploadImage(
      imageFile: imageFile,
      uploadPreset: _profileUploadPreset,
    );
  }

  // =========================================================
  // 🪑 PRODUCT IMAGE — URL + PUBLIC ID
  // =========================================================
  static Future<Map<String, String>> uploadProductImage(File imageFile) async {
    return _uploadImage(
      imageFile: imageFile,
      uploadPreset: _productUploadPreset,
    );
  }

  // =========================================================
  // ❌ DELETE IMAGE FROM CLOUDINARY (PRODUCT / PROFILE)
  // =========================================================
  static Future<void> deleteImage(String publicId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final signatureRaw = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';

    final signature = sha1.convert(utf8.encode(signatureRaw)).toString();

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy',
    );

    final response = await http.post(
      uri,
      body: {
        'public_id': publicId,
        'api_key': _apiKey,
        'timestamp': timestamp.toString(),
        'signature': signature,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Cloudinary delete failed: ${response.body}');
    }
  }

  // =========================================================
  // 🔧 INTERNAL SHARED UPLOAD HANDLER
  // =========================================================
  static Future<Map<String, String>> _uploadImage({
    required File imageFile,
    required String uploadPreset,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(body);
      return {'url': json['secure_url'], 'publicId': json['public_id']};
    } else {
      throw Exception('Cloudinary upload failed: $body');
    }
  }
}
