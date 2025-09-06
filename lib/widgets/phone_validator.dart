class PhoneValidator {
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال رقم الجوال';
    }

    // إزالة المسافات والرموز
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    // التحقق من طول الرقم
    if (cleanPhone.length < 10) {
      return 'رقم الجوال قصير جداً';
    }

    if (cleanPhone.length > 15) {
      return 'رقم الجوال طويل جداً';
    }

    // التحقق من الأرقام السعودية
    if (cleanPhone.startsWith('05') && cleanPhone.length == 10) {
      return null; // رقم سعودي صحيح
    }

    if (cleanPhone.startsWith('9665') && cleanPhone.length == 13) {
      return null; // رقم سعودي مع رمز الدولة
    }

    if (cleanPhone.startsWith('5') && cleanPhone.length == 9) {
      return null; // رقم سعودي بدون 0
    }

    return 'تنسيق رقم الجوال غير صحيح';
  }

  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.startsWith('05') && cleanPhone.length == 10) {
      return cleanPhone;
    }
    
    if (cleanPhone.startsWith('5') && cleanPhone.length == 9) {
      return '0$cleanPhone';
    }
    
    if (cleanPhone.startsWith('9665') && cleanPhone.length == 13) {
      return '0${cleanPhone.substring(4)}';
    }
    
    return phone;
  }
}

