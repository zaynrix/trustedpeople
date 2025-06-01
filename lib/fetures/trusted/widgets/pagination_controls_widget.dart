import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';

class PaginationControls extends ConsumerWidget {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalItems;
  final Color primaryColor;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalItems,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeNotifier = ref.read(homeProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Page size dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<int>(
              value: pageSize,
              isDense: true,
              underline: const SizedBox(),
              items: [10, 25, 50, 100]
                  .map((size) => DropdownMenuItem<int>(
                value: size,
                child:
                Text('$size لكل صفحة', style: GoogleFonts.cairo()),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) homeNotifier.setPageSize(value);
              },
            ),
          ),
          const Spacer(),
          // Page navigation
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed:
            currentPage > 1 ? () => homeNotifier.setCurrentPage(1) : null,
            tooltip: 'الصفحة الأولى',
            color: primaryColor,
            disabledColor: Colors.grey.shade400,
          ),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: currentPage > 1
                ? () => homeNotifier.setCurrentPage(currentPage - 1)
                : null,
            tooltip: 'الصفحة السابقة',
            color: primaryColor,
            disabledColor: Colors.grey.shade400,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              '$currentPage من $totalPages',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: currentPage < totalPages
                ? () => homeNotifier.setCurrentPage(currentPage + 1)
                : null,
            tooltip: 'الصفحة التالية',
            color: primaryColor,
            disabledColor: Colors.grey.shade400,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages
                ? () => homeNotifier.setCurrentPage(totalPages)
                : null,
            tooltip: 'الصفحة الأخيرة',
            color: primaryColor,
            disabledColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}