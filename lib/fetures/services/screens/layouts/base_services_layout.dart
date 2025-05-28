// lib/features/services/screens/layouts/base_services_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

import '../../widgets/services_empty_state.dart';

// Base layout that contains shared functionality for all layouts
abstract class BaseServicesLayout extends ConsumerWidget {
  const BaseServicesLayout({Key? key}) : super(key: key);

  // Shared build method to be implemented by each layout
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(servicesProvider);
    final filteredServices = ref.watch(filteredServicesProvider);

    // Debug prints
    debugPrint(
        "Building ServicesLayout with ${filteredServices.length} filtered services");
    debugPrint(
        "Filter category: ${ref.watch(servicesProvider).categoryFilter}");
    debugPrint(
        "isActive services: ${filteredServices.where((s) => s.isActive).length}");

    return Scaffold(
      appBar: buildAppBar(context, ref),
      drawer: shouldShowDrawer() ? const AppDrawer() : null,
      body: servicesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: buildSlivers(context, ref, servicesState, filteredServices),
      ),
    );
  }

  // Methods to be implemented or overridden by each layout
  PreferredSizeWidget buildAppBar(BuildContext context, WidgetRef ref);
  bool shouldShowDrawer();
  List<Widget> buildSlivers(
      BuildContext context,
      WidgetRef ref,
      ServicesState servicesState,
      List<ServiceModel> filteredServices
      );

  // Shared methods used by all layouts
  Widget buildEmptyState() {
    return const ServicesEmptyState();
  }

  void navigateToServiceDetail(BuildContext context, WidgetRef ref, ServiceModel service) {
    ref.read(servicesProvider.notifier).selectService(service);
    context.goNamed(
      ScreensNames.serviceDetail,
      pathParameters: {'serviceId': service.id},
    );
  }

  // Helper method for error display
  Widget buildErrorMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.red),
        ),
      ),
    );
  }
}