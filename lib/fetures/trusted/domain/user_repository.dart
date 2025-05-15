import 'package:trustedtallentsvalley/fetures/trusted/domain/user_entity.dart';

abstract class UserRepository {
  Stream<List<User>> getTrustedUsers();
  Stream<List<User>> getUntrustedUsers();
  Stream<List<User>> getAllUsers();
  Stream<List<String>> getLocations();

  Future<void> addUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String id);
}