import 'package:flutter/foundation.dart';

class AppConfig {
  // Firebase Configuration
  static String get firebaseApiKey {
    if (kDebugMode) {
      // Development key (you can keep this visible for dev)
      return "AIzaSyC_xVfBVGpI6s371eh5m7zQIxy_s0LEqag";
    } else {
      // Production - get from environment or secure source
      return const String.fromEnvironment(
        'FIREBASE_API_KEY',
        defaultValue:
            'AIzaSyC_xVfBVGpI6s371eh5m7zQIxy_s0LEqag', // Fallback to your key
      );
    }
  }

  static String get firebaseAppId {
    if (kDebugMode) {
      return "1:511012871086:web:3d64951c90d03b7a39463f";
    } else {
      return const String.fromEnvironment(
        'FIREBASE_APP_ID',
        defaultValue: '1:511012871086:web:3d64951c90d03b7a39463f',
      );
    }
  }

  static String get firebaseMessagingSenderId {
    if (kDebugMode) {
      return "511012871086";
    } else {
      return const String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID',
        defaultValue: '511012871086',
      );
    }
  }

  static String get firebaseProjectId {
    if (kDebugMode) {
      return "truested-776cd";
    } else {
      return const String.fromEnvironment(
        'FIREBASE_PROJECT_ID',
        defaultValue: 'truested-776cd',
      );
    }
  }

  // Validation method to ensure all keys are provided
  static bool get isConfigValid {
    return firebaseApiKey.isNotEmpty &&
        firebaseAppId.isNotEmpty &&
        firebaseMessagingSenderId.isNotEmpty &&
        firebaseProjectId.isNotEmpty;
  }

  // Environment detection
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;
}
