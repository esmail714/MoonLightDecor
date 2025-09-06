import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import '../models/image_data.dart';
import '../models/enums.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'event_booking.db';
  static const int _databaseVersion = 1;

  // جداول قاعدة البيانات
  static const String _bookingsTable = 'bookings';
  static const String _paymentsTable = 'payments';
  static const String _imagesTable = 'images';

  // الحصول على قاعدة البيانات
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // تهيئة قاعدة البيانات
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // إنشاء الجداول
  Future<void> _onCreate(Database db, int version) async {
    // جدول الحجوزات
    await db.execute('''
      CREATE TABLE $_bookingsTable (
        id TEXT PRIMARY KEY,
        invoice_number TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        created_date INTEGER NOT NULL,
        event_date INTEGER NOT NULL,
        event_type TEXT NOT NULL,
        responsible_employee TEXT NOT NULL,
        general_notes TEXT,
        status TEXT NOT NULL,
        parent_booking_id TEXT,
        gold_stand TEXT,
        tables TEXT,
        printing TEXT,
        speaker TEXT,
        special_devices TEXT,
        women_details TEXT,
        men_details TEXT,
        graduation_details TEXT,
        table_chair_selection TEXT,
        total_amount REAL NOT NULL DEFAULT 0,
        paid_amount REAL NOT NULL DEFAULT 0,
        payment_status TEXT NOT NULL DEFAULT 'pending',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        created_by TEXT NOT NULL,
        updated_by TEXT NOT NULL
      )
    ''');

    // جدول الدفعات
    await db.execute('''
      CREATE TABLE $_paymentsTable (
        id TEXT PRIMARY KEY,
        booking_id TEXT NOT NULL,
        payment_date INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        amount REAL NOT NULL,
        notes TEXT,
        check_number TEXT,
        card_last_four TEXT,
        reference_number TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        created_by TEXT NOT NULL,
        updated_by TEXT NOT NULL,
        FOREIGN KEY (booking_id) REFERENCES $_bookingsTable (id) ON DELETE CASCADE
      )
    ''');

    // جدول الصور
    await db.execute('''
      CREATE TABLE $_imagesTable (
        id TEXT PRIMARY KEY,
        booking_id TEXT NOT NULL,
        add_on_id TEXT,
        image_path TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        created_by TEXT NOT NULL,
        updated_by TEXT NOT NULL,
        FOREIGN KEY (booking_id) REFERENCES $_bookingsTable (id) ON DELETE CASCADE
      )
    ''');
      // فهارس لتحسين الأداء
    await db.execute('CREATE INDEX idx_bookings_event_date ON $_bookingsTable (event_date)');
    await db.execute('CREATE INDEX idx_bookings_status ON $_bookingsTable (status)');
    await db.execute('CREATE INDEX idx_bookings_customer ON $_bookingsTable (customer_name)');
    await db.execute('CREATE INDEX idx_payments_booking ON $_paymentsTable (booking_id)');
    await db.execute('CREATE INDEX idx_images_booking ON $_imagesTable (booking_id)');
  }

  // ترقية قاعدة البيانات
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // سيتم إضافة منطق الترقية هنا عند الحاجة
  }

  // تحويل الكائنات المعقدة إلى JSON للتخزين
  String? _encodeJson(dynamic object) {
    if (object == null) return null;
    return jsonEncode(object.toMap());
  }

  // تحويل JSON إلى Map
  Map<String, dynamic>? _decodeJson(String? jsonString) {
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  // === عمليات الحجوزات ===

  // إضافة حجز جديد
  Future<String> insertBooking(Booking booking) async {
    final db = await database;
    
    final bookingMap = booking.toMap();
    
    // تحويل الكائنات المعقدة إلى JSON
    bookingMap['gold_stand'] = _encodeJson(booking.goldStand);
    bookingMap['tables'] = _encodeJson(booking.tables);
    bookingMap['printing'] = _encodeJson(booking.printing);
    bookingMap['speaker'] = _encodeJson(booking.speaker);
    bookingMap['special_devices'] = _encodeJson(booking.specialDevices);
    bookingMap['women_details'] = _encodeJson(booking.womenDetails);
    bookingMap['men_details'] = _encodeJson(booking.menDetails);
    bookingMap['graduation_details'] = _encodeJson(booking.graduationDetails);
    bookingMap['table_chair_selection'] = _encodeJson(booking.tableChairSelection);
    
    await db.insert(_bookingsTable, bookingMap);
    return booking.id;
  }

  // تحديث حجز
  Future<void> updateBooking(Booking booking) async {
    final db = await database;
    
    final bookingMap = booking.toMap();
    
    // تحويل الكائنات المعقدة إلى JSON
    bookingMap['gold_stand'] = _encodeJson(booking.goldStand);
    bookingMap['tables'] = _encodeJson(booking.tables);
    bookingMap['printing'] = _encodeJson(booking.printing);
    bookingMap['speaker'] = _encodeJson(booking.speaker);
    bookingMap['special_devices'] = _encodeJson(booking.specialDevices);
    bookingMap['women_details'] = _encodeJson(booking.womenDetails);
    bookingMap['men_details'] = _encodeJson(booking.menDetails);
    bookingMap['graduation_details'] = _encodeJson(booking.graduationDetails);
    bookingMap['table_chair_selection'] = _encodeJson(booking.tableChairSelection);
    
    await db.update(
      _bookingsTable,
      bookingMap,
      where: 'id = ?',
      whereArgs: [booking.id],
    );
  }

  // حذف حجز
  Future<void> deleteBooking(String bookingId) async {
    final db = await database;
    await db.delete(
      _bookingsTable,
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  // الحصول على حجز بالمعرف
  Future<Booking?> getBooking(String bookingId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _bookingsTable,
      where: 'id = ?',
      whereArgs: [bookingId],
    );

    if (maps.isNotEmpty) {
      return _mapToBooking(maps.first);
    }
    return null;
  }

  // الحصول على جميع الحجوزات
  Future<List<Booking>> getAllBookings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _bookingsTable,
      orderBy: 'event_date DESC',
    );

    return maps.map((map) => _mapToBooking(map)).toList();
  }

  // البحث في الحجوزات
  Future<List<Booking>> searchBookings(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _bookingsTable,
      where: 'customer_name LIKE ? OR phone_number LIKE ? OR invoice_number LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'event_date DESC',
    );

    return maps.map((map) => _mapToBooking(map)).toList();
  }

  // الحصول على الحجوزات في تاريخ معين
  Future<List<Booking>> getBookingsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      _bookingsTable,
      where: 'event_date >= ? AND event_date <= ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      orderBy: 'event_date ASC',
    );

    return maps.map((map) => _mapToBooking(map)).toList();
  }

  // الحصول على الحجوزات الفرعية
  Future<List<Booking>> getSubBookings(String parentBookingId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _bookingsTable,
      where: 'parent_booking_id = ?',
      whereArgs: [parentBookingId],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => _mapToBooking(map)).toList();
  }

  // تحويل Map إلى Booking
  Booking _mapToBooking(Map<String, dynamic> map) {
    // تحويل JSON إلى كائنات
    final goldStandMap = _decodeJson(map['gold_stand']);
    final tablesMap = _decodeJson(map['tables']);
    final printingMap = _decodeJson(map['printing']);
    final speakerMap = _decodeJson(map['speaker']);
    final specialDevicesMap = _decodeJson(map['special_devices']);
    final womenDetailsMap = _decodeJson(map['women_details']);
    final menDetailsMap = _decodeJson(map['men_details']);
    final graduationDetailsMap = _decodeJson(map['graduation_details']);
    final tableChairSelectionMap = _decodeJson(map['table_chair_selection']);

    return Booking(
      id: map['id'],
      invoiceNumber: map['invoice_number'],
      customerName: map['customer_name'],
      phoneNumber: map['phone_number'],
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['created_date']),
      eventDate: DateTime.fromMillisecondsSinceEpoch(map['event_date']),
      eventType: EventType.values.firstWhere(
        (e) => e.name == map['event_type'],
        orElse: () => EventType.women,
      ),
      responsibleEmployee: map['responsible_employee'],
      generalNotes: map['general_notes'] ?? '',
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.ready,
      ),
      parentBookingId: map['parent_booking_id'],
      goldStand: goldStandMap != null ? GoldStand.fromMap(goldStandMap) : null,
      tables: tablesMap != null ? Tables.fromMap(tablesMap) : null,
      printing: printingMap != null ? Printing.fromMap(printingMap) : null,
      speaker: speakerMap != null ? Speaker.fromMap(speakerMap) : null,
      specialDevices: specialDevicesMap != null ? SpecialDevices.fromMap(specialDevicesMap) : null,
      womenDetails: womenDetailsMap != null ? WomenPartyDetails.fromMap(womenDetailsMap) : null,
      menDetails: menDetailsMap != null ? MenPartyDetails.fromMap(menDetailsMap) : null,
      graduationDetails: graduationDetailsMap != null ? GraduationDetails.fromMap(graduationDetailsMap) : null,
      tableChairSelection: tableChairSelectionMap != null ? TableChairSelection.fromMap(tableChairSelectionMap) : null,
      totalAmount: map['total_amount']?.toDouble() ?? 0.0,
      paidAmount: map['paid_amount']?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      createdBy: map['created_by'],
      updatedBy: map['updated_by'],
    );
  }

  // === عمليات الدفعات ===

  // إضافة دفعة جديدة
  Future<String> insertPayment(Payment payment) async {
    final db = await database;
    await db.insert(_paymentsTable, payment.toMap());
    
    // تحديث المبلغ المدفوع في الحجز
    await _updateBookingPaidAmount(payment.bookingId);
    
    return payment.id;
  }

  // تحديث دفعة موجودة
  Future<void> updatePayment(Payment payment) async {
    final db = await database;
    await db.update(
      _paymentsTable,
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
    
    // تحديث المبلغ المدفوع في الحجز
    await _updateBookingPaidAmount(payment.bookingId);
  }

  // حذف دفعة
  Future<void> deletePayment(String paymentId) async {
    final db = await database;
    
    // الحصول على معرف الحجز قبل الحذف
    final paymentMaps = await db.query(
      _paymentsTable,
      columns: ['booking_id'],
      where: 'id = ?',
      whereArgs: [paymentId],
    );
    
    if (paymentMaps.isNotEmpty) {
      final bookingId = paymentMaps.first['booking_id'] as String;
      
      await db.delete(
        _paymentsTable,
        where: 'id = ?',
        whereArgs: [paymentId],
      );
      
      // تحديث المبلغ المدفوع في الحجز
      await _updateBookingPaidAmount(bookingId);
    }
  }

  // الحصول على دفعات حجز معين
  Future<List<Payment>> getBookingPayments(String bookingId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _paymentsTable,
      where: 'booking_id = ?',
      whereArgs: [bookingId],
      orderBy: 'payment_date DESC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  // تحديث المبلغ المدفوع في الحجز
  Future<void> _updateBookingPaidAmount(String bookingId) async {
    final db = await database;
    
    // حساب إجمالي المدفوع
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $_paymentsTable WHERE booking_id = ?',
      [bookingId],
    );
    
    final totalPaid = result.first['total'] as double? ?? 0.0;
    
    // تحديث الحجز
    await db.update(
      _bookingsTable,
      {'paid_amount': totalPaid},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  // توليد رقم فاتورة تلقائي
  Future<String> generateInvoiceNumber() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_bookingsTable',
    );
    
    final count = result.first['count'] as int? ?? 0;
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${(count + 1).toString().padLeft(4, '0')}';
  }

  // إغلاق قاعدة البيانات
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // === عمليات الصور ===

  // إضافة صورة جديدة
  Future<String> insertImage(ImageData image) async {
    final db = await database;
    await db.insert(_imagesTable, image.toMap());
    return image.id;
  }

  // تحديث صورة موجودة
  Future<void> updateImage(ImageData image) async {
    final db = await database;
    await db.update(
      _imagesTable,
      image.toMap(),
      where: 'id = ?',
      whereArgs: [image.id],
    );
  }

  // حذف صورة
  Future<void> deleteImage(String imageId) async {
    final db = await database;
    await db.delete(
      _imagesTable,
      where: 'id = ?',
      whereArgs: [imageId],
    );
  }

  // الحصول على صور حجز معين
  Future<List<ImageData>> getBookingImages(String bookingId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _imagesTable,
      where: 'booking_id = ?',
      whereArgs: [bookingId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ImageData.fromMap(map)).toList();
  }

  // الحصول على صور إضافة معينة
  Future<List<ImageData>> getAddOnImages(String addOnId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _imagesTable,
      where: 'add_on_id = ?',
      whereArgs: [addOnId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ImageData.fromMap(map)).toList();
  }

  // الحصول على صورة بالمعرف
  Future<ImageData?> getImageById(String imageId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _imagesTable,
      where: 'id = ?',
      whereArgs: [imageId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ImageData.fromMap(maps.first);
    }
    return null;
  }

  // حذف جميع صور حجز معين
  Future<void> deleteBookingImages(String bookingId) async {
    final db = await database;
    await db.delete(
      _imagesTable,
      where: 'booking_id = ?',
      whereArgs: [bookingId],
    );
  }

  // حذف جميع صور إضافة معينة
  Future<void> deleteAddOnImages(String addOnId) async {
    final db = await database;
    await db.delete(
      _imagesTable,
      where: 'add_on_id = ?',
      whereArgs: [addOnId],
    );
  }

  // الحصول على جميع الصور
  Future<List<ImageData>> getAllImages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _imagesTable,
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ImageData.fromMap(map)).toList();
  }

  // البحث في الصور
  Future<List<ImageData>> searchImages(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _imagesTable,
      where: 'description LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ImageData.fromMap(map)).toList();
  }

  // الحصول على عدد الصور لحجز معين
  Future<int> getBookingImagesCount(String bookingId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_imagesTable WHERE booking_id = ?',
      [bookingId],
    );
    return result.first['count'] as int;
  }


}


  // دوال سجل الأنشطة (Audit Log)
  Future<void> insertAuditLog(AuditLog auditLog) async {
    final db = await database;
    await db.insert('audit_logs', auditLog.toMap());
  }

  Future<List<AuditLog>> getAuditLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audit_logs',
      orderBy: 'timestamp DESC',
      limit: 1000,
    );
    return List.generate(maps.length, (i) => AuditLog.fromMap(maps[i]));
  }

  Future<List<AuditLog>> getAuditLogsByEntity(String entityType, int entityId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audit_logs',
      where: 'entity_type = ? AND entity_id = ?',
      whereArgs: [entityType, entityId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => AuditLog.fromMap(maps[i]));
  }

  Future<List<AuditLog>> getAuditLogsByUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audit_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => AuditLog.fromMap(maps[i]));
  }

  Future<List<AuditLog>> getAuditLogsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'audit_logs',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => AuditLog.fromMap(maps[i]));
  }
}

