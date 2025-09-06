// تعدادات النظام
enum EventType {
  men('رجال'),
  women('نساء'),
  graduation('تخرج');

  const EventType(this.displayName);
  final String displayName;
}

enum BookingStatus {
  ready('جاهز'),
  inProgress('جاري'),
  postponed('مؤجل'),
  completed('مكتمل'),
  cancelled('ملغي');

  const BookingStatus(this.displayName);
  final String displayName;
}

enum DecorationType {
  house('بيت'),
  hall('صالة'),
  camp('مخيم');

  const DecorationType(this.displayName);
  final String displayName;
}

enum PaymentMethod {
  cash('كاش'),
  transfer('حوالة'),
  card('بطاقة'),
  check('شيك');

  const PaymentMethod(this.displayName);
  final String displayName;
}

enum UserRole {
  admin('مدير'),
  employee('موظف'),
  viewer('مشاهد');

  const UserRole(this.displayName);
  final String displayName;
}

enum ItemStatus {
  available('متوفر'),
  inUse('قيد الاستخدام'),
  maintenance('صيانة'),
  lost('مفقود');

  const ItemStatus(this.displayName);
  final String displayName;
}

enum ReportType {
  daily('يومي'),
  weekly('أسبوعي'),
  monthly('شهري'),
  yearly('سنوي'),
  custom('مخصص');

  const ReportType(this.displayName);
  final String displayName;
}


enum PaymentStatus {
  pending('معلق'),
  partiallyPaid('مدفوع جزئياً'),
  fullyPaid('مدفوع كاملاً'),
  overdue('متأخر');

  const PaymentStatus(this.displayName);
  final String displayName;
}

