// lib/features/services/widgets/services_category_filter.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';

class ServicesCategoryFilter extends ConsumerWidget {
  final List<ServiceCategory> categories;
  final bool isMobile;

  const ServicesCategoryFilter({
    super.key,
    required this.categories,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    return category.displayName ?? categoryName;
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
}
