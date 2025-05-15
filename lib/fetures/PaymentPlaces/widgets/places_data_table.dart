// lib/fetures/PaymentPlaces/widgets/places_data_table.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/models/payment_place_model.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/payment_method_chip.dart';

class PlacesDataTable extends ConsumerWidget {
  final List<DocumentSnapshot> places;
  final Function(String, bool)? onSort;
  final Function(PaymentPlaceModel)? onPlaceTap;
  final String currentSortField;
  final bool isAscending;

  const PlacesDataTable({
    Key? key,
    required this.places,
    this.onSort,
    this.onPlaceTap,
    this.currentSortField = 'name',
    this.isAscending = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          dataRowMaxHeight: 80,
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => Colors.grey.shade100,
          ),
          headingRowHeight: 56,
          horizontalMargin: 24,
          columnSpacing: 24,
          dividerThickness: 1,
          showCheckboxColumn: false,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          sortColumnIndex: _getSortColumnIndex(),
          sortAscending: isAscending,
          columns: [
            DataColumn(
              label: Text(
                'المكان',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              onSort: onSort != null
                  ? (columnIndex, ascending) {
                      onSort!('name', ascending);
                    }
                  : null,
            ),
            DataColumn(
              label: Text(
                'التصنيف',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              onSort: onSort != null
                  ? (columnIndex, ascending) {
                      onSort!('category', ascending);
                    }
                  : null,
            ),
            DataColumn(
              label: Text(
                'الموقع',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              onSort: onSort != null
                  ? (columnIndex, ascending) {
                      onSort!('location', ascending);
                    }
                  : null,
            ),
            DataColumn(
              label: Text(
                'رقم الهاتف',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              onSort: onSort != null
                  ? (columnIndex, ascending) {
                      onSort!('phoneNumber', ascending);
                    }
                  : null,
            ),
            DataColumn(
              label: Text(
                'طرق الدفع',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              onSort: null, // No sorting for payment methods
            ),
            DataColumn(
              label: Text(
                'التقييم',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              onSort: onSort != null
                  ? (columnIndex, ascending) {
                      onSort!('rating', ascending);
                    }
                  : null,
            ),
            const DataColumn(label: Text('')), // Actions column
          ],
          rows: places.map((doc) {
            final place = PaymentPlaceModel.fromFirestore(doc);

            return DataRow(
              cells: [
                // Place name column
                DataCell(
                  Row(
                    children: [
                      if (place.isVerified)
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Colors.green,
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.name,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  onTap: onPlaceTap != null ? () => onPlaceTap!(place) : null,
                ),

                // Category column
                DataCell(
                  Text(
                    place.category,
                    style: GoogleFonts.cairo(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Location column
                DataCell(
                  Text(
                    place.location,
                    style: GoogleFonts.cairo(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Phone column
                DataCell(
                  GestureDetector(
                    onTap: () {
                      if (place.phoneNumber.isNotEmpty) {
                        Clipboard.setData(
                            ClipboardData(text: place.phoneNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم نسخ رقم الهاتف',
                              style: GoogleFonts.cairo(),
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            width: 200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          place.phoneNumber,
                          style: GoogleFonts.cairo(),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.content_copy,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),

                // Payment methods column
                DataCell(
                  SizedBox(
                    width: 150,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: place.paymentMethods
                            .map((method) => PaymentMethodChip(
                                  method: method,
                                  compact: true,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),

                // Rating column
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "(${place.reviewsCount})",
                        style: GoogleFonts.cairo(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions column
                DataCell(
                  TextButton.icon(
                    onPressed:
                        onPlaceTap != null ? () => onPlaceTap!(place) : null,
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: Text(
                      "المزيد",
                      style: GoogleFonts.cairo(),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  int? _getSortColumnIndex() {
    switch (currentSortField) {
      case 'name':
        return 0;
      case 'category':
        return 1;
      case 'location':
        return 2;
      case 'phoneNumber':
        return 3;
      case 'rating':
        return 5;
      default:
        return 0;
    }
  }
}
