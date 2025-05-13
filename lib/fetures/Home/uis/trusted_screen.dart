import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/sideBarWidget.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/usersTable.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/usersTableVerticalLayout.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';
import 'package:trustedtallentsvalley/routs/screens_name.dart';

// Provider for trusted users stream
final trustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('userstransed')
      .where("isTrusted", isEqualTo: true)
      .snapshots();
});

class TrustedUsersScreen extends ConsumerWidget {
  const TrustedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersStream = ref.watch(trustedUsersStreamProvider);

    return UsersListScreen(
      title: "قائمة الموثوقين",
      usersStream: usersStream,
      // primaryColor: Colors.green.shade600,
      // backgroundColor: Colors.grey.shade50,
    );
  }
}

class AppDrawer extends ConsumerWidget {
  final bool isPermanent;

  const AppDrawer({Key? key, this.isPermanent = false}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return isPermanent
        ? _buildPermanentDrawer(context)
        : Drawer(child: _buildDrawerContent(context));
  }

  Widget _buildDrawerContent(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (!isPermanent)
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black12,
            ),
            child: Center(
              child: Text(
                'ترست فالي',
                style: GoogleFonts.cairo(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (isPermanent)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Text(
              'ترست فالي',
              style: GoogleFonts.cairo(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // Add Home navigation item
        _buildNavigationItem(
          context,
          icon: Icons.home,
          label: "الصفحة الرئيسية",
          route: ScreensNames.home,
          isPermanent: isPermanent,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.verified_user,
          label: "قائمة الموثوقين",
          route: ScreensNames.trusted,
          isPermanent: isPermanent,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.block,
          label: "قائمة النصابين",
          route: ScreensNames.untrusted,
          isPermanent: isPermanent,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.payment_outlined,
          label: 'أماكن تقبل الدفع البنكي',
          route: ScreensNames.ort,
          isPermanent: isPermanent,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.description,
          label: 'كيف تحمي نفسك؟',
          route: ScreensNames.instruction,
          isPermanent: isPermanent,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.contact_mail,
          label: 'تواصل للاستفسارات',
          route: ScreensNames.contactUs,
          isPermanent: isPermanent,
        ),
      ],
    );
  }

  Widget _buildPermanentDrawer(BuildContext context) {
    return Container(
      width: 250,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: _buildDrawerContent(context),
    );
  }

  Widget _buildNavigationItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String route,
        required bool isPermanent,
      }) {
    final bool isActive = GoRouterState.of(context).uri.toString() == route;

    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.green : null),
      title: Text(
        label,
        style: GoogleFonts.cairo(
          textStyle: TextStyle(
            color: isActive ? Colors.green : null,
            fontWeight: isActive ? FontWeight.bold : null,
          ),
        ),
      ),
      tileColor: isActive ? Colors.grey.shade300 : null,
      onTap: () {
        if (!isPermanent) Navigator.pop(context);
        // Use GoRouter for navigation
        context.goNamed(route);
      },
    );
  }
}

// class UsersListScreen extends ConsumerWidget {
//   final String title;
//   final AsyncValue<QuerySnapshot> usersStream;
//   final Color appBarColor;
//
//   const UsersListScreen({
//     Key? key,
//     required this.title,
//     required this.usersStream,
//     this.appBarColor = Colors.green,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isMobile = MediaQuery.of(context).size.width <= 768;
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: isMobile,
//         backgroundColor: appBarColor,
//         title: Text(
//           title,
//           style: GoogleFonts.cairo(
//             textStyle: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//       drawer: isMobile ? const AppDrawer() : null,
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (constraints.maxWidth > 768)
//                 const AppDrawer(isPermanent: true),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: _buildMainContent(context, ref, constraints),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildMainContent(
//       BuildContext context, WidgetRef ref, BoxConstraints constraints) {
//     final searchQuery = ref.watch(searchQueryProvider);
//
//     return usersStream.when(
//       data: (snapshot) {
//         final users = snapshot.docs.where((user) {
//           final aliasName = user['aliasName'] ?? '';
//           final mobileNumber = user['mobileNumber'] ?? '';
//           final query = searchQuery.toLowerCase();
//           return aliasName.toLowerCase().contains(query) ||
//               mobileNumber.contains(query);
//         }).toList();
//
//         final showSideBar = ref.watch(showSideBarProvider);
//
//         if (constraints.maxWidth > 540) {
//           return SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(minWidth: constraints.maxWidth),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: TextField(
//                       decoration: InputDecoration(
//                         labelText: 'بحث...',
//                         hintText: 'ابحث بالاسم أو رقم الجوال',
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                       ),
//                       onChanged: (value) {
//                         ref.read(searchQueryProvider.notifier).state = value;
//                       },
//                     ),
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(child: UsersTable(users: users)),
//                       if (showSideBar) const SizedBox(width: 20),
//                     ],
//                   ),
//                   if (showSideBar)
//                     const Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: UserDetailSidebar(),
//                     ),
//                 ],
//               ),
//             ),
//           );
//         } else {
//           return VerticalLayout(users: users, constraints: constraints);
//         }
//       },
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (e, _) => Center(child: Text('حدث خطأ: $e')),
//     );
//   }
// }