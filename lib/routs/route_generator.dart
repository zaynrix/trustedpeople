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
import 'package:trustedtallentsvalley/fetures/auth/admin_dashboard_screen.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin_login_screen.dart';
import 'package:trustedtallentsvalley/fetures/auth/unauthorized_screen.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/screens/protection_guide_screen.dart';
import 'package:trustedtallentsvalley/fetures/home/screens/admin_dash_status_screen.dart';
import 'package:trustedtallentsvalley/fetures/main_screen.dart';
import 'package:trustedtallentsvalley/fetures/maintenance/maintenance_service.dart';
import 'package:trustedtallentsvalley/fetures/maintenance/screens/maintenance_screen.dart';
import 'package:trustedtallentsvalley/fetures/mouthoq/screens/application_status.dart';
import 'package:trustedtallentsvalley/fetures/mouthoq/screens/trusted_user_dashboard.dart';
import 'package:trustedtallentsvalley/fetures/mouthoq/screens/trusted_user_login.dart';
import 'package:trustedtallentsvalley/fetures/mouthoq/screens/trusted_user_register.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/services/screens/service_detail_screen.dart';
import 'package:trustedtallentsvalley/fetures/services/screens/service_request_screen.dart';
import 'package:trustedtallentsvalley/fetures/services/screens/services_screen.dart';
import 'package:trustedtallentsvalley/fetures/trusted/screens/blackList_screen.dart';
import 'package:trustedtallentsvalley/fetures/trusted/screens/trusted_screen.dart';

// Import the missing screens that need to be created
// import 'package:trustedtallentsvalley/fetures/mouthoq/screens/trusted_user_dashboard.dart';

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
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAdmin = authState.isAdmin;
      final isTrustedUser = authState.isTrustedUser ?? false; // Add null safety
      final isLoading = authState.isLoading;

      // Show loading while checking auth state
      if (isLoading) return null;

      // Handle admin routes - redirect non-admins trying to access admin areas
      if (state.uri.toString().startsWith('/secure-admin-') && !isAdmin) {
        return '/secure-admin-784512/login';
      }

      // Handle trusted user dashboard - redirect non-trusted users
      if (state.uri.toString() == '/secure-trusted-895623/trusted-dashboard' &&
          !isTrustedUser) {
        return '/secure-trusted-895623/login';
      }

      // Handle admin user applications route - only admins
      if (state.uri
              .toString()
              .startsWith('/secure-trusted-895623/user-applications') &&
          !isAdmin) {
        return '/secure-admin-784512/login';
      }

      // Redirect authenticated users away from login pages
      if (isAuthenticated &&
          isAdmin &&
          state.uri.toString().contains('/secure-admin-784512/login')) {
        return '/secure-admin-784512/dashboard';
      }

      if (isAuthenticated &&
          isTrustedUser &&
          state.uri.toString() == '/secure-trusted-895623/login') {
        return '/secure-trusted-895623/trusted-dashboard';
      }

      return null; // No redirect needed
    },
    routes: [
      // Wrap all routes with the AppShell
      ShellRoute(
        builder: (context, state, child) {
          // Mobile drawer will be handled by AppShell based on screen size
          return AppShell(child: child);
        },
        routes: [
          // ========== PUBLIC ROUTES ==========
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

          // ========== PUBLIC TRUSTED USER ROUTES ==========
          // Public registration route
          GoRoute(
            path: ScreensNames.registerPath,
            name: ScreensNames.register,
            builder: (context, state) => const RegistrationScreen(),
          ),

          // Public application status check route
          GoRoute(
            path: ScreensNames.applicationStatusPath,
            name: ScreensNames.applicationStatus,
            builder: (context, state) => const ApplicationStatusScreen(),
          ),

          // ========== ADMIN ROUTES ==========
          GoRoute(
            path: ScreensNames.loginPath,
            name: ScreensNames.login,
            builder: (context, state) => const AdminLoginScreen(),
          ),
          GoRoute(
            path: ScreensNames.blockedUsersPath,
            name: ScreensNames.blockedUsers,
            builder: (context, state) {
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

          // ========== SERVICE ROUTES ==========
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
              final serviceId = state.pathParameters['serviceId']!;
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

          // ========== ADMIN SERVICE ROUTES ==========
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

          // ========== SECURE ADMIN ROUTES ==========
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
            path: '/secure-admin-784512/dashboard',
            name: 'adminDashboard',
            builder: (context, state) {
              if (authState.isAdmin) {
                return const AdminDashboardScreen();
              } else {
                return const Scaffold(
                  body: Center(child: Text('Page not found')),
                );
              }
            },
          ),

          // ========== TRUSTED USER ROUTES ==========
          // Trusted user login (separate from admin)
          GoRoute(
            path: '/secure-trusted-895623/login',
            name: 'trustedUserLogin',
            builder: (context, state) {
              if (kDebugMode) {
                print(
                    "🔐 Trusted user login route matched! Path: ${state.uri.toString()}");
              }
              return const TrustedUserLoginScreen();
            },
          ),

          // Trusted user registration
          GoRoute(
            path: '/secure-trusted-895623/register',
            name: 'trustedUserRegister',
            builder: (context, state) {
              if (kDebugMode) {
                print(
                    "🔐 Trusted user register route matched! Path: ${state.uri.toString()}");
              }
              return const RegistrationScreen();
            },
          ),

          // Trusted user dashboard (protected - only for approved trusted users)
          GoRoute(
            path: '/secure-trusted-895623/trusted-dashboard',
            name: 'trustedUserDashboard',
            builder: (context, state) {
              if (authState.isAuthenticated &&
                  (authState.isTrustedUser ?? false)) {
                return const TrustedUserDashboard(); //
                //   // TODO: Create TrustedUserDashboard screen
                // Check if user is authenticated trusted user (not admin)
                //   // return Scaffold(
                //   //   appBar: AppBar(title: Text('Trusted User Dashboard')),
                //   //   body: const Center(
                //   //     child: Column(
                //   //       mainAxisAlignment: MainAxisAlignment.center,
                //   //       children: [
                //   //         Text('Welcome to Trusted User Dashboard'),
                //   //         Text('This screen needs to be created'),
                //   //       ],
                //   //     ),
                //   //   ),
                //   // );
                //  Uncomment when screen is created
              } else {
                return const Scaffold(
                  body: Center(child: Text('غير مصرح')),
                );
              }
            },
          ),

          // Admin dashboard for managing applications (different from trusted user dashboard)
          GoRoute(
            path: '/secure-trusted-895623/dashboard',
            name: 'mouthoqDashboard',
            builder: (context, state) {
              if (authState.isAdmin) {
                return const ApplicationStatusScreen(); // Your existing admin screen
              } else {
                return const Scaffold(
                  body: Center(child: Text('Page not found')),
                );
              }
            },
          ),

          // ========== ADMIN USER APPLICATIONS MANAGEMENT ==========
          GoRoute(
            path: '/secure-trusted-895623/user-applications',
            name: ScreensNames.adminUserApplications,
            builder: (context, state) {
              if (authState.isAdmin) {
                return AdminDashboardStatusScreen(); // Your existing admin screen
              } else {
                return const Scaffold(
                  body: Center(child: Text('Page not found')),
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
  static const String login = 'login';
  static const String admin = 'admin';
  static const String adminDashboard = 'admin_dashboard';
  static const String blockedUsers = 'blockedUsers';
  static const String updates = 'updates';

  // Trusted user route names
  static const String register = 'register';
  static const String applicationStatus = 'application_status';
  static const String adminUserApplications = 'admin_user_applications';
  static const String trustedUserLogin = 'trusted_user_login';
  static const String trustedUserRegister = 'trusted_user_register';
  static const String trustedUserDashboard = 'trusted_user_dashboard';

  // Service routes
  static const String services = 'services';
  static const String serviceDetail = 'service_detail';
  static const String serviceRequest = 'service_request';

  // Admin routes
  static const String adminServices = 'admin_services';
  static const String adminServiceRequests = 'admin_service_requests';

  // paths (must start with "/")
  static const String homePath = '/';
  static const String updatesPath = '/updates';
  static const String blockedUsersPath = '/blocked-users';
  static const String trustedPath = '/trusted';
  static const String untrustedPath = '/untrusted';
  static const String instructionPath = '/instruction';
  static const String contactUsPath = '/contact-us';
  static const String ortPath = '/bank-payment-locations';
  static const String loginPath = '/login';
  static const String adminPath = '/admin';
  static const String adminDashboardPath = '/admin_dashboard';

  // Trusted user paths
  static const String registerPath = '/register';
  static const String applicationStatusPath = '/application-status';
  static const String trustedUserLoginPath = '/secure-trusted-895623/login';
  static const String trustedUserRegisterPath =
      '/secure-trusted-895623/register';
  static const String trustedUserDashboardPath =
      '/secure-trusted-895623/trusted-dashboard';
}
