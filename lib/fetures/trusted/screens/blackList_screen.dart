import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/trusted/dialogs/user_dialogs.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/usersTable.dart';

// Provider for untrusted users stream (role = 3, which is fraud/scammers)
final untrustedUsersStreamProvider = StreamProvider<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance
      .collection('userstransed')
      .where("role", isEqualTo: 3) // 3 = نصاب (Fraud)
      .snapshots();
});

class BlackListUsersScreen extends ConsumerWidget {
  const BlackListUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersStream = ref.watch(untrustedUsersStreamProvider);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final isAdmin = ref.watch(isAdminProvider);


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        title: Text(
          "قائمة النصابين",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        elevation: 0,
        actions: [
          if (!isMobile && isAdmin)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () => ExportDialog.show(context, ref, Colors.red),
              tooltip: 'تصدير البيانات',
            ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => HelpDialog.show(context),
            tooltip: 'المساعدة',
          ),
          const SizedBox(width: 8),
        ],
        shape: isMobile
            ? null
            : const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      drawer: isMobile ? const AppDrawer() : null,
      body: UsersListScreen(
        isTrusted: false,
        title: "قائمة النصابين",
        usersStream: usersStream,
        // appBarColor: Colors.red,
      ),
    );
  }
}
