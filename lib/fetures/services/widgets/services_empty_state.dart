// lib/features/services/widgets/services_empty_state.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesEmptyState extends StatelessWidget {
  const ServicesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'لم يتم العثور على خدمات',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'حاول تغيير معايير البحث أو التصفية',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}