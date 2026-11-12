import 'dart:io';

import 'package:equatable/equatable.dart';

enum UploadStatus { initial, picked, uploading, success, failure }

class UploadState extends Equatable {
  final UploadStatus status;
  final File? file;
  final String? error;

  const UploadState({
    this.status = UploadStatus.initial,
    this.file,
    this.error,
  });

  UploadState copyWith({
    UploadStatus? status,
    File? file,
    String? error,
  }) =>
      UploadState(
        status: status ?? this.status,
        file: file ?? this.file,
        error: error,
      );

  @override
  List<Object?> get props => [status, file?.path, error];
}
