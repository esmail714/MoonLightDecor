import 'package:flutter/material.dart';
import '../models/audit_log.dart';
import '../services/database_service.dart';

class AuditProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<AuditLog> _auditLogs = [];
  bool _isLoading = false;
  
  List<AuditLog> get auditLogs => List.unmodifiable(_auditLogs);
  bool get isLoading => _isLoading;
  
  Future<void> loadAuditLogs() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _auditLogs = await _databaseService.getAuditLogs();
    } catch (e) {
      debugPrint('خطأ في تحميل سجل الأنشطة: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logAction({
    required AuditAction action,
    required EntityType entityType,
    int? entityId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
    required String userId,
    required String userName,
  }) async {
    try {
      final auditLog = AuditLog(
        action: action.value,
        entityType: entityType.value,
        entityId: entityId,
        oldValues: oldValues != null ? _mapToJson(oldValues) : null,
        newValues: newValues != null ? _mapToJson(newValues) : null,
        userId: userId,
        userName: userName,
      );
      
      await _databaseService.insertAuditLog(auditLog);
      
      // إضافة السجل إلى القائمة المحلية
      _auditLogs.insert(0, auditLog);
      
      // الاحتفاظ بآخر 1000 سجل فقط
      if (_auditLogs.length > 1000) {
        _auditLogs = _auditLogs.take(1000).toList();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في تسجيل النشاط: $e');
    }
  }
  
  Future<List<AuditLog>> getAuditLogsByEntity(EntityType entityType, int entityId) async {
    try {
      return await _databaseService.getAuditLogsByEntity(entityType.value, entityId);
    } catch (e) {
      debugPrint('خطأ في تحميل سجل الأنشطة للكيان: $e');
      return [];
    }
  }
  
  Future<List<AuditLog>> getAuditLogsByUser(String userId) async {
    try {
      return await _databaseService.getAuditLogsByUser(userId);
    } catch (e) {
      debugPrint('خطأ في تحميل سجل الأنشطة للمستخدم: $e');
      return [];
    }
  }
  
  Future<List<AuditLog>> getAuditLogsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      return await _databaseService.getAuditLogsByDateRange(startDate, endDate);
    } catch (e) {
      debugPrint('خطأ في تحميل سجل الأنشطة للفترة المحددة: $e');
      return [];
    }
  }
  
  List<AuditLog> filterLogs({
    String? action,
    String? entityType,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _auditLogs.where((log) {
      if (action != null && log.action != action) return false;
      if (entityType != null && log.entityType != entityType) return false;
      if (userId != null && log.userId != userId) return false;
      if (startDate != null && log.timestamp.isBefore(startDate)) return false;
      if (endDate != null && log.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();
  }
  
  String _mapToJson(Map<String, dynamic> map) {
    // تحويل بسيط للخريطة إلى نص JSON
    final entries = map.entries.map((e) => '"${e.key}": "${e.value}"').join(', ');
    return '{$entries}';
  }
  
  // دوال مساعدة لتسجيل أنشطة محددة
  Future<void> logBookingCreated(int bookingId, Map<String, dynamic> bookingData, String userId, String userName) async {
    await logAction(
      action: AuditAction.create,
      entityType: EntityType.booking,
      entityId: bookingId,
      newValues: bookingData,
      userId: userId,
      userName: userName,
    );
  }
  
  Future<void> logBookingUpdated(int bookingId, Map<String, dynamic> oldData, Map<String, dynamic> newData, String userId, String userName) async {
    await logAction(
      action: AuditAction.update,
      entityType: EntityType.booking,
      entityId: bookingId,
      oldValues: oldData,
      newValues: newData,
      userId: userId,
      userName: userName,
    );
  }
  
  Future<void> logBookingDeleted(int bookingId, Map<String, dynamic> bookingData, String userId, String userName) async {
    await logAction(
      action: AuditAction.delete,
      entityType: EntityType.booking,
      entityId: bookingId,
      oldValues: bookingData,
      userId: userId,
      userName: userName,
    );
  }
  
  Future<void> logPaymentCreated(int paymentId, Map<String, dynamic> paymentData, String userId, String userName) async {
    await logAction(
      action: AuditAction.create,
      entityType: EntityType.payment,
      entityId: paymentId,
      newValues: paymentData,
      userId: userId,
      userName: userName,
    );
  }
  
  Future<void> logDataExport(String exportType, String userId, String userName) async {
    await logAction(
      action: AuditAction.export,
      entityType: EntityType.system,
      newValues: {'export_type': exportType},
      userId: userId,
      userName: userName,
    );
  }
}

