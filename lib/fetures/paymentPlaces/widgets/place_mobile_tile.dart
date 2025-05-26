import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/models/payment_place_model.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/payment_method_chip.dart';

class PlaceMobileTile extends StatelessWidget {
  final PaymentPlaceModel place;
  final VoidCallback onTap;

  const PlaceMobileTile({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main row with image, info and rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image or icon container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: place.imageUrl.isEmpty ? Colors.blue.shade100 : null,
                      image: place.imageUrl.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(place.imageUrl),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: place.imageUrl.isEmpty
                        ? Center(
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 32,
                        color: Colors.blue.shade700,
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Middle content - name, category, location, phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name and category
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
                        const SizedBox(height: 6),

                        // Location
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_rounded,
                                size: 14, color: Colors.grey.shade700),
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone,
                                  size: 14, color: Colors.grey.shade700),
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
                              const Icon(Icons.content_copy, size: 18, color: Colors.blue),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side - rating and verified badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Verification badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: place.isVerified
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              place.isVerified
                                  ? Icons.verified_rounded
                                  : Icons.info_outline_rounded,
                              size: 12,
                              color:
                              place.isVerified ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 2),
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
                    ],
                  ),
                ],
              ),

              // Payment methods
              if (place.paymentMethods.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
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
            ],
          ),
        ),
      ),
    );
  }
}