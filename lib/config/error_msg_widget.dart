import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String errorMessage;
  final bool isMobile;
  final IconData icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;
  final double iconSize;
  final double? fontSize;
  final EdgeInsets padding;
  final double borderRadius;
  final String? Function(String)? errorTranslator;

  const ErrorMessageWidget({
    Key? key,
    required this.errorMessage,
    this.isMobile = false,
    this.icon = Icons.error_outline,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
    this.iconSize = 20,
    this.fontSize,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 8,
    this.errorTranslator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use custom error translator if provided, otherwise use the message as-is
    String displayError = errorTranslator?.call(errorMessage) ?? errorMessage;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red.shade50,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? Colors.red.shade700,
            size: iconSize,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayError,
              style: GoogleFonts.cairo(
                color: textColor ?? Colors.red.shade800,
                fontSize: fontSize ?? (isMobile ? 14 : 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Factory constructors for different error types
  factory ErrorMessageWidget.warning({
    required String errorMessage,
    bool isMobile = false,
    String? Function(String)? errorTranslator,
  }) {
    return ErrorMessageWidget(
      errorMessage: errorMessage,
      isMobile: isMobile,
      icon: Icons.warning_outlined,
      backgroundColor: Colors.orange.shade50,
      borderColor: Colors.orange.shade200,
      iconColor: Colors.orange.shade700,
      textColor: Colors.orange.shade800,
      errorTranslator: errorTranslator,
    );
  }

  factory ErrorMessageWidget.info({
    required String errorMessage,
    bool isMobile = false,
    String? Function(String)? errorTranslator,
  }) {
    return ErrorMessageWidget(
      errorMessage: errorMessage,
      isMobile: isMobile,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue.shade50,
      borderColor: Colors.blue.shade200,
      iconColor: Colors.blue.shade700,
      textColor: Colors.blue.shade800,
      errorTranslator: errorTranslator,
    );
  }

  factory ErrorMessageWidget.success({
    required String errorMessage,
    bool isMobile = false,
    String? Function(String)? errorTranslator,
  }) {
    return ErrorMessageWidget(
      errorMessage: errorMessage,
      isMobile: isMobile,
      icon: Icons.check_circle_outline,
      backgroundColor: Colors.green.shade50,
      borderColor: Colors.green.shade200,
      iconColor: Colors.green.shade700,
      textColor: Colors.green.shade800,
      errorTranslator: errorTranslator,
    );
  }

  factory ErrorMessageWidget.network({
    required String errorMessage,
    bool isMobile = false,
    String? Function(String)? errorTranslator,
  }) {
    return ErrorMessageWidget(
      errorMessage: errorMessage,
      isMobile: isMobile,
      icon: Icons.wifi_off,
      backgroundColor: Colors.grey.shade50,
      borderColor: Colors.grey.shade300,
      iconColor: Colors.grey.shade700,
      textColor: Colors.grey.shade800,
      errorTranslator: errorTranslator,
    );
  }
}
