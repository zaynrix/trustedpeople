class ValidationUtils {
  // Phone number validator
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }

    // Simple phone validation for Palestinian numbers
    final RegExp phoneRegex = RegExp(r'^(05|07)[0-9]{8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'الرجاء إدخال رقم هاتف صحيح';
    }

    return null;
  }

  // Required field validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال $fieldName';
    }
    return null;
  }

  // URL validator
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      // Allow empty URL (optional field)
      return null;
    }

    final RegExp urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'الرجاء إدخال رابط صحيح';
    }

    return null;
  }
}