import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OdometerOCRService {
  final ImagePicker _picker = ImagePicker();

  /// 📸 Capture image from camera
  Future<File?> captureImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) return null;
    return File(image.path);
  }

  /// 🔢 Convert image to number (LOCAL OCR)
  Future<int?> readOdometer(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    final textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );

    final RecognizedText recognizedText =
    await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    // 🔍 Extract digits only
    final buffer = StringBuffer();

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final digitsOnly =
        line.text.replaceAll(RegExp(r'[^0-9]'), '');
        buffer.write(digitsOnly);
      }
    }

    if (buffer.isEmpty) return null;

    return int.tryParse(buffer.toString());
  }
}
