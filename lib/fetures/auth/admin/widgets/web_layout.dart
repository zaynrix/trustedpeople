import 'package:flutter/material.dart';

class WebLayout extends StatelessWidget {
  final bool isDesktop;
  final dynamic authState;
  final Widget header;
  final Widget form;
  final List<Color>? gradientColors;
  final double? maxWidth;
  final double? maxHeight;
  final double? elevation;
  final double? borderRadius;
  final EdgeInsets? cardPadding;
  final double spacingBetweenHeaderAndForm;

  const WebLayout({
    Key? key,
    required this.isDesktop,
    required this.authState,
    required this.header,
    required this.form,
    this.gradientColors,
    this.maxWidth,
    this.maxHeight,
    this.elevation,
    this.borderRadius,
    this.cardPadding,
    this.spacingBetweenHeaderAndForm = 0, // Will use responsive default if 0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors ??
              [
                Colors.grey.shade900,
                Colors.grey.shade800,
                Colors.grey.shade700,
              ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? (isDesktop ? 450 : 400),
            maxHeight: maxHeight ?? (isDesktop ? 700 : 600),
          ),
          child: Card(
            elevation: elevation ?? (isDesktop ? 20 : 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadius ?? (isDesktop ? 16 : 12),
              ),
            ),
            child: Container(
              padding: cardPadding ?? EdgeInsets.all(isDesktop ? 48 : 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  borderRadius ?? (isDesktop ? 16 : 12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  header,
                  SizedBox(
                    height: spacingBetweenHeaderAndForm > 0
                        ? spacingBetweenHeaderAndForm
                        : (isDesktop ? 40 : 32),
                  ),
                  form,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Factory constructors for different themes
  factory WebLayout.admin({
    required bool isDesktop,
    required dynamic authState,
    required Widget header,
    required Widget form,
  }) {
    return WebLayout(
      isDesktop: isDesktop,
      authState: authState,
      header: header,
      form: form,
      gradientColors: [
        Colors.blue.shade900,
        Colors.blue.shade800,
        Colors.blue.shade700,
      ],
    );
  }

  factory WebLayout.secure({
    required bool isDesktop,
    required dynamic authState,
    required Widget header,
    required Widget form,
  }) {
    return WebLayout(
      isDesktop: isDesktop,
      authState: authState,
      header: header,
      form: form,
      gradientColors: [
        Colors.green.shade900,
        Colors.green.shade800,
        Colors.green.shade700,
      ],
    );
  }

  factory WebLayout.dark({
    required bool isDesktop,
    required dynamic authState,
    required Widget header,
    required Widget form,
  }) {
    return WebLayout(
      isDesktop: isDesktop,
      authState: authState,
      header: header,
      form: form,
      gradientColors: [
        Colors.black87,
        Colors.grey.shade900,
        Colors.grey.shade800,
      ],
    );
  }

  factory WebLayout.light({
    required bool isDesktop,
    required dynamic authState,
    required Widget header,
    required Widget form,
  }) {
    return WebLayout(
      isDesktop: isDesktop,
      authState: authState,
      header: header,
      form: form,
      gradientColors: [
        Colors.grey.shade200,
        Colors.grey.shade300,
        Colors.grey.shade400,
      ],
    );
  }
}
