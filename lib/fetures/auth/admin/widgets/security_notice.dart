import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityNotice extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets padding;
  final double borderRadius;

  const SecurityNotice({
    Key? key,
    this.message = 'الوصول مقيد للمشرفين المعتمدين فقط',
    this.icon = Icons.security,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
    this.iconSize = 16,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w500,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.amber.shade50,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? Colors.amber.shade700,
            size: iconSize,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.cairo(
                color: textColor ?? Colors.amber.shade800,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
