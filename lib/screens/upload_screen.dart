import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants.dart';
import '../cubit/upload/upload_cubit.dart';
import '../cubit/upload/upload_state.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, required this.onUploaded});

  /// Called after a successful submit (used to switch to the Images tab)
  final VoidCallback onUploaded;

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadCubit, UploadState>(
      listener: (context, state) {
        if (state.status == UploadStatus.success) {
          _nameCtrl.clear();
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Image uploaded')));
          widget.onUploaded();
        } else if (state.status == UploadStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? 'Something went wrong')),
          );
        }
      },
      builder: (context, state) {
        final hasImage = state.file != null;
        return hasImage ? _preview(context, state) : _picker(context);
      },
    );
  }

  // ---------- Screen 1: pick ----------
  Widget _picker(BuildContext context) {
    final cubit = context.read<UploadCubit>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dashed(
              onTap: () => cubit.pick(ImageSource.gallery),
              height: 230,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 80, color: AppColors.green),
                  SizedBox(height: 12),
                  Text(
                    'Browser Gallery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('OR', style: TextStyle(fontSize: 18)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 28),
            _dashed(
              onTap: () => cubit.pick(ImageSource.camera),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.photo_camera, color: AppColors.green),
                  SizedBox(width: 12),
                  Text(
                    'Open camera',
                    style: TextStyle(fontSize: 18, color: AppColors.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashed({
    required VoidCallback onTap,
    required double height,
    required Widget child,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: DottedBorder(
        color: AppColors.green,
        strokeWidth: 1.5,
        dashPattern: const [10, 6],
        borderType: BorderType.RRect,
        radius: const Radius.circular(20),
        child: SizedBox(width: double.infinity, height: height, child: child),
      ),
    );
  }

  // ---------- Screen 2: preview + name + submit ----------
  Widget _preview(BuildContext context, UploadState state) {
    final uploading = state.status == UploadStatus.uploading;
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1 / 1.4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.file(state.file!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: uploading
                      ? null
                      : () => context.read<UploadCubit>().clear(),
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: AppColors.danger,
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  enabled: !uploading,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Reference Name',
                    hintStyle: const TextStyle(color: Colors.black26),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.text),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.text),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 56,
                  width: 150,
                  child: ElevatedButton(
                    onPressed: uploading
                        ? null
                        : () {
                            final name = _nameCtrl.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Enter a reference name'),
                                ),
                              );
                              return;
                            }
                            context.read<UploadCubit>().submit(name);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: uploading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
