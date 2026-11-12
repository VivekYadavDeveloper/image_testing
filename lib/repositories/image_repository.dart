import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/image_model.dart';
import '../services/cloudinary_service.dart';

class ImageRepository {
  ImageRepository({FirebaseFirestore? firestore, CloudinaryService? cloudinary})
    : _db = firestore ?? FirebaseFirestore.instance,
      _cloudinary = cloudinary ?? CloudinaryService();

  final FirebaseFirestore _db;
  final CloudinaryService _cloudinary;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(AppConstants.imagesCollection);

  /// 1) Upload to Cloudinary  2) Save the returned data in Firestore.
  Future<void> uploadImage({required File file, required String name}) async {
    final result = await _cloudinary.upload(file);

    final model = ImageModel(
      id: '',
      name: name,
      url: result.url,
      publicId: result.publicId,
      deleteToken: result.deleteToken,
      createdAt: DateTime.now(),
    );

    // Firestore applies local writes to snapshots immediately
    // (latency compensation), so the Images tab updates instantly.
    await _col.add(model.toMap());
  }

  /// Live list. Local writes (add / delete) show up instantly.
  Stream<List<ImageModel>> watchImages() {
    return _col
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map(ImageModel.fromDoc).toList());
  }

  Future<void> deleteImage(ImageModel image) async {
    await _col.doc(image.id).delete();

    final token = image.deleteToken;
    if (token != null && token.isNotEmpty) {
      try {
        await _cloudinary.deleteByToken(token);
      } catch (_) {
        // token expired -> asset stays in Cloudinary (needs backend cleanup)
      }
    }
  }
}
