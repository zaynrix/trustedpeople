import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildModernMobileHeader(int tipsCount) {
  return Container(
    margin: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.blue.shade600,
          Colors.blue.shade500,
          Colors.teal.shade500,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'دليل شامل للحماية',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'احمِ نفسك من النصب والاحتيال',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'تعلم كيفية حماية نفسك ومالك من عمليات النصب والاحتيال من خلال هذه النصائح المهمة.',
            style: GoogleFonts.cairo(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              buildStatItem(tipsCount.toString(), 'نصيحة مهمة'),
              const SizedBox(width: 24),
              buildStatItem('100%', 'مجاناً'),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget buildStatItem(String number, String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        number,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        label,
        style: GoogleFonts.cairo(
          color: Colors.white.withOpacity(0.8),
          fontSize: 12,
        ),
      ),
    ],
  );
}
