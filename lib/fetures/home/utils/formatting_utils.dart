import 'package:flutter/material.dart';
import 'package:trustedtallentsvalley/fetures/services/models/service_model.dart';

class FormattingUtils {
  // Helper method to get status text
  static String getStatusText(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 'قيد الانتظار';
      case ServiceRequestStatus.inProgress:
        return 'قيد المعالجة';
      case ServiceRequestStatus.completed:
        return 'مكتمل';
      case ServiceRequestStatus.cancelled:
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }

  // Helper method to get status color
  static Color getStatusColor(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Colors.blue;
      case ServiceRequestStatus.inProgress:
        return Colors.orange;
      case ServiceRequestStatus.completed:
        return Colors.green;
      case ServiceRequestStatus.cancelled:
        return Colors.red;
    }
  }

  // Helper method to get status text from string
  static String getStatusTextFromString(String statusString) {
    if (statusString.contains('pending')) {
      return 'قيد الانتظار';
    } else if (statusString.contains('inProgress')) {
      return 'قيد المعالجة';
    } else if (statusString.contains('completed')) {
      return 'مكتمل';
    } else if (statusString.contains('cancelled')) {
      return 'ملغي';
    } else {
      return 'غير معروف';
    }
  }

  // Helper method to get status color from string
  static Color getStatusColorFromString(String statusString) {
    if (statusString.contains('pending')) {
      return Colors.blue;
    } else if (statusString.contains('inProgress')) {
      return Colors.orange;
    } else if (statusString.contains('completed')) {
      return Colors.green;
    } else if (statusString.contains('cancelled')) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  static String formatDate(DateTime? date) {
    if (date == null) return 'تاريخ غير متوفر';

    // Format date to Arabic style
    final day = date.day.toString();
    final month = getArabicMonth(date.month);
    final year = date.year.toString();

    return '$day $month $year';
  }

  // Helper method to get Arabic month names
  static String getArabicMonth(int month) {
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
      'ديسمبر'
    ];
    return months[month - 1];
  }
}