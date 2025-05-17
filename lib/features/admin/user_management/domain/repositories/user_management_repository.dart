// lib/features/admin/user_management/domain/repositories/user_management_repository.dart
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/managed_user.dart';

abstract class UserManagementRepository {
  Stream<List<ManagedUser>> getTrustedUsers();
  Stream<List<ManagedUser>> getUntrustedUsers();
  Stream<List<ManagedUser>> getAllUsers();
  Stream<List<String>> getUniqueLocations();

  Future<ManagedUser?> getUserById(String id);
  Future<bool> addUser(ManagedUser user);
  Future<bool> updateUser(ManagedUser user);
  Future<bool> deleteUser(String id);
  Future<int> getTrustedUsersCount();
  Future<int> getUntrustedUsersCount();
}
