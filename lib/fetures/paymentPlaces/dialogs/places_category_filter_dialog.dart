import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/providers/payment_places_provider.dart';

void showCategoryFilterDialog(BuildContext context, WidgetRef ref) {
  final placesNotifier = ref.read(paymentPlacesProvider.notifier);
  final categories = ref.watch(placesCategoriesProvider);

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
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'اختر التصنيف للتصفية',
            style: GoogleFonts.cairo(),
          ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
