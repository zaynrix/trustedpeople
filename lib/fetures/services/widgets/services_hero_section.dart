// lib/features/services/widgets/services_hero_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesHeroSection extends StatelessWidget {
  final bool isMobile;

  const ServicesHeroSection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 20 : 24,
        horizontal: isMobile ? 16 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade200.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.design_services,
            color: Colors.white,
            size: isMobile ? 40 : 48,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'خدمات متميزة تلبي احتياجاتك',
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            'تصفح خدماتنا المتنوعة واطلب ما يناسبك، وسنتواصل معك في أقرب وقت!',
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 14 : 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          SizedBox(
            width: isMobile ? double.infinity : null,
            child: ElevatedButton.icon(
              onPressed: () {
                // Scroll down smoothly (no specific target needed as it's already scrollable)
              },
              icon: const Icon(Icons.arrow_downward),
              label: Text(
                'تصفح الخدمات',
                style: GoogleFonts.cairo(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal.shade700,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20,
                  vertical: isMobile ? 10 : 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}