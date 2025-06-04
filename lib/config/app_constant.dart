import 'package:flutter/material.dart';

// ==================== App Constants ====================
class AppConstants {
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Chart constants
  static const double chartHeight = 250.0;
  static const double mobileChartHeight = 200.0;

  // Map constants
  static const double mapHeight = 300.0;
  static const double mobileMapHeight = 200.0;

  // Grid constants
  static const double gridSpacing = 16.0;
  static const double mobileGridSpacing = 8.0;

  // Padding constants
  static const double defaultPadding = 16.0;
  static const double mobilePadding = 12.0;
  static const double largePadding = 24.0;

  // Font sizes
  static const double titleFontSize = 24.0;
  static const double mobileTitleFontSize = 20.0;
  static const double subtitleFontSize = 16.0;
  static const double mobileSubtitleFontSize = 14.0;
  static const double bodyFontSize = 14.0;
  static const double mobileBodyFontSize = 12.0;

  // Icon sizes
  static const double iconSize = 24.0;
  static const double mobileIconSize = 20.0;
  static const double largeIconSize = 32.0;

  // Card sizes
  static const double cardHeight = 120.0;
  static const double mobileCardHeight = 100.0;

  // Button sizes
  static const double buttonHeight = 48.0;
  static const double mobileButtonHeight = 44.0;
}

// ==================== Responsive Breakpoints ====================
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= largeDesktop;

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= largeDesktop) return 4;
    if (width >= desktop) return 3;
    if (width >= tablet) return 2;
    return 2; // Mobile: 2 columns for better space usage
  }

  static double getCardSpacing(BuildContext context) {
    return isMobile(context)
        ? AppConstants.mobileGridSpacing
        : AppConstants.gridSpacing;
  }

  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= largeDesktop) return 32.0;
    if (width >= desktop) return AppConstants.largePadding;
    if (width >= tablet) return AppConstants.defaultPadding;
    return AppConstants.mobilePadding;
  }

  static double getFontSize(
    BuildContext context, {
    required double desktop,
    required double mobile,
  }) {
    return isMobile(context) ? mobile : desktop;
  }

  static double getIconSize(BuildContext context) {
    return isMobile(context)
        ? AppConstants.mobileIconSize
        : AppConstants.iconSize;
  }

  static double getChartHeight(BuildContext context) {
    return isMobile(context)
        ? AppConstants.mobileChartHeight
        : AppConstants.chartHeight;
  }

  static double getMapHeight(BuildContext context) {
    return isMobile(context)
        ? AppConstants.mobileMapHeight
        : AppConstants.mapHeight;
  }
}

// ==================== App Colors ====================
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryVariant = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF03DAC6);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF1976D2), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF009688), // Teal
    Color(0xFFF44336), // Red
    Color(0xFF3F51B5), // Indigo
    Color(0xFF00BCD4), // Cyan
  ];

  // Background colors
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF121212);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
}

// ==================== App Text Styles ====================
class AppTextStyles {
  static const String fontFamily = 'Cairo';

  static const TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headline3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headline4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headline5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headline6 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
  );
}
