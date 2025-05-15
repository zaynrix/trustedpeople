import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart'; // Added missing import
import 'package:trustedtallentsvalley/providers/analytics_provider.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';
import 'package:trustedtallentsvalley/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

    return MaterialApp.router(
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      routerConfig: router, // Using the GoRouter from our provider
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade600,
          secondary: Colors.blue.shade600,
          background: Colors.grey.shade50,
        ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade600,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade400, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        fontFamily: GoogleFonts.cairo().fontFamily,
        textTheme: GoogleFonts.cairoTextTheme(),
      ),
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      locale: const Locale('ar', 'AR'),
    );
  }
}
