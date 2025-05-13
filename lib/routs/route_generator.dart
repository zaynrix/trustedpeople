import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/blackList_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/contactUs_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/home_screen.dart'; // Import the new home screen
import 'package:trustedtallentsvalley/fetures/Home/uis/trusted_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/trade_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: ScreensNames.homePath,
  routes: [
    GoRoute(
      path: ScreensNames.homePath,
      name: ScreensNames.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: ScreensNames.trustedPath,
      name: ScreensNames.trusted,
      builder: (context, state) => const TrustedUsersScreen(), // Renamed from HomeScreen to be more specific
    ),
    GoRoute(
      path: ScreensNames.untrustedPath,
      name: ScreensNames.untrusted,
      builder: (context, state) => const BlackListUsersScreen(),
    ),
    GoRoute(
      path: ScreensNames.instructionPath,
      name: ScreensNames.instruction,
      builder: (context, state) => const TransactionsGuideScreen(),
    ),
    GoRoute(
      path: ScreensNames.contactUsPath,
      name: ScreensNames.contactUs,
      builder: (context, state) => ContactUsScreen(),
    ),
    GoRoute(
      path: ScreensNames.ortPath,
      name: ScreensNames.ort,
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('أماكن تقبل الدفع البنكي - قيد الإنشاء')),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('The page you were looking for does not exist.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go(ScreensNames.homePath),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),
);

class ScreensNames {
  // route names
  static const String home = 'home';
  static const String trusted = 'trusted';
  static const String untrusted = 'untrusted';
  static const String instruction = 'instruction';
  static const String contactUs = 'contactUs';
  static const String ort = 'ort';

  // paths (must start with "/")
  static const String homePath = '/';
  static const String trustedPath = '/trusted';
  static const String untrustedPath = '/untrusted';
  static const String instructionPath = '/instruction';
  static const String contactUsPath = '/contact-us';
  static const String ortPath = '/bank-payment-locations';
}