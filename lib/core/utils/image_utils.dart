import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> compressImage(File imageFile, int maxSizeKB) async {
    try {
      final int fileSize = await imageFile.length();
      if (fileSize <= maxSizeKB * 1024) {
        return imageFile;
      }

      final XFile compressedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      ) as XFile;

      return File(compressedImage.path);
    } catch (e) {
      return imageFile;
    }
  }

  static Future<Uint8List?> getImageBytes(File imageFile) async {
    try {
      return await imageFile.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  static String getImageExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  static bool isImageFile(String filePath) {
    final ext = getImageExtension(filePath);
    return ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.gif';
  }
}
