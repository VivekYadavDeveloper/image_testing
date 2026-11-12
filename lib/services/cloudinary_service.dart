import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants.dart';

class CloudinaryUploadResult {
  final String url;
  final String publicId;
  final String? deleteToken;

  const CloudinaryUploadResult({
    required this.url,
    required this.publicId,
    this.deleteToken,
  });
}

class CloudinaryService {
  static const _base = 'https://api.cloudinary.com/v1_1';

  Future<CloudinaryUploadResult> upload(File file) async {
    final uri = Uri.parse(
        '$_base/${AppConstants.cloudinaryCloudName}/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('Cloudinary upload failed (${streamed.statusCode}): $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return CloudinaryUploadResult(
      url: json['secure_url'] as String,
      publicId: json['public_id'] as String,
      deleteToken: json['delete_token'] as String?,
    );
  }

  /// Best-effort delete from Cloudinary using the delete token
  /// (valid ~10 minutes, only returned if the preset has
  /// "Return delete token" enabled). Real, permanent deletion of older
  /// assets needs the API secret, so do it from a backend / Cloud Function.
  Future<void> deleteByToken(String token) async {
    final uri = Uri.parse(
        '$_base/${AppConstants.cloudinaryCloudName}/delete_by_token');
    await http.post(uri, body: {'token': token});
  }
}
