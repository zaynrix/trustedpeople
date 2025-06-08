import 'dart:html' as html;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // Add this import
import 'package:go_router/go_router.dart';
import "package:intl/date_symbol_data_local.dart";
import 'package:trustedtallentsvalley/config/app_config.dart';
import 'package:trustedtallentsvalley/core/theme/app_theme.dart';
import 'package:trustedtallentsvalley/core/utils/notification_helper.dart';
import 'package:trustedtallentsvalley/fetures/services/block_service.dart';
import 'package:trustedtallentsvalley/fetures/services/notification_service.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/enhanced_analytics_provider.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';
import 'package:trustedtallentsvalley/service_locator.dart';

import 'fetures/auth/admin/screens/blocked_screen.dart';

// Add a state provider for blocked status
final isUserBlockedProvider = StateProvider<bool>((ref) => false);

// Add a provider to track if notifications are enabled
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

void main() async {
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);

  // Initialize Firebase for web with environment variables
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        appId: AppConfig.firebaseAppId,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
      ),
    );
  }

  await ScreenUtil.ensureScreenSize();
  await init(); // Initializes service locator

  // Setup provider container
  final container = ProviderContainer();

  // Initialize notification system first
  await NotificationHelper.initializeNotificationsStarts(container);

  // Check if user is blocked
  bool isBlocked = false;
  try {
    isBlocked = await BlockService.isUserBlocked();
    container.read(isUserBlockedProvider.notifier).state = isBlocked;
  } catch (e) {
    debugPrint('Error checking if user is blocked: $e');
  }

  // Only record analytics if user is not blocked
  // if (!isBlocked) {
  //   try {
  //     // Important: Record visit for ALL users (not just admins)
  //     final analyticsService = container.read(visitorAnalyticsProvider);
  //     final success = await analyticsService.recordUniqueVisit();
  //     debugPrint('Visit recording success: $success');
  //
  //     // Initialize notification system for new visitors
  //     if (success) {
  //       try {
  //         final notificationManager =
  //             container.read(adminNotificationManagerProvider);
  //         final visitorStats = await analyticsService.getVisitorStats();
  //
  //         // Send notification for new visitor
  //         await notificationManager.notifyNewVisitor(visitorData: visitorStats);
  //         debugPrint('New visitor notification sent');
  //       } catch (e) {
  //         debugPrint('Error sending new visitor notification: $e');
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error recording visit: $e');
  //   }
  // }

  runApp(ProviderScope(parent: container, child: const TrustedGazianApp()));
  html.window.dispatchEvent(html.Event('flutter-initialized'));
}

class TrustedGazianApp extends ConsumerStatefulWidget {
  const TrustedGazianApp({Key? key}) : super(key: key);

  @override
  ConsumerState<TrustedGazianApp> createState() => _TrustedGazianAppState();
}

class _TrustedGazianAppState extends ConsumerState<TrustedGazianApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // Add lifecycle observer for app state changes
    WidgetsBinding.instance.addObserver(this);

    // Set up analytics tracking after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAnalyticsTracking();
      _initializeNotificationSystem();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _handleAppLifecycle(state);
  }

  void _setupAnalyticsTracking() {
    // Only track if user is not blocked
    final isBlocked = ref.read(isUserBlockedProvider);
    if (isBlocked) return;

    // Get the router and set up tracking
    final router = ref.read(routerProvider);

    // Add listener to track route changes for ALL users
    router.routerDelegate.addListener(() {
      // final location = router.routeInformationProvider.value.location;
      // // Extract page title from path
      // final segments = location.split('/');
      // final title =
      //     segments.isEmpty || segments.last.isEmpty ? 'home' : segments.last;

      // Record page view for analytics
      // ref.read(visitorAnalyticsProvider).recordPageView(location, title);
      // debugPrint('Page view recorded: $location, title: $title');

      // Send page view notification for admin monitoring
      // _notifyPageView(location, title);
    });

    // Record the initial page view
    // final initialLocation = router.routeInformationProvider.value.location;
    // final segments = initialLocation.split('/');
    // final title =
    //     segments.isEmpty || segments.last.isEmpty ? 'home' : segments.last;
    // ref.read(visitorAnalyticsProvider).recordPageView(initialLocation, title);
    // debugPrint('Initial page view recorded: $initialLocation');
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
      // Convert location to Arabic page names
      final pageMap = {
        '/admin': 'لوحة التحكم',
        '/dashboard': 'الرئيسية',
        '/service-request': 'طلبات الخدمة',
        '/contact': 'تواصل معنا',
        '/services': 'الخدمات',
        '/about': 'من نحن',
        '/trusted': 'الموثوقين',
        '/untrusted': 'النصابين',
        '/blocked-users': 'المحظورين',
      };

      // Get Arabic page name
      String arabicPageName = pageMap[location] ?? title;

      // Send detailed page visit notification
      final notificationManager = ref.read(adminNotificationManagerProvider);
      notificationManager.notifyPageVisit(
        pageName: arabicPageName,
        visitorCount: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        userAgent:
            kIsWeb ? html.window.navigator.userAgent : 'Flutter Mobile App',
        timestamp: DateTime.now(),
      );

      // Send additional notification for important pages
      final importantPages = [
        '/admin',
        '/dashboard',
        '/service-request',
        '/contact'
      ];
      if (importantPages.any((page) => location.contains(page))) {
        notificationManager.notifyUserActivity(
          activityType: 'زيارة صفحة مهمة',
          userName: 'زائر',
          details: 'تم الوصول إلى صفحة: $arabicPageName',
        );
      }
    } catch (e) {
      debugPrint('Error sending page view notification: $e');
    }
  }

  /// Handle application lifecycle for notifications
  void _handleAppLifecycle(AppLifecycleState state) {
    final isBlocked = ref.read(isUserBlockedProvider);
    final notificationsEnabled = ref.read(notificationsEnabledProvider);

    if (isBlocked || !notificationsEnabled) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // App resumed, refresh analytics and check for updates
        try {
          ref.refresh(enhancedAnalyticsDataProvider);
          debugPrint('App resumed - analytics refreshed');
        } catch (e) {
          debugPrint('Error refreshing analytics on resume: $e');
        }
        break;
      case AppLifecycleState.paused:
        // App paused, send activity summary
        _sendActivitySummary();
        break;
      case AppLifecycleState.detached:
        // App closing, send session end notification if needed
        _sendSessionEndNotification();
        break;
      default:
        break;
    }
  }

  void _sendActivitySummary() {
    try {
      // Only send summary for longer sessions (avoid spam)
      final notificationManager = ref.read(adminNotificationManagerProvider);
      notificationManager.notifyUserActivity(
        activityType: 'إيقاف مؤقت للجلسة',
        userName: 'زائر',
        details: 'تم إيقاف التطبيق مؤقتاً',
      );
    } catch (e) {
      debugPrint('Error sending activity summary: $e');
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
          try {
            ref.read(enhancedAnalyticsDataProvider);
            ref.read(enhancedServiceRequestsProvider);
            ref.read(enhancedMessagesProvider);
          } catch (e) {
            debugPrint('Error initializing enhanced providers: $e');
          }
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

// Utility class for notification management in main app
class AppNotificationManager {
  final WidgetRef ref;

  AppNotificationManager(this.ref);

  /// Initialize all notification-related providers and services
  Future<void> initializeNotificationSystem() async {
    try {
      // Initialize notification helper
      await NotificationHelper.initializeNotifications(ref);

      // Check if notifications are configured
      final isConfigured =
          await NotificationHelper.areNotificationsConfiguredRef(ref);
      debugPrint('Notifications configured: $isConfigured');

      if (isConfigured) {
        // Send system startup notification
        final notificationManager = ref.read(adminNotificationManagerProvider);
        await notificationManager.notifySystemAlert(
          alertType: 'بدء تشغيل النظام',
          description: 'تم تشغيل التطبيق بنجاح وبدء مراقبة النشاط',
          priority: 'منخفض',
        );
      }
    } catch (e) {
      debugPrint('Error in AppNotificationManager initialization: $e');
    }
  }

  /// Send welcome notification for new visitors
  Future<void> sendWelcomeNotification(Map<String, dynamic> visitorData) async {
    try {
      final notificationManager = ref.read(adminNotificationManagerProvider);
      await notificationManager.notifyNewVisitor(visitorData: visitorData);
    } catch (e) {
      debugPrint('Error sending welcome notification: $e');
    }
  }

  /// Track and notify page changes
  void trackPageChange(String path, String title) {
    try {
      final pageMap = {
        '/': 'الصفحة الرئيسية',
        '/admin': 'لوحة التحكم',
        '/dashboard': 'لوحة المراقبة',
        '/service-request': 'طلبات الخدمة',
        '/contact': 'تواصل معنا',
        '/services': 'الخدمات',
        '/about': 'من نحن',
        '/trusted': 'المستخدمين الموثوقين',
        '/untrusted': 'المستخدمين النصابين',
        '/blocked-users': 'المستخدمين المحظورين',
      };

      final arabicPageName = pageMap[path] ?? title;

      final notificationManager = ref.read(adminNotificationManagerProvider);
      notificationManager.notifyPageVisit(
        pageName: arabicPageName,
        visitorCount: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        userAgent:
            kIsWeb ? html.window.navigator.userAgent : 'Flutter Mobile App',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error tracking page change: $e');
    }
  }
}
