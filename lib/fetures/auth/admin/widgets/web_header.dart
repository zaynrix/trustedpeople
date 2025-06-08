import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WebHeader extends StatelessWidget {
  final bool isDesktop;
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final double? iconSize;
  final double? titleFontSize;
  final double? subtitleFontSize;
  final FontWeight titleFontWeight;
  final double? letterSpacing;
  final EdgeInsets? iconPadding;
  final double iconBorderRadius;
  final double spacingAfterIcon;
  final double spacingAfterTitle;

  const WebHeader({
    Key? key,
    required this.isDesktop,
    this.title = 'Admin Access',
    this.subtitle = 'Authorized Personnel Only',
    this.headerIcon = Icons.security,
    this.iconBackgroundColor,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
    this.iconSize,
    this.titleFontSize,
    this.subtitleFontSize,
    this.titleFontWeight = FontWeight.bold,
    this.letterSpacing = 0.5,
    this.iconPadding,
    this.iconBorderRadius = 12,
    this.spacingAfterIcon = 0, // Will use responsive default if 0
    this.spacingAfterTitle = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: iconPadding ?? EdgeInsets.all(isDesktop ? 16 : 12),
          decoration: BoxDecoration(
            color: iconBackgroundColor ?? Colors.grey.shade100,
            borderRadius: BorderRadius.circular(iconBorderRadius),
          ),
          child: Icon(
            headerIcon,
            size: iconSize ?? (isDesktop ? 40 : 32),
            color: iconColor ?? Colors.grey.shade700,
          ),
        ),
        SizedBox(
            height: spacingAfterIcon > 0
                ? spacingAfterIcon
                : (isDesktop ? 24 : 20)),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: titleFontSize ?? (isDesktop ? 28 : 24),
            fontWeight: titleFontWeight,
            color: titleColor ?? Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacingAfterTitle),
        Text(
          subtitle,
          style: GoogleFonts.cairo(
            fontSize: subtitleFontSize ?? 14,
            color: subtitleColor ?? Colors.grey.shade600,
            letterSpacing: letterSpacing,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Factory constructors for different header types
  factory WebHeader.arabic({
    required bool isDesktop,
    String title = 'دخول المشرف',
    String subtitle = 'للمشرفين المعتمدين فقط',
  }) {
    return WebHeader(
      isDesktop: isDesktop,
      title: title,
      subtitle: subtitle,
      headerIcon: Icons.admin_panel_settings,
    );
  }

  factory WebHeader.admin({
    required bool isDesktop,
    String title = 'Administrator',
    String subtitle = 'System Management Portal',
  }) {
    return WebHeader(
      isDesktop: isDesktop,
      title: title,
      subtitle: subtitle,
      headerIcon: Icons.admin_panel_settings,
      iconBackgroundColor: Colors.blue.shade50,
      iconColor: Colors.blue.shade700,
      titleColor: Colors.blue.shade800,
    );
  }

  factory WebHeader.secure({
    required bool isDesktop,
    String title = 'Secure Access',
    String subtitle = 'Protected Area - Authentication Required',
  }) {
    return WebHeader(
      isDesktop: isDesktop,
      title: title,
      subtitle: subtitle,
      headerIcon: Icons.shield,
      iconBackgroundColor: Colors.green.shade50,
      iconColor: Colors.green.shade700,
      titleColor: Colors.green.shade800,
    );
  }

  factory WebHeader.user({
    required bool isDesktop,
    String title = 'User Login',
    String subtitle = 'Access Your Account',
  }) {
    return WebHeader(
      isDesktop: isDesktop,
      title: title,
      subtitle: subtitle,
      headerIcon: Icons.person,
      iconBackgroundColor: Colors.purple.shade50,
      iconColor: Colors.purple.shade700,
      titleColor: Colors.purple.shade800,
    );
  }
}
