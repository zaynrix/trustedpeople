// Updated route_generator.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/activityDetailScreen.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/contactUs_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/home_screen.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/screens/payment_places_screen.dart';
import 'package:trustedtallentsvalley/fetures/admin/screens/admin_services_screen.dart';
import 'package:trustedtallentsvalley/fetures/auth/BlockedUsersScreen.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin_dashboard.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin_dashboard_screen.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin_login_screen.dart';
import 'package:trustedtallentsvalley/fetures/auth/unauthorized_screen.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/screens/protection_guide_screen.dart';
import 'package:trustedtallentsvalley/fetures/main_screen.dart';
import 'package:trustedtallentsvalley/fetures/maintenance/maintenance_service.dart';
import 'package:trustedtallentsvalley/fetures/maintenance/screens/maintenance_screen.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/services/screens/service_detail_screen.dart';
import 'package:trustedtallentsvalley/fetures/services/screens/service_request_screen.dart';
import 'package:trustedtallentsvalley/fetures/services/screens/services_screen.dart';
import 'package:trustedtallentsvalley/fetures/trusted/screens/blackList_screen.dart';
import 'package:trustedtallentsvalley/fetures/trusted/screens/trusted_screen.dart';

import '../fetures/admin/screens/admin_service_requests_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Helper widget to check maintenance status
class MaintenanceGuard extends ConsumerWidget {
  final String screenName;
  final Widget child;

  const MaintenanceGuard({
    required this.screenName,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isUnderMaintenance = ref.watch(screenMaintenanceProvider(screenName));

    // Allow admins to bypass maintenance mode
    if (authState.isAdmin) {
      return child;
    }

    // Show maintenance screen if the route is under maintenance
    if (isUnderMaintenance) {
      return MaintenanceScreen(screenName: screenName);
    }

    return child;
  }
}

// Router provider that depends on auth state
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: ScreensNames.homePath,
    routes: [
      // Wrap all routes with the AppShell
      ShellRoute(
        builder: (context, state, child) {
          // Mobile drawer will be handled by AppShell based on screen size
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: ScreensNames.homePath,
            name: ScreensNames.home,
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: ScreensNames.trustedPath,
            name: ScreensNames.trusted,
            builder: (context, state) => const MaintenanceGuard(
              screenName: ScreensNames.trusted,
              child: TrustedUsersScreen(),
            ),
          ),
          GoRoute(
            path: ScreensNames.untrustedPath,
            name: ScreensNames.untrusted,
            builder: (context, state) => const MaintenanceGuard(
              screenName: ScreensNames.untrusted,
              child: BlackListUsersScreen(),
            ),
          ),
          GoRoute(
            path: ScreensNames.instructionPath,
            name: ScreensNames.instruction,
            builder: (context, state) => const MaintenanceGuard(
              screenName: ScreensNames.instruction,
              child: ProtectionGuideScreen(),
            ),
          ),
          GoRoute(
            path: ScreensNames.ortPath,
            name: ScreensNames.ort,
            builder: (context, state) => const MaintenanceGuard(
              screenName: ScreensNames.ort,
              child: PaymentPlacesScreen(),
            ),
          ),
          GoRoute(
            path: ScreensNames.contactUsPath,
            name: ScreensNames.contactUs,
            builder: (context, state) => const MaintenanceGuard(
              screenName: ScreensNames.contactUs,
              child: ContactUsScreen(),
            ),
          ),
          // Add these new routes
          GoRoute(
            path: ScreensNames.loginPath,
            name: ScreensNames.login,
            builder: (context, state) => const AdminLoginScreen(),
          ),
          GoRoute(
            path: ScreensNames.blockedUsersPath,
            name: ScreensNames.blockedUsers,
            builder: (context, state) {
              // Only allow admins to access
              if (authState.isAdmin) {
                return const MaintenanceGuard(
                  screenName: ScreensNames.blockedUsers,
                  child: BlockedUsersScreen2(),
                );
              } else {
                return const UnauthorizedScreen();
              }
            },
          ),

          // Service routes
          GoRoute(
            path: '/services',
            name: ScreensNames.services,
            builder: (context, state) => const MaintenanceGuard(
              screenName: ScreensNames.services,
              child: ServicesScreen(),
            ),
          ),
          GoRoute(
            path: '/service/:serviceId',
            name: ScreensNames.serviceDetail,
            builder: (context, state) {
              final serviceId = state.pathParameters[
                  'serviceId']!; // FIXED - parameter name matches path
              return ServiceDetailScreen(serviceId: serviceId);
            },
          ),
          GoRoute(
            path: '/service-request/:serviceId',
            name: ScreensNames.serviceRequest,
            builder: (context, state) {
              final serviceId = state.pathParameters['serviceId']!;
              return ServiceRequestScreen(serviceId: serviceId);
            },
          ),

          // Admin routes (no maintenance guard for admin routes)
          GoRoute(
            path: '/admin/services',
            name: ScreensNames.adminServices,
            builder: (context, state) {
              if (authState.isAdmin) {
                return const MaintenanceGuard(
                  screenName: ScreensNames.adminServices,
                  child: AdminServicesScreen(),
                );
              } else {
                return const UnauthorizedScreen();
              }
            },
          ),
          GoRoute(
            path: '/admin/service-requests',
            name: ScreensNames.adminServiceRequests,
            builder: (context, state) {
              if (authState.isAdmin) {
                return const MaintenanceGuard(
                  screenName: ScreensNames.adminServiceRequests,
                  child: AdminServiceRequestsScreen(),
                );
              } else {
                return const UnauthorizedScreen();
              }
            },
          ),
          GoRoute(
            path: ScreensNames.updatesPath,
            name: ScreensNames.updates,
            builder: (context, state) => const MaintenanceGuard(
              screenName: ScreensNames.updates,
              child: AllUpdatesScreen(),
            ),
          ),
          GoRoute(
            path: ScreensNames.adminDashboardPath,
            name: ScreensNames.adminDashboard,
            builder: (context, state) {
              // Only allow admins to access admin page - NO maintenance guard for admin dashboard
              if (authState.isAdmin) {
                return const AdminDashboard();
              } else {
                return const UnauthorizedScreen();
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
              return const AdminLoginScreen();
            },
          ),
          GoRoute(
            path: '/secure-admin-784512/dashboard', // Obscure path
            name: 'adminDashboard', // No constant reference in ScreensNames
            builder: (context, state) {
              // Only allow authenticated admins - NO maintenance guard
              if (authState.isAdmin) {
                return const AdminDashboardScreen();
              } else {
                return const Scaffold(
                  body: Center(
                      child:
                          Text('Page not found')), // Generic error for security
                );
              }
            },
          ),
        ],
      )
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
});

class ScreensNames {
  // route names
  static const String home = 'home';
  static const String trusted = 'trusted';
  static const String untrusted = 'untrusted';
  static const String instruction = 'instruction';
  static const String contactUs = 'contactUs';
  static const String ort = 'ort';
  static const String login = 'login'; // Add this
  static const String admin = 'admin'; // Add this
  static const String adminDashboard = 'admin_dashboard'; // Add this
  static const String blockedUsers = 'blockedUsers';
  static const String updates = 'updates';
  static const String homePath = '/';
  // paths (must start with "/")

  // Add service routes
  static const String services = 'services';
  static const String serviceDetail = 'service_detail';
  static const String serviceRequest = 'service_request';

  // Admin routes
  static const String adminServices = 'admin_services';
  static const String adminServiceRequests = 'admin_service_requests';
  static const String updatesPath = '/updates';
  static const String blockedUsersPath = '/blocked-users';
  static const String trustedPath = '/trusted';
  static const String untrustedPath = '/untrusted';
  static const String instructionPath = '/instruction';
  static const String contactUsPath = '/contact-us';
  static const String ortPath = '/bank-payment-locations';
  static const String loginPath = '/login'; // Add this
  static const String adminPath = '/admin'; // Add this
  static const String adminDashboardPath = '/admin_dashboard'; // Add this
}
