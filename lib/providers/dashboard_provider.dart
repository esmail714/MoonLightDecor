import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import '../models/enums.dart';
import '../services/database_service.dart';

class DashboardProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  // الإحصائيات الأساسية
  int _totalBookings = 0;
  double _totalRevenue = 0.0;
  int _upcomingBookings = 0;
  double _averageBookingValue = 0.0;
  
  // بيانات الرسوم البيانية
  Map<String, int> _monthlyBookings = {};
  Map<String, double> _monthlyRevenue = {};
  Map<EventType, int> _eventTypeDistribution = {};
  
  bool _isLoading = false;
  
  // Getters
  int get totalBookings => _totalBookings;
  double get totalRevenue => _totalRevenue;
  int get upcomingBookings => _upcomingBookings;
  double get averageBookingValue => _averageBookingValue;
  Map<String, int> get monthlyBookings => _monthlyBookings;
  Map<String, double> get monthlyRevenue => _monthlyRevenue;
  Map<EventType, int> get eventTypeDistribution => _eventTypeDistribution;
  bool get isLoading => _isLoading;
  
  // تحميل جميع الإحصائيات
  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await Future.wait([
        _loadBasicStats(),
        _loadMonthlyData(),
        _loadEventTypeDistribution(),
      ]);
    } catch (e) {
      debugPrint('خطأ في تحميل بيانات لوحة المعلومات: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // تحميل الإحصائيات الأساسية
  Future<void> _loadBasicStats() async {
    final bookings = await _databaseService.getBookings();
    final payments = await _databaseService.getAllPayments();
    
    _totalBookings = bookings.length;
    _totalRevenue = payments.fold(0.0, (sum, payment) => sum + payment.amount);
    
    // حساب الحجوزات القادمة (خلال الشهر القادم)
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, now.day);
    _upcomingBookings = bookings.where((booking) => 
      booking.eventDate.isAfter(now) && booking.eventDate.isBefore(nextMonth)
    ).length;
    
    // حساب متوسط قيمة الحجز
    if (_totalBookings > 0) {
      final totalBookingValue = bookings.fold(0.0, (sum, booking) => sum + booking.totalAmount);
      _averageBookingValue = totalBookingValue / _totalBookings;
    } else {
      _averageBookingValue = 0.0;
    }
  }
  
  // تحميل البيانات الشهرية
  Future<void> _loadMonthlyData() async {
    final bookings = await _databaseService.getBookings();
    final payments = await _databaseService.getAllPayments();
    
    // إعادة تعيين البيانات
    _monthlyBookings.clear();
    _monthlyRevenue.clear();
    
    // تجميع الحجوزات حسب الشهر
    for (final booking in bookings) {
      final monthKey = '${booking.eventDate.year}-${booking.eventDate.month.toString().padLeft(2, '0')}';
      _monthlyBookings[monthKey] = (_monthlyBookings[monthKey] ?? 0) + 1;
    }
    
    // تجميع الإيرادات حسب الشهر
    for (final payment in payments) {
      final monthKey = '${payment.paymentDate.year}-${payment.paymentDate.month.toString().padLeft(2, '0')}';
      _monthlyRevenue[monthKey] = (_monthlyRevenue[monthKey] ?? 0.0) + payment.amount;
    }
  }
  
  // تحميل توزيع أنواع الحفلات
  Future<void> _loadEventTypeDistribution() async {
    final bookings = await _databaseService.getBookings();
    
    _eventTypeDistribution.clear();
    
    for (final booking in bookings) {
      _eventTypeDistribution[booking.eventType] = 
        (_eventTypeDistribution[booking.eventType] ?? 0) + 1;
    }
  }
  
  // الحصول على أحدث الحجوزات
  Future<List<Booking>> getRecentBookings({int limit = 5}) async {
    final bookings = await _databaseService.getBookings();
    bookings.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return bookings.take(limit).toList();
  }
  
  // الحصول على الحجوزات القادمة
  Future<List<Booking>> getUpcomingBookings({int limit = 5}) async {
    final bookings = await _databaseService.getBookings();
    final now = DateTime.now();
    final upcomingBookings = bookings.where((booking) => 
      booking.eventDate.isAfter(now)
    ).toList();
    upcomingBookings.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return upcomingBookings.take(limit).toList();
  }
  
  // الحصول على إحصائيات الدفعات
  Future<Map<String, dynamic>> getPaymentStats() async {
    final payments = await _databaseService.getAllPayments();
    
    final stats = <String, dynamic>{};
    
    // إجمالي المدفوعات
    stats['totalPaid'] = payments.fold(0.0, (sum, payment) => sum + payment.amount);
    
    // عدد الدفعات
    stats['totalPayments'] = payments.length;
    
    // متوسط قيمة الدفعة
    stats['averagePayment'] = payments.isNotEmpty ? 
      stats['totalPaid'] / payments.length : 0.0;
    
    // توزيع طرق الدفع
    final paymentMethods = <PaymentMethod, int>{};
    for (final payment in payments) {
      paymentMethods[payment.paymentMethod] = 
        (paymentMethods[payment.paymentMethod] ?? 0) + 1;
    }
    stats['paymentMethods'] = paymentMethods;
    
    return stats;
  }
  
  // الحصول على بيانات الرسم البياني للأشهر الستة الماضية
  List<Map<String, dynamic>> getLastSixMonthsData() {
    final now = DateTime.now();
    final data = <Map<String, dynamic>>[];
    
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      data.add({
        'month': _getMonthName(date.month),
        'bookings': _monthlyBookings[monthKey] ?? 0,
        'revenue': _monthlyRevenue[monthKey] ?? 0.0,
      });
    }
    
    return data;
  }
  
  // الحصول على اسم الشهر بالعربية
  String _getMonthName(int month) {
    const monthNames = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return monthNames[month];
  }
}

