import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_service.dart';

class EnhancedImagePickerWidget extends StatefulWidget {
  final List<String> initialImagePaths;
  final Function(List<String>) onImagesChanged;
  final bool allowMultiple;
  final int maxImages;
  final String? title;

  const EnhancedImagePickerWidget({
    super.key,
    this.initialImagePaths = const [],
    required this.onImagesChanged,
    this.allowMultiple = true,
    this.maxImages = 10,
    this.title,
  });

  @override
  State<EnhancedImagePickerWidget> createState() => _EnhancedImagePickerWidgetState();
}

class _EnhancedImagePickerWidgetState extends State<EnhancedImagePickerWidget> {
  List<String> _imagePaths = [];
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    _imagePaths = List.from(widget.initialImagePaths);
  }

  Future<void> _addImage() async {
    if (_imagePaths.length >= widget.maxImages) {
      _showMaxImagesReachedDialog();
      return;
    }

    final String? imagePath = await _imageService.showImageSourceDialog(context);
    if (imagePath != null) {
      setState(() {
        if (widget.allowMultiple) {
          _imagePaths.add(imagePath);
        } else {
          _imagePaths = [imagePath];
        }
      });
      widget.onImagesChanged(_imagePaths);
    }
  }

  Future<void> _addMultipleImages() async {
    if (!widget.allowMultiple) return;
    
    final int remainingSlots = widget.maxImages - _imagePaths.length;
    if (remainingSlots <= 0) {
      _showMaxImagesReachedDialog();
      return;
    }

    final List<String> newImagePaths = await _imageService.pickMultipleImagesFromGallery();
    if (newImagePaths.isNotEmpty) {
      setState(() {
        final int imagesToAdd = remainingSlots < newImagePaths.length 
            ? remainingSlots 
            : newImagePaths.length;
        _imagePaths.addAll(newImagePaths.take(imagesToAdd));
      });
      widget.onImagesChanged(_imagePaths);
      
      if (newImagePaths.length > remainingSlots) {
        _showSomeImagesSkippedDialog(newImagePaths.length - remainingSlots);
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
    widget.onImagesChanged(_imagePaths);
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('عرض الصورة'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('خطأ في تحميل الصورة'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMaxImagesReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنبيه'),
        content: Text('تم الوصول للحد الأقصى من الصور (${widget.maxImages})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showSomeImagesSkippedDialog(int skippedCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنبيه'),
        content: Text('تم تخطي $skippedCount صورة بسبب الوصول للحد الأقصى'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
        ],
        
        // أزرار إضافة الصور
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('إضافة صورة'),
            ),
            if (widget.allowMultiple) ...[
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addMultipleImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('إضافة متعددة'),
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 16),
        
        // عرض الصور
        if (_imagePaths.isEmpty)
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('لا توجد صور', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                final imagePath = _imagePaths[index];
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _showImageDialog(imagePath),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        
        const SizedBox(height: 8),
        
        // معلومات إضافية
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الصور: ${_imagePaths.length}/${widget.maxImages}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (_imagePaths.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _imagePaths.clear();
                  });
                  widget.onImagesChanged(_imagePaths);
                },
                child: const Text(
                  'حذف الكل',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

