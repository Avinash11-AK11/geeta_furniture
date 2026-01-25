import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dqp6ow5n3';

  // Upload presets
  static const String _profileUploadPreset = 'profile_images';
  static const String _productUploadPreset = 'geeta_products';

  /// ================================
  /// PROFILE IMAGE (URL ONLY)
  /// ================================
  static Future<String> uploadProfileImage(File imageFile) async {
    final result = await _uploadImage(
      imageFile: imageFile,
      uploadPreset: _profileUploadPreset,
    );
    return result['url']!;
  }

  /// ================================
  /// PRODUCT IMAGE (URL + PUBLIC ID)
  /// ================================
  static Future<Map<String, String>> uploadProductImage(File imageFile) async {
    return _uploadImage(
      imageFile: imageFile,
      uploadPreset: _productUploadPreset,
    );
  }

  /// ================================
  /// INTERNAL SHARED UPLOAD
  /// ================================
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
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(responseBody);
      return {'url': json['secure_url'], 'publicId': json['public_id']};
    } else {
      throw Exception('Cloudinary upload failed: $responseBody');
    }
  }
}
