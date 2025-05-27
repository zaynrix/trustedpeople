// File: lib/services/notification_service.dart
import 'dart:convert';

// File: lib/widgets/notification_settings_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _whatsappApiUrl = 'https://api.whatsapp.com/send';
  static const String _telegramApiUrl = 'https://api.telegram.org/bot';

  // Store admin contact info in SharedPreferences
  static const String _adminWhatsAppKey = 'admin_whatsapp';
  static const String _adminTelegramChatIdKey = 'admin_telegram_chat_id';
  static const String _telegramBotTokenKey = 'telegram_bot_token';

  Future<void> setAdminContacts({
    String? whatsappNumber,
    String? telegramChatId,
    String? telegramBotToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (whatsappNumber != null) {
      await prefs.setString(_adminWhatsAppKey, whatsappNumber);
    }
    if (telegramChatId != null) {
      await prefs.setString(_adminTelegramChatIdKey, telegramChatId);
    }
    if (telegramBotToken != null) {
      await prefs.setString(_telegramBotTokenKey, telegramBotToken);
    }
  }

  Future<Map<String, String?>> getAdminContacts() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'whatsapp': prefs.getString(_adminWhatsAppKey),
      'telegramChatId': prefs.getString(_adminTelegramChatIdKey),
      'telegramBotToken': prefs.getString(_telegramBotTokenKey),
    };
  }

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

      // Create WhatsApp URL
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = 'https://wa.me/$cleanNumber?text=$encodedMessage';

      // For web, you can open the URL directly
      // For mobile, you might want to use url_launcher
      print('WhatsApp notification URL: $whatsappUrl');

      // You can also use a WhatsApp Business API if you have access
      // await _sendWhatsAppBusinessAPI(cleanNumber, message);
    } catch (e) {
      print('Error sending WhatsApp notification: $e');
    }
  }

  Future<void> sendTelegramNotification({
    required String message,
    String? customChatId,
    String? customBotToken,
  }) async {
    try {
      final contacts = await getAdminContacts();
      final chatId = customChatId ?? contacts['telegramChatId'];
      final botToken = customBotToken ?? contacts['telegramBotToken'];

      if (chatId == null || botToken == null) {
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
          'parse_mode': 'HTML',
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
}

// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class AdminNotificationManager {
  final NotificationService _notificationService;

  AdminNotificationManager(this._notificationService);

  // New visitor notification
  Future<void> notifyNewVisitor({
    required Map<String, dynamic> visitorData,
  }) async {
    final message = '''
🌟 *زائر جديد للموقع*

📅 التاريخ: ${DateTime.now().toString().split('.')[0]}
🌍 عدد الزوار اليوم: ${visitorData['todayVisitors'] ?? 'غير محدد'}
👥 إجمالي الزوار: ${visitorData['totalVisitors'] ?? 'غير محدد'}

📊 تفاصيل إضافية:
• الصفحات المعروضة: ${visitorData['pageViews'] ?? 'غير محدد'}
• معدل الارتداد: ${visitorData['bounceRate'] ?? 'غير محدد'}%

🔗 عرض التفاصيل الكاملة في لوحة التحكم
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  // New message notification
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

⏰ الوقت: ${DateTime.now().toString().split('.')[0]}

🔗 عرض الرسالة كاملة في لوحة التحكم
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  // New service request notification
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

⏰ وقت الطلب: ${DateTime.now().toString().split('.')[0]}

🔗 عرض تفاصيل الطلب في لوحة التحكم
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  // User activity notification
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

⏰ الوقت: ${DateTime.now().toString().split('.')[0]}

🔗 عرض المزيد في لوحة التحكم
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  // System alert notification
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

⏰ الوقت: ${DateTime.now().toString().split('.')[0]}

🔗 تحقق من لوحة التحكم للمزيد
''';

    await _notificationService.sendNotificationToAll(message: message);
  }

  // Daily summary notification
  Future<void> sendDailySummary({
    required Map<String, dynamic> summaryData,
  }) async {
    final message = '''
📊 *ملخص يومي للموقع*

📅 التاريخ: ${DateTime.now().toString().split(' ')[0]}

📈 إحصائيات اليوم:
• زوار جدد: ${summaryData['newVisitors'] ?? 0}
• إجمالي الزيارات: ${summaryData['totalVisits'] ?? 0}
• رسائل جديدة: ${summaryData['newMessages'] ?? 0}
• طلبات خدمة: ${summaryData['serviceRequests'] ?? 0}

🎯 أعلى الصفحات زيارة:
${summaryData['topPages']?.join('\n• ') ?? 'لا توجد بيانات'}

🔗 عرض التقرير الكامل في لوحة التحكم
''';

    await _notificationService.sendNotificationToAll(message: message);
  }
}

// Provider for the notification manager
final adminNotificationManagerProvider =
    Provider<AdminNotificationManager>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return AdminNotificationManager(notificationService);
});

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notificationService = ref.read(notificationServiceProvider);
    final contacts = await notificationService.getAdminContacts();

    setState(() {
      _whatsappController.text = contacts['whatsapp'] ?? '';
      _telegramChatIdController.text = contacts['telegramChatId'] ?? '';
      _telegramBotTokenController.text = contacts['telegramBotToken'] ?? '';
    });
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الإعدادات بنجاح', style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حفظ الإعدادات', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال رسالة الاختبار', style: GoogleFonts.cairo()),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إرسال رسالة الاختبار', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
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
                const Icon(Icons.notifications, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'إعدادات الإشعارات',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                    decoration: InputDecoration(
                      labelText: 'Bot Token',
                      hintText: '123456789:ABCdefGHIjklMNOpqrsTUVwxyz',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.key),
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
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _testNotification,
                  icon: const Icon(Icons.send),
                  label: Text('اختبار', style: GoogleFonts.cairo()),
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
                  Text(
                    'تعليمات الإعداد:',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• للحصول على Telegram Bot Token: ابحث عن @BotFather في تليجرام\n'
                    '• للحصول على Chat ID: ابحث عن @userinfobot في تليجرام\n'
                    '• رقم WhatsApp يجب أن يتضمن رمز البلد (+966 للسعودية)',
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
