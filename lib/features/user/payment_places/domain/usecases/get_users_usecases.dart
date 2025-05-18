import 'package:trustedtallentsvalley/features/user/payment_places/domain/repositories/user_repository.dart';

import '../../../../auth/domain/entities/user.dart';

/// Use case for getting all trusted users
class GetTrustedUsersUseCase {
  final UserRepository repository;

  GetTrustedUsersUseCase(this.repository);

  Stream<List<User>> call() {
    return repository.getTrustedUsers();
  }
}

/// Use case for getting all untrusted users
class GetUntrustedUsersUseCase {
  final UserRepository repository;

  GetUntrustedUsersUseCase(this.repository);

  Stream<List<User>> call() {
    return repository.getUntrustedUsers();
  }
}

/// Use case for getting all users
class GetAllUsersUseCase {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  Stream<List<User>> call() {
    return repository.getAllUsers();
  }
}

/// Use case for getting a user by ID
class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<User?> call(String id) {
    return repository.getUserById(id);
  }
}
