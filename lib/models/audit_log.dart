class AuditLog {
  final int? id;
  final String action;
  final String entityType;
  final int? entityId;
  final String? oldValues;
  final String? newValues;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;

  AuditLog({
    this.id,
    required this.action,
    required this.entityType,
    this.entityId,
    this.oldValues,
    this.newValues,
    required this.userId,
    required this.userName,
    DateTime? timestamp,
    this.ipAddress,
    this.userAgent,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'old_values': oldValues,
      'new_values': newValues,
      'user_id': userId,
      'user_name': userName,
      'timestamp': timestamp.toIso8601String(),
      'ip_address': ipAddress,
      'user_agent': userAgent,
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id']?.toInt(),
      action: map['action'] ?? '',
      entityType: map['entity_type'] ?? '',
      entityId: map['entity_id']?.toInt(),
      oldValues: map['old_values'],
      newValues: map['new_values'],
      userId: map['user_id'] ?? '',
      userName: map['user_name'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      ipAddress: map['ip_address'],
      userAgent: map['user_agent'],
    );
  }

  AuditLog copyWith({
    int? id,
    String? action,
    String? entityType,
    int? entityId,
    String? oldValues,
    String? newValues,
    String? userId,
    String? userName,
    DateTime? timestamp,
    String? ipAddress,
    String? userAgent,
  }) {
    return AuditLog(
      id: id ?? this.id,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      oldValues: oldValues ?? this.oldValues,
      newValues: newValues ?? this.newValues,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      timestamp: timestamp ?? this.timestamp,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
    );
  }
}

enum AuditAction {
  create,
  update,
  delete,
  view,
  login,
  logout,
  export,
}

extension AuditActionExtension on AuditAction {
  String get displayName {
    switch (this) {
      case AuditAction.create:
        return 'إنشاء';
      case AuditAction.update:
        return 'تعديل';
      case AuditAction.delete:
        return 'حذف';
      case AuditAction.view:
        return 'عرض';
      case AuditAction.login:
        return 'تسجيل دخول';
      case AuditAction.logout:
        return 'تسجيل خروج';
      case AuditAction.export:
        return 'تصدير';
    }
  }

  String get value {
    return name;
  }
}

enum EntityType {
  booking,
  customer,
  employee,
  payment,
  lostItem,
  user,
  system,
}

extension EntityTypeExtension on EntityType {
  String get displayName {
    switch (this) {
      case EntityType.booking:
        return 'حجز';
      case EntityType.customer:
        return 'عميل';
      case EntityType.employee:
        return 'موظف';
      case EntityType.payment:
        return 'دفعة';
      case EntityType.lostItem:
        return 'مفقود';
      case EntityType.user:
        return 'مستخدم';
      case EntityType.system:
        return 'النظام';
    }
  }

  String get value {
    return name;
  }
}

