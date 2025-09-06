import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/booking.dart';
import '../models/customer.dart';
import '../models/employee.dart';
import '../models/payment.dart';
import '../models/lost_item.dart';
import '../models/audit_log.dart';

class ExportService {
  
  Future<String> exportBookingsToCSV(List<Booking> bookings) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/bookings_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    
    final csvContent = StringBuffer();
    
    // إضافة العناوين
    csvContent.writeln('ID,اسم العميل,نوع الحفلة,تاريخ الحفلة,وقت الحفلة,المكان,عدد الضيوف,السعر الإجمالي,المبلغ المدفوع,المبلغ المتبقي,الحالة,تاريخ الإنشاء');
    
    // إضافة البيانات
    for (final booking in bookings) {
      csvContent.writeln([
        booking.id,
        _escapeCsvField(booking.customerName),
        _escapeCsvField(booking.eventType),
        booking.eventDate,
        booking.eventTime,
        _escapeCsvField(booking.location),
        booking.guestCount,
        booking.totalPrice,
        booking.paidAmount,
        booking.remainingAmount,
        _escapeCsvField(booking.status),
        booking.createdAt,
      ].join(','));
    }
    
    await file.writeAsString(csvContent.toString());
    return file.path;
  }
  
  Future<String> exportCustomersToCSV(List<Customer> customers) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/customers_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    
    final csvContent = StringBuffer();
    
    // إضافة العناوين
    csvContent.writeln('ID,الاسم,رقم الجوال,البريد الإلكتروني,العنوان,عدد الحجوزات,إجمالي المبلغ المدفوع,تاريخ الإنشاء');
    
    // إضافة البيانات
    for (final customer in customers) {
      csvContent.writeln([
        customer.id,
        _escapeCsvField(customer.name),
        _escapeCsvField(customer.phone),
        _escapeCsvField(customer.email ?? ''),
        _escapeCsvField(customer.address ?? ''),
        customer.totalBookings,
        customer.totalPaid,
        customer.createdAt,
      ].join(','));
    }
    
    await file.writeAsString(csvContent.toString());
    return file.path;
  }
  
  Future<String> exportEmployeesToCSV(List<Employee> employees) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/employees_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    
    final csvContent = StringBuffer();
    
    // إضافة العناوين
    csvContent.writeln('ID,الاسم,رقم الجوال,الدور,الصلاحيات,تاريخ الإنشاء');
    
    // إضافة البيانات
    for (final employee in employees) {
      csvContent.writeln([
        employee.id,
        _escapeCsvField(employee.name),
        _escapeCsvField(employee.phone),
        _escapeCsvField(employee.role),
        _escapeCsvField(employee.permissions),
        employee.createdAt,
      ].join(','));
    }
    
    await file.writeAsString(csvContent.toString());
    return file.path;
  }
  
  Future<String> exportPaymentsToCSV(List<Payment> payments) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/payments_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    
    final csvContent = StringBuffer();
    
    // إضافة العناوين
    csvContent.writeln('ID,معرف الحجز,المبلغ,طريقة الدفع,تاريخ الدفع,الملاحظات,تاريخ الإنشاء');
    
    // إضافة البيانات
    for (final payment in payments) {
      csvContent.writeln([
        payment.id,
        payment.bookingId,
        payment.amount,
        _escapeCsvField(payment.paymentMethod),
        payment.paymentDate,
        _escapeCsvField(payment.notes ?? ''),
        payment.createdAt,
      ].join(','));
    }
    
    await file.writeAsString(csvContent.toString());
    return file.path;
  }
  
  Future<String> exportLostItemsToCSV(List<LostItem> lostItems) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/lost_items_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    
    final csvContent = StringBuffer();
    
    // إضافة العناوين
    csvContent.writeln('ID,الوصف,المكان,تاريخ الفقدان,الحالة,معرف الحجز,تاريخ الإنشاء');
    
    // إضافة البيانات
    for (final item in lostItems) {
      csvContent.writeln([
        item.id,
        _escapeCsvField(item.description),
        _escapeCsvField(item.location),
        item.dateFound,
        _escapeCsvField(item.status),
        item.bookingId ?? '',
        item.createdAt,
      ].join(','));
    }
    
    await file.writeAsString(csvContent.toString());
    return file.path;
  }
  
  Future<String> exportAuditLogsToCSV(List<AuditLog> auditLogs) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/audit_logs_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    
    final csvContent = StringBuffer();
    
    // إضافة العناوين
    csvContent.writeln('ID,الإجراء,نوع الكيان,معرف الكيان,القيم القديمة,القيم الجديدة,معرف المستخدم,اسم المستخدم,التوقيت');
    
    // إضافة البيانات
    for (final log in auditLogs) {
      csvContent.writeln([
        log.id,
        _escapeCsvField(log.action),
        _escapeCsvField(log.entityType),
        log.entityId ?? '',
        _escapeCsvField(log.oldValues ?? ''),
        _escapeCsvField(log.newValues ?? ''),
        _escapeCsvField(log.userId),
        _escapeCsvField(log.userName),
        log.timestamp.toIso8601String(),
      ].join(','));
    }
    
    await file.writeAsString(csvContent.toString());
    return file.path;
  }
  
  String _escapeCsvField(String field) {
    // إذا كان الحقل يحتوي على فاصلة أو علامة اقتباس أو سطر جديد، يجب وضعه بين علامتي اقتباس
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // استبدال علامات الاقتباس المزدوجة بعلامتين
      final escapedField = field.replaceAll('"', '""');
      return '"$escapedField"';
    }
    return field;
  }
  
  Future<String> exportAllDataToCSV({
    required List<Booking> bookings,
    required List<Customer> customers,
    required List<Employee> employees,
    required List<Payment> payments,
    required List<LostItem> lostItems,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // تصدير كل نوع من البيانات
    await exportBookingsToCSV(bookings);
    await exportCustomersToCSV(customers);
    await exportEmployeesToCSV(employees);
    await exportPaymentsToCSV(payments);
    await exportLostItemsToCSV(lostItems);
    
    return directory.path;
  }
}

