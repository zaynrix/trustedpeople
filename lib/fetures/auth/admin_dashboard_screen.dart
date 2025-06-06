// // تحديث ملف lib/fetures/auth/admin_dashboard_screen.dart
// import 'dart:html' as html; // Use this instead
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
// import 'package:trustedtallentsvalley/routs/route_generator.dart';
//
// import '../../fetures/services/providers/service_requests_provider.dart';
//
// class AdminDashboardScreen extends ConsumerStatefulWidget {
//   const AdminDashboardScreen({Key? key}) : super(key: key);
//
//   @override
//   ConsumerState<AdminDashboardScreen> createState() =>
//       _AdminDashboardScreenState();
// }
//
// class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Hide admin pages from browser history
//     // OPTION 1: Fixed JavaScript interop (safer approach)
//     if (kIsWeb) {
//       try {
//         // Use proper dart:html instead of js.context.callMethod
//         html.window.history.replaceState(null, '', '/');
//         if (kDebugMode) {
//           print('✅ Browser history updated successfully');
//         }
//       } catch (e) {
//         if (kDebugMode) {
//           print('⚠️ Could not update browser history: $e');
//           // This is not critical, just continue without it
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);
//
//     // مراقبة عدد طلبات الخدمات الجديدة للإشعارات
//     final pendingRequestsCount = ref.watch(newRequestsCountProvider);
//
//     // Redirect non-admin users
//     if (!authState.isAdmin) {
//       return const Scaffold(
//         body: Center(child: Text('غير مصرح بالوصول')),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           'لوحة تحكم المشرف',
//           style: GoogleFonts.cairo(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.grey.shade800,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               ref.read(authProvider.notifier).signOut();
//               context.go('/'); // Go to home after logout
//             },
//             tooltip: 'تسجيل الخروج',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'مرحباً بك في لوحة التحكم الإدارية',
//               style: GoogleFonts.cairo(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'البريد الإلكتروني: ${authState.user?.email}',
//               style: GoogleFonts.cairo(),
//             ),
//             const SizedBox(height: 32),
//
//             // إضافة قسم إدارة الخدمات وطلبات الخدمات
//             _buildAdminAction(
//               context,
//               title: 'إدارة الخدمات',
//               icon: Icons.miscellaneous_services,
//               onTap: () => context.go('/admin/services'),
//               color: Colors.purple,
//             ),
//             const SizedBox(height: 16),
//             _buildAdminAction(
//               context,
//               title: 'طلبات الخدمات',
//               icon: Icons.support_agent,
//               onTap: () => context.go('/admin/service-requests'),
//               color: Colors.orange,
//               badgeCount: pendingRequestsCount,
//             ),
//             const SizedBox(height: 16),
//             // أقسام لوحة التحكم الأخرى
//             _buildAdminAction(
//               context,
//               title: 'إدارة أماكن الدفع البنكي',
//               icon: Icons.storefront_rounded,
//               onTap: () => context.go(ScreensNames.ortPath),
//               color: Colors.blue,
//             ),
//             const SizedBox(height: 16),
//             _buildAdminAction(
//               context,
//               title: 'إدارة قائمة الموثوقين',
//               icon: Icons.verified_user_rounded,
//               onTap: () => context.go(ScreensNames.trustedPath),
//               color: Colors.green,
//             ),
//             const SizedBox(height: 16),
//             _buildAdminAction(
//               context,
//               title: 'إدارة قائمة النصابين',
//               icon: Icons.block_rounded,
//               onTap: () => context.go(ScreensNames.untrustedPath),
//               color: Colors.red,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAdminAction(
//     BuildContext context, {
//     required String title,
//     required IconData icon,
//     required VoidCallback onTap,
//     required Color color,
//     int badgeCount = 0,
//   }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Stack(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: color.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(
//                       icon,
//                       color: color,
//                       size: 28,
//                     ),
//                   ),
//                   if (badgeCount > 0)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         constraints: const BoxConstraints(
//                           minWidth: 20,
//                           minHeight: 20,
//                         ),
//                         child: Text(
//                           badgeCount.toString(),
//                           style: GoogleFonts.cairo(
//                             fontSize: 12,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(width: 20),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: GoogleFonts.cairo(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       'إضافة، تعديل، وحذف العناصر',
//                       style: GoogleFonts.cairo(
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 color: Colors.grey,
//                 size: 16,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
