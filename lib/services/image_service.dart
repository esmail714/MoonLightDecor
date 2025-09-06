import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // الحصول على مجلد الصور للتطبيق
  Future<Directory> get _imagesDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  // التقاط صورة من الكاميرا
  Future<String?> captureImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return await _saveImageToAppDirectory(image);
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في التقاط الصورة من الكاميرا: $e');
      return null;
    }
  }

  // اختيار صورة من المعرض
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return await _saveImageToAppDirectory(image);
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في اختيار الصورة من المعرض: $e');
      return null;
    }
  }

  // اختيار صور متعددة من المعرض
  Future<List<String>> pickMultipleImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      List<String> savedPaths = [];
      for (XFile image in images) {
        final savedPath = await _saveImageToAppDirectory(image);
        if (savedPath != null) {
          savedPaths.add(savedPath);
        }
      }
      return savedPaths;
    } catch (e) {
      debugPrint('خطأ في اختيار الصور المتعددة: $e');
      return [];
    }
  }

  // حفظ الصورة في مجلد التطبيق
  Future<String?> _saveImageToAppDirectory(XFile image) async {
    try {
      final imagesDir = await _imagesDirectory;
      final String fileName = '${_uuid.v4()}.jpg';
      final String filePath = path.join(imagesDir.path, fileName);
      
      final File imageFile = File(image.path);
      final File savedFile = await imageFile.copy(filePath);
      
      return savedFile.path;
    } catch (e) {
      debugPrint('خطأ في حفظ الصورة: $e');
      return null;
    }
  }

  // حفظ صورة من البيانات
  Future<String?> saveImageFromBytes(Uint8List bytes, String fileName) async {
    try {
      final imagesDir = await _imagesDirectory;
      final String filePath = path.join(imagesDir.path, fileName);
      
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return file.path;
    } catch (e) {
      debugPrint('خطأ في حفظ الصورة من البيانات: $e');
      return null;
    }
  }

  // حذف صورة
  Future<bool> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('خطأ في حذف الصورة: $e');
      return false;
    }
  }

  // حذف صور متعددة
  Future<void> deleteMultipleImages(List<String> imagePaths) async {
    for (String imagePath in imagePaths) {
      await deleteImage(imagePath);
    }
  }

  // التحقق من وجود الصورة
  Future<bool> imageExists(String imagePath) async {
    try {
      final File file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // الحصول على حجم الصورة
  Future<int?> getImageSize(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في الحصول على حجم الصورة: $e');
      return null;
    }
  }

  // تنظيف الصور غير المستخدمة
  Future<void> cleanupUnusedImages(List<String> usedImagePaths) async {
    try {
      final imagesDir = await _imagesDirectory;
      final List<FileSystemEntity> files = imagesDir.listSync();
      
      for (FileSystemEntity file in files) {
        if (file is File && !usedImagePaths.contains(file.path)) {
          await file.delete();
          debugPrint('تم حذف الصورة غير المستخدمة: ${file.path}');
        }
      }
    } catch (e) {
      debugPrint('خطأ في تنظيف الصور غير المستخدمة: $e');
    }
  }

  // الحصول على جميع الصور في مجلد التطبيق
  Future<List<String>> getAllImages() async {
    try {
      final imagesDir = await _imagesDirectory;
      final List<FileSystemEntity> files = imagesDir.listSync();
      
      return files
          .where((file) => file is File && _isImageFile(file.path))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      debugPrint('خطأ في الحصول على جميع الصور: $e');
      return [];
    }
  }

  // التحقق من أن الملف صورة
  bool _isImageFile(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  // عرض نافذة اختيار مصدر الصورة
  Future<String?> showImageSourceDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اختيار مصدر الصورة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('الكاميرا'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await captureImageFromCamera();
                  if (context.mounted) {
                    Navigator.pop(context, imagePath);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('المعرض'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await pickImageFromGallery();
                  if (context.mounted) {
                    Navigator.pop(context, imagePath);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }
}

