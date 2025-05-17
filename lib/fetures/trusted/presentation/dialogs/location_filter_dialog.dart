import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';

void showLocationFilterDialog(BuildContext context, WidgetRef ref) {
  final homeNotifier = ref.read(homeProvider.notifier);
  final locations = ref.watch(locationsProvider);

  // Show loading if locations are loading
  if (locations.isLoading) {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    return;
  }

  // Show error if locations failed to load
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

  // Show locations dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'تصفية حسب الموقع',
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'اختر الموقع للتصفية',
            style: GoogleFonts.cairo(),
          ),
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
                      homeNotifier.setLocationFilter(location);
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
            homeNotifier.setFilterMode(FilterMode.all);
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
