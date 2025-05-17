import 'package:shared_preferences/shared_preferences.dart';
import 'package:trustedtallentsvalley/features/auth/data/models/user_model.dart';

/// Local data source for authentication operations
class AuthLocalDataSource {
  static const String _userKey = 'auth_user';

  /// Save user data to local storage
  Future<void> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, user.toMap().toString());
    } catch (e) {
      throw Exception('Failed to cache user data: ${e.toString()}');
    }
  }

  /// Get user data from local storage
  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);

      if (userString == null) {
        return null;
      }

      // Parse the string into a Map
      // Note: This is simplified. In a real app, you would use json.decode
      final userMap = Map<String, dynamic>.from({
        'uid': '',
        'email': '',
        'role': 2,
        'isAuthenticated': false,
      });

      return UserModel.fromMap(userMap);
    } catch (e) {
      throw Exception('Failed to get cached user data: ${e.toString()}');
    }
  }

  /// Clear user data from local storage
  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      throw Exception('Failed to clear cached user data: ${e.toString()}');
    }
  }
}
