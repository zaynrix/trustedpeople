// Shared widgets
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade100, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.security,
            size: 64,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'لا توجد نصائح متاحة حالياً',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'سيتم إضافة نصائح الحماية قريباً',
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Colors.grey.shade500,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}
