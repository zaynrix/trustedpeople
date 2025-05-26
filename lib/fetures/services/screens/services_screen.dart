// lib/fetures/fetures/services/screens/service_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/core/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

import '../widgets/service_card.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final servicesState = ref.watch(servicesProvider);
    final filteredServices = ref.watch(filteredServicesProvider);
    final categories = ref.watch(serviceCategoriesProvider);

    // Add debug prints
    debugPrint(
        "Building ServicesScreen with ${filteredServices.length} filtered services");
    debugPrint(
        "Filter category: ${ref.watch(servicesProvider).categoryFilter}");
    debugPrint(
        "isActive services: ${filteredServices.where((s) => s.isActive).length}");

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        title: Text(
          "اطلب خدمتك",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade600,
        elevation: 0,
        shape: isMobile
            ? null
            : const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
      ),
      drawer: isMobile ? const AppDrawer() : null,
      body: servicesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Hero section as sliver
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                    child: _buildHeroSection(context, isMobile),
                  ),
                ),

                // Search and filter section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16.0 : 24.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        // Search bar
                        SearchField(
                          onChanged: (value) {
                            ref
                                .read(servicesProvider.notifier)
                                .setSearchQuery(value);
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
                            return _buildCategoryFilter(
                                context, ref, serviceCategories, isMobile);
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
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
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          servicesState.errorMessage!,
                          style: GoogleFonts.cairo(color: Colors.red),
                        ),
                      ),
                    ),
                  )
                else if (filteredServices.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(),
                  )
                else
                  // Services grid as sliver
                  SliverPadding(
                    padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                    sliver: _buildServicesGrid(
                        ref, context, filteredServices, isMobile),
                  ),

                // Bottom padding for better scrolling experience
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 20 : 24,
        horizontal: isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade200.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.design_services,
            color: Colors.white,
            size: isMobile ? 40 : 48,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'خدمات متميزة تلبي احتياجاتك',
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            'تصفح خدماتنا المتنوعة واطلب ما يناسبك، وسنتواصل معك في أقرب وقت!',
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          SizedBox(
            width: isMobile ? double.infinity : null,
            child: ElevatedButton.icon(
              onPressed: () {
                // Scroll down smoothly (no specific target needed as it's already scrollable)
              },
              icon: const Icon(Icons.arrow_downward),
              label: Text(
                'تصفح الخدمات',
                style: GoogleFonts.cairo(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal.shade700,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20,
                  vertical: isMobile ? 10 : 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(
    BuildContext context,
    WidgetRef ref,
    List<ServiceCategory> categories,
    bool isMobile,
  ) {
    final selectedCategory = ref.watch(servicesProvider).categoryFilter;

    return SizedBox(
      width: double.infinity,
      child: PopupMenuButton<ServiceCategory?>(
        tooltip: 'فلترة حسب التصنيف',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 8),
                  Text(
                    selectedCategory != null
                        ? _getCategoryDisplayName(selectedCategory)
                        : 'جميع التصنيفات',
                    style: GoogleFonts.cairo(
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: null,
            child: Row(
              children: [
                Icon(
                  Icons.all_inclusive,
                  color: selectedCategory == null
                      ? Colors.teal
                      : Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'جميع التصنيفات',
                  style: GoogleFonts.cairo(
                    fontWeight:
                        selectedCategory == null ? FontWeight.bold : null,
                    color: selectedCategory == null
                        ? Colors.teal
                        : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          ...categories.map((category) {
            final isSelected = selectedCategory == category.name;
            return PopupMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: isSelected ? Colors.teal : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.displayName,
                    style: GoogleFonts.cairo(
                      fontWeight: isSelected ? FontWeight.bold : null,
                      color: isSelected ? Colors.teal : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
        onSelected: (category) {
          ref.read(servicesProvider.notifier).setCategoryFilter(category?.name);
        },
      ),
    );
  }

  String _getCategoryDisplayName(String categoryName) {
    final category = ServiceCategoryExtension.fromString(categoryName);
    return category?.displayName ?? categoryName;
  }

  IconData _getCategoryIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.webDevelopment:
        return Icons.web;
      case ServiceCategory.mobileDevelopment:
        return Icons.phone_android;
      case ServiceCategory.graphicDesign:
        return Icons.brush;
      case ServiceCategory.marketing:
        return Icons.trending_up;
      case ServiceCategory.writing:
        return Icons.description;
      case ServiceCategory.translation:
        return Icons.translate;
      case ServiceCategory.other:
        return Icons.category;
    }
  }

  Widget _buildServicesGrid(
    WidgetRef ref,
    BuildContext context,
    List<ServiceModel> services,
    bool isMobile,
  ) {
    int crossAxisCount;
    double childAspectRatio;

    if (MediaQuery.of(context).size.width > 1200) {
      crossAxisCount = 4;
      childAspectRatio = 0.8;
    } else if (MediaQuery.of(context).size.width > 900) {
      crossAxisCount = 3;
      childAspectRatio = 0.8;
    } else if (MediaQuery.of(context).size.width > 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.85;
    } else {
      // Mobile: single column for better readability
      crossAxisCount = 1;
      childAspectRatio = 1.2; // Wider cards for mobile
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 12 : 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final service = services[index];
          return ServiceCard(
            service: service,
            onTap: () {
              ref.read(servicesProvider.notifier).selectService(service);
              context.goNamed(
                ScreensNames.serviceDetail,
                pathParameters: {'serviceId': service.id},
              );
            },
          );
        },
        childCount: services.length,
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'لم يتم العثور على خدمات',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'حاول تغيير معايير البحث أو التصفية',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
