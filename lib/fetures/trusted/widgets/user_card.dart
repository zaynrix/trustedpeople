import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/status_chip.dart';

class UserCard extends ConsumerWidget {
  final UserModel user;
  final VoidCallback onTap;
  final String? visiblePhoneNumberId;
  final Function(String) onTogglePhoneNumber;

  const UserCard({
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // Just add a subtle border for admins
        side: isAdmin
            ? BorderSide(color: Colors.purple.shade300, width: 1.5)
            : BorderSide.none,
      ),
      // Subtle background for admins
      color: isAdmin ? Colors.purple.shade50 : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(
                  maxHeight: 200), // Increased height slightly
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.aliasName,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isAdmin ? Colors.purple.shade700 : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(
                        role: user.role,
                        compact: true,
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Modified phone number row with visibility toggle
                  _buildPhoneInfoRow(
                    context,
                    isPhoneVisible: isPhoneVisible,
                    phoneNumber: user.mobileNumber,
                    onToggle: () => onTogglePhoneNumber(user.id),
                  ),
                  const SizedBox(height: 8),

                  _buildInfoRow(
                    context,
                    icon: Icons.location_on,
                    label: user.location,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    context,
                    icon: Icons.star,
                    label: user.reviews,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: Text(
                        'عرض التفاصيل',
                        style: GoogleFonts.cairo(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdmin
                            ? Colors.purple.shade600
                            : Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // New method for phone number row with visibility toggle
  Widget _buildPhoneInfoRow(
    BuildContext context, {
    required bool isPhoneVisible,
    required String phoneNumber,
    required VoidCallback onToggle,
  }) {
    return Row(
      children: [
        Icon(
          Icons.phone,
          size: 18,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 8),
        Expanded(
            child: isPhoneVisible
                ? Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: phoneNumber.isNotEmpty
                              ? () {
                                  Clipboard.setData(
                                      ClipboardData(text: phoneNumber));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('تم النسخ'),
                                      backgroundColor: Colors.blue.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      width: 200,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              : null,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  phoneNumber.isEmpty ? '-' : phoneNumber,
                                  style: GoogleFonts.cairo(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (phoneNumber.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.content_copy,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onToggle,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.visibility_off,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  )
                : IntrinsicWidth(
                    child: GestureDetector(
                      onTap: onToggle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'اظهر رقم الجوال',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool copyable = false,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color ?? Colors.grey.shade700,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: copyable && label.isNotEmpty
                ? () {
                    Clipboard.setData(ClipboardData(text: label));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم النسخ'),
                        backgroundColor: Colors.blue.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        width: 200,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                : null,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label.isEmpty ? '-' : label,
                    style: GoogleFonts.cairo(
                      color: Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (copyable && label.isNotEmpty)
                  const Icon(
                    Icons.content_copy,
                    size: 14,
                    color: Colors.blue,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
