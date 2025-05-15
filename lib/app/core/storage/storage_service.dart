import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing local storage with Hive
class StorageService {
  /// Initialize the storage service
  static Future<void> init() async {
    await Hive.initFlutter();

    // Open the necessary boxes during initialization
    // This improves performance by pre-loading the boxes
    await _openThemeBox();

    // Register other boxes here if needed
  }

  /// Open the theme box
  static Future<Box> _openThemeBox() async {
    const String themeBoxName = 'theme_box';
    if (Hive.isBoxOpen(themeBoxName)) {
      return Hive.box(themeBoxName);
    }
    return await Hive.openBox(themeBoxName);
  }

  /// Close all boxes when app is terminated
  static Future<void> dispose() async {
    await Hive.close();
  }

  /// Clear all data (useful for logout or reset)
  static Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }
}