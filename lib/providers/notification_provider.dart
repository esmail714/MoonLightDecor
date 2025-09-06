import 'package:flutter/material.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
}

class NotificationData {
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  NotificationData({
    required this.title,
    required this.message,
    required this.type,
    DateTime? timestamp,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();

  NotificationData copyWith({
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationData(
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final List<NotificationData> _notifications = [];
  
  List<NotificationData> get notifications => List.unmodifiable(_notifications);
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) {
    _notifications.insert(0, NotificationData(
      title: title,
      message: message,
      type: type,
    ));
    
    // الاحتفاظ بآخر 50 إشعار فقط
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }
    
    notifyListeners();
  }
  
  void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }
  
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }
  
  void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }
  
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
  
  // إشعارات محددة للتطبيق
  void notifyBookingCreated(String customerName) {
    addNotification(
      title: 'حجز جديد',
      message: 'تم إنشاء حجز جديد للعميل: $customerName',
      type: NotificationType.success,
    );
  }
  
  void notifyBookingUpdated(String customerName) {
    addNotification(
      title: 'تحديث حجز',
      message: 'تم تحديث حجز العميل: $customerName',
      type: NotificationType.info,
    );
  }
  
  void notifyPaymentReceived(String customerName, double amount) {
    addNotification(
      title: 'دفعة جديدة',
      message: 'تم استلام دفعة بقيمة $amount ريال من العميل: $customerName',
      type: NotificationType.success,
    );
  }
  
  void notifyLostItemFound(String itemDescription) {
    addNotification(
      title: 'تم العثور على مفقود',
      message: 'تم العثور على: $itemDescription',
      type: NotificationType.info,
    );
  }
  
  void notifyUpcomingEvent(String eventName, DateTime eventDate) {
    final daysUntil = eventDate.difference(DateTime.now()).inDays;
    addNotification(
      title: 'تذكير بفعالية قادمة',
      message: 'فعالية "$eventName" خلال $daysUntil أيام',
      type: NotificationType.warning,
    );
  }
}

