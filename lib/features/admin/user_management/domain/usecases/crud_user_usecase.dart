// lib/features/admin/user_management/domain/usecases/crud_user_usecase.dart
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/managed_user.dart';
import 'package:trustedtallentsvalley/features/admin/user_management/domain/repositories/user_management_repository.dart';

class AddUserUseCase {
  final UserManagementRepository repository;

  AddUserUseCase(this.repository);

  Future<bool> execute(ManagedUser user) {
    return repository.addUser(user);
  }
}

class UpdateUserUseCase {
  final UserManagementRepository repository;

  UpdateUserUseCase(this.repository);

  Future<bool> execute(ManagedUser user) {
    return repository.updateUser(user);
  }
}

class DeleteUserUseCase {
  final UserManagementRepository repository;

  DeleteUserUseCase(this.repository);

  Future<bool> execute(String id) {
    return repository.deleteUser(id);
  }
}

class GetUserByIdUseCase {
  final UserManagementRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<ManagedUser?> execute(String id) {
    return repository.getUserById(id);
  }
}
