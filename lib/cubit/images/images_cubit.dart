import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/image_model.dart';
import '../../repositories/image_repository.dart';
import 'images_state.dart';

class ImagesCubit extends Cubit<ImagesState> {
  ImagesCubit(this._repo) : super(const ImagesState()) {
    _sub = _repo.watchImages().listen(
      (list) => emit(state.copyWith(status: ImagesStatus.loaded, images: list)),
      onError: (e) =>
          emit(state.copyWith(status: ImagesStatus.failure, error: e.toString())),
    );
  }

  final ImageRepository _repo;
  StreamSubscription<List<ImageModel>>? _sub;

  /// Optimistic delete: the tile disappears immediately,
  /// then Firestore (and Cloudinary best-effort) is updated.
  Future<void> delete(ImageModel image) async {
    final previous = state.images;
    emit(state.copyWith(
      images: previous.where((i) => i.id != image.id).toList(),
    ));
    try {
      await _repo.deleteImage(image);
    } catch (e) {
      // roll back if it failed
      emit(state.copyWith(images: previous, error: 'Delete failed: $e'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
