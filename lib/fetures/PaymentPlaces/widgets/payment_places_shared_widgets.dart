import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/providers/payment_places_provider.dart';

class PaymentPlacesSharedWidgets {
  // Sort button with dropdown menu
  static Widget buildSortButton(BuildContext context, WidgetRef ref) {
    final sortField = ref.watch(placesSortFieldProvider);
    final sortAscending = ref.watch(placesSortDirectionProvider);
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);

    String getSortFieldName() {
      switch (sortField) {
        case 'name':
          return 'الاسم';
        case 'category':
          return 'التصنيف';
        case 'location':
          return 'الموقع';
        case 'phoneNumber':
          return 'رقم الهاتف';
        case 'rating':
          return 'التقييم';
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
          context,
          ref,
          field: 'name',
          label: 'الاسم',
          icon: Icons.storefront_rounded,
        ),
        _buildSortMenuItem(
          context,
          ref,
          field: 'category',
          label: 'التصنيف',
          icon: Icons.category_rounded,
        ),
        _buildSortMenuItem(
          context,
          ref,
          field: 'location',
          label: 'الموقع',
          icon: Icons.location_on_rounded,
        ),
        _buildSortMenuItem(
          context,
          ref,
          field: 'phoneNumber',
          label: 'رقم الهاتف',
          icon: Icons.phone_rounded,
        ),
        _buildSortMenuItem(
          context,
          ref,
          field: 'rating',
          label: 'التقييم',
          icon: Icons.star_rounded,
        ),
      ],
      onSelected: (value) {
        if (sortField == value) {
          // Toggle direction if same field
          placesNotifier.setSort(value);
        } else {
          // Set new field and reset to ascending
          placesNotifier.setSort(value, ascending: true);
        }
      },
    );
  }

  static PopupMenuItem<String> _buildSortMenuItem(
      BuildContext context,
      WidgetRef ref, {
        required String field,
        required String label,
        required IconData icon,
      }) {
    final sortField = ref.watch(placesSortFieldProvider);
    final sortAscending = ref.watch(placesSortDirectionProvider);

    return PopupMenuItem(
      value: field,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: sortField == field ? Colors.blue.shade600 : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.cairo()),
          const Spacer(),
          if (sortField == field)
            Icon(
              sortAscending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 14,
              color: Colors.blue.shade600,
            ),
        ],
      ),
    );
  }

  // Pagination controls
  static Widget buildPagination(BuildContext context, WidgetRef ref, int totalItems) {
    final currentPage = ref.watch(placesCurrentPageProvider);
    final pageSize = ref.watch(placesPageSizeProvider);
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);
    final totalPages = (totalItems / pageSize).ceil();

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
                if (value != null) {
                  placesNotifier.setPageSize(value);
                }
              },
            ),
          ),
          const Spacer(),
          // Page navigation
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed:
            currentPage > 1 ? () => placesNotifier.setCurrentPage(1) : null,
            tooltip: 'الصفحة الأولى',
            color: Colors.blue.shade600,
            disabledColor: Colors.grey.shade400,
          ),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: currentPage > 1
                ? () => placesNotifier.setCurrentPage(currentPage - 1)
                : null,
            tooltip: 'الصفحة السابقة',
            color: Colors.blue.shade600,
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
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: currentPage < totalPages
                ? () => placesNotifier.setCurrentPage(currentPage + 1)
                : null,
            tooltip: 'الصفحة التالية',
            color: Colors.blue.shade600,
            disabledColor: Colors.grey.shade400,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages
                ? () => placesNotifier.setCurrentPage(totalPages)
                : null,
            tooltip: 'الصفحة الأخيرة',
            color: Colors.blue.shade600,
            disabledColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  // Export option item
  static Widget buildExportOption(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade600),
      title: Text(title, style: GoogleFonts.cairo()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onTap,
      hoverColor: Colors.blue.shade50,
    );
  }
}