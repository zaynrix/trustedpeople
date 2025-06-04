import 'package:flutter/material.dart';

// ==================== Device Type Extension ====================
extension DeviceTypeExtension on String {
  bool get isMobile => toLowerCase().contains('mobile');
  bool get isTablet => toLowerCase().contains('tablet');
  bool get isDesktop => !isMobile && !isTablet;

  bool get isIPhone => toLowerCase().contains('iphone');
  bool get isAndroid => toLowerCase().contains('android');
  bool get isWindows => toLowerCase().contains('windows');
  bool get isMac => toLowerCase().contains('mac');

  bool get isChrome => toLowerCase().contains('chrome');
  bool get isFirefox => toLowerCase().contains('firefox');
  bool get isSafari => toLowerCase().contains('safari');
  bool get isEdge => toLowerCase().contains('edge');
}

// ==================== DateTime Extension ====================
extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return day == yesterday.day &&
        month == yesterday.month &&
        year == yesterday.year;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return isAfter(weekAgo);
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }

  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'منذ ${years} ${years == 1 ? 'سنة' : 'سنوات'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'منذ ${months} ${months == 1 ? 'شهر' : 'أشهر'}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  String get arabicWeekday {
    const weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return weekdays[weekday - 1];
  }

  String get arabicMonth {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }

  String get formattedArabicDate {
    return '$day ${arabicMonth} $year';
  }
}

// ==================== Theme Extension ====================
extension ThemeExtension on ThemeData {
  Color get surfaceVariant => colorScheme.surfaceVariant;
  Color get primaryVariant => colorScheme.primaryContainer;
  Color get onSurfaceVariant => colorScheme.onSurfaceVariant;
  Color get outline => colorScheme.outline;

  TextStyle get headlineMedium => textTheme.headlineMedium ?? const TextStyle();
  TextStyle get headlineSmall => textTheme.headlineSmall ?? const TextStyle();
  TextStyle get titleLarge => textTheme.titleLarge ?? const TextStyle();
  TextStyle get titleMedium => textTheme.titleMedium ?? const TextStyle();
  TextStyle get titleSmall => textTheme.titleSmall ?? const TextStyle();
  TextStyle get bodyLarge => textTheme.bodyLarge ?? const TextStyle();
  TextStyle get bodyMedium => textTheme.bodyMedium ?? const TextStyle();
  TextStyle get bodySmall => textTheme.bodySmall ?? const TextStyle();
  TextStyle get labelLarge => textTheme.labelLarge ?? const TextStyle();
  TextStyle get labelMedium => textTheme.labelMedium ?? const TextStyle();
  TextStyle get labelSmall => textTheme.labelSmall ?? const TextStyle();

  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;
}

// ==================== Color Extension ====================
extension ColorExtension on Color {
  Color get lighter {
    return Color.fromARGB(
      alpha,
      (red + ((255 - red) * 0.1)).round(),
      (green + ((255 - green) * 0.1)).round(),
      (blue + ((255 - blue) * 0.1)).round(),
    );
  }

  Color get darker {
    return Color.fromARGB(
      alpha,
      (red * 0.9).round(),
      (green * 0.9).round(),
      (blue * 0.9).round(),
    );
  }

  String get hexString {
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}

// ==================== Number Extension ====================
extension NumberExtension on num {
  String get formatted {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}م';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}ك';
    }
    return toString();
  }

  String get arabicFormatted {
    final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return toString().split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? arabicDigits[digit] : char;
    }).join();
  }
}

// ==================== String Extension ====================
extension StringExtension on String {
  String get toArabicNumbers {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = this;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  String get toEnglishNumbers {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = this;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }

  bool get isValidIP {
    final parts = split('.');
    if (parts.length != 4) return false;

    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  String get masked {
    if (length <= 4) return this;
    return '${substring(0, 2)}${'*' * (length - 4)}${substring(length - 2)}';
  }

  String get truncated {
    if (length <= 20) return this;
    return '${substring(0, 17)}...';
  }
}

// ==================== List Extension ====================
extension ListExtension<T> on List<T> {
  List<T> get safeReversed {
    if (isEmpty) return this;
    return reversed.toList();
  }

  T? get firstOrNull {
    return isEmpty ? null : first;
  }

  T? get lastOrNull {
    return isEmpty ? null : last;
  }

  List<T> take(int count) {
    if (count >= length) return this;
    return sublist(0, count);
  }

  List<T> skip(int count) {
    if (count >= length) return [];
    return sublist(count);
  }
}

// ==================== BuildContext Extension ====================
extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;

  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: theme.colorScheme.error);
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }

  Future<void> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  Future<T?> push<T>(Route<T> route) {
    return Navigator.of(this).push(route);
  }

  void pop<T>([T? result]) {
    return Navigator.of(this).pop(result);
  }
}
