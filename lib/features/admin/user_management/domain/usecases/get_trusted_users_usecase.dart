// lib/features/admin/user_management/domain/usecases/get_trusted_users_usecase.dart
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/managed_user.dart';
import 'package:trustedtallentsvalley/features/admin/user_management/domain/repositories/user_management_repository.dart';

class GetTrustedUsersUseCase {
  final UserManagementRepository repository;

  GetTrustedUsersUseCase(this.repository);

  Stream<List<ManagedUser>> execute() {
    return repository.getTrustedUsers();
  }
}
