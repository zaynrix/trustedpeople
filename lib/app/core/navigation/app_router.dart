import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/presentation/pages/admin_payment_places_screen.dart';
import 'package:trustedtallentsvalley/features/auth/presentation/pages/login_page.dart';
import 'package:trustedtallentsvalley/features/auth/presentation/providers/auth_provider.dart';
import 'package:trustedtallentsvalley/features/user/home/presentation/pages/user_home_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/activityDetailScreen.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/blackList_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/contactUs_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/trade_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/trusted_screen.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/screens/payment_places_screen.dart';
import 'package:trustedtallentsvalley/fetures/auth/BlockedUsersScreen.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin_dashboard.dart';
import 'package:trustedtallentsvalley/fetures/auth/unauthorized_screen.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Router provider that depends on auth state
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRouter.homePath,
    routes: [
      GoRoute(
        path: AppRouter.homePath,
        name: AppRouter.home,
        builder: (context, state) => const UserHomeScreen(),
      ),
      GoRoute(
        path: AppRouter.trustedPath,
        name: AppRouter.trusted,
        builder: (context, state) => const TrustedUsersScreen(),
      ),
      GoRoute(
        path: AppRouter.untrustedPath,
        name: AppRouter.untrusted,
        builder: (context, state) => const BlackListUsersScreen(),
      ),
      GoRoute(
        path: AppRouter.instructionPath,
        name: AppRouter.instruction,
        builder: (context, state) => const ProtectionGuideScreen(),
      ),
      // GoRoute(
      //   path: ScreensNames.ortPath,
      //   name: ScreensNames.ort,
      //   builder: (context, state) {
      //     if(authState.isAdmin){
      //       return const AdminPaymentPlacesScreen();
      //     } else  {
      //       return UserPaymentPlacesScreen();
      //     }
      //   } ,
      // ),
      GoRoute(
        path: AppRouter.contactUsPath,
        name: AppRouter.contactUs,
        builder: (context, state) => ContactUsScreen(),
      ),
      // Add these new routes
      GoRoute(
        path: AppRouter.loginPath,
        name: AppRouter.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: ScreensNames.blockedUsersPath,
        name: ScreensNames.blockedUsers,
        builder: (context, state) {
          // Only allow admins to access
          if (authState.isAdmin) {
            return const BlockedUsersScreen2();
          } else {
            return const UnauthorizedScreen();
          }
        },
      ),

      GoRoute(
        path: ScreensNames.updatesPath,
        name: ScreensNames.updates,
        builder: (context, state) => const AllUpdatesScreen(),
      ),
      // GoRoute(
      //   path: ScreensNames.adminPath,
      //   name: ScreensNames.admin,
      //   builder: (context, state) {
      //     // Only allow admins to access admin page
      //     if (authState.isAdmin) {
      //       return const AdminDashboardScreen();
      //     } else {
      //       return const UnauthorizedScreen();
      //     }
      //   },
      // ),
      GoRoute(
        path: ScreensNames.adminDashboardPath,
        name: ScreensNames.adminDashboard,
        builder: (context, state) {
          // Only allow admins to access admin page
          if (authState.isAdmin) {
            return const AdminDashboard();
          } else {
            return const UnauthorizedScreen();
          }
        },
      ),
      GoRoute(
        path: AppRouter.adminPaymentPlacePath,
        name: AppRouter.adminPaymentPlace,
        builder: (context, state) {
          // Only allow admins to access admin page
          if(authState.isAdmin){
            return const AdminPaymentPlacesScreen();
          } else  {
            return UserPaymentPlacesScreen();
          }
        },
      ),
      GoRoute(
        path: '/secure-admin-784512/login',
        name: 'adminLogin',
        builder: (context, state) {
          if (kDebugMode) {
            print(
                "🔐 Admin login route matched! Path: ${state.uri.toString()}");
          }
          return const LoginPage();
        },
      ),
      // GoRoute(
      //   path: '/secure-admin-784512/dashboard', // Obscure path
      //   name: 'adminDashboard', // No constant reference in ScreensNames
      //   builder: (context, state) {
      //     // Only allow authenticated admins
      //     if (authState.isAdmin) {
      //       return const AdminDashboardScreen();
      //     } else {
      //       return const Scaffold(
      //         body: Center(
      //             child: Text('Page not found')), // Generic error for security
      //       );
      //     }
      //   },
      // ),
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
              onPressed: () => context.go(AppRouter.homePath),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

class AppRouter {
  // Route names
  static const String home = 'home';
  static const String trusted = 'trusted';
  static const String untrusted = 'untrusted';
  static const String instruction = 'instruction';
  static const String contactUs = 'contactUs';
  static const String paymentPlaces = 'paymentPlaces';
  static const String login = 'login';
  static const String admin = 'admin';
  static const String adminPaymentPlace = 'admin_payment_place';
  static const String adminAddPaymentPlace = 'admin_add_payment_place';
  static const String adminEditPaymentPlace = 'admin_edit_payment_place';

  // Paths (must start with "/")
  static const String homePath = '/';
  static const String trustedPath = '/trusted';
  static const String untrustedPath = '/untrusted';
  static const String instructionPath = '/instruction';
  static const String contactUsPath = '/contact-us';
  static const String paymentPlacesPath = '/payment-places';
  static const String loginPath = '/login';
  static const String adminPath = '/admin';
  static const String adminPaymentPlacePath = '/admin_payment_place_path';
  static const String adminAddPaymentPlacePath = '/admin_add_payment_place';
  static const String adminEditPaymentPlacePath = '/admin_edit_payment_place';
}
