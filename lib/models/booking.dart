import 'enums.dart';


// نموذج الحجز الرئيسي
class Booking {
  final String id;
  String invoiceNumber;
  String customerName;
  String phoneNumber;
  final DateTime createdDate;
  DateTime eventDate;
  EventType eventType;
  String responsibleEmployee;
  String generalNotes;
  BookingStatus status;
  String? parentBookingId; // للحجوزات الفرعية
  
  // إضافات الأثاث والخدمات
  GoldStand? goldStand;
  Tables? tables;
  Printing? printing;
  Speaker? speaker;
  SpecialDevices? specialDevices;
  
  // تفاصيل حسب نوع الحفلة
  WomenPartyDetails? womenDetails;
  MenPartyDetails? menDetails;
  GraduationDetails? graduationDetails;
  
  // اختيار الطاولات والكراسي
  TableChairSelection? tableChairSelection;
  
  // الحسابات
  double totalAmount;
  double paidAmount;
  PaymentStatus paymentStatus;
  
  // تواريخ النظام
  final DateTime createdAt;
  DateTime updatedAt;
  final String createdBy;
  String updatedBy;

  Booking({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.phoneNumber,
    required this.createdDate,
    required this.eventDate,
    required this.eventType,
    required this.responsibleEmployee,
    this.generalNotes = '',
    this.status = BookingStatus.ready,
    this.parentBookingId,
    this.goldStand,
    this.tables,
    this.printing,
    this.speaker,
    this.specialDevices,
    this.womenDetails,
    this.menDetails,
    this.graduationDetails,
    this.tableChairSelection,
    this.totalAmount = 0.0,
    this.paidAmount = 0.0,
    this.paymentStatus = PaymentStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  // الرصيد المتبقي
  double get remainingAmount => totalAmount - paidAmount;
  
  // نسبة الدفع
  double get paymentPercentage => totalAmount > 0 ? (paidAmount / totalAmount) : 0.0;
  
  // تحديث حالة الدفع تلقائياً
  PaymentStatus get calculatedPaymentStatus {
    if (totalAmount == 0) return PaymentStatus.pending;
    if (paidAmount == 0) return PaymentStatus.pending;
    if (paidAmount >= totalAmount) return PaymentStatus.fullyPaid;
    if (paidAmount > 0) return PaymentStatus.partiallyPaid;
    
    // التحقق من التأخير (إذا كان تاريخ الحفلة قد مضى ولم يتم الدفع كاملاً)
    if (eventDate.isBefore(DateTime.now()) && paidAmount < totalAmount) {
      return PaymentStatus.overdue;
    }
    
    return PaymentStatus.pending;
  }
  
  // هل هو حجز فرعي
  bool get isSubBooking => parentBookingId != null;
  
  // هل هو حجز كبير (أكثر من 4 طاولات في البيت)
  bool get isLargeBooking {
    if (eventType == EventType.women && 
        womenDetails?.decorationType == DecorationType.house &&
        tableChairSelection != null) {
      return tableChairSelection!.tableCount > 4;
    }
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'created_date': createdDate.millisecondsSinceEpoch,
      'event_date': eventDate.millisecondsSinceEpoch,
      'event_type': eventType.name,
      'responsible_employee': responsibleEmployee,
      'general_notes': generalNotes,
      'status': status.name,
      'parent_booking_id': parentBookingId,
      'gold_stand': goldStand?.toMap(),
      'tables': tables?.toMap(),
      'printing': printing?.toMap(),
      'speaker': speaker?.toMap(),
      'special_devices': specialDevices?.toMap(),
      'women_details': womenDetails?.toMap(),
      'men_details': menDetails?.toMap(),
      'graduation_details': graduationDetails?.toMap(),
      'table_chair_selection': tableChairSelection?.toMap(),
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'payment_status': paymentStatus.name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map["id"],
      invoiceNumber: map["invoice_number"],
      customerName: map["customer_name"],
      phoneNumber: map["phone_number"],
      createdDate: DateTime.fromMillisecondsSinceEpoch(map["created_date"]),
      eventDate: DateTime.fromMillisecondsSinceEpoch(map["event_date"]),
      eventType: EventType.values.firstWhere(
        (e) => e.name == map["event_type"],
        orElse: () => EventType.women,
      ),
      responsibleEmployee: map["responsible_employee"],
      generalNotes: map["general_notes"] ?? "",
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map["status"],
        orElse: () => BookingStatus.ready,
      ),
      parentBookingId: map["parent_booking_id"],
      goldStand: map["gold_stand"] != null ? GoldStand.fromMap(map["gold_stand"]) : null,
      tables: map["tables"] != null ? Tables.fromMap(map["tables"]) : null,
      printing: map["printing"] != null ? Printing.fromMap(map["printing"]) : null,
      speaker: map["speaker"] != null ? Speaker.fromMap(map["speaker"]) : null,
      specialDevices: map["special_devices"] != null ? SpecialDevices.fromMap(map["special_devices"]) : null,
      womenDetails: map["women_details"] != null ? WomenPartyDetails.fromMap(map["women_details"]) : null,
      menDetails: map["men_details"] != null ? MenPartyDetails.fromMap(map["men_details"]) : null,
      graduationDetails: map["graduation_details"] != null ? GraduationDetails.fromMap(map["graduation_details"]) : null,
      tableChairSelection: map["table_chair_selection"] != null ? TableChairSelection.fromMap(map["table_chair_selection"]) : null,
      totalAmount: map["total_amount"]?.toDouble() ?? 0.0,
      paidAmount: map["paid_amount"]?.toDouble() ?? 0.0,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map["payment_status"],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map["created_at"]),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map["updated_at"]),
      createdBy: map["created_by"],
      updatedBy: map["updated_by"],
    );
  }

  Booking copyWith({
    String? id,
    String? invoiceNumber,
    String? customerName,
    String? phoneNumber,
    DateTime? createdDate,
    DateTime? eventDate,
    EventType? eventType,
    String? responsibleEmployee,
    String? generalNotes,
    BookingStatus? status,
    String? parentBookingId,
    GoldStand? goldStand,
    Tables? tables,
    Printing? printing,
    Speaker? speaker,
    SpecialDevices? specialDevices,
    WomenPartyDetails? womenDetails,
    MenPartyDetails? menDetails,
    GraduationDetails? graduationDetails,
    TableChairSelection? tableChairSelection,
    double? totalAmount,
    double? paidAmount,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Booking(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdDate: createdDate ?? this.createdDate,
      eventDate: eventDate ?? this.eventDate,
      eventType: eventType ?? this.eventType,
      responsibleEmployee: responsibleEmployee ?? this.responsibleEmployee,
      generalNotes: generalNotes ?? this.generalNotes,
      status: status ?? this.status,
      parentBookingId: parentBookingId ?? this.parentBookingId,
      goldStand: goldStand ?? this.goldStand,
      tables: tables ?? this.tables,
      printing: printing ?? this.printing,
      speaker: speaker ?? this.speaker,
      specialDevices: specialDevices ?? this.specialDevices,
      womenDetails: womenDetails ?? this.womenDetails,
      menDetails: menDetails ?? this.menDetails,
      graduationDetails: graduationDetails ?? this.graduationDetails,
      tableChairSelection: tableChairSelection ?? this.tableChairSelection,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

// إضافات الأثاث والخدمات
class GoldStand {
  bool isSelected;
  String? imageUrl;
  String notes;
  double amount;

  GoldStand({
    this.isSelected = false,
    this.imageUrl,
    this.notes = "",
    this.amount = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_selected': isSelected,
      'image_url': imageUrl,
      'notes': notes,
      'amount': amount,
    };
  }

  factory GoldStand.fromMap(Map<String, dynamic> map) {
    return GoldStand(
      isSelected: map['is_selected'] ?? false,
      imageUrl: map['image_url'],
      notes: map['notes'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
    );
  }

  GoldStand copyWith({
    bool? isSelected,
    String? imageUrl,
    String? notes,
    double? amount,
  }) {
    return GoldStand(
      isSelected: isSelected ?? this.isSelected,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
    );
  }
}

class Tables {
  bool isSelected;
  String? imageUrl;
  String notes;
  double amount;

  Tables({
    this.isSelected = false,
    this.imageUrl,
    this.notes = '',
    this.amount = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_selected': isSelected,
      'image_url': imageUrl,
      'notes': notes,
      'amount': amount,
    };
  }

  factory Tables.fromMap(Map<String, dynamic> map) {
    return Tables(
      isSelected: map['is_selected'] ?? false,
      imageUrl: map['image_url'],
      notes: map['notes'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
    );
  }

  Tables copyWith({
    bool? isSelected,
    String? imageUrl,
    String? notes,
    double? amount,
  }) {
    return Tables(
      isSelected: isSelected ?? this.isSelected,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
    );
  }
}

class Printing {
  bool isSelected;
  String notes;
  double amount;
  String additionalNotes;

  Printing({
    this.isSelected = false,
    this.notes = '',
    this.amount = 0.0,
    this.additionalNotes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'is_selected': isSelected,
      'notes': notes,
      'amount': amount,
      'additional_notes': additionalNotes,
    };
  }

  factory Printing.fromMap(Map<String, dynamic> map) {
    return Printing(
      isSelected: map['is_selected'] ?? false,
      notes: map['notes'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      additionalNotes: map['additional_notes'] ?? '',
    );
  }

  Printing copyWith({
    bool? isSelected,
    String? notes,
    double? amount,
    String? additionalNotes,
  }) {
    return Printing(
      isSelected: isSelected ?? this.isSelected,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }
}

class Speaker {
  bool isSelected;
  double amount;
  String notes;

  Speaker({
    this.isSelected = false,
    this.amount = 0.0,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'is_selected': isSelected,
      'amount': amount,
      'notes': notes,
    };
  }

  factory Speaker.fromMap(Map<String, dynamic> map) {
    return Speaker(
      isSelected: map['is_selected'] ?? false,
      amount: map['amount']?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
    );
  }

  Speaker copyWith({
    bool? isSelected,
    double? amount,
    String? notes,
  }) {
    return Speaker(
      isSelected: isSelected ?? this.isSelected,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
    );
  }
}

class SpecialDevices {
  SmokeDevice? smokeDevice;
  LaserDevice? laserDevice;
  FollowDevice? followDevice;

  SpecialDevices({
    this.smokeDevice,
    this.laserDevice,
    this.followDevice,
  });

  Map<String, dynamic> toMap() {
    return {
      'smoke_device': smokeDevice?.toMap(),
      'laser_device': laserDevice?.toMap(),
      'follow_device': followDevice?.toMap(),
    };
  }

  factory SpecialDevices.fromMap(Map<String, dynamic> map) {
    return SpecialDevices(
      smokeDevice: map['smoke_device'] != null ? SmokeDevice.fromMap(map['smoke_device']) : null,
      laserDevice: map['laser_device'] != null ? LaserDevice.fromMap(map['laser_device']) : null,
      followDevice: map['follow_device'] != null ? FollowDevice.fromMap(map['follow_device']) : null,
    );
  }

  SpecialDevices copyWith({
    SmokeDevice? smokeDevice,
    LaserDevice? laserDevice,
    FollowDevice? followDevice,
  }) {
    return SpecialDevices(
      smokeDevice: smokeDevice ?? this.smokeDevice,
      laserDevice: laserDevice ?? this.laserDevice,
      followDevice: followDevice ?? this.followDevice,
    );
  }
}

class SmokeDevice {
  bool isSelected;
  double amount;
  String notes;
  String? imageUrl;

  SmokeDevice({
    this.isSelected = false,
    this.amount = 0.0,
    this.notes = '',
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_selected': isSelected,
      'amount': amount,
      'notes': notes,
      'image_url': imageUrl,
    };
  }

  factory SmokeDevice.fromMap(Map<String, dynamic> map) {
    return SmokeDevice(
      isSelected: map['is_selected'] ?? false,
      amount: map['amount']?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
      imageUrl: map['image_url'],
    );
  }

  SmokeDevice copyWith({
    bool? isSelected,
    double? amount,
    String? notes,
    String? imageUrl,
  }) {
    return SmokeDevice(
      isSelected: isSelected ?? this.isSelected,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class LaserDevice {
  bool isSelected;
  double amount;
  String notes;
  String? imageUrl;

  LaserDevice({
    this.isSelected = false,
    this.amount = 0.0,
    this.notes = '',
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_selected': isSelected,
      'amount': amount,
      'notes': notes,
      'image_url': imageUrl,
    };
  }

  factory LaserDevice.fromMap(Map<String, dynamic> map) {
    return LaserDevice(
      isSelected: map['is_selected'] ?? false,
      amount: map['amount']?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
      imageUrl: map['image_url'],
    );
  }

  LaserDevice copyWith({
    bool? isSelected,
    double? amount,
    String? notes,
    String? imageUrl,
  }) {
    return LaserDevice(
      isSelected: isSelected ?? this.isSelected,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class FollowDevice {
  bool isSelected;
  double amount;
  String notes;
  String? imageUrl;

  FollowDevice({
    this.isSelected = false,
    this.amount = 0.0,
    this.notes = '',
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_selected': isSelected,
      'amount': amount,
      'notes': notes,
      'image_url': imageUrl,
    };
  }

  factory FollowDevice.fromMap(Map<String, dynamic> map) {
    return FollowDevice(
      isSelected: map['is_selected'] ?? false,
      amount: map['amount']?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
      imageUrl: map['image_url'],
    );
  }

  FollowDevice copyWith({
    bool? isSelected,
    double? amount,
    String? notes,
    String? imageUrl,
  }) {
    return FollowDevice(
      isSelected: isSelected ?? this.isSelected,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// تفاصيل حفلة النساء
class WomenPartyDetails {
  DecorationType decorationType;
  String? decorImageUrl;
  String flowerColor;
  int numberOfDays;
  String? address;
  String? floor;
  String? hallName;
  
  // للصالة فقط
  HallDecorations? hallDecorations;

  WomenPartyDetails({
    required this.decorationType,
    this.decorImageUrl,
    this.flowerColor = '',
    this.numberOfDays = 1,
    this.address,
    this.floor,
    this.hallName,
    this.hallDecorations,
  });

  Map<String, dynamic> toMap() {
    return {
      'decoration_type': decorationType.name,
      'decor_image_url': decorImageUrl,
      'flower_color': flowerColor,
      'number_of_days': numberOfDays,
      'address': address,
      'floor': floor,
      'hall_name': hallName,
      'hall_decorations': hallDecorations?.toMap(),
    };
  }

  factory WomenPartyDetails.fromMap(Map<String, dynamic> map) {
    return WomenPartyDetails(
      decorationType: DecorationType.values.firstWhere(
        (e) => e.name == map['decoration_type'],
        orElse: () => DecorationType.house,
      ),
      decorImageUrl: map['decor_image_url'],
      flowerColor: map['flower_color'] ?? '',
      numberOfDays: map['number_of_days'] ?? 1,
      address: map['address'],
      floor: map['floor'],
      hallName: map['hall_name'],
      hallDecorations: map['hall_decorations'] != null
          ? HallDecorations.fromMap(map['hall_decorations'])
          : null,
    );
  }

  WomenPartyDetails copyWith({
    DecorationType? decorationType,
    String? decorImageUrl,
    String? flowerColor,
    int? numberOfDays,
    String? address,
    String? floor,
    String? hallName,
    HallDecorations? hallDecorations,
  }) {
    return WomenPartyDetails(
      decorationType: decorationType ?? this.decorationType,
      decorImageUrl: decorImageUrl ?? this.decorImageUrl,
      flowerColor: flowerColor ?? this.flowerColor,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      address: address ?? this.address,
      floor: floor ?? this.floor,
      hallName: hallName ?? this.hallName,
      hallDecorations: hallDecorations ?? this.hallDecorations,
    );
  }
}

class HallDecorations {
  String? corridorImageUrl;
  String? corridorNotes;
  String? stairImageUrl;
  String? stairNotes;
  String? entranceImageUrl;
  String? entranceNotes;

  HallDecorations({
    this.corridorImageUrl,
    this.corridorNotes,
    this.stairImageUrl,
    this.stairNotes,
    this.entranceImageUrl,
    this.entranceNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'corridor_image_url': corridorImageUrl,
      'corridor_notes': corridorNotes,
      'stair_image_url': stairImageUrl,
      'stair_notes': stairNotes,
      'entrance_image_url': entranceImageUrl,
      'entrance_notes': entranceNotes,
    };
  }

  factory HallDecorations.fromMap(Map<String, dynamic> map) {
    return HallDecorations(
      corridorImageUrl: map['corridor_image_url'],
      corridorNotes: map['corridor_notes'],
      stairImageUrl: map['stair_image_url'],
      stairNotes: map['stair_notes'],
      entranceImageUrl: map['entrance_image_url'],
      entranceNotes: map['entrance_notes'],
    );
  }

  HallDecorations copyWith({
    String? corridorImageUrl,
    String? corridorNotes,
    String? stairImageUrl,
    String? stairNotes,
    String? entranceImageUrl,
    String? entranceNotes,
  }) {
    return HallDecorations(
      corridorImageUrl: corridorImageUrl ?? this.corridorImageUrl,
      corridorNotes: corridorNotes ?? this.corridorNotes,
      stairImageUrl: stairImageUrl ?? this.stairImageUrl,
      stairNotes: stairNotes ?? this.stairNotes,
      entranceImageUrl: entranceImageUrl ?? this.entranceImageUrl,
      entranceNotes: entranceNotes ?? this.entranceNotes,
    );
  }
}

// تفاصيل حفلة الرجال
class MenPartyDetails {
  String hallName;
  int numberOfDays;
  double amount;
  String? decorImageUrl;
  String? decorNotes;
  String notes;

  MenPartyDetails({
    required this.hallName,
    required this.numberOfDays,
    required this.amount,
    this.decorImageUrl,
    this.decorNotes,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'hall_name': hallName,
      'number_of_days': numberOfDays,
      'amount': amount,
      'decor_image_url': decorImageUrl,
      'decor_notes': decorNotes,
      'notes': notes,
    };
  }

  factory MenPartyDetails.fromMap(Map<String, dynamic> map) {
    return MenPartyDetails(
      hallName: map['hall_name'] ?? '',
      numberOfDays: map['number_of_days'] ?? 1,
      amount: map['amount']?.toDouble() ?? 0.0,
      decorImageUrl: map['decor_image_url'],
      decorNotes: map['decor_notes'],
      notes: map['notes'] ?? '',
    );
  }

  MenPartyDetails copyWith({
    String? hallName,
    int? numberOfDays,
    double? amount,
    String? decorImageUrl,
    String? decorNotes,
    String? notes,
  }) {
    return MenPartyDetails(
      hallName: hallName ?? this.hallName,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      amount: amount ?? this.amount,
      decorImageUrl: decorImageUrl ?? this.decorImageUrl,
      decorNotes: decorNotes ?? this.decorNotes,
      notes: notes ?? this.notes,
    );
  }
}

// تفاصيل حفلة التخرج
class GraduationDetails {
  String hallName;
  int femaleGraduates;
  int maleGraduates;
  String? corridorImageUrl;
  String? corridorDecorNotes;
  ChairOption? chairOption;
  String notes;
  double amount;

  GraduationDetails({
    required this.hallName,
    required this.femaleGraduates,
    required this.maleGraduates,
    this.corridorImageUrl,
    this.corridorDecorNotes,
    this.chairOption,
    this.notes = '',
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'hall_name': hallName,
      'female_graduates': femaleGraduates,
      'male_graduates': maleGraduates,
      'corridor_image_url': corridorImageUrl,
      'corridor_decor_notes': corridorDecorNotes,
      'chair_option': chairOption?.toMap(),
      'notes': notes,
      'amount': amount,
    };
  }

  factory GraduationDetails.fromMap(Map<String, dynamic> map) {
    return GraduationDetails(
      hallName: map['hall_name'] ?? '',
      femaleGraduates: map['female_graduates'] ?? 0,
      maleGraduates: map['male_graduates'] ?? 0,
      corridorImageUrl: map['corridor_image_url'],
      corridorDecorNotes: map['corridor_decor_notes'],
      chairOption: map['chair_option'] != null
          ? ChairOption.fromMap(map['chair_option'])
          : null,
      notes: map['notes'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
    );
  }

  GraduationDetails copyWith({
    String? hallName,
    int? femaleGraduates,
    int? maleGraduates,
    String? corridorImageUrl,
    String? corridorDecorNotes,
    ChairOption? chairOption,
    String? notes,
    double? amount,
  }) {
    return GraduationDetails(
      hallName: hallName ?? this.hallName,
      femaleGraduates: femaleGraduates ?? this.femaleGraduates,
      maleGraduates: maleGraduates ?? this.maleGraduates,
      corridorImageUrl: corridorImageUrl ?? this.corridorImageUrl,
      corridorDecorNotes: corridorDecorNotes ?? this.corridorDecorNotes,
      chairOption: chairOption ?? this.chairOption,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
    );
  }
}

class ChairOption {
  bool isSelected;
  int chairCount;
  String notes;
  List<String> imageUrls;

  ChairOption({
    this.isSelected = false,
    this.chairCount = 0,
    this.notes = '',
    this.imageUrls = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'is_selected': isSelected,
      'chair_count': chairCount,
      'notes': notes,
      'image_urls': imageUrls,
    };
  }

  factory ChairOption.fromMap(Map<String, dynamic> map) {
    return ChairOption(
      isSelected: map['is_selected'] ?? false,
      chairCount: map['chair_count'] ?? 0,
      notes: map['notes'] ?? '',
      imageUrls: List<String>.from(map['image_urls'] ?? []),
    );
  }

  ChairOption copyWith({
    bool? isSelected,
    int? chairCount,
    String? notes,
    List<String>? imageUrls,
  }) {
    return ChairOption(
      isSelected: isSelected ?? this.isSelected,
      chairCount: chairCount ?? this.chairCount,
      notes: notes ?? this.notes,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

// اختيار الطاولات والكراسي
class TableChairSelection {
  String tableType;
  int tableCount;
  String tableNotes;
  String chairType;
  int chairCount;
  String chairNotes;
  String? imageUrl;
  String notes;

  TableChairSelection({
    this.tableType = '',
    this.tableCount = 0,
    this.tableNotes = '',
    this.chairType = '',
    this.chairCount = 0,
    this.chairNotes = '',
    this.imageUrl,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'table_type': tableType,
      'table_count': tableCount,
      'table_notes': tableNotes,
      'chair_type': chairType,
      'chair_count': chairCount,
      'chair_notes': chairNotes,
      'image_url': imageUrl,
      'notes': notes,
    };
  }

  factory TableChairSelection.fromMap(Map<String, dynamic> map) {
    return TableChairSelection(
      tableType: map['table_type'] ?? '',
      tableCount: map['table_count'] ?? 0,
      tableNotes: map['table_notes'] ?? '',
      chairType: map['chair_type'] ?? '',
      chairCount: map['chair_count'] ?? 0,
      chairNotes: map['chair_notes'] ?? '',
      imageUrl: map['image_url'],
      notes: map['notes'] ?? '',
    );
  }

  TableChairSelection copyWith({
    String? tableType,
    int? tableCount,
    String? tableNotes,
    String? chairType,
    int? chairCount,
    String? chairNotes,
    String? imageUrl,
    String? notes,
  }) {
    return TableChairSelection(
      tableType: tableType ?? this.tableType,
      tableCount: tableCount ?? this.tableCount,
      tableNotes: tableNotes ?? this.tableNotes,
      chairType: chairType ?? this.chairType,
      chairCount: chairCount ?? this.chairCount,
      chairNotes: chairNotes ?? this.chairNotes,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
    );
  }
}


