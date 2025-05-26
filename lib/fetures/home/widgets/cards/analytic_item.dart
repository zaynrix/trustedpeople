import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String subtext;
  final VoidCallback? onTap;

  const AnalyticItem({
    Key? key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.subtext,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                // Show arrow icon only if onTap is provided
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: color.withOpacity(0.7),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}