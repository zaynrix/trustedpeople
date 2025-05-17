// lib/features/admin/user_management/domain/usecases/get_untrusted_users_usecase.dart
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/managed_user.dart';
import 'package:trustedtallentsvalley/features/admin/user_management/domain/repositories/user_management_repository.dart';

class GetUntrustedUsersUseCase {
  final UserManagementRepository repository;

  GetUntrustedUsersUseCase(this.repository);

  Stream<List<ManagedUser>> execute() {
    return repository.getUntrustedUsers();
  }
}
