// lib/features/services/screens/layouts/desktop_services_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';

import '../../widgets/services_category_filter.dart';
import '../../widgets/services_grid.dart';
import '../../widgets/services_hero_section.dart';
import 'base_services_layout.dart';

class DesktopServicesLayout extends BaseServicesLayout {
  const DesktopServicesLayout({super.key});

  @override
  PreferredSizeWidget buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        "اطلب خدمتك",
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.teal.shade600,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
    );
  }

  @override
  bool shouldShowDrawer() => false;

  @override
  List<Widget> buildSlivers(
      BuildContext context,
      WidgetRef ref,
      ServicesState servicesState,
      List<ServiceModel> filteredServices
      ) {
    final categories = ref.watch(serviceCategoriesProvider);

    return [
      // Hero section
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: ServicesHeroSection(isMobile: false),
        ),
      ),

      // Search and filter section
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 8.0,
          ),
          child: Column(
            children: [
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
                    isMobile: false,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => const Center(
                    child: Text('حدث خطأ أثناء تحميل التصنيفات')),
              ),
            ],
          ),
        ),
      ),

      // Error or empty state
      if (servicesState.errorMessage != null)
        SliverToBoxAdapter(
          child: buildErrorMessage(servicesState.errorMessage!),
        )
      else if (filteredServices.isEmpty)
        SliverToBoxAdapter(
          child: buildEmptyState(),
        )
      else
      // Services grid
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: ServicesGrid(
            services: filteredServices,
            isMobile: false,
            crossAxisCount: 4,
            childAspectRatio: 0.9,
            onServiceTap: (service) => navigateToServiceDetail(context, ref, service),
          ),
        ),

      // Bottom padding
      const SliverToBoxAdapter(
        child: SizedBox(height: 100),
      ),
    ];
  }
}