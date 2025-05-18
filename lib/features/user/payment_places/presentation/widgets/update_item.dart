import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trustedtallentsvalley/features/user/home/domain/entities/home_data.dart';

class UpdateItem extends StatelessWidget {
  final AppUpdate update;

  const UpdateItem({Key? key, required this.update}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date in Arabic
    final formattedDate = DateFormat.yMMMd().format(update.date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 12, color: Colors.teal.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.title,
                  style: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  update.description,
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  formattedDate,
                  style: GoogleFonts.cairo(
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
