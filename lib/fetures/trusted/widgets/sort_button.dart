import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';

class SortButton extends ConsumerWidget {
  final Color primaryColor;

  const SortButton({
    super.key,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortField = ref.watch(sortFieldProvider);
    final sortAscending = ref.watch(sortDirectionProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

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
            Text('ترتيب حسب: ${_getSortFieldName(sortField)}',
                style: GoogleFonts.cairo()),
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
            'aliasName', 'الاسم', Icons.person, sortField, sortAscending),
        _buildSortMenuItem('mobileNumber', 'رقم الجوال', Icons.phone, sortField,
            sortAscending),
        _buildSortMenuItem(
            'location', 'الموقع', Icons.location_on, sortField, sortAscending),
        _buildSortMenuItem(
            'reviews', 'التقييمات', Icons.star, sortField, sortAscending),
        _buildSortMenuItem(
            'role', 'الحالة', Icons.security, sortField, sortAscending),
      ],
      onSelected: (value) {
        if (sortField == value) {
          homeNotifier.setSort(value);
        } else {
          homeNotifier.setSort(value, ascending: true);
        }
      },
    );
  }

  String _getSortFieldName(String sortField) {
    switch (sortField) {
      case 'aliasName':
        return 'الاسم';
      case 'mobileNumber':
        return 'رقم الجوال';
      case 'location':
        return 'الموقع';
      case 'reviews':
        return 'التقييمات';
      case 'role':
        return 'الحالة';
      default:
        return 'الاسم';
    }
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String label,
      IconData icon, String currentSortField, bool sortAscending) {
    final isSelected = currentSortField == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? primaryColor : Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.cairo()),
          const Spacer(),
          if (isSelected)
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