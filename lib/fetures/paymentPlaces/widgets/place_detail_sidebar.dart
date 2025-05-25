// lib/fetures/PaymentPlaces/widgets/place_detail_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/user_info_card.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/models/payment_place_model.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/payment_method_chip.dart';

import '../../../fetures/services/auth_service.dart';

class PlaceDetailSidebar extends ConsumerWidget {
  final PaymentPlaceModel place;
  final VoidCallback onClose;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlaceDetailSidebar({
    Key? key,
    required this.place,
    required this.onClose,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (place.imageUrl.isNotEmpty)
                    Container(
                      height: 180,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(place.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  UserInfoCard(
                    icon: Icons.storefront_rounded,
                    title: "اسم المكان",
                    value: place.name,
                  ),
                  const SizedBox(height: 12),
                  UserInfoCard(
                    icon: Icons.phone_rounded,
                    title: "رقم الهاتف",
                    value: place.phoneNumber,
                  ),
                  const SizedBox(height: 12),
                  UserInfoCard(
                    icon: Icons.location_on_rounded,
                    title: "الموقع",
                    value: place.location,
                  ),
                  const SizedBox(height: 12),
                  UserInfoCard(
                    icon: Icons.category_rounded,
                    title: "التصنيف",
                    value: place.category,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "طرق الدفع المقبولة",
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: place.paymentMethods
                            .map((method) => PaymentMethodChip(method: method))
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (place.workingHours.isNotEmpty)
                    UserInfoCard(
                      icon: Icons.access_time_rounded,
                      title: "ساعات العمل",
                      value: place.workingHours,
                    ),
                  if (place.workingHours.isNotEmpty) const SizedBox(height: 12),
                  if (place.description.isNotEmpty)
                    UserInfoCard(
                      icon: Icons.description_rounded,
                      title: "وصف",
                      value: place.description,
                    ),
                  if (place.description.isNotEmpty) const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${place.reviewsCount} تقييم)",
                        style: GoogleFonts.cairo(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (isAdmin && (onEdit != null || onDelete != null)) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (onEdit != null)
                          ElevatedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 18),
                            label: Text(
                              'تعديل',
                              style: GoogleFonts.cairo(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        const SizedBox(width: 16),
                        if (onDelete != null)
                          ElevatedButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, size: 18),
                            label: Text(
                              'حذف',
                              style: GoogleFonts.cairo(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.blue.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلومات المتجر',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: place.isVerified
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: place.isVerified
                          ? Colors.green.shade300
                          : Colors.orange.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        place.isVerified
                            ? Icons.verified_rounded
                            : Icons.info_outline_rounded,
                        size: 14,
                        color: place.isVerified ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        place.isVerified ? 'متحقق منه' : 'قيد التحقق',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              place.isVerified ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
