import 'dart:html' as html;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:trustedtallentsvalley/core/theme/app_theme.dart';
import 'package:trustedtallentsvalley/fetures/services/block_service.dart';
import 'package:trustedtallentsvalley/fetures/services/notification_service.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/enhanced_analytics_provider.dart';
import 'package:trustedtallentsvalley/providers/analytics_provider2.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';
import 'package:trustedtallentsvalley/service_locator.dart';

import 'fetures/auth/blocked_screen.dart';

// Add a state provider for blocked status
final isUserBlockedProvider = StateProvider<bool>((ref) => false);

// Add a provider to track if notifications are enabled
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);

  // Initialize Firebase for web
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC_xVfBVGpI6s371eh5m7zQIxy_s0LEqag",
        appId: "1:511012871086:web:3d64951c90d03b7a39463f",
        messagingSenderId: "511012871086",
        projectId: "truested-776cd",
      ),
    );
  }

  await ScreenUtil.ensureScreenSize();
  await init(); // Initializes service locator

  // Setup provider container
  final container = ProviderContainer();

  // Check if user is blocked
  bool isBlocked = false;
  try {
    isBlocked = await BlockService.isUserBlocked();
    container.read(isUserBlockedProvider.notifier).state = isBlocked;
  } catch (e) {
    debugPrint('Error checking if user is blocked: $e');
  }

  // Only record analytics if user is not blocked
  if (!isBlocked) {
    try {
      // Important: Record visit for ALL users (not just admins)
      final analyticsService = container.read(visitorAnalyticsProvider);
      final success = await analyticsService.recordUniqueVisit();
      debugPrint('Visit recording success: $success');

      // Initialize notification system for new visitors
      if (success) {
        try {
          final notificationManager =
              container.read(adminNotificationManagerProvider);
          final visitorStats = await analyticsService.getVisitorStats();

          // Send notification for new visitor
          await notificationManager.notifyNewVisitor(visitorData: visitorStats);
          debugPrint('New visitor notification sent');
        } catch (e) {
          debugPrint('Error sending new visitor notification: $e');
        }
      }
    } catch (e) {
      debugPrint('Error recording visit: $e');
    }
  }

  runApp(ProviderScope(parent: container, child: const TrustedGazianApp()));
  html.window.dispatchEvent(html.Event('flutter-initialized'));
}

class TrustedGazianApp extends ConsumerStatefulWidget {
  const TrustedGazianApp({Key? key}) : super(key: key);

  @override
  ConsumerState<TrustedGazianApp> createState() => _TrustedGazianAppState();
}

class _TrustedGazianAppState extends ConsumerState<TrustedGazianApp> {
  @override
  void initState() {
    super.initState();

    // Set up analytics tracking after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAnalyticsTracking();
      _initializeNotificationSystem();
    });
  }

  void _setupAnalyticsTracking() {
    // Only track if user is not blocked
    final isBlocked = ref.read(isUserBlockedProvider);
    if (isBlocked) return;

    // Get the router and set up tracking
    final router = ref.read(routerProvider);

    // Add listener to track route changes for ALL users
    router.routerDelegate.addListener(() {
      final location = router.routeInformationProvider.value.location;
      // Extract page title from path
      final segments = location.split('/');
      final title =
          segments.isEmpty || segments.last.isEmpty ? 'home' : segments.last;

      // Record page view for analytics
      ref.read(visitorAnalyticsProvider).recordPageView(location, title);
      debugPrint('Page view recorded: $location, title: $title');

      // Send page view notification for admin monitoring
      _notifyPageView(location, title);
    });

    // Record the initial page view
    final initialLocation = router.routeInformationProvider.value.location;
    final segments = initialLocation.split('/');
    final title =
        segments.isEmpty || segments.last.isEmpty ? 'home' : segments.last;
    ref.read(visitorAnalyticsProvider).recordPageView(initialLocation, title);
    debugPrint('Initial page view recorded: $initialLocation');
  }

  void _initializeNotificationSystem() {
    // Only initialize if user is not blocked and notifications are enabled
    final isBlocked = ref.read(isUserBlockedProvider);
    final notificationsEnabled = ref.read(notificationsEnabledProvider);

    if (isBlocked || !notificationsEnabled) return;

    try {
      // Initialize system monitoring
      ref.read(systemMonitorProvider);
      ref.read(dailySummaryProvider);

      debugPrint('Notification system initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification system: $e');
    }
  }

  void _notifyPageView(String location, String title) {
    // Only send notifications if user is not blocked
    final isBlocked = ref.read(isUserBlockedProvider);
    if (isBlocked) return;

    try {
      // Send user activity notification for important pages
      final importantPages = [
        '/admin',
        '/dashboard',
        '/service-request',
        '/contact'
      ];

      if (importantPages.any((page) => location.contains(page))) {
        final notificationManager = ref.read(adminNotificationManagerProvider);
        notificationManager.notifyUserActivity(
          activityType: 'زيارة صفحة مهمة',
          userName: 'زائر',
          details: 'تم الوصول إلى صفحة: $title',
        );
      }
    } catch (e) {
      debugPrint('Error sending page view notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is blocked
    final isBlocked = ref.watch(isUserBlockedProvider);

    // Use the appropriate router
    final router = isBlocked
        ? GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const BlockedScreen(),
              ),
            ],
          )
        : ref.watch(routerProvider);

    return MaterialApp.router(
      builder: (context, child) {
        // Add notification system initialization here for better lifecycle management
        if (!isBlocked) {
          // Initialize enhanced providers to start monitoring
          ref.read(enhancedAnalyticsDataProvider);
          ref.read(enhancedServiceRequestsProvider);
          ref.read(enhancedMessagesProvider);
        }

        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      locale: const Locale('ar', 'AR'),
    );
  }
}

// Extension to add notification helper methods
extension NotificationHelpers on ConsumerState<TrustedGazianApp> {
  /// Send a test notification to verify the system is working
  Future<void> sendTestNotification() async {
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

  /// Handle application lifecycle for notifications
  void handleAppLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App resumed, refresh analytics and check for updates
        ref.refresh(enhancedAnalyticsDataProvider);
        break;
      case AppLifecycleState.paused:
        // App paused, potentially send activity summary
        break;
      case AppLifecycleState.detached:
        // App closing, send session end notification if needed
        _sendSessionEndNotification();
        break;
      default:
        break;
    }
  }

  void _sendSessionEndNotification() {
    try {
      final notificationManager = ref.read(adminNotificationManagerProvider);
      notificationManager.notifyUserActivity(
        activityType: 'انتهاء الجلسة',
        userName: 'زائر',
        details: 'تم إنهاء جلسة التصفح',
      );
    } catch (e) {
      debugPrint('Error sending session end notification: $e');
    }
  }
}
