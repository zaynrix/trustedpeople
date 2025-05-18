import 'package:trustedtallentsvalley/features/user/data/datasources/user_remote_datasource.dart';
import 'package:trustedtallentsvalley/features/user/data/models/user_model.dart';
import 'package:trustedtallentsvalley/features/user/domain/entities/user.dart';
import 'package:trustedtallentsvalley/features/user/domain/repositories/user_repository.dart';

/// Implementation of the UserRepository
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<User>> getTrustedUsers() {
    return remoteDataSource.getTrustedUsersStream().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<User>> getUntrustedUsers() {
    return remoteDataSource.getUntrustedUsersStream().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Stream<List<User>> getAllUsers() {
    return remoteDataSource.getAllUsersStream().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<User?> getUserById(String id) async {
    final docSnapshot = await remoteDataSource.getUserById(id);
    if (docSnapshot == null || !docSnapshot.exists) {
      return null;
    }
    return UserModel.fromFirestore(docSnapshot);
  }

  @override
  Future<bool> addUser({
    required String aliasName,
    required String mobileNumber,
    required String location,
    required bool isTrusted,
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
  }) {
    final userData = {
      'aliasName': aliasName,
      'mobileNumber': mobileNumber,
      'location': location,
      'isTrusted': isTrusted,
      'servicesProvided': servicesProvided ?? '',
      'telegramAccount': telegramAccount ?? '',
      'otherAccounts': otherAccounts ?? '',
      'reviews': reviews ?? '',
    };

    return remoteDataSource.addUser(userData);
  }

  @override
  Future<bool> updateUser({
    required String id,
    String? aliasName,
    String? mobileNumber,
    String? location,
    bool? isTrusted,
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
  }) {
    final userData = <String, dynamic>{};

    if (aliasName != null) userData['aliasName'] = aliasName;
    if (mobileNumber != null) userData['mobileNumber'] = mobileNumber;
    if (location != null) userData['location'] = location;
    if (isTrusted != null) userData['isTrusted'] = isTrusted;
    if (servicesProvided != null)
      userData['servicesProvided'] = servicesProvided;
    if (telegramAccount != null) userData['telegramAccount'] = telegramAccount;
    if (otherAccounts != null) userData['otherAccounts'] = otherAccounts;
    if (reviews != null) userData['reviews'] = reviews;

    return remoteDataSource.updateUser(id, userData);
  }

  @override
  Future<bool> deleteUser(String id) {
    return remoteDataSource.deleteUser(id);
  }

  @override
  Stream<List<String>> getAllLocations() {
    return remoteDataSource.getLocationsStream().map((snapshot) {
      final locations = snapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['location'] as String? ?? '')
          .where((location) => location.isNotEmpty)
          .toSet()
          .toList();

      locations.sort();
      return locations;
    });
  }
}
