class ImageData {
  final String id;
  final String bookingId;
  final String? addOnId; // معرف الإضافة (اختياري)
  final String imagePath;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;

  ImageData({
    required this.id,
    required this.bookingId,
    this.addOnId,
    required this.imagePath,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  // تحويل إلى Map لحفظ في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'add_on_id': addOnId,
      'image_path': imagePath,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  // إنشاء من Map
  factory ImageData.fromMap(Map<String, dynamic> map) {
    return ImageData(
      id: map['id'] ?? '',
      bookingId: map['booking_id'] ?? '',
      addOnId: map['add_on_id'],
      imagePath: map['image_path'] ?? '',
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] ?? 0),
      createdBy: map['created_by'] ?? '',
      updatedBy: map['updated_by'] ?? '',
    );
  }

  // نسخ مع تعديل
  ImageData copyWith({
    String? id,
    String? bookingId,
    String? addOnId,
    String? imagePath,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ImageData(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      addOnId: addOnId ?? this.addOnId,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  String toString() {
    return 'ImageData{id: $id, bookingId: $bookingId, addOnId: $addOnId, imagePath: $imagePath, description: $description}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

