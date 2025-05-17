import 'package:trustedtallentsvalley/features/auth/domain/entities/user.dart';
import 'package:trustedtallentsvalley/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing in with email and password
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Execute the login use case
  Future<User> call(String email, String password) async {
    return await repository.signIn(email, password);
  }
}
