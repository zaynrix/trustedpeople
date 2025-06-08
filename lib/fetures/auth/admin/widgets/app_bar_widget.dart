import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;
  final String title;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? fontSize;
  final double? toolbarHeight;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    Key? key,
    required this.isMobile,
    this.title = 'تسجيل الدخول',
    this.backgroundColor,
    this.titleColor,
    this.fontSize = 18,
    this.toolbarHeight,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return AppBar(
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: titleColor ?? Colors.white,
            fontSize: fontSize,
          ),
        ),
        backgroundColor: backgroundColor ?? Colors.grey.shade800,
        elevation: 0,
        centerTitle: centerTitle,
        automaticallyImplyLeading: automaticallyImplyLeading,
      );
    } else {
      return AppBar(
        backgroundColor: backgroundColor ?? Colors.grey.shade900,
        elevation: 0,
        toolbarHeight: toolbarHeight ?? 40,
        automaticallyImplyLeading: false,
      );
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(
        isMobile ? kToolbarHeight : (toolbarHeight ?? 40),
      );
}
