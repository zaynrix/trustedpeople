import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable status chip that shows trusted/untrusted status
class StatusChip extends StatelessWidget {
  final bool isTrusted;
  final bool compact;

  const StatusChip({
    Key? key,
    required this.isTrusted,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isTrusted ? Colors.green.shade50 : Colors.red.shade50;

    final Color textColor =
        isTrusted ? Colors.green.shade700 : Colors.red.shade700;

    final Color borderColor =
        isTrusted ? Colors.green.shade300 : Colors.red.shade300;

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
            isTrusted ? Icons.verified_user : Icons.warning,
            color: textColor,
            size: compact ? 14 : 18,
          ),
          const SizedBox(width: 6),
          Text(
            isTrusted ? "موثوق" : "نصاب",
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
