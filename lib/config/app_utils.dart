import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_constant.dart';

// ==================== Analytics Utils ====================
class AnalyticsUtils {
  static String formatDuration(String duration) {
    if (duration.isEmpty || duration == '0:00') {
      return 'غير متاح';
    }
    return duration;
  }

  static String formatNumber(dynamic number) {
    if (number == null) return '0';
    if (number is String) return number;

    final num = number;
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}م';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}ك';
    }
    return num.toString();
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  static Color getCountryColor(String country) {
    return AppColors
        .chartColors[country.hashCode.abs() % AppColors.chartColors.length];
  }

  static String getDeviceTypeArabic(String userAgent) {
    final ua = userAgent.toLowerCase();

    if (ua.contains('iphone')) return 'iPhone';
    if (ua.contains('android')) return 'Android';
    if (ua.contains('mobile')) return 'جوال';
    if (ua.contains('tablet')) return 'لوحي';
    if (ua.contains('windows')) return 'Windows';
    if (ua.contains('mac')) return 'Mac';

    return 'كمبيوتر';
  }

  static String getBrowserArabic(String userAgent) {
    final ua = userAgent.toLowerCase();

    if (ua.contains('chrome')) return 'Chrome';
    if (ua.contains('firefox')) return 'Firefox';
    if (ua.contains('safari')) return 'Safari';
    if (ua.contains('edge')) return 'Edge';

    return 'غير معروف';
  }

  static double calculatePercentageChange(num current, num previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  static Map<String, dynamic> getVisitorStatsSummary(
      List<Map<String, dynamic>> visitors) {
    if (visitors.isEmpty) {
      return {
        'total': 0,
        'today': 0,
        'unique': 0,
        'countries': 0,
        'devices': {'mobile': 0, 'desktop': 0, 'tablet': 0},
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayVisitors = visitors.where((v) {
      final timestamp = (v['timestamp'] as Timestamp?)?.toDate();
      return timestamp != null && timestamp.isAfter(today);
    }).length;

    final uniqueIPs = visitors.map((v) => v['ipAddress']).toSet().length;
    final uniqueCountries = visitors.map((v) => v['country']).toSet().length;

    int mobileCount = 0, desktopCount = 0, tabletCount = 0;

    for (final visitor in visitors) {
      final userAgent = (visitor['userAgent'] as String? ?? '').toLowerCase();
      if (userAgent.contains('mobile')) {
        mobileCount++;
      } else if (userAgent.contains('tablet')) {
        tabletCount++;
      } else {
        desktopCount++;
      }
    }

    return {
      'total': visitors.length,
      'today': todayVisitors,
      'unique': uniqueIPs,
      'countries': uniqueCountries,
      'devices': {
        'mobile': mobileCount,
        'desktop': desktopCount,
        'tablet': tabletCount,
      },
    };
  }

  static List<Map<String, dynamic>> getChartDataForDays(
    List<Map<String, dynamic>> visitors,
    int days,
  ) {
    final now = DateTime.now();
    final chartData = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayVisitors = visitors.where((v) {
        final timestamp = (v['timestamp'] as Timestamp?)?.toDate();
        return timestamp != null &&
            timestamp.isAfter(dayStart) &&
            timestamp.isBefore(dayEnd);
      }).length;

      chartData.add({
        'day': _getArabicDayName(date.weekday),
        'date': date,
        'visits': dayVisitors,
      });
    }

    return chartData;
  }

  static String _getArabicDayName(int weekday) {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];
    return days[weekday - 1];
  }
}

// ==================== Error Handler ====================
class ErrorHandler {
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
  }) {
    String message = customMessage ?? 'حدث خطأ غير متوقع';

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          message = 'ليس لديك صلاحية للوصول لهذه البيانات';
          break;
        case 'network-request-failed':
          message = 'فشل في الاتصال بالشبكة';
          break;
        case 'too-many-requests':
          message = 'تم تجاوز الحد المسموح من الطلبات';
          break;
        case 'unavailable':
          message = 'الخدمة غير متاحة حالياً';
          break;
        case 'deadline-exceeded':
          message = 'انتهت مهلة الانتظار';
          break;
        case 'resource-exhausted':
          message = 'تم استنفاد الموارد المتاحة';
          break;
        default:
          message = 'خطأ في قاعدة البيانات: ${error.message}';
      }
    } else if (error is Exception) {
      message = 'خطأ: ${error.toString()}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        action: SnackBarAction(
          label: 'حسناً',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}

// ==================== Animation Utils ====================
class AnimationUtils {
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset begin = const Offset(1.0, 0.0),
    Curve curve = Curves.easeInOut,
  }) {
    return SlideTransition(
      position: animation.drive(
        Tween(begin: begin, end: Offset.zero).chain(
          CurveTween(curve: curve),
        ),
      ),
      child: child,
    );
  }

  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
    Curve curve = Curves.easeInOut,
  }) {
    return FadeTransition(
      opacity: animation.drive(
        CurveTween(curve: curve),
      ),
      child: child,
    );
  }

  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    Curve curve = Curves.elasticOut,
    double begin = 0.0,
  }) {
    return ScaleTransition(
      scale: animation.drive(
        Tween(begin: begin, end: 1.0).chain(
          CurveTween(curve: curve),
        ),
      ),
      child: child,
    );
  }

  static Widget rotationTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return RotationTransition(
      turns: animation.drive(
        Tween(begin: begin, end: end),
      ),
      child: child,
    );
  }

  static Route<T> createSlideRoute<T>({
    required Widget page,
    Offset begin = const Offset(1.0, 0.0),
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return slideTransition(
          child: child,
          animation: animation,
          begin: begin,
        );
      },
    );
  }

  static Route<T> createFadeRoute<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return fadeTransition(
          child: child,
          animation: animation,
        );
      },
    );
  }
}

// ==================== Clipboard Utils ====================
class ClipboardUtils {
  static Future<void> copyToClipboard(
    BuildContext context,
    String text, {
    String? successMessage,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ErrorHandler.showSuccess(
        context,
        successMessage ?? 'تم النسخ بنجاح',
      );
    } catch (e) {
      ErrorHandler.handleError(
        context,
        e,
        customMessage: 'فشل في نسخ النص',
      );
    }
  }

  static Future<String?> getFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } catch (e) {
      debugPrint('Error getting clipboard data: $e');
      return null;
    }
  }
}

// ==================== Validation Utils ====================
class ValidationUtils {
  static bool isValidIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(email);
  }

  static bool isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  static bool isNotEmpty(String? text) {
    return text != null && text.trim().isNotEmpty;
  }

  static bool isValidPort(String port) {
    final num = int.tryParse(port);
    return num != null && num >= 1 && num <= 65535;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'حقل $fieldName مطلوب';
    }
    return null;
  }

  static String? validateIP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'عنوان IP مطلوب';
    }
    if (!isValidIP(value.trim())) {
      return 'عنوان IP غير صحيح';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!isValidEmail(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }
}

// ==================== Format Utils ====================
class FormatUtils {
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String maskString(String input, {int visibleChars = 4}) {
    if (input.length <= visibleChars) return input;
    final visible = visibleChars ~/ 2;
    return '${input.substring(0, visible)}${'*' * (input.length - visibleChars)}${input.substring(input.length - visible)}';
  }

  static String truncateString(String input, {int maxLength = 50}) {
    if (input.length <= maxLength) return input;
    return '${input.substring(0, maxLength - 3)}...';
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  static String toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }
}

// ==================== Device Utils ====================
class DeviceUtils {
  static bool isPhysicalDevice() {
    // This would require additional platform-specific code
    return true; // Placeholder
  }

  static Future<void> hideKeyboard(BuildContext context) async {
    FocusScope.of(context).unfocus();
  }

  static void hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  static void vibrate() {
    HapticFeedback.heavyImpact();
  }
}
