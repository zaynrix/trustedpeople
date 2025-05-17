import 'package:flutter/material.dart';

/// Constants for all app routes
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route names (for named routes)
  static const String home = 'home';
  static const String trusted = 'trusted';
  static const String untrusted = 'untrusted';
  static const String instruction = 'instruction';
  static const String contactUs = 'contactUs';
  static const String ort = 'ort'; // Bank payment locations
  static const String login = 'login';
  static const String admin = 'admin';
  static const String adminDashboard = 'admin_dashboard';

  // Route paths (must start with "/")
  static const String homePath = '/';
  static const String trustedPath = '/trusted';
  static const String untrustedPath = '/untrusted';
  static const String instructionPath = '/instruction';
  static const String contactUsPath = '/contact-us';
  static const String ortPath = '/bank-payment-locations';
  static const String loginPath = '/login';
  static const String adminPath = '/admin';
  static const String adminDashboardPath = '/admin-dashboard';

  // Secure admin paths
  static const String secureAdminLogin = '/secure-admin-784512/login';
  static const String secureAdminDashboard = '/secure-admin-784512/dashboard';
}

/// Key constants for app navigation
class NavigationKeys {
  // Private constructor to prevent instantiation
  NavigationKeys._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(debugLabel: 'scaffoldMessenger');
}
