// // lib/fetures/admin/widgets/request_notification_badge.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// class RequestNotificationBadge extends ConsumerWidget {
//   final Widget child;
//   final Color? badgeColor;
//
//   const RequestNotificationBadge({
//     Key? key,
//     required this.child,
//     this.badgeColor,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final pendingRequestsCount = ref.watch(newRequestsCountProvider);
//
//     if (pendingRequestsCount <= 0) {
//       return child;
//     }
//
//     return Stack(
//       children: [
//         child,
//         Positioned(
//           right: 0,
//           top: 0,
//           child: Container(
//             padding: const EdgeInsets.all(2),
//             decoration: BoxDecoration(
//               color: badgeColor ?? Colors.red,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             constraints: const BoxConstraints(
//               minWidth: 16,
//               minHeight: 16,
//             ),
//             child: Text(
//               pendingRequestsCount.toString(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // Update lib/fetures/admin/screens/admin_dashboard_screen.dart
//
// // Add these imports at the top of the file:
// // import 'package:trustedtallentsvalley/fetures/fetures/services/providers/service_requests_provider.dart';
// // import 'package:trustedtallentsvalley/fetures/admin/widgets/request_notification_badge.dart';
//
// // Then, add the service related actions to the dashboard
// // Inside the build method, locate the admin action sections and add these new actions:
//
// /* Add these new admin actions inside the Column with _buildAdminAction calls:
//
// // Service management actions
// _buildAdminAction(
//   context,
//   title: 'إدارة الخدمات',
//   icon: Icons.miscellaneous_services,
//   onTap: () => context.go('/admin/services'),
//   color: Colors.purple,
// ),
// const SizedBox(height: 16),
// _buildAdminAction(
//   context,
//   title: 'طلبات الخدمات',
//   icon: Icons.support_agent,
//   badge: RequestNotificationBadge(
//     child: Icon(Icons.support_agent),
//     badgeColor: Colors.red,
//   ),
//   onTap: () => context.go('/admin/service-requests'),
//   color: Colors.orange,
// ),
// */
//
// // Then modify the _buildAdminAction method to support notification badges:
//
// /*
// Widget _buildAdminAction(
//   BuildContext context, {
//   required String title,
//   required IconData icon,
//   required VoidCallback onTap,
//   required Color color,
//   Widget? badge,
// }) {
//   return Card(
//     elevation: 2,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: badge ?? Icon(
//                 icon,
//                 color: color,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: GoogleFonts.cairo(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     'إضافة، تعديل، وحذف العناصر',
//                     style: GoogleFonts.cairo(
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: Colors.grey,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
// */
