import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/app/core/widgets/custom_filter_chip.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/domain/repositories/admin_payment_places_repository.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/presentation/providers/admin_payment_places_provider.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/presentation/providers/payment_places_provider.dart';

class AdminFilterOptions extends ConsumerWidget {
  const AdminFilterOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterMode = ref.watch(adminFilterModeProvider);
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);
    final categories = ref.watch(adminCategoriesProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'الكل',
            icon: Icons.all_inclusive,
            selected: filterMode == AdminPlacesFilterMode.all,
            onSelected: (selected) {
              if (selected) {
                placesNotifier.setFilterMode(AdminPlacesFilterMode.all);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'متحقق منها',
            icon: Icons.verified_rounded,
            selected: filterMode == AdminPlacesFilterMode.verified,
            onSelected: (selected) {
              if (selected) {
                placesNotifier.setFilterMode(AdminPlacesFilterMode.verified);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'قيد التحقق',
            icon: Icons.pending_rounded,
            selected: filterMode == AdminPlacesFilterMode.unverified,
            onSelected: (selected) {
              if (selected) {
                placesNotifier.setFilterMode(AdminPlacesFilterMode.unverified);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'التقييم العالي',
            icon: Icons.star_rounded,
            selected: filterMode == AdminPlacesFilterMode.highRated,
            onSelected: (selected) {
              if (selected) {
                placesNotifier.setFilterMode(AdminPlacesFilterMode.highRated);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'حسب التصنيف',
            icon: Icons.category_rounded,
            selected: filterMode == AdminPlacesFilterMode.category,
            onSelected: (selected) {
              if (selected) {
                _showCategoryFilterDialog(context, ref);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'حسب الموقع',
            icon: Icons.location_on_rounded,
            selected: filterMode == AdminPlacesFilterMode.byLocation,
            onSelected: (selected) {
              if (selected) {
                _showLocationFilterDialog(context, ref);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCategoryFilterDialog(BuildContext context, WidgetRef ref) {
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);
    final categories = ref.watch(adminCategoriesProvider);

    if (categories.isLoading) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      return;
    }

    if (categories.hasError) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('خطأ',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text('فشل تحميل التصنيفات: ${categories.error}',
              style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تصفية حسب التصنيف',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر التصنيف للتصفية', style: GoogleFonts.cairo()),
            const SizedBox(height: 16),
            if (categories.value!.isEmpty)
              Text(
                'لا توجد تصنيفات متاحة',
                style: GoogleFonts.cairo(),
                textAlign: TextAlign.center,
              )
            else
              SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.value!.length,
                  itemBuilder: (context, index) {
                    final category = categories.value![index];
                    return ListTile(
                      title: Text(category, style: GoogleFonts.cairo()),
                      leading: const Icon(Icons.category_outlined),
                      onTap: () {
                        placesNotifier.setCategoryFilter(category);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              placesNotifier.setFilterMode(PlacesFilterMode.all);
              Navigator.pop(context);
            },
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showLocationFilterDialog(BuildContext context, WidgetRef ref) {
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);
    final locations = ref.watch(adminLocationsProvider);

    if (locations.isLoading) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      return;
    }

    if (locations.hasError) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('خطأ',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text('فشل تحميل المواقع: ${locations.error}',
              style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تصفية حسب الموقع',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر الموقع للتصفية', style: GoogleFonts.cairo()),
            const SizedBox(height: 16),
            if (locations.value!.isEmpty)
              Text(
                'لا توجد مواقع متاحة',
                style: GoogleFonts.cairo(),
                textAlign: TextAlign.center,
              )
            else
              SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: locations.value!.length,
                  itemBuilder: (context, index) {
                    final location = locations.value![index];
                    return ListTile(
                      title: Text(location, style: GoogleFonts.cairo()),
                      leading: const Icon(Icons.location_on_outlined),
                      onTap: () {
                        placesNotifier.setLocationFilter(location);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              placesNotifier.setFilterMode(PlacesFilterMode.all);
              Navigator.pop(context);
            },
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
