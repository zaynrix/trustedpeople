// File: lib/utils/notification_helper.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/services/notification_service.dart';

class NotificationHelper {
  /// Initialize notification settings when app starts
  static Future<void> initializeNotificationsStarts(
      ProviderContainer container) async {
    try {
      final notificationService = container.read(notificationServiceProvider);

      // Check if secure storage is available
      final isSecureAvailable =
          await notificationService.isSecureStorageAvailable();
      debugPrint('Secure storage available: $isSecureAvailable');

      // Migrate to secure storage if available
      if (isSecureAvailable) {
        await notificationService.migrateToSecureStorage();
        debugPrint('Migrated to secure storage');
      }

      // Get current settings
      final contacts = await notificationService.getAdminContacts();
      final hasSettings = (contacts['telegramBotToken']?.isNotEmpty ?? false) &&
          (contacts['telegramChatId']?.isNotEmpty ?? false);

      if (hasSettings) {
        debugPrint('Notification system initialized successfully');
      } else {
        debugPrint('Notification system needs configuration');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Initialize notification settings when app starts (for WidgetRef)
  static Future<void> initializeNotifications(WidgetRef ref) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);

      // Check if secure storage is available
      final isSecureAvailable =
          await notificationService.isSecureStorageAvailable();
      debugPrint('Secure storage available: $isSecureAvailable');

      // Migrate to secure storage if available
      if (isSecureAvailable) {
        await notificationService.migrateToSecureStorage();
        debugPrint('Migrated to secure storage');
      }

      // Get current settings
      final contacts = await notificationService.getAdminContacts();
      final hasSettings = (contacts['telegramBotToken']?.isNotEmpty ?? false) &&
          (contacts['telegramChatId']?.isNotEmpty ?? false);

      if (hasSettings) {
        debugPrint('Notification system initialized successfully');
      } else {
        debugPrint('Notification system needs configuration');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Send a test notification to verify the system is working
  static Future<void> sendTestNotification(WidgetRef ref) async {
    try {
      final notificationManager = ref.read(adminNotificationManagerProvider);
      await notificationManager.notifySystemAlert(
        alertType: 'اختبار النظام',
        description: 'تم تشغيل النظام بنجاح وجميع الإشعارات تعمل بشكل صحيح',
        priority: 'متوسط',
      );
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  /// Check if notifications are properly configured
  static Future<bool> areNotificationsConfiguredRef(WidgetRef ref) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      final contacts = await notificationService.getAdminContacts();

      return (contacts['telegramBotToken']?.isNotEmpty ?? false) &&
          (contacts['telegramChatId']?.isNotEmpty ?? false);
    } catch (e) {
      debugPrint('Error checking notification configuration: $e');
      return false;
    }
  }

  /// Check if notifications are properly configured (for ProviderContainer)
  static Future<bool> areNotificationsConfigured(
      ProviderContainer container) async {
    try {
      final notificationService = container.read(notificationServiceProvider);
      final contacts = await notificationService.getAdminContacts();

      return (contacts['telegramBotToken']?.isNotEmpty ?? false) &&
          (contacts['telegramChatId']?.isNotEmpty ?? false);
    } catch (e) {
      debugPrint('Error checking notification configuration: $e');
      return false;
    }
  }

  /// Get notification configuration status
  static Future<Map<String, dynamic>> getNotificationStatus(
      WidgetRef ref) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      final contacts = await notificationService.getAdminContacts();
      final storageInfo = await notificationService.getStorageInfo();

      return {
        'isConfigured': (contacts['telegramBotToken']?.isNotEmpty ?? false) &&
            (contacts['telegramChatId']?.isNotEmpty ?? false),
        'hasTelegram': (contacts['telegramBotToken']?.isNotEmpty ?? false) &&
            (contacts['telegramChatId']?.isNotEmpty ?? false),
        'hasWhatsApp': contacts['whatsapp']?.isNotEmpty ?? false,
        'storageType': storageInfo['storageType'],
        'isSecureStorageAvailable': storageInfo['isSecureAvailable'],
      };
    } catch (e) {
      debugPrint('Error getting notification status: $e');
      return {
        'isConfigured': false,
        'hasTelegram': false,
        'hasWhatsApp': false,
        'storageType': 'unknown',
        'isSecureStorageAvailable': false,
        'error': e.toString(),
      };
    }
  }

  /// Clear all notification settings (useful for logout/reset)
  static Future<void> clearNotificationSettings(WidgetRef ref) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.clearAllCredentials();
      debugPrint('Notification settings cleared');
    } catch (e) {
      debugPrint('Error clearing notification settings: $e');
    }
  }

  /// Setup notification credentials
  static Future<bool> setupNotificationCredentials({
    required WidgetRef ref,
    required String telegramBotToken,
    required String telegramChatId,
    String? whatsappNumber,
  }) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);

      await notificationService.setAdminContacts(
        telegramBotToken: telegramBotToken,
        telegramChatId: telegramChatId,
        whatsappNumber: whatsappNumber,
      );

      // Test the configuration by sending a welcome notification
      final notificationManager = ref.read(adminNotificationManagerProvider);
      await notificationManager.notifySystemAlert(
        alertType: 'إعداد النظام',
        description:
            'تم إعداد نظام الإشعارات بنجاح! ستصلك الآن جميع التحديثات.',
        priority: 'عالي',
      );

      debugPrint('Notification credentials setup successfully');
      return true;
    } catch (e) {
      debugPrint('Error setting up notification credentials: $e');
      return false;
    }
  }

  /// Send startup notification
  static Future<void> sendStartupNotification(WidgetRef ref) async {
    try {
      final isConfigured = await areNotificationsConfiguredRef(ref);
      if (!isConfigured) return;

      final notificationManager = ref.read(adminNotificationManagerProvider);
      await notificationManager.notifySystemAlert(
        alertType: 'بدء تشغيل النظام',
        description:
            'تم تشغيل موقع وادي المواهب الموثوق بنجاح وبدء مراقبة النشاط',
        priority: 'منخفض',
      );
    } catch (e) {
      debugPrint('Error sending startup notification: $e');
    }
  }

  /// Track page visit with notification
  static Future<void> trackPageVisit({
    required WidgetRef ref,
    required String pageName,
    String? userAgent,
  }) async {
    try {
      final isConfigured = await areNotificationsConfiguredRef(ref);
      if (!isConfigured) return;

      final notificationManager = ref.read(adminNotificationManagerProvider);
      await notificationManager.notifyPageVisit(
        pageName: pageName,
        visitorCount: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        userAgent: userAgent,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error tracking page visit: $e');
    }
  }
}
