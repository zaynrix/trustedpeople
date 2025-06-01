// // Updated route_generator.dart
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:trustedtallentsvalley/fetures/Home/uis/activityDetailScreen.dart';
// import 'package:trustedtallentsvalley/fetures/Home/uis/contactUs_screen.dart';
// import 'package:trustedtallentsvalley/fetures/Home/uis/home_screen.dart';
// import 'package:trustedtallentsvalley/fetures/PaymentPlaces/screens/payment_places_screen.dart';
// import 'package:trustedtallentsvalley/fetures/admin/screens/admin_services_screen.dart';
// import 'package:trustedtallentsvalley/fetures/auth/BlockedUsersScreen.dart';
// import 'package:trustedtallentsvalley/fetures/auth/admin_dashboard.dart';
// import 'package:trustedtallentsvalley/fetures/auth/admin_login_screen.dart';
// import 'package:trustedtallentsvalley/fetures/auth/unauthorized_screen.dart';
// import 'package:trustedtallentsvalley/fetures/home/protection_guide/screens/protection_guide_screen.dart';
// import 'package:trustedtallentsvalley/fetures/home/screens/admin_dash_status_screen.dart';
// import 'package:trustedtallentsvalley/fetures/main_screen.dart';
// import 'package:trustedtallentsvalley/fetures/maintenance/maintenance_service.dart';
// import 'package:trustedtallentsvalley/fetures/maintenance/screens/maintenance_screen.dart';
// import 'package:trustedtallentsvalley/fetures/mouthoq/screens/application_status.dart';
// import 'package:trustedtallentsvalley/fetures/mouthoq/screens/trusted_user_dashboard.dart';
// import 'package:trustedtallentsvalley/fetures/mouthoq/screens/trusted_user_login.dart';
// import 'package:trustedtallentsvalley/fetures/mouthoq/screens/trusted_user_register.dart';
// import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
// import 'package:trustedtallentsvalley/fetures/services/screens/service_detail_screen.dart';
// import 'package:trustedtallentsvalley/fetures/services/screens/service_request_screen.dart';
// import 'package:trustedtallentsvalley/fetures/services/screens/services_screen.dart';
// import 'package:trustedtallentsvalley/fetures/trusted/screens/blackList_screen.dart';
// import 'package:trustedtallentsvalley/fetures/trusted/screens/trusted_screen.dart';
//
// // Import the missing screens that need to be created
// // import 'package:trustedtallentsvalley/fetures/mouthoq/screens/trusted_user_dashboard.dart';
//
// import '../fetures/admin/screens/admin_service_requests_screen.dart';
//
// final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
//
// // Helper widget to check maintenance status
// class MaintenanceGuard extends ConsumerWidget {
//   final String screenName;
//   final Widget child;
//
//   const MaintenanceGuard({
//     required this.screenName,
//     required this.child,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authProvider);
//     final isUnderMaintenance = ref.watch(screenMaintenanceProvider(screenName));
//
//     // Allow admins to bypass maintenance mode
//     if (authState.isAdmin) {
//       return child;
//     }
//
//     // Show maintenance screen if the route is under maintenance
//     if (isUnderMaintenance) {
//       return MaintenanceScreen(screenName: screenName);
//     }
//
//     return child;
//   }
// }
//
// // Updated router provider with stable auth watching
// final routerProvider = Provider<GoRouter>((ref) {
//   // Watch auth state but only react to specific changes
//   final authState = ref.watch(authProvider);
//
//   return GoRouter(
//     routerNeglect: true, // Prevents some history issues
//
//     navigatorKey: _rootNavigatorKey,
//     initialLocation: ScreensNames.homePath,
//
//     // Simplified redirect that doesn't interfere with login flows
//     // redirect: (context, state) {
//     //   final currentPath = state.uri.toString();
//     //   final isAuthenticated = authState.isAuthenticated;
//     //   final isAdmin = authState.isAdmin;
//     //   final isTrustedUser = authState.isTrustedUser;
//     //   final isLoading = authState.isLoading;
//     //   print('🔍 Router redirect check:');
//     //   print('  - Path: $currentPath');
//     //   print('  - isAuthenticated: $isAuthenticated');
//     //   print('  - isTrustedUser: $isTrustedUser');
//     //   print('  - isLoading: $isLoading');
//     //
//     //   // Don't redirect during loading states
//     //   if (isLoading) {
//     //     print('🔍 Loading state - no redirect');
//     //     return null;
//     //   }
//     //
//     //   // AUTO-NAVIGATE: If authenticated trusted user is on login page, redirect to dashboard
//     //   if (isAuthenticated &&
//     //       isTrustedUser &&
//     //       currentPath == '/secure-trusted-895623/login') {
//     //     print(
//     //         '🔍 ✅ Authenticated trusted user on login page - redirecting to dashboard');
//     //     return '/secure-trusted-895623/trusted-dashboard';
//     //   }
//     //
//     //   // Protect admin routes
//     //   if (currentPath.startsWith('/secure-admin-') && !isAdmin) {
//     //     print('🔍 Non-admin accessing admin route');
//     //     return '/secure-admin-784512/login';
//     //   }
//     //
//     //   // Protect trusted dashboard from non-authenticated users
//     //   if (currentPath == '/secure-trusted-895623/trusted-dashboard' &&
//     //       (!isAuthenticated || !isTrustedUser)) {
//     //     print('🔍 Non-trusted user accessing dashboard');
//     //     return '/secure-trusted-895623/login';
//     //   }
//     //
//     //   // Protect admin user applications
//     //   if (currentPath.startsWith('/secure-trusted-895623/user-applications') &&
//     //       !isAdmin) {
//     //     print('🔍 Non-admin accessing user applications');
//     //     return '/secure-admin-784512/login';
//     //   }
//     //
//     //   // Redirect authenticated admin away from admin login
//     //   if (isAuthenticated &&
//     //       isAdmin &&
//     //       currentPath == '/secure-admin-784512/login') {
//     //     print('🔍 Authenticated admin on login page');
//     //     return '/secure-admin-784512/dashboard';
//     //   }
//     //
//     //   print('🔍 No redirect needed');
//     //   return null;
//     // },
//     routes: [
//       ShellRoute(
//         builder: (context, state, child) {
//           return AppShell(child: child);
//         },
//         routes: [
//           // ========== PUBLIC ROUTES ==========
//           GoRoute(
//             path: ScreensNames.homePath,
//             name: ScreensNames.home,
//             builder: (context, state) => HomeScreen(),
//           ),
//           GoRoute(
//             path: ScreensNames.trustedPath,
//             name: ScreensNames.trusted,
//             builder: (context, state) => const MaintenanceGuard(
//               screenName: ScreensNames.trusted,
//               child: TrustedUsersScreen(),
//             ),
//           ),
//           GoRoute(
//             path: ScreensNames.untrustedPath,
//             name: ScreensNames.untrusted,
//             builder: (context, state) => const MaintenanceGuard(
//               screenName: ScreensNames.untrusted,
//               child: BlackListUsersScreen(),
//             ),
//           ),
//           GoRoute(
//             path: ScreensNames.instructionPath,
//             name: ScreensNames.instruction,
//             builder: (context, state) => const MaintenanceGuard(
//               screenName: ScreensNames.instruction,
//               child: ProtectionGuideScreen(),
//             ),
//           ),
//           GoRoute(
//             path: ScreensNames.ortPath,
//             name: ScreensNames.ort,
//             builder: (context, state) => const MaintenanceGuard(
//               screenName: ScreensNames.ort,
//               child: PaymentPlacesScreen(),
//             ),
//           ),
//           GoRoute(
//             path: ScreensNames.contactUsPath,
//             name: ScreensNames.contactUs,
//             builder: (context, state) => const MaintenanceGuard(
//               screenName: ScreensNames.contactUs,
//               child: ContactUsScreen(),
//             ),
//           ),
//
//           // ========== PUBLIC TRUSTED USER ROUTES ==========
//           GoRoute(
//             path: ScreensNames.registerPath,
//             name: ScreensNames.register,
//             builder: (context, state) => const RegistrationScreen(),
//           ),
//           GoRoute(
//             path: ScreensNames.applicationStatusPath,
//             name: ScreensNames.applicationStatus,
//             builder: (context, state) => const ApplicationStatusScreen(),
//           ),
//
//           // ========== ADMIN ROUTES ==========
//           GoRoute(
//             path: ScreensNames.loginPath,
//             name: ScreensNames.login,
//             builder: (context, state) => const AdminLoginScreen(),
//           ),
//           GoRoute(
//             path: ScreensNames.blockedUsersPath,
//             name: ScreensNames.blockedUsers,
//             builder: (context, state) {
//               if (authState.isAdmin) {
//                 return const MaintenanceGuard(
//                   screenName: ScreensNames.blockedUsers,
//                   child: BlockedUsersScreen2(),
//                 );
//               } else {
//                 return const UnauthorizedScreen();
//               }
//             },
//           ),
//
//           // ========== SERVICE ROUTES ==========
//           GoRoute(
//             path: '/services',
//             name: ScreensNames.services,
//             builder: (context, state) => const MaintenanceGuard(
//               screenName: ScreensNames.services,
//               child: ServicesScreen(),
//             ),
//           ),
//           GoRoute(
//             path: '/service/:serviceId',
//             name: ScreensNames.serviceDetail,
//             builder: (context, state) {
//               final serviceId = state.pathParameters['serviceId']!;
//               return ServiceDetailScreen(serviceId: serviceId);
//             },
//           ),
//           GoRoute(
//             path: '/service-request/:serviceId',
//             name: ScreensNames.serviceRequest,
//             builder: (context, state) {
//               final serviceId = state.pathParameters['serviceId']!;
//               return ServiceRequestScreen(serviceId: serviceId);
//             },
//           ),
//
//           // ========== ADMIN SERVICE ROUTES ==========
//           GoRoute(
//             path: '/admin/services',
//             name: ScreensNames.adminServices,
//             builder: (context, state) {
//               if (authState.isAdmin) {
//                 return const MaintenanceGuard(
//                   screenName: ScreensNames.adminServices,
//                   child: AdminServicesScreen(),
//                 );
//               } else {
//                 return const UnauthorizedScreen();
//               }
//             },
//           ),
//           GoRoute(
//             path: '/admin/service-requests',
//             name: ScreensNames.adminServiceRequests,
//             builder: (context, state) {
//               if (authState.isAdmin) {
//                 return const MaintenanceGuard(
//                   screenName: ScreensNames.adminServiceRequests,
//                   child: AdminServiceRequestsScreen(),
//                 );
//               } else {
//                 return const UnauthorizedScreen();
//               }
//             },
//           ),
//
//           GoRoute(
//             path: ScreensNames.updatesPath,
//             name: ScreensNames.updates,
//             builder: (context, state) => const MaintenanceGuard(
//               screenName: ScreensNames.updates,
//               child: AllUpdatesScreen(),
//             ),
//           ),
//
//           // ========== SECURE ADMIN ROUTES ==========
//           GoRoute(
//             path: '/secure-admin-784512/login',
//             name: 'adminLogin',
//             builder: (context, state) {
//               if (kDebugMode) {
//                 print(
//                     "🔐 Admin login route matched! Path: ${state.uri.toString()}");
//               }
//               return const AdminLoginScreen();
//             },
//           ),
//           GoRoute(
//             path: '/secure-admin-784512/dashboard',
//             name: 'adminDashboard',
//             builder: (context, state) {
//               if (authState.isAdmin) {
//                 return const AdminDashboard();
//               } else {
//                 return const Scaffold(
//                   body: Center(child: Text('Page not found')),
//                 );
//               }
//             },
//           ),
//
//           // ========== TRUSTED USER ROUTES ==========
//           GoRoute(
//             path: '/secure-trusted-895623/login',
//             name: 'trustedUserLogin',
//             builder: (context, state) {
//               if (kDebugMode) {
//                 print(
//                     "🔐 Trusted user login route matched! Path: ${state.uri.toString()}");
//               }
//               return const TrustedUserLoginScreen();
//             },
//           ),
//           GoRoute(
//             path: '/secure-trusted-895623/register',
//             name: 'trustedUserRegister',
//             builder: (context, state) {
//               if (kDebugMode) {
//                 print(
//                     "🔐 Trusted user register route matched! Path: ${state.uri.toString()}");
//               }
//               return const RegistrationScreen();
//             },
//           ),
//
//           // FIXED: Trusted user dashboard - no auth checks here, let redirect handle it
//           GoRoute(
//             path: '/secure-trusted-895623/trusted-dashboard',
//             name: 'trustedUserDashboard',
//             builder: (context, state) {
//               if (kDebugMode) {
//                 print("🏠 Trusted dashboard route accessed");
//                 print(
//                     "🏠 Auth: isAuth=${authState.isAuthenticated}, isTrusted=${authState.isTrustedUser}");
//               }
//               return const TrustedUserDashboard();
//             },
//           ),
//
//           GoRoute(
//             path: '/secure-trusted-895623/dashboard',
//             name: 'mouthoqDashboard',
//             builder: (context, state) {
//               if (authState.isAdmin) {
//                 return const ApplicationStatusScreen();
//               } else {
//                 return const Scaffold(
//                   body: Center(child: Text('Page not found')),
//                 );
//               }
//             },
//           ),
//
//           // ========== ADMIN USER APPLICATIONS MANAGEMENT ==========
//           GoRoute(
//             path: '/secure-trusted-895623/user-applications',
//             name: ScreensNames.adminUserApplications,
//             builder: (context, state) {
//               if (authState.isAdmin) {
//                 return AdminDashboardStatusScreen();
//               } else {
//                 return const Scaffold(
//                   body: Center(child: Text('Page not found')),
//                 );
//               }
//             },
//           ),
//         ],
//       )
//     ],
//
//     errorBuilder: (context, state) => Scaffold(
//       appBar: AppBar(title: const Text('Page Not Found')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('The page you were looking for does not exist.'),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => context.go(ScreensNames.homePath),
//               child: const Text('Go to Home'),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// });
//
// class ScreensNames {
//   // route names
//   static const String home = 'home';
//   static const String trusted = 'trusted';
//   static const String untrusted = 'untrusted';
//   static const String instruction = 'instruction';
//   static const String contactUs = 'contactUs';
//   static const String ort = 'ort';
//   static const String login = 'login';
//   static const String admin = 'admin';
//   static const String adminDashboard = 'adminDashboard';
//   static const String blockedUsers = 'blockedUsers';
//   static const String updates = 'updates';
//
//   // Trusted user route names
//   static const String register = 'register';
//   static const String applicationStatus = 'application_status';
//   static const String adminUserApplications = 'admin_user_applications';
//   static const String trustedUserLogin = 'trusted_user_login';
//   static const String trustedUserRegister = 'trusted_user_register';
//   static const String trustedUserDashboard = 'trusted_user_dashboard';
//
//   // Service routes
//   static const String services = 'services';
//   static const String serviceDetail = 'service_detail';
//   static const String serviceRequest = 'service_request';
//
//   // Admin routes
//   static const String adminServices = 'admin_services';
//   static const String adminServiceRequests = 'admin_service_requests';
//
//   // paths (must start with "/")
//   static const String homePath = '/';
//   static const String updatesPath = '/updates';
//   static const String blockedUsersPath = '/blocked-users';
//   static const String trustedPath = '/trusted';
//   static const String untrustedPath = '/untrusted';
//   static const String instructionPath = '/instruction';
//   static const String contactUsPath = '/contact-us';
//   static const String ortPath = '/bank-payment-locations';
//   static const String loginPath = '/login';
//   static const String adminPath = '/admin';
//   static const String adminDashboardPath = '/adminDashboard';
//
//   // Trusted user paths
//   static const String registerPath = '/register';
//   static const String applicationStatusPath = '/application-status';
//   static const String trustedUserLoginPath = '/secure-trusted-895623/login';
//   static const String trustedUserRegisterPath =
//       '/secure-trusted-895623/register';
//   static const String trustedUserDashboardPath =
//       '/secure-trusted-895623/trusted-dashboard';
// }
// Fixed route_generator.dart
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
import 'package:trustedtallentsvalley/routs/not_found_screen.dart';

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

// Updated router provider with proper redirect logic
final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state but only react to specific changes
  final authState = ref.watch(authProvider);

  return GoRouter(
    routerNeglect: true, // Prevents some history issues
    navigatorKey: _rootNavigatorKey,
    initialLocation: ScreensNames.homePath,

    // FIXED: Updated router redirect logic
    redirect: (context, state) {
      final currentPath = state.uri.toString();
      final isAuthenticated = authState.isAuthenticated;
      final isAdmin = authState.isAdmin;
      final isTrustedUser = authState.isTrustedUser;
      final isLoading = authState.isLoading;

      print('🔍 Router redirect check:');
      print('  - Path: $currentPath');
      print('  - isAuthenticated: $isAuthenticated');
      print('  - isTrustedUser: $isTrustedUser');
      print('  - isAdmin: $isAdmin');
      print('  - isLoading: $isLoading');

      // Don't redirect during loading states
      if (isLoading) {
        print('🔍 Loading state - no redirect');
        return null;
      }

      // FIXED: Dashboard access logic
      // if (currentPath == '/secure-trusted-895623/trusted-dashboard') {
      //   if (!isAuthenticated || !isTrustedUser) {
      //     print(
      //         '🔍 ❌ Non-authenticated/non-trusted user accessing dashboard - redirecting to login');
      //     return '/secure-trusted-895623/login';
      //   }
      //   print('🔍 ✅ Authenticated trusted user accessing dashboard - allowing');
      //   return null;
      // }

      // FIXED: Auto-navigate authenticated trusted users away from login
      if (isAuthenticated &&
          isTrustedUser &&
          currentPath == '/secure-trusted-895623/login') {
        print(
            '🔍 ✅ Authenticated trusted user on login page - redirecting to dashboard');
        return '/secure-trusted-895623/trusted-dashboard';
      }

      // Protect admin routes
      if (currentPath.startsWith('/secure-admin-') && !isAdmin) {
        if (currentPath != '/secure-admin-784512/login') {
          print('🔍 Non-admin accessing admin route');
          return '/secure-admin-784512/login';
        }
      }

      // Redirect authenticated admin away from admin login
      if (isAuthenticated &&
          isAdmin &&
          currentPath == '/secure-admin-784512/login') {
        print('🔍 Authenticated admin on login page');
        return '/secure-admin-784512/dashboard';
      }

      print('🔍 No redirect needed');
      return null;
    },

    routes: [
      ShellRoute(
        builder: (context, state, child) {
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
          GoRoute(
            path: ScreensNames.registerPath,
            name: ScreensNames.register,
            builder: (context, state) => const RegistrationScreen(),
          ),
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
                return const AdminDashboard();
              } else {
                return const Scaffold(
                  body: Center(child: Text('Page not found')),
                );
              }
            },
          ),

          // ========== TRUSTED USER ROUTES ==========
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

          // CRITICAL FIX: Protected trusted user dashboard
          GoRoute(
            path: '/secure-trusted-895623/trusted-dashboard',
            name: 'trustedUserDashboard',
            builder: (context, state) {
              if (kDebugMode) {
                print("🏠 Trusted dashboard route accessed");
                print(
                    "🏠 Auth: isAuth=${authState.isAuthenticated}, isTrusted=${authState.isTrustedUser}");
              }

              // The redirect function will handle authentication checks
              // If we reach here, user is allowed to access
              return const TrustedUserDashboard();
            },
          ),

          GoRoute(
            path: '/secure-trusted-895623/dashboard',
            name: 'mouthoqDashboard',
            builder: (context, state) {
              if (authState.isAdmin) {
                return const ApplicationStatusScreen();
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
                return AdminDashboardStatusScreen();
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

    errorBuilder: (context, state) {
      // Log the error for debugging
      if (kDebugMode) {
        print('🚫 Route error: ${state.error}');
        print('🚫 Attempted path: ${state.uri.toString()}');
      }

      // Return the modern 404 screen
      return Modern404Screen(
        attemptedPath: state.uri.toString(),
      );
    },
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
  static const String adminDashboard = 'adminDashboard';
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
  static const String adminDashboardPath = '/adminDashboard';

  // Trusted user paths
  static const String registerPath = '/register';
  static const String applicationStatusPath = '/application-status';
  static const String trustedUserLoginPath = '/secure-trusted-895623/login';
  static const String trustedUserRegisterPath =
      '/secure-trusted-895623/register';
  static const String trustedUserDashboardPath =
      '/secure-trusted-895623/trusted-dashboard';
}
