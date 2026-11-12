import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ImageModel extends Equatable {
  final String id;
  final String name;
  final String url;
  final String publicId;
  final String? deleteToken;
  final DateTime createdAt;

  const ImageModel({
    required this.id,
    required this.name,
    required this.url,
    required this.publicId,
    required this.createdAt,
    this.deleteToken,
  });

  factory ImageModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    // createdAt is null for a moment while the server timestamp is pending
    final ts = d['createdAt'];
    return ImageModel(
      id: doc.id,
      name: (d['name'] ?? '') as String,
      url: (d['url'] ?? '') as String,
      publicId: (d['publicId'] ?? '') as String,
      deleteToken: d['deleteToken'] as String?,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'url': url,
        'publicId': publicId,
        'deleteToken': deleteToken,
        'createdAt': FieldValue.serverTimestamp(),
      };

  @override
  List<Object?> get props => [id, name, url, publicId, deleteToken, createdAt];
}
