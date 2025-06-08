import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionButton extends StatelessWidget {
  final bool isMobile;
  final bool isLoading;
  final VoidCallback? onPressed;
  final String loginText;
  final String loadingText;
  final IconData loginIcon;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? foregroundColor;
  final Color? loadingIndicatorColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final EdgeInsets? padding;
  final double borderRadius;
  final double elevation;
  final double loadingIndicatorSize;
  final double loadingIndicatorStrokeWidth;

  const ActionButton({
    super.key,
    required this.isMobile,
    required this.isLoading,
    this.onPressed,
    this.loginText = 'تسجيل الدخول',
    this.loadingText = 'جارٍ تسجيل الدخول...',
    this.loginIcon = Icons.login,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.foregroundColor,
    this.loadingIndicatorColor,
    this.fontSize,
    this.fontWeight = FontWeight.w600,
    this.padding,
    this.borderRadius = 8,
    this.elevation = 2,
    this.loadingIndicatorSize = 18,
    this.loadingIndicatorStrokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isLoading
            ? (disabledBackgroundColor ?? Colors.grey.shade400)
            : (backgroundColor ?? Colors.grey.shade800),
        foregroundColor: foregroundColor ?? Colors.white,
        disabledBackgroundColor:
            disabledBackgroundColor ?? Colors.grey.shade400,
        padding: padding ??
            EdgeInsets.symmetric(
              vertical: isMobile ? 16 : 18,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: isLoading ? 0 : elevation,
      ),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: loadingIndicatorSize,
                  width: loadingIndicatorSize,
                  child: CircularProgressIndicator(
                    strokeWidth: loadingIndicatorStrokeWidth,
                    color: loadingIndicatorColor ?? Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  loadingText,
                  style: GoogleFonts.cairo(
                    fontSize: fontSize ?? (isMobile ? 16 : 15),
                    fontWeight: fontWeight,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  loginIcon,
                  size: isMobile ? 20 : 18,
                ),
                const SizedBox(width: 8),
                Text(
                  loginText,
                  style: GoogleFonts.cairo(
                    fontSize: fontSize ?? (isMobile ? 16 : 15),
                    fontWeight: fontWeight,
                  ),
                ),
              ],
            ),
    );
  }
}
