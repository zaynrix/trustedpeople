// lib/core/errors/exceptions.dart
/// الاستثناء الأساسي للتطبيق
class AppException implements Exception {
  final String message;
  final int? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

/// استثناء الخادم
class ServerException extends AppException {
  const ServerException({required String message, int? code})
      : super(message: message, code: code);
}

/// استثناء المصادقة
class AuthException extends AppException {
  const AuthException({required String message, int? code})
      : super(message: message, code: code);
}

/// استثناء اتصال الإنترنت
class ConnectionException extends AppException {
  const ConnectionException({required String message, int? code})
      : super(message: message, code: code);
}

/// استثناء المخزن المحلي
class CacheException extends AppException {
  const CacheException({required String message, int? code})
      : super(message: message, code: code);
}

/// استثناء الإدخال
class InputException extends AppException {
  const InputException({required String message, int? code})
      : super(message: message, code: code);
}

/// استثناء الصلاحيات
class PermissionException extends AppException {
  const PermissionException({required String message, int? code})
      : super(message: message, code: code);
}
