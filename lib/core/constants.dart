import 'package:flutter/material.dart';

class AppConstants {
  // ---- Cloudinary ----
  // Dashboard > Settings > Upload > Upload presets > Add preset
  // Signing mode = "Unsigned". Optionally enable "Return delete token".
  static const String cloudinaryCloudName = 'dhwezgnmj';
  static const String cloudinaryUploadPreset = 'flutter_unsigned';

  // ---- Firestore ----
  static const String imagesCollection = 'images';
}

class AppColors {
  static const Color green = Color(0xFF16A31A);
  static const Color navBg = Color(0xFFEAEAEA);
  static const Color text = Color(0xFF2B2B2B);
  static const Color danger = Color(0xFFFF3B30);
}
