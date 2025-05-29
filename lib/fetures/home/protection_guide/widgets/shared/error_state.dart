import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildErrorState(BuildContext context, Object error) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child:
              Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
        ),
        const SizedBox(height: 24),
        Text(
          'حدث خطأ أثناء تحميل النصائح',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'يرجى المحاولة مرة أخرى',
          style: GoogleFonts.cairo(color: Colors.grey.shade600, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            // Trigger a rebuild to retry loading
            // You might want to add a refresh mechanism here
          },
          icon: const Icon(Icons.refresh),
          label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    ),
  );
}
