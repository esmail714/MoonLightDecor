import 'package:uuid/uuid.dart';

enum LostItemStatus {
  found,
  returned,
  pending,
}

extension LostItemStatusExtension on LostItemStatus {
  String get displayName {
    switch (this) {
      case LostItemStatus.found:
        return 'تم العثور عليه';
      case LostItemStatus.returned:
        return 'تم تسليمه';
      case LostItemStatus.pending:
        return 'قيد الانتظار';
    }
  }
}

class LostItem {
  String id;
  String description;
  DateTime dateFound;
  String locationFound;
  LostItemStatus status;
  String? bookingId;

  LostItem({
    String? id,
    required this.description,
    required this.dateFound,
    required this.locationFound,
    this.status = LostItemStatus.pending,
    this.bookingId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'dateFound': dateFound.toIso8601String(),
      'locationFound': locationFound,
      'status': status.index,
      'bookingId': bookingId,
    };
  }

  factory LostItem.fromMap(Map<String, dynamic> map) {
    return LostItem(
      id: map['id'],
      description: map['description'],
      dateFound: DateTime.parse(map['dateFound']),
      locationFound: map['locationFound'],
      status: LostItemStatus.values[map['status']],
      bookingId: map['bookingId'],
    );
  }

  LostItem copyWith({
    String? id,
    String? description,
    DateTime? dateFound,
    String? locationFound,
    LostItemStatus? status,
    String? bookingId,
  }) {
    return LostItem(
      id: id ?? this.id,
      description: description ?? this.description,
      dateFound: dateFound ?? this.dateFound,
      locationFound: locationFound ?? this.locationFound,
      status: status ?? this.status,
      bookingId: bookingId ?? this.bookingId,
    );
  }
}

