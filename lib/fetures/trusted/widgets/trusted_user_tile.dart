import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/clipboard_utils.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/status_chip.dart';

/// A streamlined tile version of UserCard specifically designed for mobile list views.
/// More compact and efficient for scrolling performance in ListViews.
class TrustedUserTile extends ConsumerWidget {
  final UserModel user;
  final VoidCallback onTap;
  final String? visiblePhoneNumberId;
  final Function(String) onTogglePhoneNumber;

  const TrustedUserTile({
    super.key,
    required this.user,
    required this.onTap,
    this.visiblePhoneNumberId,
    required this.onTogglePhoneNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAdmin = user.role == 0;
    final bool isPhoneVisible = visiblePhoneNumberId == user.id;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.purple.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdmin ? Colors.purple.shade300 : Colors.grey.shade200,
          width: isAdmin ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with name and status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.aliasName,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isAdmin ? Colors.purple.shade700 : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusChip(role: user.role, compact: true),
                  ],
                ),

                const SizedBox(height: 10),

                // Info rows
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user.location.isEmpty ? '-' : user.location,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Reviews row
                if (user.reviews.isNotEmpty)
                  _buildReviewsSection(user.reviews),

                const SizedBox(height: 12),

                // Phone number section
                _buildPhoneSection(context, isPhoneVisible),

                const SizedBox(height: 10),

                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // View details button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility_outlined, size: 14),
                        label: Text('عرض التفاصيل', style: GoogleFonts.cairo(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          minimumSize: const Size(0, 32),
                          side: BorderSide(color: theme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    // Only show these if the user has telegram or other accounts
                    if (user.telegramAccount.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildIconButton(
                        icon: Icons.telegram,
                        color: Colors.blue,
                        tooltip: 'تيليجرام',
                      ),
                    ],
                    if (user.otherAccounts.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildIconButton(
                        icon: Icons.alternate_email,
                        color: Colors.teal,
                        tooltip: 'حسابات أخرى',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneSection(BuildContext context, bool isPhoneVisible) {
    if (isPhoneVisible) {
      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ClipboardUtils.copyToClipboard(context, user.mobileNumber),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.mobileNumber,
                              style: GoogleFonts.cairo(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.content_copy, size: 12, color: Colors.green.shade700),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.visibility_off,
            color: Colors.grey.shade600,
            tooltip: 'إخفاء الرقم',
            onTap: () => onTogglePhoneNumber(user.id),
          ),
        ],
      );
    } else {
      return TextButton.icon(
        onPressed: () => onTogglePhoneNumber(user.id),
        icon: const Icon(Icons.visibility, size: 14),
        label: Text('اظهر رقم الجوال', style: GoogleFonts.cairo(fontSize: 12)),
        style: TextButton.styleFrom(
          foregroundColor: Colors.green.shade700,
          backgroundColor: Colors.green.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.green.shade200),
          ),
        ),
      );
    }
  }

  Widget _buildReviewsSection(String reviews) {
    // Parse the review value to determine rating level
    bool isHighlyRated = false;
    double? rating;

    // Try to extract numerical rating
    if (reviews.contains('/')) {
      try {
        final parts = reviews.split('/');
        if (parts.length >= 2) {
          final ratingStr = parts[0].trim();
          final totalStr = parts[1].trim();
          final ratingVal = double.tryParse(ratingStr);
          final totalVal = double.tryParse(totalStr);

          if (ratingVal != null && totalVal != null) {
            rating = ratingVal;
            isHighlyRated = (ratingVal / totalVal) >= 0.8; // 80% or higher
          }
        }
      } catch (e) {
        // If parsing fails, continue with default handling
      }
    } else if (reviews.contains('5') || reviews.contains('4')) {
      isHighlyRated = true;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                reviews,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isHighlyRated) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade300, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 12, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'موصى به',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    String? tooltip,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Tooltip(
        message: tooltip ?? '',
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}