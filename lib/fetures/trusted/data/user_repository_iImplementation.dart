import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trustedtallentsvalley/fetures/trusted/data/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/data/user_remote_data_source.dart';
import 'package:trustedtallentsvalley/fetures/trusted/domain/user_entity.dart';
import 'package:trustedtallentsvalley/fetures/trusted/domain/user_repository.dart';
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource dataSource;

  UserRepositoryImpl({required this.dataSource});

  @override
  Stream<List<User>> getTrustedUsers() => dataSource.getTrustedUsers();

  @override
  Stream<List<User>> getUntrustedUsers() => dataSource.getUntrustedUsers();

  @override
  Stream<List<User>> getAllUsers() => dataSource.getAllUsers();

  @override
  Stream<List<String>> getLocations() => dataSource.getLocations();

  @override
  Future<void> addUser(User user) async {
    final userModel = UserModel(
      id: user.id,
      aliasName: user.aliasName,
      mobileNumber: user.mobileNumber,
      location: user.location,
      isTrusted: user.isTrusted,
      servicesProvided: user.servicesProvided,
      telegramAccount: user.telegramAccount,
      otherAccounts: user.otherAccounts,
      reviews: user.reviews,
    );

    await dataSource.addUser(userModel);
  }

  @override
  Future<void> updateUser(User user) async {
    final userModel = UserModel(
      id: user.id,
      aliasName: user.aliasName,
      mobileNumber: user.mobileNumber,
      location: user.location,
      isTrusted: user.isTrusted,
      servicesProvided: user.servicesProvided,
      telegramAccount: user.telegramAccount,
      otherAccounts: user.otherAccounts,
      reviews: user.reviews,
    );

    await dataSource.updateUser(userModel);
  }

  @override
  Future<void> deleteUser(String id) async {
    await dataSource.deleteUser(id);
  }
}