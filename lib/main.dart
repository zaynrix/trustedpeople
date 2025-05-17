import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trustedtallentsvalley/app/core/storage/storage_service.dart';
import 'package:trustedtallentsvalley/app/core/theme/app_theme.dart';
// Import your theme providers
import 'package:trustedtallentsvalley/app/core/theme/theme_providers.dart';
import 'package:trustedtallentsvalley/providers/analytics_provider.dart';
import 'package:trustedtallentsvalley/providers/analytics_provider2.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';
import 'package:trustedtallentsvalley/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage (Hive)
  // await StorageService.init();

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

  // Setup service provider
  final container = ProviderContainer();

  // Record unique visit (will only count once per day)
  await container.read(visitorAnalyticsProvider).recordUniqueVisit();

  runApp(const ProviderScope(child: TrustedGazianApp()));
}

class TrustedGazianApp extends ConsumerWidget {
  const TrustedGazianApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the router from the provider instead of creating a new one
    final router = ref.watch(routerProvider);

    // Use the themeModeProvider to get the current theme mode
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      routerConfig: router, // Using the GoRouter from our provider
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Using the theme mode from the provider
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      locale: const Locale('ar', 'AR'),
    );
  }
}