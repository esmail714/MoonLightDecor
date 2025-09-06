import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import '../models/image_data.dart';
import '../models/enums.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';

class BookingProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  List<Booking> _bookings = [];
  List<Booking> _filteredBookings = [];
  Booking? _currentBooking;
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<Booking> get bookings => _filteredBookings;
  Booking? get currentBooking => _currentBooking;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // تحميل جميع الحجوزات
  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _databaseService.getAllBookings();
      _applyFilter();
    } catch (e) {
      debugPrint('خطأ في تحميل الحجوزات: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // البحث في الحجوزات
  void searchBookings(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  // تطبيق الفلتر
  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredBookings = List.from(_bookings);
    } else {
      _filteredBookings = _bookings.where((booking) {
        return booking.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               booking.phoneNumber.contains(_searchQuery) ||
               booking.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  // إنشاء حجز جديد
  Booking createNewBooking() {
    final now = DateTime.now();
    return Booking(
      id: _uuid.v4(),
      invoiceNumber: '', // سيتم توليده تلقائياً
      customerName: '',
      phoneNumber: '',
      createdDate: now,
      eventDate: now.add(const Duration(days: 1)),
      eventType: EventType.women,
      responsibleEmployee: 'المدير', // قيمة افتراضية
      createdAt: now,
      updatedAt: now,
      createdBy: 'النظام', // سيتم تحديثه لاحقاً
      updatedBy: 'النظام',
    );
  }

  // تعيين الحجز الحالي
  void setCurrentBooking(Booking? booking) {
    _currentBooking = booking;
    notifyListeners();
  }

  // إضافة حجز جديد
  Future<void> addBooking(Booking booking) async {
    _isLoading = true;
    notifyListeners();
    try {
      booking.invoiceNumber = await _databaseService.generateInvoiceNumber();
      booking.totalAmount = _calculateTotalAmount(booking);
      await _databaseService.insertBooking(booking);
      _bookings.insert(0, booking);
      _applyFilter();
    } catch (e) {
      debugPrint("خطأ في إضافة الحجز: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحديث حجز موجود
  Future<void> updateBooking(Booking booking) async {
    _isLoading = true;
    notifyListeners();
    try {
      booking.updatedAt = DateTime.now();
      booking.totalAmount = _calculateTotalAmount(booking);
      await _databaseService.updateBooking(booking);
      final index = _bookings.indexWhere((b) => b.id == booking.id);
      if (index != -1) {
        _bookings[index] = booking;
      }
      _applyFilter();
    } catch (e) {
      debugPrint("خطأ في تحديث الحجز: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // حذف حجز
  Future<bool> deleteBooking(String bookingId) async {
    try {
      await _databaseService.deleteBooking(bookingId);
      
      _bookings.removeWhere((booking) => booking.id == bookingId);
      _applyFilter();
      
      if (_currentBooking?.id == bookingId) {
        _currentBooking = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('خطأ في حذف الحجز: $e');
      return false;
    }
  }

  // الحصول على الحجوزات في تاريخ معين
  Future<List<Booking>> getBookingsByDate(DateTime date) async {
    try {
      return await _databaseService.getBookingsByDate(date);
    } catch (e) {
      debugPrint('خطأ في الحصول على حجوزات التاريخ: $e');
      return [];
    }
  }

  // إضافة حجز فرعي
  Future<bool> addSubBooking(String parentBookingId, Booking subBooking) async {
    try {
      subBooking.parentBookingId = parentBookingId;
      await addBooking(subBooking);
      return true;
    } catch (e) {
      debugPrint('خطأ في إضافة الحجز الفرعي: $e');
      return false;
    }
  }

  // الحصول على الحجوزات الفرعية
  Future<List<Booking>> getSubBookings(String parentBookingId) async {
    try {
      return await _databaseService.getSubBookings(parentBookingId);
    } catch (e) {
      debugPrint('خطأ في الحصول على الحجوزات الفرعية: $e');
      return [];
    }
  }

  // إضافة دفعة
  Future<bool> addPayment(String bookingId, Payment payment) async {
    try {
      await _databaseService.insertPayment(payment);
      
      // تحديث الحجز في القائمة المحلية
      final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        final payments = await _databaseService.getBookingPayments(bookingId);
        final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amount);
        _bookings[bookingIndex].paidAmount = totalPaid;
        _bookings[bookingIndex].paymentStatus = _bookings[bookingIndex].calculatedPaymentStatus;
        
        if (_currentBooking?.id == bookingId) {
          _currentBooking!.paidAmount = totalPaid;
          _currentBooking!.paymentStatus = _currentBooking!.calculatedPaymentStatus;
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('خطأ في إضافة الدفعة: $e');
      return false;
    }
  }

  // تحديث دفعة موجودة
  Future<bool> updatePayment(Payment payment) async {
    try {
      await _databaseService.updatePayment(payment);
      
      // تحديث الحجز المرتبط
      final bookingIndex = _bookings.indexWhere((b) => b.id == payment.bookingId);
      if (bookingIndex != -1) {
        final payments = await _databaseService.getBookingPayments(payment.bookingId);
        final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amount);
        _bookings[bookingIndex].paidAmount = totalPaid;
        _bookings[bookingIndex].paymentStatus = _bookings[bookingIndex].calculatedPaymentStatus;
        
        if (_currentBooking?.id == payment.bookingId) {
          _currentBooking!.paidAmount = totalPaid;
          _currentBooking!.paymentStatus = _currentBooking!.calculatedPaymentStatus;
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('خطأ في تحديث الدفعة: $e');
      return false;
    }
  }

  // حذف دفعة
  Future<bool> deletePayment(String paymentId, String bookingId) async {
    try {
      await _databaseService.deletePayment(paymentId);
      
      // تحديث الحجز المرتبط
      final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        final payments = await _databaseService.getBookingPayments(bookingId);
        final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amount);
        _bookings[bookingIndex].paidAmount = totalPaid;
        _bookings[bookingIndex].paymentStatus = _bookings[bookingIndex].calculatedPaymentStatus;
        
        if (_currentBooking?.id == bookingId) {
          _currentBooking!.paidAmount = totalPaid;
          _currentBooking!.paymentStatus = _currentBooking!.calculatedPaymentStatus;
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('خطأ في حذف الدفعة: $e');
      return false;
    }
  }

  // الحصول على دفعات حجز
  Future<List<Payment>> getBookingPayments(String bookingId) async {
    try {
      return await _databaseService.getBookingPayments(bookingId);
    } catch (e) {
      debugPrint('خطأ في الحصول على الدفعات: $e');
      return [];
    }
  }

  // حساب المبلغ الإجمالي
  double _calculateTotalAmount(Booking booking) {
    double total = 0.0;

    // إضافات الأثاث والخدمات
    if (booking.goldStand?.isSelected == true) {
      total += booking.goldStand!.amount;
    }
    if (booking.tables?.isSelected == true) {
      total += booking.tables!.amount;
    }
    if (booking.printing?.isSelected == true) {
      total += booking.printing!.amount;
    }
    if (booking.speaker?.isSelected == true) {
      total += booking.speaker!.amount;
    }

    // الأجهزة الخاصة
    if (booking.specialDevices != null) {
      if (booking.specialDevices!.smokeDevice?.isSelected == true) {
        total += booking.specialDevices!.smokeDevice!.amount;
      }
      if (booking.specialDevices!.laserDevice?.isSelected == true) {
        total += booking.specialDevices!.laserDevice!.amount;
      }
      if (booking.specialDevices!.followDevice?.isSelected == true) {
        total += booking.specialDevices!.followDevice!.amount;
      }
    }

    // تفاصيل حسب نوع الحفلة
    switch (booking.eventType) {
      case EventType.men:
        if (booking.menDetails != null) {
          total += booking.menDetails!.amount;
        }
        break;
      case EventType.graduation:
        if (booking.graduationDetails != null) {
          total += booking.graduationDetails!.amount;
        }
        break;
      case EventType.women:
        // للنساء قد يكون هناك تكاليف إضافية حسب نوع الديكور
        break;
    }

    return total;
  }

  // الحصول على إحصائيات سريعة
  Map<String, dynamic> getQuickStats() {
    final totalBookings = _bookings.length;
    final readyBookings = _bookings.where((b) => b.status == BookingStatus.ready).length;
    final inProgressBookings = _bookings.where((b) => b.status == BookingStatus.inProgress).length;
    final completedBookings = _bookings.where((b) => b.status == BookingStatus.completed).length;
    
    final totalRevenue = _bookings.fold<double>(0, (sum, b) => sum + b.totalAmount);
    final totalPaid = _bookings.fold<double>(0, (sum, b) => sum + b.paidAmount);
    final totalRemaining = totalRevenue - totalPaid;

    return {
      'totalBookings': totalBookings,
      'readyBookings': readyBookings,
      'inProgressBookings': inProgressBookings,
      'completedBookings': completedBookings,
      'totalRevenue': totalRevenue,
      'totalPaid': totalPaid,
      'totalRemaining': totalRemaining,
    };
  }

  // تحديث حالة الحجز
  Future<bool> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    try {
      final bookingIndex = _bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        _bookings[bookingIndex].status = newStatus;
        _bookings[bookingIndex].updatedAt = DateTime.now();
        
        await _databaseService.updateBooking(_bookings[bookingIndex]);
        
        if (_currentBooking?.id == bookingId) {
          _currentBooking!.status = newStatus;
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('خطأ في تحديث حالة الحجز: $e');
      return false;
    }
  }

  // === وظائف إدارة الصور ===

  final ImageService _imageService = ImageService();

  // إضافة صورة لحجز
  Future<bool> addImageToBooking(String bookingId, String imagePath, {String? description, String? addOnId}) async {
    try {
      final now = DateTime.now();
      final imageData = ImageData(
        id: _uuid.v4(),
        bookingId: bookingId,
        addOnId: addOnId,
        imagePath: imagePath,
        description: description,
        createdAt: now,
        updatedAt: now,
        createdBy: 'المستخدم',
        updatedBy: 'المستخدم',
      );

      await _databaseService.insertImage(imageData);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('خطأ في إضافة الصورة: $e');
      return false;
    }
  }

  // إضافة صور متعددة لحجز
  Future<bool> addMultipleImagesToBooking(String bookingId, List<String> imagePaths, {String? addOnId}) async {
    try {
      for (String imagePath in imagePaths) {
        await addImageToBooking(bookingId, imagePath, addOnId: addOnId);
      }
      return true;
    } catch (e) {
      debugPrint('خطأ في إضافة الصور المتعددة: $e');
      return false;
    }
  }

  // الحصول على صور حجز
  Future<List<ImageData>> getBookingImages(String bookingId) async {
    try {
      return await _databaseService.getBookingImages(bookingId);
    } catch (e) {
      debugPrint('خطأ في الحصول على صور الحجز: $e');
      return [];
    }
  }

  // الحصول على صور إضافة معينة
  Future<List<ImageData>> getAddOnImages(String addOnId) async {
    try {
      return await _databaseService.getAddOnImages(addOnId);
    } catch (e) {
      debugPrint('خطأ في الحصول على صور الإضافة: $e');
      return [];
    }
  }

  // حذف صورة
  Future<bool> deleteImage(ImageData image) async {
    try {
      // حذف الصورة من قاعدة البيانات
      await _databaseService.deleteImage(image.id);
      
      // حذف الملف من التخزين
      await _imageService.deleteImage(image.imagePath);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('خطأ في حذف الصورة: $e');
      return false;
    }
  }

  // حذف جميع صور حجز
  Future<bool> deleteAllBookingImages(String bookingId) async {
    try {
      // الحصول على جميع صور الحجز
      final images = await getBookingImages(bookingId);
      
      // حذف الملفات من التخزين
      for (ImageData image in images) {
        await _imageService.deleteImage(image.imagePath);
      }
      
      // حذف السجلات من قاعدة البيانات
      await _databaseService.deleteBookingImages(bookingId);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('خطأ في حذف جميع صور الحجز: $e');
      return false;
    }
  }

  // تحديث وصف الصورة
  Future<bool> updateImageDescription(String imageId, String description) async {
    try {
      final image = await _databaseService.getImageById(imageId);
      if (image != null) {
        final updatedImage = image.copyWith(
          description: description,
          updatedAt: DateTime.now(),
          updatedBy: 'المستخدم',
        );
        await _databaseService.updateImage(updatedImage);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('خطأ في تحديث وصف الصورة: $e');
      return false;
    }
  }

  // الحصول على عدد صور الحجز
  Future<int> getBookingImagesCount(String bookingId) async {
    try {
      return await _databaseService.getBookingImagesCount(bookingId);
    } catch (e) {
      debugPrint('خطأ في الحصول على عدد صور الحجز: $e');
      return 0;
    }
  }

  // تنظيف الصور غير المستخدمة
  Future<void> cleanupUnusedImages() async {
    try {
      final allImages = await _databaseService.getAllImages();
      final usedImagePaths = allImages.map((img) => img.imagePath).toList();
      await _imageService.cleanupUnusedImages(usedImagePaths);
    } catch (e) {
      debugPrint('خطأ في تنظيف الصور غير المستخدمة: $e');
    }
  }
}

