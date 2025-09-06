enum UserRole {
  admin,
  manager,
  receptionist,
  accountant,
  employee,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'مدير النظام';
      case UserRole.manager:
        return 'مدير';
      case UserRole.receptionist:
        return 'موظف استقبال';
      case UserRole.accountant:
        return 'محاسب';
      case UserRole.employee:
        return 'موظف';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'صلاحيات كاملة على النظام';
      case UserRole.manager:
        return 'إدارة الحجوزات والموظفين والتقارير';
      case UserRole.receptionist:
        return 'إدارة الحجوزات والعملاء';
      case UserRole.accountant:
        return 'إدارة الدفعات والتقارير المالية';
      case UserRole.employee:
        return 'عرض البيانات الأساسية فقط';
    }
  }

  List<Permission> get permissions {
    switch (this) {
      case UserRole.admin:
        return Permission.values;
      case UserRole.manager:
        return [
          Permission.viewBookings,
          Permission.createBooking,
          Permission.editBooking,
          Permission.deleteBooking,
          Permission.viewCustomers,
          Permission.createCustomer,
          Permission.editCustomer,
          Permission.deleteCustomer,
          Permission.viewEmployees,
          Permission.createEmployee,
          Permission.editEmployee,
          Permission.viewPayments,
          Permission.createPayment,
          Permission.editPayment,
          Permission.viewReports,
          Permission.exportData,
          Permission.viewDashboard,
          Permission.viewLostItems,
          Permission.createLostItem,
          Permission.editLostItem,
          Permission.deleteLostItem,
        ];
      case UserRole.receptionist:
        return [
          Permission.viewBookings,
          Permission.createBooking,
          Permission.editBooking,
          Permission.viewCustomers,
          Permission.createCustomer,
          Permission.editCustomer,
          Permission.viewPayments,
          Permission.createPayment,
          Permission.viewLostItems,
          Permission.createLostItem,
          Permission.editLostItem,
        ];
      case UserRole.accountant:
        return [
          Permission.viewBookings,
          Permission.viewCustomers,
          Permission.viewPayments,
          Permission.createPayment,
          Permission.editPayment,
          Permission.deletePayment,
          Permission.viewReports,
          Permission.exportData,
          Permission.viewDashboard,
        ];
      case UserRole.employee:
        return [
          Permission.viewBookings,
          Permission.viewCustomers,
          Permission.viewLostItems,
        ];
    }
  }
}

enum Permission {
  // حجوزات
  viewBookings,
  createBooking,
  editBooking,
  deleteBooking,
  
  // عملاء
  viewCustomers,
  createCustomer,
  editCustomer,
  deleteCustomer,
  
  // موظفين
  viewEmployees,
  createEmployee,
  editEmployee,
  deleteEmployee,
  
  // دفعات
  viewPayments,
  createPayment,
  editPayment,
  deletePayment,
  
  // مفقودات
  viewLostItems,
  createLostItem,
  editLostItem,
  deleteLostItem,
  
  // تقارير
  viewReports,
  exportData,
  
  // لوحة المعلومات
  viewDashboard,
  
  // إدارة النظام
  manageUsers,
  viewAuditLog,
  systemSettings,
}

extension PermissionExtension on Permission {
  String get displayName {
    switch (this) {
      case Permission.viewBookings:
        return 'عرض الحجوزات';
      case Permission.createBooking:
        return 'إنشاء حجز';
      case Permission.editBooking:
        return 'تعديل حجز';
      case Permission.deleteBooking:
        return 'حذف حجز';
      case Permission.viewCustomers:
        return 'عرض العملاء';
      case Permission.createCustomer:
        return 'إنشاء عميل';
      case Permission.editCustomer:
        return 'تعديل عميل';
      case Permission.deleteCustomer:
        return 'حذف عميل';
      case Permission.viewEmployees:
        return 'عرض الموظفين';
      case Permission.createEmployee:
        return 'إنشاء موظف';
      case Permission.editEmployee:
        return 'تعديل موظف';
      case Permission.deleteEmployee:
        return 'حذف موظف';
      case Permission.viewPayments:
        return 'عرض الدفعات';
      case Permission.createPayment:
        return 'إنشاء دفعة';
      case Permission.editPayment:
        return 'تعديل دفعة';
      case Permission.deletePayment:
        return 'حذف دفعة';
      case Permission.viewLostItems:
        return 'عرض المفقودات';
      case Permission.createLostItem:
        return 'إنشاء مفقود';
      case Permission.editLostItem:
        return 'تعديل مفقود';
      case Permission.deleteLostItem:
        return 'حذف مفقود';
      case Permission.viewReports:
        return 'عرض التقارير';
      case Permission.exportData:
        return 'تصدير البيانات';
      case Permission.viewDashboard:
        return 'عرض لوحة المعلومات';
      case Permission.manageUsers:
        return 'إدارة المستخدمين';
      case Permission.viewAuditLog:
        return 'عرض سجل الأنشطة';
      case Permission.systemSettings:
        return 'إعدادات النظام';
    }
  }
}

