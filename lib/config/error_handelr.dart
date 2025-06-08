class ErrorMessageHandler {
  // Map of error codes to Arabic messages
  static const Map<String, String> _errorMessages = {
    // Authentication errors
    'user-not-found': 'المستخدم غير موجود',
    'user not found': 'المستخدم غير موجود',
    'wrong-password': 'كلمة المرور غير صحيحة',
    'invalid-credential': 'كلمة المرور غير صحيحة',
    'invalid-login-credentials': 'كلمة المرور غير صحيحة',
    'invalid-email': 'البريد الإلكتروني غير صحيح',
    'user-disabled': 'تم تعطيل هذا الحساب',
    'too-many-requests': 'محاولات كثيرة، يرجى المحاولة لاحقاً',
    'network-request-failed': 'خطأ في الاتصال، تحقق من الإنترنت',
    'email-already-in-use': 'البريد الإلكتروني مستخدم بالفعل',
    'weak-password': 'كلمة المرور ضعيفة جداً',
    'admin': 'لا تملك صلاحيات المشرف المطلوبة',
    'صلاحيات': 'لا تملك صلاحيات المشرف المطلوبة',

    // Additional common errors
    'operation-not-allowed': 'العملية غير مسموحة',
    'requires-recent-login': 'يتطلب تسجيل دخول حديث',
    'account-exists-with-different-credential':
        'الحساب موجود ببيانات اعتماد مختلفة',
    'timeout': 'انتهت مهلة الاتصال',
    'permission-denied': 'تم رفض الإذن',
    'unavailable': 'الخدمة غير متاحة حالياً',
    'cancelled': 'تم إلغاء العملية',
    'internal': 'خطأ داخلي في الخادم',
  };

  // Default error message
  static const String _defaultErrorMessage =
      'حدث خطأ أثناء تسجيل الدخول، يرجى المحاولة مرة أخرى';

  /// Converts an error message to a user-friendly Arabic message
  static String getDisplayError(String error, {String? customDefaultMessage}) {
    if (error.isEmpty) return customDefaultMessage ?? _defaultErrorMessage;

    String errorLower = error.toLowerCase();

    // Check for exact matches first
    for (String key in _errorMessages.keys) {
      if (errorLower.contains(key.toLowerCase())) {
        return _errorMessages[key]!;
      }
    }

    // Return custom default or standard default
    return customDefaultMessage ?? _defaultErrorMessage;
  }

  /// Adds a custom error mapping
  static Map<String, String> _customErrorMessages = {};

  static void addCustomErrorMessage(String errorCode, String arabicMessage) {
    _customErrorMessages[errorCode.toLowerCase()] = arabicMessage;
  }

  /// Gets display error with custom mappings included
  static String getDisplayErrorWithCustom(String error,
      {String? customDefaultMessage}) {
    if (error.isEmpty) return customDefaultMessage ?? _defaultErrorMessage;

    String errorLower = error.toLowerCase();

    // Check custom mappings first
    for (String key in _customErrorMessages.keys) {
      if (errorLower.contains(key)) {
        return _customErrorMessages[key]!;
      }
    }

    // Fall back to default mappings
    return getDisplayError(error, customDefaultMessage: customDefaultMessage);
  }

  /// Checks if an error is a network-related error
  static bool isNetworkError(String error) {
    String errorLower = error.toLowerCase();
    return errorLower.contains('network') ||
        errorLower.contains('timeout') ||
        errorLower.contains('connection') ||
        errorLower.contains('unavailable');
  }

  /// Checks if an error is an authentication error
  static bool isAuthError(String error) {
    String errorLower = error.toLowerCase();
    return errorLower.contains('user-not-found') ||
        errorLower.contains('wrong-password') ||
        errorLower.contains('invalid-credential') ||
        errorLower.contains('invalid-email') ||
        errorLower.contains('user-disabled');
  }

  /// Checks if an error is a permission error
  static bool isPermissionError(String error) {
    String errorLower = error.toLowerCase();
    return errorLower.contains('admin') ||
        errorLower.contains('permission') ||
        errorLower.contains('صلاحيات');
  }

  /// Gets error category for styling purposes
  static ErrorCategory getErrorCategory(String error) {
    if (isNetworkError(error)) return ErrorCategory.network;
    if (isAuthError(error)) return ErrorCategory.authentication;
    if (isPermissionError(error)) return ErrorCategory.permission;
    return ErrorCategory.general;
  }
}

enum ErrorCategory {
  network,
  authentication,
  permission,
  general,
}
