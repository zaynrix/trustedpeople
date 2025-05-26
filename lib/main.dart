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
import 'package:trustedtallentsvalley/providers/analytics_provider2.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';
import 'package:trustedtallentsvalley/service_locator.dart';

import 'fetures/auth/blocked_screen.dart';

// Add a state provider for blocked status
final isUserBlockedProvider = StateProvider<bool>((ref) => false);

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
    });

    // Record the initial page view
    final initialLocation = router.routeInformationProvider.value.location;
    final segments = initialLocation.split('/');
    final title =
        segments.isEmpty || segments.last.isEmpty ? 'home' : segments.last;
    ref.read(visitorAnalyticsProvider).recordPageView(initialLocation, title);
    debugPrint('Initial page view recorded: $initialLocation');
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
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      locale: const Locale('ar', 'AR'),
    );
  }
}
