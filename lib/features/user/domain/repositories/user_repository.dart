import 'package:trustedtallentsvalley/features/user/domain/entities/user.dart';

/// Repository interface for user management
abstract class UserRepository {
  /// Get all trusted users
  Stream<List<User>> getTrustedUsers();

  /// Get all untrusted users
  Stream<List<User>> getUntrustedUsers();

  /// Get all users
  Stream<List<User>> getAllUsers();

  /// Get user by ID
  Future<User?> getUserById(String id);

  /// Add a new user
  Future<bool> addUser({
    required String aliasName,
    required String mobileNumber,
    required String location,
    required bool isTrusted,
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
  });

  /// Update an existing user
  Future<bool> updateUser({
    required String id,
    String? aliasName,
    String? mobileNumber,
    String? location,
    bool? isTrusted,
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
  });

  /// Delete a user
  Future<bool> deleteUser(String id);

  /// Get all unique locations
  Stream<List<String>> getAllLocations();
}
