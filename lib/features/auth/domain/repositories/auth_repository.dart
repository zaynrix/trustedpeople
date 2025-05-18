import 'package:trustedtallentsvalley/features/auth/domain/entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Get the currently logged in user or null if not authenticated
  Future<User?> getCurrentUser();

  /// Sign in with email and password
  Future<User> signIn(String email, String password);

  /// Sign out the current user
  Future<void> signOut();

  /// Check if the current user is an admin
  Future<bool> isUserAdmin(String uid);

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
}
