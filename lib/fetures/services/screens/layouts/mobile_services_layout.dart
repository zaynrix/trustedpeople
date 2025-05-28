// lib/features/services/screens/mobile_services_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/core/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';
import 'package:trustedtallentsvalley/fetures/services/widgets/service_tile.dart';
import 'package:trustedtallentsvalley/fetures/services/widgets/services_category_filter.dart';
import 'package:trustedtallentsvalley/fetures/services/widgets/services_empty_state.dart';
import 'package:trustedtallentsvalley/fetures/services/widgets/services_hero_section.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class MobileServicesScreen extends ConsumerWidget {
  const MobileServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(servicesProvider);
    final filteredServices = ref.watch(filteredServicesProvider);
    final categories = ref.watch(serviceCategoriesProvider);

    // Debug prints
    debugPrint(
        "Building MobileServicesScreen with ${filteredServices.length} filtered services");
    debugPrint(
        "Filter category: ${ref.watch(servicesProvider).categoryFilter}");
    debugPrint(
        "isActive services: ${filteredServices.where((s) => s.isActive).length}");

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          "اطلب خدمتك",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade600,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: servicesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Hero section
          const ServicesHeroSection(isMobile: true),
          const SizedBox(height: 16),

          // Search bar
          SearchField(
            onChanged: (value) {
              ref.read(servicesProvider.notifier).setSearchQuery(value);
            },
            hintText: 'البحث في الخدمات المتوفرة...',
          ),
          const SizedBox(height: 16),

          // Category filter
          categories.when(
            data: (categoryStrings) {
              final serviceCategories = categoryStrings
                  .map(ServiceCategoryExtension.fromString)
                  .toList();
              return ServicesCategoryFilter(
                categories: serviceCategories,
                isMobile: true,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => const Center(
                child: Text('حدث خطأ أثناء تحميل التصنيفات')),
          ),
          const SizedBox(height: 24),

          // Error or empty state
          if (servicesState.errorMessage != null)
            Center(
              child: Text(
                servicesState.errorMessage!,
                style: GoogleFonts.cairo(color: Colors.red),
              ),
            )
          else if (filteredServices.isEmpty)
            const ServicesEmptyState()
          else
          // List of services using ListView.builder
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ServiceTile(
                    service: service,
                    onTap: () => _navigateToServiceDetail(context, ref, service),
                  ),
                );
              },
            ),

          // Bottom padding
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Navigate to service detail
  void _navigateToServiceDetail(BuildContext context, WidgetRef ref, ServiceModel service) {
    ref.read(servicesProvider.notifier).selectService(service);
    context.goNamed(
      ScreensNames.serviceDetail,
      pathParameters: {'serviceId': service.id},
    );
  }

  // Build error message
  Widget _buildErrorMessage(String message) {
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