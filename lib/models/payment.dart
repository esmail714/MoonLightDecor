import 'enums.dart';

class Payment {
  final String id;
  final String bookingId;
  final DateTime paymentDate;
  final PaymentMethod paymentMethod;
  final double amount;
  final String notes;
  final DateTime createdAt;
  DateTime updatedAt;
  final String createdBy;
  String updatedBy;
  
  // حقول إضافية حسب نوع الدفع
  final String? checkNumber; // رقم الشيك
  final String? cardLastFour; // آخر 4 أرقام البطاقة
  final String? referenceNumber; // رقم مرجعي للحوالة أو البطاقة

  Payment({
    required this.id,
    required this.bookingId,
    required this.paymentDate,
    required this.paymentMethod,
    required this.amount,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    this.checkNumber,
    this.cardLastFour,
    this.referenceNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'payment_date': paymentDate.millisecondsSinceEpoch,
      'payment_method': paymentMethod.name,
      'amount': amount,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'check_number': checkNumber,
      'card_last_four': cardLastFour,
      'reference_number': referenceNumber,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      bookingId: map['booking_id'],
      paymentDate: DateTime.fromMillisecondsSinceEpoch(map['payment_date']),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['payment_method'],
        orElse: () => PaymentMethod.cash,
      ),
      amount: map['amount']?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      createdBy: map['created_by'],
      updatedBy: map['updated_by'],
      checkNumber: map['check_number'],
      cardLastFour: map['card_last_four'],
      referenceNumber: map['reference_number'],
    );
  }

  Payment copyWith({
    String? id,
    String? bookingId,
    DateTime? paymentDate,
    PaymentMethod? paymentMethod,
    double? amount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? checkNumber,
    String? cardLastFour,
    String? referenceNumber,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      checkNumber: checkNumber ?? this.checkNumber,
      cardLastFour: cardLastFour ?? this.cardLastFour,
      referenceNumber: referenceNumber ?? this.referenceNumber,
    );
  }
}


