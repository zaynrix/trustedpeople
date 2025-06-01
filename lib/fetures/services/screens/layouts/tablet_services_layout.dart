// lib/features/services/screens/layouts/tablet_services_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';
import 'package:trustedtallentsvalley/fetures/services/widgets/service_card.dart';

import '../../widgets/services_category_filter.dart';
import '../../widgets/services_hero_section.dart';
import 'base_services_layout.dart';

class TabletServicesLayout extends BaseServicesLayout {
  const TabletServicesLayout({super.key});

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
  List<Widget> buildSlivers(BuildContext context, WidgetRef ref,
      ServicesState servicesState, List<ServiceModel> filteredServices) {
    final categories = ref.watch(serviceCategoriesProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine cross axis count based on screen width
    int crossAxisCount;
    if (screenWidth > 900) {
      crossAxisCount = 3;
    } else if (screenWidth > 700) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 2;
    }

    return [
      // Hero section
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: ServicesHeroSection(isMobile: false),
        ),
      ),

      // Search and filter section
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
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
                error: (error, _) =>
                    const Center(child: Text('حدث خطأ أثناء تحميل التصنيفات')),
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
        // Services staggered grid - cards size based on content
        SliverPadding(
          padding: const EdgeInsets.all(20.0),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childCount: filteredServices.length,
            itemBuilder: (context, index) {
              final service = filteredServices[index];
              return ServiceCard(
                service: service,
                onTap: () => navigateToServiceDetail(context, ref, service),
              );
            },
          ),
        ),

      // Bottom padding
      const SliverToBoxAdapter(
        child: SizedBox(height: 100),
      ),
    ];
  }
}
