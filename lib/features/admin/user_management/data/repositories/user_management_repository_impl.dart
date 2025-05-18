// lib/features/admin/user_management/data/repositories/user_management_repository_impl.dart
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/managed_user.dart';
import 'package:trustedtallentsvalley/features/admin/user_management/data/datasources/user_management_remote_datasource.dart';
import 'package:trustedtallentsvalley/features/admin/user_management/domain/repositories/user_management_repository.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementRemoteDatasource _remoteDatasource;

  UserManagementRepositoryImpl(
      {required UserManagementRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Stream<List<ManagedUser>> getTrustedUsers() {
    return _remoteDatasource.getTrustedUsersStream();
  }

  @override
  Stream<List<ManagedUser>> getUntrustedUsers() {
    return _remoteDatasource.getUntrustedUsersStream();
  }

  @override
  Stream<List<ManagedUser>> getAllUsers() {
    return _remoteDatasource.getAllUsersStream();
  }

  @override
  Stream<List<String>> getUniqueLocations() {
    return _remoteDatasource.getUniqueLocationsStream();
  }

  @override
  Future<ManagedUser?> getUserById(String id) async {
    return _remoteDatasource.getUserById(id);
  }

  @override
  Future<bool> addUser(ManagedUser user) async {
    return _remoteDatasource.addUser(user);
  }

  @override
  Future<bool> updateUser(ManagedUser user) async {
    return _remoteDatasource.updateUser(user);
  }

  @override
  Future<bool> deleteUser(String id) async {
    return _remoteDatasource.deleteUser(id);
  }

  @override
  Future<int> getTrustedUsersCount() async {
    return _remoteDatasource.getTrustedUsersCount();
  }

  @override
  Future<int> getUntrustedUsersCount() async {
    return _remoteDatasource.getUntrustedUsersCount();
  }
}
