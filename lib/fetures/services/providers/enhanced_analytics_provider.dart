// File: lib/providers/enhanced_analytics_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/services/notification_service.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_requests_provider.dart';
import 'package:trustedtallentsvalley/providers/analytics_provider2.dart';

// Enhanced analytics provider with notifications
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
        // New visitor detected
        await notificationManager.notifyNewVisitor(visitorData: data);
      }
    }

    previousData = data;
    return data;
  }).asyncMap((future) => future);
});

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

  // Delegate all methods to the original notifier
  // void refresh() => _originalNotifier.refresh();
  void clearNewRequestsBadge() => _originalNotifier.clearNewRequestsBadge();
// Add other methods as needed...
}

final enhancedServiceRequestsProvider = StateNotifierProvider<
    EnhancedServiceRequestsNotifier, ServiceRequestsState>((ref) {
  final originalNotifier = ref.watch(serviceRequestsProvider.notifier);
  final notificationManager = ref.watch(adminNotificationManagerProvider);
  return EnhancedServiceRequestsNotifier(originalNotifier, notificationManager);
});

// Assuming you have a messages provider, enhance it with notifications
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
  return AsyncValue.data(messagesState.unreadCount);
});

class SystemMonitor {
  final AdminNotificationManager _notificationManager;

  SystemMonitor(this._notificationManager);

  void startMonitoring() {
    // Monitor for system events
    _monitorServerHealth();
    _monitorDatabaseConnections();
    _monitorErrorRates();
  }

  void _monitorServerHealth() {
    // Simulate server health monitoring
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      // Check server health metrics
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
    // Monitor database connections
    Timer.periodic(const Duration(minutes: 10), (timer) async {
      final connectionCount = await _getDatabaseConnections();

      if (connectionCount > 100) {
        // Threshold
        await _notificationManager.notifySystemAlert(
          alertType: 'تحذير قاعدة البيانات',
          description: 'عدد الاتصالات مرتفع: $connectionCount',
          priority: 'متوسط',
        );
      }
    });
  }

  void _monitorErrorRates() {
    // Monitor error rates
    Timer.periodic(const Duration(minutes: 15), (timer) async {
      final errorRate = await _getErrorRate();

      if (errorRate > 0.05) {
        // 5% error rate threshold
        await _notificationManager.notifySystemAlert(
          alertType: 'معدل أخطاء مرتفع',
          description: 'معدل الأخطاء: ${(errorRate * 100).toStringAsFixed(1)}%',
          priority: 'عالي',
        );
      }
    });
  }

  Future<bool> _checkServerHealth() async {
    // Implement actual server health check
    // This is a placeholder
    try {
      // Check response time, memory usage, CPU usage, etc.
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> _getDatabaseConnections() async {
    // Implement actual database connection count
    // This is a placeholder
    return 50;
  }

  Future<double> _getErrorRate() async {
    // Implement actual error rate calculation
    // This is a placeholder
    return 0.02; // 2% error rate
  }

  Future<void> sendDailySummary() async {
    // Collect daily statistics
    final summaryData = await _collectDailySummary();
    await _notificationManager.sendDailySummary(summaryData: summaryData);
  }

  Future<Map<String, dynamic>> _collectDailySummary() async {
    // Collect various metrics for daily summary
    return {
      'newVisitors': 150,
      'totalVisits': 500,
      'newMessages': 12,
      'serviceRequests': 8,
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

  // Schedule daily summary at 8 PM
  Timer.periodic(const Duration(hours: 1), (timer) {
    final now = DateTime.now();
    if (now.hour == 20 && now.minute == 0) {
      // 8:00 PM
      systemMonitor.sendDailySummary();
    }
  });
});
