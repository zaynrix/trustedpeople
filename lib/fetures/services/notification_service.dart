// File: lib/services/notification_service.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service class for managing notification settings and sending notifications
/// with secure storage support and automatic fallback to SharedPreferences
class NotificationService {
  static const String _whatsappApiUrl = 'https://api.whatsapp.com/send';
  static const String _telegramApiUrl = 'https://api.telegram.org/bot';

  // Storage keys for admin contact information
  static const String _adminWhatsAppKey = 'admin_whatsapp';
  static const String _adminTelegramChatIdKey = 'admin_telegram_chat_id';
  static const String _telegramBotTokenKey = 'telegram_bot_token';
  static const String _storageTypeKey = 'storage_type_secure';

  // Configure secure storage with platform-specific security options
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'notification_secure_prefs',
      preferencesKeyPrefix: 'notification_',
    ),
    iOptions: IOSOptions(
      groupId: 'notification.secure.storage',
      accountName: 'notification_service',
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
    mOptions: MacOsOptions(
      groupId: 'notification.secure.storage',
      accountName: 'notification_service',
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Internal state tracking
  bool _useSecureStorage = false;
  bool _secureStorageChecked = false;

  /// Check if secure storage is available and working
  Future<bool> _checkSecureStorageAvailability() async {
    if (_secureStorageChecked) return _useSecureStorage;

    try {
      // Try to write and read a test key to verify functionality
      await _secureStorage.write(key: 'test_key', value: 'test_value');
      final testValue = await _secureStorage.read(key: 'test_key');
      await _secureStorage.delete(key: 'test_key');

      _useSecureStorage = testValue == 'test_value';
      _secureStorageChecked = true;

      print('Secure storage available: $_useSecureStorage');
      return _useSecureStorage;
    } catch (e) {
      print(
          'Secure storage not available, falling back to SharedPreferences: $e');
      _useSecureStorage = false;
      _secureStorageChecked = true;
      return false;
    }
  }

  /// Write data to secure storage or SharedPreferences as fallback
  Future<void> _writeSecurely(String key, String value) async {
    final useSecure = await _checkSecureStorageAvailability();

    if (useSecure) {
      try {
        await _secureStorage.write(key: key, value: value);
        return;
      } catch (e) {
        print('Error writing to secure storage, falling back: $e');
        // Fall through to SharedPreferences
      }
    }

    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Read data from secure storage or SharedPreferences as fallback
  Future<String?> _readSecurely(String key) async {
    final useSecure = await _checkSecureStorageAvailability();

    if (useSecure) {
      try {
        return await _secureStorage.read(key: key);
      } catch (e) {
        print('Error reading from secure storage, falling back: $e');
        // Fall through to SharedPreferences
      }
    }

    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Delete data from secure storage or SharedPreferences as fallback
  Future<void> _deleteSecurely(String key) async {
    final useSecure = await _checkSecureStorageAvailability();

    if (useSecure) {
      try {
        await _secureStorage.delete(key: key);
        return;
      } catch (e) {
        print('Error deleting from secure storage, falling back: $e');
        // Fall through to SharedPreferences
      }
    }

    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Set admin contact information
  Future<void> setAdminContacts({
    String? whatsappNumber,
    String? telegramChatId,
    String? telegramBotToken,
  }) async {
    try {
      if (whatsappNumber != null) {
        if (whatsappNumber.isEmpty) {
          await _deleteSecurely(_adminWhatsAppKey);
        } else {
          await _writeSecurely(_adminWhatsAppKey, whatsappNumber);
        }
      }

      if (telegramChatId != null) {
        if (telegramChatId.isEmpty) {
          await _deleteSecurely(_adminTelegramChatIdKey);
        } else {
          await _writeSecurely(_adminTelegramChatIdKey, telegramChatId);
        }
      }

      if (telegramBotToken != null) {
        if (telegramBotToken.isEmpty) {
          await _deleteSecurely(_telegramBotTokenKey);
        } else {
          await _writeSecurely(_telegramBotTokenKey, telegramBotToken);
        }
      }
    } catch (e) {
      print('Error saving admin contacts: $e');
      rethrow;
    }
  }

  /// Get all stored admin contact information
  Future<Map<String, String?>> getAdminContacts() async {
    try {
      final whatsapp = await _readSecurely(_adminWhatsAppKey);
      final telegramChatId = await _readSecurely(_adminTelegramChatIdKey);
      final telegramBotToken = await _readSecurely(_telegramBotTokenKey);

      return {
        'whatsapp': whatsapp,
        'telegramChatId': telegramChatId,
        'telegramBotToken': telegramBotToken,
      };
    } catch (e) {
      print('Error reading admin contacts: $e');
      return {
        'whatsapp': null,
        'telegramChatId': null,
        'telegramBotToken': null,
      };
    }
  }

  /// Send WhatsApp notification using web URL
  Future<void> sendWhatsAppNotification({
    required String message,
    String? customNumber,
  }) async {
    try {
      final contacts = await getAdminContacts();
      final phoneNumber = customNumber ?? contacts['whatsapp'];

      if (phoneNumber == null || phoneNumber.isEmpty) {
        print('WhatsApp number not configured');
        return;
      }

      // Format phone number (remove any non-digits)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      // Create WhatsApp URL for web/mobile
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = 'https://wa.me/$cleanNumber?text=$encodedMessage';

      print('WhatsApp notification URL: $whatsappUrl');
      // In a real app, you would use url_launcher to open this URL
      // await launch(whatsappUrl);
    } catch (e) {
      print('Error sending WhatsApp notification: $e');
    }
  }

  /// Send Telegram notification using Bot API
  Future<void> sendTelegramNotification({
    required String message,
    String? customChatId,
    String? customBotToken,
  }) async {
    try {
      final contacts = await getAdminContacts();
      final chatId = customChatId ?? contacts['telegramChatId'];
      final botToken = customBotToken ?? contacts['telegramBotToken'];

      if (chatId == null ||
          botToken == null ||
          chatId.isEmpty ||
          botToken.isEmpty) {
        print('Telegram credentials not configured');
        return;
      }

      final url = '${_telegramApiUrl}$botToken/sendMessage';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'Markdown',
          'disable_web_page_preview': true,
        }),
      );

      if (response.statusCode == 200) {
        print('Telegram notification sent successfully');
      } else {
        print('Failed to send Telegram notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending Telegram notification: $e');
    }
  }

  /// Send notification to all configured platforms
  Future<void> sendNotificationToAll({
    required String message,
    bool includeWhatsApp = true,
    bool includeTelegram = true,
  }) async {
    final futures = <Future>[];

    if (includeWhatsApp) {
      futures.add(sendWhatsAppNotification(message: message));
    }

    if (includeTelegram) {
      futures.add(sendTelegramNotification(message: message));
    }

    await Future.wait(futures);
  }

  /// Check if secure storage is available on this device
  Future<bool> isSecureStorageAvailable() async {
    return await _checkSecureStorageAvailability();
  }

  /// Get a human-readable description of the current storage type being used
  Future<String> getCurrentStorageType() async {
    final useSecure = await _checkSecureStorageAvailability();
    return useSecure ? 'Secure Storage' : 'SharedPreferences (Fallback)';
  }

  /// Clear all stored credentials (useful for logout/reset functionality)
  Future<void> clearAllCredentials() async {
    try {
      await _deleteSecurely(_adminWhatsAppKey);
      await _deleteSecurely(_adminTelegramChatIdKey);
      await _deleteSecurely(_telegramBotTokenKey);
    } catch (e) {
      print('Error clearing credentials: $e');
      rethrow;
    }
  }

  /// Migrate existing data from SharedPreferences to secure storage
  /// Useful when secure storage becomes available after initial setup
  Future<void> migrateToSecureStorage() async {
    try {
      final useSecure = await _checkSecureStorageAvailability();
      if (!useSecure) {
        print('Secure storage not available, cannot migrate');
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      // Migrate existing data if it exists in SharedPreferences
      final whatsapp = prefs.getString(_adminWhatsAppKey);
      final telegramChatId = prefs.getString(_adminTelegramChatIdKey);
      final telegramBotToken = prefs.getString(_telegramBotTokenKey);

      if (whatsapp != null) {
        await _secureStorage.write(key: _adminWhatsAppKey, value: whatsapp);
        await prefs.remove(_adminWhatsAppKey);
      }

      if (telegramChatId != null) {
        await _secureStorage.write(
            key: _adminTelegramChatIdKey, value: telegramChatId);
        await prefs.remove(_adminTelegramChatIdKey);
      }

      if (telegramBotToken != null) {
        await _secureStorage.write(
            key: _telegramBotTokenKey, value: telegramBotToken);
        await prefs.remove(_telegramBotTokenKey);
      }

      print('Successfully migrated data to secure storage');
    } catch (e) {
      print('Error migrating to secure storage: $e');
    }
  }

  /// Get storage statistics and debug information
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final useSecure = await _checkSecureStorageAvailability();
      final contacts = await getAdminContacts();

      return {
        'storageType': useSecure ? 'secure' : 'shared_preferences',
        'isSecureAvailable': useSecure,
        'hasWhatsApp': contacts['whatsapp']?.isNotEmpty ?? false,
        'hasTelegram': (contacts['telegramChatId']?.isNotEmpty ?? false) &&
            (contacts['telegramBotToken']?.isNotEmpty ?? false),
        'configuredPlatforms': [
          if (contacts['whatsapp']?.isNotEmpty ?? false) 'WhatsApp',
          if ((contacts['telegramChatId']?.isNotEmpty ?? false) &&
              (contacts['telegramBotToken']?.isNotEmpty ?? false))
            'Telegram',
        ],
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'storageType': 'unknown',
        'isSecureAvailable': false,
      };
    }
  }

  // Helper method to format date and time in Arabic
  String _formatDateTime(DateTime dateTime) {
    final arabicMonths = [
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

    final day = dateTime.day;
    final month = arabicMonths[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year - $hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    final arabicMonths = [
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

    final day = dateTime.day;
    final month = arabicMonths[dateTime.month - 1];
    final year = dateTime.year;

    return '$day $month $year';
  }

  // Helper method to extract browser info from user agent
  String _extractBrowserInfo(String userAgent) {
    final ua = userAgent.toLowerCase();

    if (ua.contains('firefox')) {
      return 'Firefox 🦊';
    } else if (ua.contains('chrome') && !ua.contains('edge')) {
      return 'Chrome 🌐';
    } else if (ua.contains('safari') && !ua.contains('chrome')) {
      return 'Safari 🧭';
    } else if (ua.contains('edge')) {
      return 'Edge 🔷';
    } else if (ua.contains('opera')) {
      return 'Opera 🎭';
    } else {
      return 'متصفح آخر 💻';
    }
  }
}

/// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Manager class for handling different types of admin notifications
class AdminNotificationManager {
  final NotificationService _notificationService;

  AdminNotificationManager(this._notificationService);

  /// Send notification for user activity
  Future<void> notifyUserActivity({
    required String activityType,
    required String userName,
    required String details,
  }) async {
    final message = '''
👤 *نشاط مستخدم جديد*

🎯 نوع النشاط: $activityType
👤 المستخدم: $userName
📝 التفاصيل: $details

⏰ الوقت: ${_notificationService._formatDateTime(DateTime.now())}

🔗 عرض المزيد في لوحة التحكم
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  /// Send notification for new contact form submission
  Future<void> notifyNewContactForm({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String messagePreview,
  }) async {
    final message = '''
📩 *رسالة تواصل جديدة*

👤 *الاسم:* $name
📧 *البريد الإلكتروني:* $email
📱 *الهاتف:* ${phone.isEmpty ? 'غير محدد' : phone}
📋 *الموضوع:* $subject

💬 *معاينة الرسالة:*
${messagePreview.length > 200 ? '${messagePreview.substring(0, 200)}...' : messagePreview}

⏰ *وقت الإرسال:* ${_notificationService._formatDateTime(DateTime.now())}

🔔 *تنبيه:* يرجى مراجعة لوحة التحكم للرد على الرسالة
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  /// Send notification for new website visitor
  Future<void> notifyNewWebsiteVisitor({
    required int visitorCount,
    required int currentOnline,
    required String pageViewed,
    required DateTime timestamp,
  }) async {
    final message = '''
👥 *زائر جديد للموقع*

📊 *رقم الزائر:* $visitorCount
🔴 *متصل الآن:* $currentOnline نسمة
📄 *الصفحة المشاهدة:* $pageViewed

⏰ *وقت الزيارة:* ${_notificationService._formatDateTime(timestamp)}

📈 *ملاحظة:* يمكنك متابعة نشاط الموقع من لوحة التحكم
🎯 استمر في تقديم محتوى قيم لجذب المزيد من الزوار!
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  /// Send notification for page visit
  Future<void> notifyPageVisit({
    required String pageName,
    required int visitorCount,
    String? userAgent,
    required DateTime timestamp,
  }) async {
    final browserInfo = userAgent != null
        ? _notificationService._extractBrowserInfo(userAgent)
        : 'غير محدد';

    final message = '''
📄 *زيارة صفحة جديدة*

🏷️ *الصفحة:* $pageName
👤 *رقم الزائر:* $visitorCount
🖥️ *المتصفح:* $browserInfo
⏰ *الوقت:* ${_notificationService._formatDateTime(timestamp)}

💡 *نصيحة:* تابع أكثر الصفحات زيارة لتحسين المحتوى
📊 راجع التحليلات التفصيلية في لوحة التحكم
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  /// Send notification for new website visitor
  Future<void> notifyNewVisitor({
    required Map<String, dynamic> visitorData,
  }) async {
    final todayVisitors = visitorData['todayVisitors'] ?? 0;
    final totalVisitors = visitorData['totalVisitors'] ?? 0;
    final topPage = visitorData['topPage'] ?? 'الرئيسية';

    final message = '''
🎉 *زائر جديد للموقع!*

📊 *زوار اليوم:* $todayVisitors
📈 *إجمالي الزوار:* $totalVisitors
🔥 *الصفحة الأكثر زيارة:* $topPage

⏰ *الآن:* ${_notificationService._formatDateTime(DateTime.now())}

🚀 *نمو رائع!* موقعك يجذب المزيد من الزوار
💡 راجع التحليلات التفصيلية في لوحة التحكم
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  /// Send notification for new customer message
  Future<void> notifyNewMessage({
    required String senderName,
    required String senderEmail,
    required String subject,
    required String messagePreview,
  }) async {
    final message = '''
📧 *رسالة جديدة من العميل*

👤 المرسل: $senderName
📧 البريد: $senderEmail
📝 الموضوع: $subject

💬 معاينة الرسالة:
${messagePreview.length > 100 ? '${messagePreview.substring(0, 100)}...' : messagePreview}

⏰ الوقت: ${_notificationService._formatDateTime(DateTime.now())}

🔗 عرض الرسالة كاملة في لوحة التحكم
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  /// Send notification for new service request
  Future<void> notifyNewServiceRequest({
    required String clientName,
    required String serviceName,
    required String requestId,
    required String status,
  }) async {
    final message = '''
🛠️ *طلب خدمة جديد*

👤 العميل: $clientName
🔧 الخدمة: $serviceName
🆔 رقم الطلب: $requestId
📊 الحالة: $status

⏰ وقت الطلب: ${_notificationService._formatDateTime(DateTime.now())}

🔗 عرض تفاصيل الطلب في لوحة التحكم
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  /// Send system alert notification
  Future<void> notifySystemAlert({
    required String alertType,
    required String description,
    String priority = 'متوسط',
  }) async {
    final priorityEmoji = priority == 'عالي'
        ? '🚨'
        : priority == 'متوسط'
            ? '⚠️'
            : 'ℹ️';

    final message = '''
$priorityEmoji *تنبيه النظام*

🔔 نوع التنبيه: $alertType
📋 الوصف: $description
📊 الأولوية: $priority

⏰ الوقت: ${_notificationService._formatDateTime(DateTime.now())}

🔗 تحقق من لوحة التحكم للمزيد
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  /// Send daily summary notification
  Future<void> sendDailySummary({
    required Map<String, dynamic> summaryData,
  }) async {
    String _getTopPage(dynamic topPages) {
      if (topPages is List && topPages.isNotEmpty) {
        return topPages.first.toString();
      }
      return 'الرئيسية';
    }

    int _getTotalNotifications(Map<String, dynamic> summaryData) {
      return (summaryData['newVisitors'] as int? ?? 0) +
          (summaryData['contactFormSubmissions'] as int? ?? 0) +
          (summaryData['newMessages'] as int? ?? 0) +
          (summaryData['serviceRequests'] as int? ?? 0);
    }

    String _generateDailySummaryInsight(Map<String, dynamic> summaryData) {
      final visitors = summaryData['newVisitors'] as int? ?? 0;
      final contacts = summaryData['contactFormSubmissions'] as int? ?? 0;
      final total = _getTotalNotifications(summaryData);

      if (total == 0) {
        return 'يوم هادئ! لا توجد نشاطات جديدة.';
      } else if (visitors > contacts * 10) {
        return 'زيارات عالية! فكر في تحسين دعوات العمل لزيادة التفاعل.';
      } else if (contacts > 0) {
        return 'تفاعل ممتاز! يرجى الرد على رسائل التواصل في أقرب وقت.';
      } else {
        return 'نشاط جيد! استمر في تقديم محتوى قيم.';
      }
    }

    final message = '''
📊 *التقرير اليومي - ${_notificationService._formatDate(DateTime.now())}*

━━━━━━━━━━━━━━━━━━━━━━━━

👥 *إحصائيات الزوار:*
   🔹 زوار جدد: ${summaryData['newVisitors'] ?? 0}
   🔹 إجمالي الزيارات: ${summaryData['totalVisits'] ?? 0}
   🔹 الصفحات الأكثر زيارة: ${_getTopPage(summaryData['topPages'])}

💬 *الرسائل والتفاعل:*
   🔹 رسائل تواصل: ${summaryData['contactFormSubmissions'] ?? 0}
   🔹 رسائل عامة: ${summaryData['newMessages'] ?? 0}
   🔹 طلبات خدمة: ${summaryData['serviceRequests'] ?? 0}

📱 *نشاط الإشعارات:*
   🔹 إجمالي الإشعارات المرسلة: ${_getTotalNotifications(summaryData)}

━━━━━━━━━━━━━━━━━━━━━━━━

🎯 *ملاحظة للمشرف:*
${_generateDailySummaryInsight(summaryData)}

📅 *تاريخ التقرير:* ${_notificationService._formatDateTime(DateTime.now())}
''';

    await _notificationService.sendNotificationToAll(message: message);
  }
}

/// Provider for the notification manager
final adminNotificationManagerProvider =
    Provider<AdminNotificationManager>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return AdminNotificationManager(notificationService);
});
Future<void> notifyNewContactForm({
  required String name,
  required String email,
  required String phone,
  required String subject,
  required String messagePreview,
}) async {
  final message = '''
📩 *رسالة تواصل جديدة*

👤 *الاسم:* $name
📧 *البريد الإلكتروني:* $email
📱 *الهاتف:* ${phone.isEmpty ? 'غير محدد' : phone}
📋 *الموضوع:* $subject

💬 *معاينة الرسالة:*
${messagePreview.length > 200 ? '${messagePreview.substring(0, 200)}...' : messagePreview}

⏰ *وقت الإرسال:* ${_formatDateTime(DateTime.now())}

🔔 *تنبيه:* يرجى مراجعة لوحة التحكم للرد على الرسالة
''';

  await _sendTelegramMessage(message);
}

// NEW: Notify when someone visits the website
Future<void> notifyNewWebsiteVisitor({
  required int visitorCount,
  required int currentOnline,
  required String pageViewed,
  required DateTime timestamp,
}) async {
  final message = '''
👥 *زائر جديد للموقع*

📊 *رقم الزائر:* $visitorCount
🔴 *متصل الآن:* $currentOnline نسمة
📄 *الصفحة المشاهدة:* $pageViewed

⏰ *وقت الزيارة:* ${_formatDateTime(timestamp)}

📈 *ملاحظة:* يمكنك متابعة نشاط الموقع من لوحة التحكم
🎯 استمر في تقديم محتوى قيم لجذب المزيد من الزوار!
''';

  await _sendTelegramMessage(message);
}

// NEW: Notify when someone visits a specific page
Future<void> notifyPageVisit({
  required String pageName,
  required int visitorCount,
  String? userAgent,
  required DateTime timestamp,
}) async {
  final browserInfo =
      userAgent != null ? _extractBrowserInfo(userAgent) : 'غير محدد';

  final message = '''
📄 *زيارة صفحة جديدة*

🏷️ *الصفحة:* $pageName
👤 *رقم الزائر:* $visitorCount
🖥️ *المتصفح:* $browserInfo
⏰ *الوقت:* ${_formatDateTime(timestamp)}

💡 *نصيحة:* تابع أكثر الصفحات زيارة لتحسين المحتوى
📊 راجع التحليلات التفصيلية في لوحة التحكم
''';

  await _sendTelegramMessage(message);
}

// Enhanced visitor notification with more details
Future<void> notifyNewVisitor(
    {required Map<String, dynamic> visitorData}) async {
  final todayVisitors = visitorData['todayVisitors'] ?? 0;
  final totalVisitors = visitorData['totalVisitors'] ?? 0;
  final topPage = visitorData['topPage'] ?? 'الرئيسية';

  final message = '''
🎉 *زائر جديد للموقع!*

📊 *زوار اليوم:* $todayVisitors
📈 *إجمالي الزوار:* $totalVisitors
🔥 *الصفحة الأكثر زيارة:* $topPage

⏰ *الآن:* ${_formatDateTime(DateTime.now())}

🚀 *نمو رائع!* موقعك يجذب المزيد من الزوار
💡 راجع التحليلات التفصيلية في لوحة التحكم
''';

  await _sendTelegramMessage(message);
}

// Send enhanced daily summary including contact forms and visitors
Future<void> sendDailySummary(
    {required Map<String, dynamic> summaryData}) async {
  final message = '''
📊 *التقرير اليومي - ${_formatDate(DateTime.now())}*

━━━━━━━━━━━━━━━━━━━━━━━━

👥 *إحصائيات الزوار:*
   🔹 زوار جدد: ${summaryData['newVisitors'] ?? 0}
   🔹 إجمالي الزيارات: ${summaryData['totalVisits'] ?? 0}
   🔹 الصفحات الأكثر زيارة: ${_getTopPage(summaryData['topPages'])}

💬 *الرسائل والتفاعل:*
   🔹 رسائل تواصل: ${summaryData['contactFormSubmissions'] ?? 0}
   🔹 رسائل عامة: ${summaryData['newMessages'] ?? 0}
   🔹 طلبات خدمة: ${summaryData['serviceRequests'] ?? 0}

📱 *نشاط الإشعارات:*
   🔹 إجمالي الإشعارات المرسلة: ${_getTotalNotifications(summaryData)}

━━━━━━━━━━━━━━━━━━━━━━━━

🎯 *ملاحظة للمشرف:*
${_generateDailySummaryInsight(summaryData)}

📅 *تاريخ التقرير:* ${_formatDateTime(DateTime.now())}
''';

  await _sendTelegramMessage(message);
}

// Private helper methods
Future<void> _sendTelegramMessage(String message) async {
  try {
    final url =
        'https://api.telegram.org/bot${NotificationService._telegramBotTokenKey}/sendMessage';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'chat_id': NotificationService._adminTelegramChatIdKey,
        'text': message,
        'parse_mode': 'Markdown',
        'disable_web_page_preview': true,
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to send Telegram message: ${response.body}');
    }
  } catch (e) {
    print('Error sending Telegram message: $e');
  }
}

// Helper method to extract browser info from user agent
String _extractBrowserInfo(String userAgent) {
  final ua = userAgent.toLowerCase();

  if (ua.contains('firefox')) {
    return 'Firefox 🦊';
  } else if (ua.contains('chrome') && !ua.contains('edge')) {
    return 'Chrome 🌐';
  } else if (ua.contains('safari') && !ua.contains('chrome')) {
    return 'Safari 🧭';
  } else if (ua.contains('edge')) {
    return 'Edge 🔷';
  } else if (ua.contains('opera')) {
    return 'Opera 🎭';
  } else {
    return 'متصفح آخر 💻';
  }
}

// Helper method to format date and time in Arabic
String _formatDateTime(DateTime dateTime) {
  final arabicMonths = [
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

  final day = dateTime.day;
  final month = arabicMonths[dateTime.month - 1];
  final year = dateTime.year;
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');

  return '$day $month $year - $hour:$minute';
}

String _formatDate(DateTime dateTime) {
  final arabicMonths = [
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

  final day = dateTime.day;
  final month = arabicMonths[dateTime.month - 1];
  final year = dateTime.year;

  return '$day $month $year';
}

String _getTopPage(dynamic topPages) {
  if (topPages is List && topPages.isNotEmpty) {
    return topPages.first.toString();
  }
  return 'الرئيسية';
}

int _getTotalNotifications(Map<String, dynamic> summaryData) {
  return (summaryData['newVisitors'] as int? ?? 0) +
      (summaryData['contactFormSubmissions'] as int? ?? 0) +
      (summaryData['newMessages'] as int? ?? 0) +
      (summaryData['serviceRequests'] as int? ?? 0);
}

String _generateDailySummaryInsight(Map<String, dynamic> summaryData) {
  final visitors = summaryData['newVisitors'] as int? ?? 0;
  final contacts = summaryData['contactFormSubmissions'] as int? ?? 0;
  final total = _getTotalNotifications(summaryData);

  if (total == 0) {
    return 'يوم هادئ! لا توجد نشاطات جديدة.';
  } else if (visitors > contacts * 10) {
    return 'زيارات عالية! فكر في تحسين دعوات العمل لزيادة التفاعل.';
  } else if (contacts > 0) {
    return 'تفاعل ممتاز! يرجى الرد على رسائل التواصل في أقرب وقت.';
  } else {
    return 'نشاط جيد! استمر في تقديم محتوى قيم.';
  }
}

class NotificationSettingsWidget extends ConsumerStatefulWidget {
  const NotificationSettingsWidget({super.key});

  @override
  ConsumerState<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends ConsumerState<NotificationSettingsWidget> {
  final _whatsappController = TextEditingController();
  final _telegramChatIdController = TextEditingController();
  final _telegramBotTokenController = TextEditingController();

  bool _isLoading = false;
  bool _whatsappEnabled = true;
  bool _telegramEnabled = true;
  bool _secureStorageAvailable = true;

  @override
  void initState() {
    super.initState();
    _checkSecureStorage();
    _loadSettings();
  }

  Future<void> _checkSecureStorage() async {
    final notificationService = ref.read(notificationServiceProvider);
    final isAvailable = await notificationService.isSecureStorageAvailable();

    if (mounted) {
      setState(() {
        _secureStorageAvailable = isAvailable;
      });

      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تحذير: التخزين الآمن غير متاح على هذا الجهاز',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final notificationService = ref.read(notificationServiceProvider);
      final contacts = await notificationService.getAdminContacts();

      if (mounted) {
        setState(() {
          _whatsappController.text = contacts['whatsapp'] ?? '';
          _telegramChatIdController.text = contacts['telegramChatId'] ?? '';
          _telegramBotTokenController.text = contacts['telegramBotToken'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('خطأ في تحميل الإعدادات: $e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      final notificationService = ref.read(notificationServiceProvider);

      await notificationService.setAdminContacts(
        whatsappNumber: _whatsappController.text.trim(),
        telegramChatId: _telegramChatIdController.text.trim(),
        telegramBotToken: _telegramBotTokenController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.security, color: Colors.white),
                const SizedBox(width: 8),
                Text('تم حفظ الإعدادات بأمان', style: GoogleFonts.cairo()),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('خطأ في حفظ الإعدادات: $e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testNotification() async {
    final notificationService = ref.read(notificationServiceProvider);

    try {
      await notificationService.sendNotificationToAll(
        message: '🧪 رسالة اختبار من لوحة التحكم\n\n⏰ الوقت: ${DateTime.now()}',
        includeWhatsApp: _whatsappEnabled,
        includeTelegram: _telegramEnabled,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('تم إرسال رسالة الاختبار', style: GoogleFonts.cairo()),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إرسال رسالة الاختبار: $e',
                style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllCredentials() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد المسح', style: GoogleFonts.cairo()),
        content: Text(
          'هل أنت متأكد من حذف جميع البيانات المحفوظة؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('حذف', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      try {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.clearAllCredentials();

        setState(() {
          _whatsappController.clear();
          _telegramChatIdController.clear();
          _telegramBotTokenController.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف جميع البيانات', style: GoogleFonts.cairo()),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('خطأ في حذف البيانات: $e', style: GoogleFonts.cairo()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _secureStorageAvailable ? Icons.security : Icons.warning,
                  color: _secureStorageAvailable ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'إعدادات الإشعارات الآمنة',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!_secureStorageAvailable)
                  Chip(
                    label:
                        Text('غير آمن', style: GoogleFonts.cairo(fontSize: 10)),
                    backgroundColor: Colors.orange.withOpacity(0.2),
                  ),
              ],
            ),

            if (!_secureStorageAvailable)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'التخزين الآمن غير متاح. البيانات قد تكون أقل أماناً.',
                        style: GoogleFonts.cairo(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // WhatsApp Settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'إعدادات WhatsApp',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(
                        value: _whatsappEnabled,
                        onChanged: (value) =>
                            setState(() => _whatsappEnabled = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _whatsappController,
                    enabled: _whatsappEnabled,
                    decoration: InputDecoration(
                      labelText: 'رقم WhatsApp (مع رمز البلد)',
                      hintText: '+966501234567',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone),
                      suffixIcon: _secureStorageAvailable
                          ? const Icon(Icons.lock,
                              color: Colors.green, size: 16)
                          : const Icon(Icons.lock_open,
                              color: Colors.orange, size: 16),
                      labelStyle: GoogleFonts.cairo(),
                      hintStyle: GoogleFonts.cairo(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Telegram Settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.telegram, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'إعدادات Telegram',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Switch(
                        value: _telegramEnabled,
                        onChanged: (value) =>
                            setState(() => _telegramEnabled = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _telegramBotTokenController,
                    enabled: _telegramEnabled,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Bot Token',
                      hintText: '123456789:ABCdefGHIjklMNOpqrsTUVwxyz',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.key),
                      suffixIcon: _secureStorageAvailable
                          ? const Icon(Icons.lock,
                              color: Colors.green, size: 16)
                          : const Icon(Icons.lock_open,
                              color: Colors.orange, size: 16),
                      labelStyle: GoogleFonts.cairo(),
                      hintStyle: GoogleFonts.cairo(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _telegramChatIdController,
                    enabled: _telegramEnabled,
                    decoration: InputDecoration(
                      labelText: 'Chat ID',
                      hintText: '123456789',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.chat),
                      suffixIcon: _secureStorageAvailable
                          ? const Icon(Icons.lock,
                              color: Colors.green, size: 16)
                          : const Icon(Icons.lock_open,
                              color: Colors.orange, size: 16),
                      labelStyle: GoogleFonts.cairo(),
                      hintStyle: GoogleFonts.cairo(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveSettings,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _isLoading ? 'جاري الحفظ...' : 'حفظ الإعدادات',
                      style: GoogleFonts.cairo(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _testNotification,
                  icon: const Icon(Icons.send),
                  label: Text('اختبار', style: GoogleFonts.cairo()),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clearAllCredentials,
                  icon: const Icon(Icons.delete_forever),
                  label: Text('مسح', style: GoogleFonts.cairo()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'تعليمات الإعداد الآمن:',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• جميع البيانات الحساسة يتم تشفيرها وحفظها بشكل آمن\n'
                    '• للحصول على Telegram Bot Token: ابحث عن @BotFather في تليجرام\n'
                    '• للحصول على Chat ID: ابحث عن @userinfobot في تليجرام\n'
                    '• رقم WhatsApp يجب أن يتضمن رمز البلد (+966 للسعودية)\n'
                    '• استخدم زر "مسح" لحذف جميع البيانات المحفوظة',
                    style: GoogleFonts.cairo(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    _telegramChatIdController.dispose();
    _telegramBotTokenController.dispose();
    super.dispose();
  }
}
