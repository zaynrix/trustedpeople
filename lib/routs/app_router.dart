// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:trustedtallentsvalley/fetures/Home/uis/blackList_screen.dart';
// import 'package:trustedtallentsvalley/fetures/Home/uis/contactUs_screen.dart';
// import 'package:trustedtallentsvalley/fetures/Home/uis/trusted_screen.dart';
// import 'package:trustedtallentsvalley/fetures/Home/uis/trade_screen.dart';
// import 'package:trustedtallentsvalley/routs/screens_name.dart';
//
// class AppRouter {
//   late final GoRouter goRouter;
//
//   AppRouter() {
//     goRouter = GoRouter(
//       initialLocation: '/trusted',
//       routes: [
//         GoRoute(
//           name: ScreensNames.trusted,
//           path: '/trusted',
//           builder: (context, state) => const HomeScreen(),
//         ),
//         GoRoute(
//           name: ScreensNames.untrusted,
//           path: '/untrusted',
//           builder: (context, state) => const BlackListUsersScreen(),
//         ),
//         GoRoute(
//           name: ScreensNames.instruction,
//           path: '/instruction',
//           builder: (context, state) => const TransactionsGuideScreen(),
//         ),
//         GoRoute(
//           name: ScreensNames.contactUs,
//           path: '/contactuns', // ✅ يجب أن يبدأ بـ /
//           builder: (context, state) => ContactUsScreen(),
//         ),
//       ],
//       errorBuilder: (context, state) {
//         return const Scaffold(
//           body: Center(
//             child: Text(
//               'Page not found',
//               style: TextStyle(fontSize: 24),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Navigation helper methods
//
//   void goTo(String path, {Object? extra}) {
//     goRouter.go(path, extra: extra);
//   }
//
//   void goToNamed(String name, {Object? extra}) {
//     goRouter.goNamed(name, extra: extra);
//   }
//
//   void pushTo(String path, {Object? extra}) {
//     goRouter.push(path, extra: extra);
//   }
//
//   void pushToNamed(String name, {Object? extra}) {
//     goRouter.pushNamed(name, extra: extra);
//   }
//
//   void removeAllAndGo(String name, {Object? extra}) {
//     goRouter.goNamed(name, extra: extra);
//   }
//
//   void back<T extends Object?>([T? result]) {
//     goRouter.pop(result);
//   }
//
//   void maybeBack<T extends Object?>([T? result]) {
//     if (goRouter.canPop()) {
//       goRouter.pop(result);
//     }
//   }
// }
