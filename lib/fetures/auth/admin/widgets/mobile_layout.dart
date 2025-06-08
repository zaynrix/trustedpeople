import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/widgets/security_notice.dart';

class MobileLayout extends StatelessWidget {
  final dynamic authState;
  final GlobalKey<FormState> formKey;
  final Widget Function(bool isMobile, bool isLoading) buildEmailField;
  final Widget Function(bool isMobile, bool isLoading) buildPasswordField;
  final Widget Function(bool isMobile, String error) buildErrorMessage;
  final Widget Function(bool isMobile, bool isLoading) buildLoginButton;
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final EdgeInsets padding;
  final double headerIconSize;
  final Color? headerIconColor;
  final Color? headerBackgroundColor;
  final Color? formBackgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;

  const MobileLayout({
    Key? key,
    required this.authState,
    required this.formKey,
    required this.buildEmailField,
    required this.buildPasswordField,
    required this.buildErrorMessage,
    required this.buildLoginButton,
    this.title = 'تسجيل دخول المشرف',
    this.subtitle = 'يرجى إدخال بيانات الاعتماد للوصول لوحة التحكم',
    this.headerIcon = Icons.admin_panel_settings,
    this.padding = const EdgeInsets.all(24.0),
    this.headerIconSize = 48,
    this.headerIconColor,
    this.headerBackgroundColor,
    this.formBackgroundColor,
    this.titleColor,
    this.subtitleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: padding,
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildMobileHeader(),
              const SizedBox(height: 40),
              _buildMobileForm(),
              const SizedBox(height: 32),
              const SecurityNotice(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: headerBackgroundColor ?? Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Icon(
            headerIcon,
            size: headerIconSize,
            color: headerIconColor ?? Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: titleColor ?? Colors.grey.shade800,
          ),
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
      ],
    );
  }

  Widget _buildMobileForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: formBackgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildEmailField(true, authState.isLoading),
            const SizedBox(height: 20),
            buildPasswordField(true, authState.isLoading),
            if (authState.error != null) ...[
              const SizedBox(height: 16),
              buildErrorMessage(true, authState.error!),
            ],
            const SizedBox(height: 24),
            buildLoginButton(true, authState.isLoading),
          ],
        ),
      ),
    );
  }
}
