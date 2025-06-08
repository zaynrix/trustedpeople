import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? progressColor;
  final bool showProgress;
  final double iconSize;
  final bool barrierDismissible;
  final EdgeInsets padding;
  final double borderRadius;

  const SuccessDialog({
    Key? key,
    this.title = 'تم تسجيل الدخول بنجاح',
    this.subtitle = 'جاري التوجيه إلى لوحة التحكم...',
    this.icon = Icons.check,
    this.iconColor,
    this.iconBackgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.progressColor,
    this.showProgress = true,
    this.iconSize = 40,
    this.barrierDismissible = false,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor ?? Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: subtitleColor ?? Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (showProgress) ...[
              const SizedBox(height: 16),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Static method to show the dialog
  static void show(
    BuildContext context, {
    String title = 'تم تسجيل الدخول بنجاح',
    String subtitle = 'جاري التوجيه إلى لوحة التحكم...',
    IconData icon = Icons.check,
    Color? iconColor,
    Color? iconBackgroundColor,
    Color? titleColor,
    Color? subtitleColor,
    Color? progressColor,
    bool showProgress = true,
    double iconSize = 40,
    bool barrierDismissible = false,
    EdgeInsets padding = const EdgeInsets.all(24),
    double borderRadius = 16,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return SuccessDialog(
          title: title,
          subtitle: subtitle,
          icon: icon,
          iconColor: iconColor,
          iconBackgroundColor: iconBackgroundColor,
          titleColor: titleColor,
          subtitleColor: subtitleColor,
          progressColor: progressColor,
          showProgress: showProgress,
          iconSize: iconSize,
          barrierDismissible: barrierDismissible,
          padding: padding,
          borderRadius: borderRadius,
        );
      },
    );
  }
}
