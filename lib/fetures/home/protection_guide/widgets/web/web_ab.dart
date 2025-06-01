import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildWebActionButton({
  required String label,
  required IconData icon,
  required bool isPrimary,
  required VoidCallback onPressed,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      boxShadow: isPrimary
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    ),
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.transparent,
        foregroundColor: isPrimary ? Colors.blue.shade700 : Colors.white,
        side: isPrimary ? null : const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
