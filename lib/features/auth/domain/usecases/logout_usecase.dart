import 'package:trustedtallentsvalley/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing out
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Execute the logout use case
  Future<void> call() async {
    return await repository.signOut();
  }
}
