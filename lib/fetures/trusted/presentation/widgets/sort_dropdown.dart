// presentation/widgets/sort_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';

class SortButton extends StatelessWidget {
  final Color primaryColor;

  const SortButton({
    super.key,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final sortField = ref.watch(sortFieldProvider);
        final sortAscending = ref.watch(sortDirectionProvider);
        final homeNotifier = ref.read(homeProvider.notifier);

        // Helper function to get the display name of the sort field
        String getSortFieldName() {
          switch (sortField) {
            case 'aliasName':
              return 'الاسم';
            case 'mobileNumber':
              return 'رقم الجوال';
            case 'location':
              return 'الموقع';
            case 'reviews':
              return 'التقييمات';
            default:
              return 'الاسم';
          }
        }

        return PopupMenuButton<String>(
          tooltip: 'ترتيب',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.sort_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  'ترتيب حسب: ${getSortFieldName()}',
                  style: GoogleFonts.cairo(),
                ),
                const SizedBox(width: 8),
                Icon(
                  sortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 18,
                ),
              ],
            ),
          ),
          itemBuilder: (context) => [
            _buildSortMenuItem(
                sortField,
                sortAscending,
                'aliasName',
                'الاسم',
                Icons.person
            ),
            _buildSortMenuItem(
                sortField,
                sortAscending,
                'mobileNumber',
                'رقم الجوال',
                Icons.phone
            ),
            _buildSortMenuItem(
                sortField,
                sortAscending,
                'location',
                'الموقع',
                Icons.location_on
            ),
            _buildSortMenuItem(
                sortField,
                sortAscending,
                'reviews',
                'التقييمات',
                Icons.star
            ),
          ],
          onSelected: (value) {
            if (sortField == value) {
              // Toggle direction if same field
              homeNotifier.setSort(value);
            } else {
              // Set new field and reset to ascending
              homeNotifier.setSort(value, ascending: true);
            }
          },
        );
      },
    );
  }

  // Helper method to build a sort menu item
  PopupMenuItem<String> _buildSortMenuItem(
      String currentSortField,
      bool sortAscending,
      String fieldValue,
      String displayName,
      IconData icon,
      ) {
    return PopupMenuItem(
      value: fieldValue,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: currentSortField == fieldValue ? primaryColor : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(displayName, style: GoogleFonts.cairo()),
          const Spacer(),
          if (currentSortField == fieldValue)
            Icon(
              sortAscending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 14,
              color: primaryColor,
            ),
        ],
      ),
    );
  }
}