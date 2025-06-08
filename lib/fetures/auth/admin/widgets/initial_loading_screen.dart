import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialLoadingScreen extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final Color? progressColor;
  final Color? textColor;
  final IconData icon;
  final double iconSize;
  final String loadingText;
  final double fontSize;
  final double containerPadding;
  final double borderRadius;

  const InitialLoadingScreen({
    Key? key,
    this.backgroundColor,
    this.iconBackgroundColor,
    this.iconColor,
    this.progressColor,
    this.textColor,
    this.icon = Icons.admin_panel_settings,
    this.iconSize = 60,
    this.loadingText = 'جاري التحقق من حالة تسجيل الدخول...',
    this.fontSize = 16,
    this.containerPadding = 20,
    this.borderRadius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.grey.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(containerPadding),
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? Colors.green.shade700,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loadingText,
              style: GoogleFonts.cairo(
                fontSize: fontSize,
                color: textColor ?? Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
