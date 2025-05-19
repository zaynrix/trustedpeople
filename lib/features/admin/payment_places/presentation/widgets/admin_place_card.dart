// lib/features/admin/payment_places/presentation/widgets/admin_place_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/domain/entities/admin_payment_place.dart';
import 'package:trustedtallentsvalley/app/core/widgets/payment_places/payment_method_chip.dart';

class AdminPlaceCard extends StatelessWidget {
  final AdminPaymentPlace place;
  final VoidCallback onTap;

  const AdminPlaceCard({
    Key? key,
    required this.place,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image or colored header
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: place.imageUrl.isEmpty ? Colors.blue.shade100 : null,
                image: place.imageUrl.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(place.imageUrl),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: Stack(
                children: [
                  if (place.imageUrl.isEmpty)
                    Center(
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 40,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: place.isVerified
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            place.isVerified
                                ? Icons.verified_rounded
                                : Icons.info_outline_rounded,
                            size: 14,
                            color:
                            place.isVerified ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.isVerified ? 'متحقق' : 'قيد التحقق',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: place.isVerified
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              place.category,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.location,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Phone
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
                      children: [
                        Icon(Icons.phone,
                            size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.phoneNumber,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.content_copy, size: 12, color: Colors.blue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Payment methods
                  if (place.paymentMethods.isNotEmpty)
                    SingleChildScrollView(
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

                  const SizedBox(height: 8),

                  // Details and admin buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: Text(
                          'التفاصيل',
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      // Admin-specific: Verification status button
                      IconButton(
                        icon: Icon(
                          place.isVerified
                              ? Icons.verified_user
                              : Icons.pending_rounded,
                          size: 20,
                          color: place.isVerified ? Colors.green : Colors.orange,
                        ),
                        onPressed: onTap, // Navigate to details to change status
                        tooltip: place.isVerified
                            ? 'متحقق منه - انقر للتفاصيل'
                            : 'قيد التحقق - انقر للتفاصيل',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}