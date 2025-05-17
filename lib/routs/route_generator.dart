import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Router provider that depends on auth state
// final routerProvider = Provider<GoRouter>((ref) {
//   final authState = ref.watch(authProvider);
//
//   return GoRouter(
//     navigatorKey: _rootNavigatorKey,
//     initialLocation: ScreensNames.homePath,
//     routes: [
//       GoRoute(
//         path: ScreensNames.homePath,
//         name: ScreensNames.home,
//         builder: (context, state) => HomeScreen(),
//       ),
//       GoRoute(
//         path: ScreensNames.trustedPath,
//         name: ScreensNames.trusted,
//         builder: (context, state) => const TrustedUsersScreen(),
//       ),
//       GoRoute(
//         path: ScreensNames.untrustedPath,
//         name: ScreensNames.untrusted,
//         builder: (context, state) => const BlackListUsersScreen(),
//       ),
//       GoRoute(
//         path: ScreensNames.instructionPath,
//         name: ScreensNames.instruction,
//         builder: (context, state) => const ProtectionGuideScreen(),
//       ),
//       GoRoute(
//         path: ScreensNames.ortPath,
//         name: ScreensNames.ort,
//         builder: (context, state) => const PaymentPlacesScreen(),
//       ),
//       GoRoute(
//         path: ScreensNames.contactUsPath,
//         name: ScreensNames.contactUs,
//         builder: (context, state) => ContactUsScreen(),
//       ),
//       // Add these new routes
//       GoRoute(
//         path: ScreensNames.loginPath,
//         name: ScreensNames.login,
//         builder: (context, state) => const LoginPage(),
//       ),
//       GoRoute(
//         path: ScreensNames.blockedUsersPath,
//         name: ScreensNames.blockedUsers,
//         builder: (context, state) {
//           // Only allow admins to access
//           if (authState.isAdmin) {
//             return const BlockedUsersScreen2();
//           } else {
//             return const UnauthorizedScreen();
//           }
//         },
//       ),
//
//       GoRoute(
//         path: ScreensNames.updatesPath,
//         name: ScreensNames.updates,
//         builder: (context, state) => const AllUpdatesScreen(),
//       ),
//       // GoRoute(
//       //   path: ScreensNames.adminPath,
//       //   name: ScreensNames.admin,
//       //   builder: (context, state) {
//       //     // Only allow admins to access admin page
//       //     if (authState.isAdmin) {
//       //       return const AdminDashboardScreen();
//       //     } else {
//       //       return const UnauthorizedScreen();
//       //     }
//       //   },
//       // ),
//       GoRoute(
//         path: ScreensNames.adminDashboardPath,
//         name: ScreensNames.adminDashboard,
//         builder: (context, state) {
//           // Only allow admins to access admin page
//           if (authState.isAdmin) {
//             return const AdminDashboard();
//           } else {
//             return const UnauthorizedScreen();
//           }
//         },
//       ),
//       GoRoute(
//         path: '/secure-admin-784512/login',
//         name: 'adminLogin',
//         builder: (context, state) {
//           if (kDebugMode) {
//             print(
//                 "🔐 Admin login route matched! Path: ${state.uri.toString()}");
//           }
//           return const LoginPage();
//         },
//       ),
//       // GoRoute(
//       //   path: '/secure-admin-784512/dashboard', // Obscure path
//       //   name: 'adminDashboard', // No constant reference in ScreensNames
//       //   builder: (context, state) {
//       //     // Only allow authenticated admins
//       //     if (authState.isAdmin) {
//       //       return const AdminDashboardScreen();
//       //     } else {
//       //       return const Scaffold(
//       //         body: Center(
//       //             child: Text('Page not found')), // Generic error for security
//       //       );
//       //     }
//       //   },
//       // ),
//     ],
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
