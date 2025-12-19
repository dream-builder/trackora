import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CameraHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Opens camera, takes picture, saves it locally
  /// Returns image path or null if cancelled
  static Future<String?> takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo == null) return null;

      final Directory dir = await getApplicationDocumentsDirectory();
      final String fileName = basename(photo.path);
      final String savedPath = join(dir.path, fileName);

      final File savedImage = await File(photo.path).copy(savedPath);

      return savedImage.path;
    } catch (e) {
      debugPrint("Camera error: $e");
      return null;
    }
  }
}
