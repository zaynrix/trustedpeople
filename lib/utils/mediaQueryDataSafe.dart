// Create a file called extensions.dart
import 'package:flutter/material.dart';

extension MediaQueryData on MediaQuery {
  static bool boldTextOverride(BuildContext context) {
    // Return false as a safe default
    return false;
  }
}