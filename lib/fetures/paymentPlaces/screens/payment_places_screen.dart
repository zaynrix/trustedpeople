import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/trusted_help_dialog.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/dialogs/payment_places_dialogs.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/providers/payment_places_provider.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/screens/payment_places_desktop_view.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/screens/payment_places_tablet_view.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/screens/places_mobile_screen.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

class PaymentPlacesScreen extends ConsumerWidget {
  const PaymentPlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 768,
        title: Text(
          "أماكن تقبل الدفع البنكي",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        actions: [
          if (MediaQuery.of(context).size.width >= 768)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () =>
                  PaymentPlacesDialogs.showExportDialog(context, ref),
              tooltip: 'تصدير البيانات',
            ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => showHelpDialog(context),
            tooltip: 'المساعدة',
          ),
          const SizedBox(width: 8),
        ],
        shape: MediaQuery.of(context).size.width < 768
            ? null
            : const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
      ),
      drawer:
          MediaQuery.of(context).size.width < 768 ? const AppDrawer() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Handle error messages
          final errorMessage = ref.watch(placesErrorMessageProvider);
          if (errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage, style: GoogleFonts.cairo()),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }

          // Determine which view to show based on screen size
          if (constraints.maxWidth < 768) {
            // Mobile view
            return const PaymentPlacesMobileView();
          } else if (constraints.maxWidth < 1200) {
            // Tablet view
            return const PaymentPlacesTabletView();
          } else {
            // Desktop view
            return const PaymentPlacesDesktopView();
          }
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.blue.shade600,
              onPressed: () =>
                  PaymentPlacesDialogs.showAddPlaceDialog(context, ref),
              tooltip: 'إضافة متجر جديد',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
