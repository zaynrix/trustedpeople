import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusChip extends StatelessWidget {
  final int role; // Made required and removed isTrusted
  final bool compact;

  const StatusChip({
    Key? key,
    required this.role, // Now required
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set defaults based on role
    Color bgColor;
    Color textColor;
    Color borderColor;
    String statusText;
    IconData iconData;

    // Determine styling based on role
    switch (role) {
      case 0: // Admin
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        borderColor = Colors.purple.shade300;
        statusText = "مشرف"; // Admin
        iconData = Icons.admin_panel_settings;
        break;

      case 1: // Trusted
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        borderColor = Colors.green.shade300;
        statusText = "موثوق"; // Trusted
        iconData = Icons.verified_user;
        break;

      case 2: // Known person
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        borderColor = Colors.blue.shade300;
        statusText = "معروف"; // Known person
        iconData = Icons.person;
        break;

      case 3: // Fraud
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        borderColor = Colors.red.shade300;
        statusText = "نصاب"; // Fraud
        iconData = Icons.warning;
        break;

      default: // Fallback for unknown role values
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        borderColor = Colors.grey.shade300;
        statusText = "غير محدد"; // Unknown
        iconData = Icons.help_outline;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8.0 : 12.0,
        vertical: compact ? 4.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: textColor,
            size: compact ? 14 : 18,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: GoogleFonts.cairo(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
