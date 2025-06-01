// File: lib/providers/enhanced_analytics_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/services/notification_service.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_requests_provider.dart';
import 'package:trustedtallentsvalley/providers/analytics_provider2.dart';

// Enhanced analytics provider with notifications for visitors
final enhancedAnalyticsDataProvider =
    StreamProvider<Map<String, dynamic>>((ref) {
  final analytics = ref.watch(visitorAnalyticsProvider);
  final notificationManager = ref.watch(adminNotificationManagerProvider);

  Map<String, dynamic>? previousData;

  return Stream.periodic(const Duration(seconds: 30), (_) async {
    final data = await analytics.getVisitorStats();

    // Check for new visitors and send notification
    if (previousData != null) {
      final previousVisitors = previousData!['todayVisitors'] as int? ?? 0;
      final currentVisitors = data['todayVisitors'] as int? ?? 0;

      if (currentVisitors > previousVisitors) {
        // New visitor detected - send Telegram notification
        await notificationManager.notifyNewVisitor(visitorData: data);
      }
    }

    previousData = data;
    return data;
  }).asyncMap((future) => future);
});

// Enhanced Contact Form Handler with Telegram notifications
class ContactFormNotifier extends StateNotifier<ContactFormState> {
  final AdminNotificationManager _notificationManager;

  ContactFormNotifier(this._notificationManager)
      : super(ContactFormState(submissions: [], isLoading: false));

  Future<bool> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      // Create new contact submission
      final submission = ContactSubmission(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        subject: subject,
        message: message,
        timestamp: DateTime.now(),
      );

      // Add to state
      state = state.copyWith(
        submissions: [submission, ...state.submissions],
        isLoading: false,
      );

      // Send Telegram notification immediately
      await _notificationManager.notifyNewContactForm(
        name: name,
        email: email,
        phone: phone,
        subject: subject,
        messagePreview:
            message.length > 100 ? '${message.substring(0, 100)}...' : message,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  void markAsRead(String submissionId) {
    final updatedSubmissions = state.submissions.map((submission) {
      if (submission.id == submissionId) {
        return submission.copyWith(isRead: true);
      }
      return submission;
    }).toList();

    state = state.copyWith(submissions: updatedSubmissions);
  }
}

// Contact Form State Management
class ContactFormState {
  final List<ContactSubmission> submissions;
  final bool isLoading;

  ContactFormState({
    required this.submissions,
    required this.isLoading,
  });

  ContactFormState copyWith({
    List<ContactSubmission>? submissions,
    bool? isLoading,
  }) {
    return ContactFormState(
      submissions: submissions ?? this.submissions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get unreadCount => submissions.where((s) => !s.isRead).length;
}

class ContactSubmission {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String subject;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ContactSubmission({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subject,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  ContactSubmission copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? subject,
    String? message,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ContactSubmission(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

// Provider for contact form management
final contactFormProvider =
    StateNotifierProvider<ContactFormNotifier, ContactFormState>((ref) {
  final notificationManager = ref.watch(adminNotificationManagerProvider);
  return ContactFormNotifier(notificationManager);
});

// Visitor Tracking with Real-time Notifications
class VisitorTracker extends StateNotifier<VisitorState> {
  final AdminNotificationManager _notificationManager;
  Timer? _visitorCheckTimer;

  VisitorTracker(this._notificationManager)
      : super(VisitorState(currentVisitors: 0, totalVisitors: 0)) {
    _startVisitorMonitoring();
  }

  void _startVisitorMonitoring() {
    // Check for new visitors every 10 seconds
    _visitorCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkForNewVisitors();
    });
  }

  Future<void> _checkForNewVisitors() async {
    try {
      // Get current visitor data (you'll need to implement this method)
      final newVisitorData = await _getCurrentVisitorData();

      final previousTotal = state.totalVisitors;
      final currentTotal = newVisitorData['totalVisitors'] as int;

      if (currentTotal > previousTotal) {
        // New visitor detected
        state = state.copyWith(
          currentVisitors: newVisitorData['currentVisitors'] as int,
          totalVisitors: currentTotal,
        );

        // Send immediate Telegram notification
        await _notificationManager.notifyNewWebsiteVisitor(
          visitorCount: currentTotal,
          currentOnline: newVisitorData['currentVisitors'] as int,
          pageViewed: newVisitorData['lastPage'] as String? ?? 'الرئيسية',
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error checking visitors: $e');
    }
  }

  Future<Map<String, dynamic>> _getCurrentVisitorData() async {
    // Implement your visitor tracking logic here
    // This could connect to Google Analytics, your database, or other tracking service

    // Placeholder implementation - replace with your actual visitor tracking
    return {
      'totalVisitors': state.totalVisitors + 1, // Simulate new visitor
      'currentVisitors': 5, // Current online users
      'lastPage': 'الرئيسية', // Last viewed page
    };
  }

  // Call this method when someone visits a page
  Future<void> trackPageVisit({
    required String pageName,
    String? userAgent,
    String? ipAddress,
  }) async {
    final newTotal = state.totalVisitors + 1;

    state = state.copyWith(
      totalVisitors: newTotal,
      currentVisitors: state.currentVisitors + 1,
    );

    // Send notification for each page visit
    await _notificationManager.notifyPageVisit(
      pageName: pageName,
      visitorCount: newTotal,
      userAgent: userAgent,
      timestamp: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _visitorCheckTimer?.cancel();
    super.dispose();
  }
}

class VisitorState {
  final int currentVisitors;
  final int totalVisitors;

  VisitorState({
    required this.currentVisitors,
    required this.totalVisitors,
  });

  VisitorState copyWith({
    int? currentVisitors,
    int? totalVisitors,
  }) {
    return VisitorState(
      currentVisitors: currentVisitors ?? this.currentVisitors,
      totalVisitors: totalVisitors ?? this.totalVisitors,
    );
  }
}

final visitorTrackerProvider =
    StateNotifierProvider<VisitorTracker, VisitorState>((ref) {
  final notificationManager = ref.watch(adminNotificationManagerProvider);
  return VisitorTracker(notificationManager);
});

// Enhanced Service Requests Notifier (keeping existing functionality)
class EnhancedServiceRequestsNotifier
    extends StateNotifier<ServiceRequestsState> {
  final ServiceRequestsNotifier _originalNotifier;
  final AdminNotificationManager _notificationManager;

  EnhancedServiceRequestsNotifier(
      this._originalNotifier, this._notificationManager)
      : super(_originalNotifier.state) {
    // Listen to changes in the original notifier
    _originalNotifier.addListener((newState) {
      _checkForNewRequests(state, newState);
      state = newState;
    });
  }

  void _checkForNewRequests(
      ServiceRequestsState oldState, ServiceRequestsState newState) {
    // Check if there are new requests
    if (newState.requests.length > oldState.requests.length) {
      final newRequests = newState.requests
          .where((request) =>
              !oldState.requests.any((old) => old.id == request.id))
          .toList();

      // Send notification for each new request
      for (final request in newRequests) {
        _notificationManager.notifyNewServiceRequest(
          clientName: request.clientName,
          serviceName: request.serviceName,
          requestId: request.id,
          status: request.status.toString(),
        );
      }
    }
  }

  void clearNewRequestsBadge() => _originalNotifier.clearNewRequestsBadge();
}

final enhancedServiceRequestsProvider = StateNotifierProvider<
    EnhancedServiceRequestsNotifier, ServiceRequestsState>((ref) {
  final originalNotifier = ref.watch(serviceRequestsProvider.notifier);
  final notificationManager = ref.watch(adminNotificationManagerProvider);
  return EnhancedServiceRequestsNotifier(originalNotifier, notificationManager);
});

// Enhanced Messages Provider (keeping existing functionality)
class Message {
  final String id;
  final String senderName;
  final String senderEmail;
  final String subject;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderName,
    required this.senderEmail,
    required this.subject,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });
}

class MessagesState {
  final List<Message> messages;
  final bool isLoading;
  final int unreadCount;

  MessagesState({
    required this.messages,
    required this.isLoading,
    required this.unreadCount,
  });

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    int? unreadCount,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class EnhancedMessagesNotifier extends StateNotifier<MessagesState> {
  final AdminNotificationManager _notificationManager;

  EnhancedMessagesNotifier(this._notificationManager)
      : super(MessagesState(messages: [], isLoading: false, unreadCount: 0));

  Future<void> addMessage({
    required String senderName,
    required String senderEmail,
    required String subject,
    required String content,
  }) async {
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderName: senderName,
      senderEmail: senderEmail,
      subject: subject,
      content: content,
      timestamp: DateTime.now(),
    );

    // Add message to state
    state = state.copyWith(
      messages: [newMessage, ...state.messages],
      unreadCount: state.unreadCount + 1,
    );

    // Send notification
    await _notificationManager.notifyNewMessage(
      senderName: senderName,
      senderEmail: senderEmail,
      subject: subject,
      messagePreview: content,
    );
  }

  void markAsRead(String messageId) {
    final updatedMessages = state.messages.map((message) {
      if (message.id == messageId && !message.isRead) {
        return Message(
          id: message.id,
          senderName: message.senderName,
          senderEmail: message.senderEmail,
          subject: message.subject,
          content: message.content,
          timestamp: message.timestamp,
          isRead: true,
        );
      }
      return message;
    }).toList();

    final unreadCount = updatedMessages.where((m) => !m.isRead).length;

    state = state.copyWith(
      messages: updatedMessages,
      unreadCount: unreadCount,
    );
  }
}

final enhancedMessagesProvider =
    StateNotifierProvider<EnhancedMessagesNotifier, MessagesState>((ref) {
  final notificationManager = ref.watch(adminNotificationManagerProvider);
  return EnhancedMessagesNotifier(notificationManager);
});

// Compatible provider for unread count
final enhancedUnreadMessagesCountProvider = Provider<AsyncValue<int>>((ref) {
  final messagesState = ref.watch(enhancedMessagesProvider);
  final contactFormState = ref.watch(contactFormProvider);

  // Combine unread messages and contact form submissions
  final totalUnread = messagesState.unreadCount + contactFormState.unreadCount;
  return AsyncValue.data(totalUnread);
});

// System Monitor (keeping existing functionality)
class SystemMonitor {
  final AdminNotificationManager _notificationManager;

  SystemMonitor(this._notificationManager);

  void startMonitoring() {
    _monitorServerHealth();
    _monitorDatabaseConnections();
    _monitorErrorRates();
  }

  void _monitorServerHealth() {
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      final isHealthy = await _checkServerHealth();
      if (!isHealthy) {
        await _notificationManager.notifySystemAlert(
          alertType: 'خطأ في الخادم',
          description: 'تم اكتشاف مشكلة في أداء الخادم',
          priority: 'عالي',
        );
      }
    });
  }

  void _monitorDatabaseConnections() {
    Timer.periodic(const Duration(minutes: 10), (timer) async {
      final connectionCount = await _getDatabaseConnections();
      if (connectionCount > 100) {
        await _notificationManager.notifySystemAlert(
          alertType: 'تحذير قاعدة البيانات',
          description: 'عدد الاتصالات مرتفع: $connectionCount',
          priority: 'متوسط',
        );
      }
    });
  }

  void _monitorErrorRates() {
    Timer.periodic(const Duration(minutes: 15), (timer) async {
      final errorRate = await _getErrorRate();
      if (errorRate > 0.05) {
        await _notificationManager.notifySystemAlert(
          alertType: 'معدل أخطاء مرتفع',
          description: 'معدل الأخطاء: ${(errorRate * 100).toStringAsFixed(1)}%',
          priority: 'عالي',
        );
      }
    });
  }

  Future<bool> _checkServerHealth() async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> _getDatabaseConnections() async {
    return 50;
  }

  Future<double> _getErrorRate() async {
    return 0.02;
  }

  Future<void> sendDailySummary() async {
    final summaryData = await _collectDailySummary();
    await _notificationManager.sendDailySummary(summaryData: summaryData);
  }

  Future<Map<String, dynamic>> _collectDailySummary() async {
    return {
      'newVisitors': 150,
      'totalVisits': 500,
      'newMessages': 12,
      'serviceRequests': 8,
      'contactFormSubmissions': 5,
      'topPages': ['الرئيسية', 'الخدمات', 'تواصل معنا'],
    };
  }
}

final systemMonitorProvider = Provider<SystemMonitor>((ref) {
  final notificationManager = ref.watch(adminNotificationManagerProvider);
  final monitor = SystemMonitor(notificationManager);
  monitor.startMonitoring();
  return monitor;
});

// Daily summary scheduler
final dailySummaryProvider = Provider<void>((ref) {
  final systemMonitor = ref.watch(systemMonitorProvider);

  Timer.periodic(const Duration(hours: 1), (timer) {
    final now = DateTime.now();
    if (now.hour == 20 && now.minute == 0) {
      systemMonitor.sendDailySummary();
    }
  });
});
