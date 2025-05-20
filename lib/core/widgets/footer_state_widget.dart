import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FooterStateWidget extends StatelessWidget {
  const FooterStateWidget({super.key,
  required this.filteredCount,
  required this.totalCount});

  final int filteredCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            'عرض $filteredCount من إجمالي $totalCount',
            style: GoogleFonts.cairo(
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            'آخر تحديث: ${DateTime.now().toString().substring(0, 16)}',
            style: GoogleFonts.cairo(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
