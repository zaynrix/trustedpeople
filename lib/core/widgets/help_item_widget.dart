import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpItemWidget extends StatelessWidget {
   const HelpItemWidget({
    super.key,
    required this.title,
    required this.description,
     required this.primaryColor,
    required this.icon,});

  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.cairo(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
