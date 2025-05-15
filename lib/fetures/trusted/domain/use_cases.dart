import 'package:trustedtallentsvalley/fetures/trusted/domain/user_entity.dart';
import 'package:trustedtallentsvalley/fetures/trusted/domain/user_repository.dart';

class GetTrustedUsers {
  final UserRepository repository;

  GetTrustedUsers(this.repository);

  Stream<List<User>> call() => repository.getTrustedUsers();
}

class GetUntrustedUsers {
  final UserRepository repository;

  GetUntrustedUsers(this.repository);

  Stream<List<User>> call() => repository.getUntrustedUsers();
}

class GetAllUsers {
  final UserRepository repository;

  GetAllUsers(this.repository);

  Stream<List<User>> call() => repository.getAllUsers();
}

class GetLocations {
  final UserRepository repository;

  GetLocations(this.repository);

  Stream<List<String>> call() => repository.getLocations();
}

class AddUser {
  final UserRepository repository;

  AddUser(this.repository);

  Future<void> call(User user) => repository.addUser(user);
}

class UpdateUser {
  final UserRepository repository;

  UpdateUser(this.repository);

  Future<void> call(User user) => repository.updateUser(user);
}

class DeleteUser {
  final UserRepository repository;

  DeleteUser(this.repository);

  Future<void> call(String id) => repository.deleteUser(id);
}