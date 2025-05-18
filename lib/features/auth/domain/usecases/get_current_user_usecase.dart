import 'package:trustedtallentsvalley/features/auth/domain/entities/user.dart';
import 'package:trustedtallentsvalley/features/auth/domain/repositories/auth_repository.dart';

/// Use case for getting the current user
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// Execute the get current user use case
  Future<User?> call() async {
    return await repository.getCurrentUser();
  }

  /// Get a stream of auth state changes
  Stream<User?> get authStateChanges => repository.authStateChanges;
}
