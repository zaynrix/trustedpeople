import 'package:flutter/material.dart';

class WebForm extends StatelessWidget {
  final bool isDesktop;
  final dynamic authState;
  final GlobalKey<FormState> formKey;
  final Widget Function(bool isMobile, bool isLoading) buildEmailField;
  final Widget Function(bool isMobile, bool isLoading) buildPasswordField;
  final Widget Function(bool isMobile, String error) buildErrorMessage;
  final Widget Function(bool isMobile, bool isLoading) buildLoginButton;
  final Widget Function() buildSecurityNotice;
  final CrossAxisAlignment crossAxisAlignment;
  final double emailPasswordSpacing;
  final double errorSpacing;
  final double buttonSpacing;
  final double securityNoticeSpacing;

  const WebForm({
    Key? key,
    required this.isDesktop,
    required this.authState,
    required this.formKey,
    required this.buildEmailField,
    required this.buildPasswordField,
    required this.buildErrorMessage,
    required this.buildLoginButton,
    required this.buildSecurityNotice,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.emailPasswordSpacing = 20,
    this.errorSpacing = 16,
    this.buttonSpacing = 28,
    this.securityNoticeSpacing = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          buildEmailField(false, authState.isLoading),
          SizedBox(height: emailPasswordSpacing),
          buildPasswordField(false, authState.isLoading),
          if (authState.error != null) ...[
            SizedBox(height: errorSpacing),
            buildErrorMessage(false, authState.error!),
          ],
          SizedBox(height: buttonSpacing),
          buildLoginButton(false, authState.isLoading),
          SizedBox(height: securityNoticeSpacing),
          buildSecurityNotice(),
        ],
      ),
    );
  }
}
