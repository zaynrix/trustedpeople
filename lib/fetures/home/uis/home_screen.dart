import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/home/dialogs/quick_actions_dialog.dart';
import 'package:trustedtallentsvalley/fetures/home/screens/admin_dashboard_screen.dart';
import 'package:trustedtallentsvalley/fetures/home/screens/user_home_content_screen.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        backgroundColor: isAdmin ? Colors.green.shade700 : Colors.teal,
        title: Text(
          isAdmin ? 'موثوق - لوحة التحكم' : 'موثوق - الصفحة الرئيسية',
          style: GoogleFonts.cairo(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'إعدادات النظام',
              onPressed: () {
                // Navigate to admin settings screen
                // You can implement this later
              },
            ),
        ],
      ),
      drawer: isMobile ? const AppDrawer() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isAdmin
                      ? const AdminDashboardWidget()
                      : HomeContentWidget(constraints: constraints),
                ),
              ),
            ],
          );
        },
      ),
      // Show quick action FAB for admins
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                QuickActionsDialog.show(context);
              },
              backgroundColor: Colors.green.shade700,
              icon: const Icon(Icons.add),
              label: Text(
                'إضافة سريعة',
                style: GoogleFonts.cairo(),
              ),
            )
          : null,
    );
  }
}
