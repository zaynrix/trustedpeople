import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/status_chip.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const UserCard({
    Key? key,
    required this.user,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = user.role == 0;

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
              constraints: BoxConstraints(maxHeight: 180),
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
                        isTrusted: user.isTrusted,
                        role: user.role,
                        compact: true,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    context,
                    icon: Icons.phone,
                    label: user.mobileNumber,
                    copyable: true,
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
