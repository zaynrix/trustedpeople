import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable info card widget that shows user information with copy functionality
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool copyable;
  final Color? iconColor;

  const InfoCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    this.copyable = true,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.blue.shade50).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor ?? Colors.blue.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: copyable && value.isNotEmpty
                        ? () {
                            Clipboard.setData(ClipboardData(text: value));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم النسخ'),
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
                            value.isEmpty ? '-' : value,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (copyable && value.isNotEmpty)
                          Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: Colors.blue.shade400,
                          ),
                      ],
                    ),
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
