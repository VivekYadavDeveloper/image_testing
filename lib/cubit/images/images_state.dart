import 'package:equatable/equatable.dart';

import '../../models/image_model.dart';

enum ImagesStatus { loading, loaded, failure }

class ImagesState extends Equatable {
  final ImagesStatus status;
  final List<ImageModel> images;
  final String? error;

  const ImagesState({
    this.status = ImagesStatus.loading,
    this.images = const [],
    this.error,
  });

  ImagesState copyWith({
    ImagesStatus? status,
    List<ImageModel>? images,
    String? error,
  }) =>
      ImagesState(
        status: status ?? this.status,
        images: images ?? this.images,
        error: error,
      );

  @override
  List<Object?> get props => [status, images, error];
}
