import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../repositories/image_repository.dart';
import 'upload_state.dart';

class UploadCubit extends Cubit<UploadState> {
  UploadCubit(this._repo) : super(const UploadState());

  final ImageRepository _repo;
  final ImagePicker _picker = ImagePicker();

  Future<void> pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(source: source, imageQuality: 85);
      if (x == null) return;
      emit(UploadState(status: UploadStatus.picked, file: File(x.path)));
    } catch (e) {
      emit(state.copyWith(status: UploadStatus.failure, error: e.toString()));
    }
  }

  void clear() => emit(const UploadState());

  Future<void> submit(String name) async {
    final file = state.file;
    if (file == null || state.status == UploadStatus.uploading) return;

    emit(state.copyWith(status: UploadStatus.uploading));
    try {
      await _repo.uploadImage(file: file, name: name.trim());
      emit(const UploadState(status: UploadStatus.success));
    } catch (e) {
      emit(state.copyWith(status: UploadStatus.failure, error: e.toString()));
    }
  }
}
