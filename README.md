# Image App (Flutter + Cubit + Cloudinary + Firestore)

Upload / capture an image -> Cloudinary storage -> URL + name saved to Firestore -> shown instantly in the Images tab. Delete removes it instantly.

## Setup

1. Create project and copy the `lib/` folder + `pubspec.yaml` into it:
   ```
   flutter create image_app
   ```
2. Firebase:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart`. In Firebase console create a Firestore database.
   For testing, use rules like:
   ```
   allow read, write: if true;
   ```
   (tighten before production).
3. Cloudinary: Settings -> Upload -> Add upload preset -> Signing mode **Unsigned**
   (optionally enable "Return delete token"). Put cloud name + preset name in
   `lib/core/constants.dart`.
4. Permissions
    - Android: `android/app/build.gradle` -> `minSdkVersion 21`. Camera works through image_picker without extra manifest entries.
    - iOS `ios/Runner/Info.plist`:
      ```xml
      <key>NSCameraUsageDescription</key><string>Capture photos to upload</string>
      <key>NSPhotoLibraryUsageDescription</key><string>Pick photos to upload</string>
      ```
5. Run: `flutter pub get && flutter run`

## Structure

```
lib/
  core/constants.dart
  models/image_model.dart
  services/cloudinary_service.dart
  repositories/image_repository.dart
  cubit/upload/{upload_cubit,upload_state}.dart
  cubit/images/{images_cubit,images_state}.dart
  screens/{main_shell,upload_screen,images_screen}.dart
  main.dart
```

## How "instant" works

- Upload: `UploadCubit.submit` -> Cloudinary -> Firestore `add`. The Images tab listens to a Firestore snapshot stream, so the new tile appears right away and the app switches to the Images tab.
- Delete: long-press a tile (or tap the trash icon) -> `ImagesCubit.delete` removes it from state first (optimistic), then deletes the Firestore doc. On failure it rolls back.

## Note on Cloudinary deletion

Unsigned clients cannot permanently delete assets. The app uses `delete_by_token` (valid ~10 min after upload, needs "Return delete token" on the preset). For guaranteed deletion of old images, call Cloudinary's destroy API from a backend / Cloud Function using the stored `publicId`.
