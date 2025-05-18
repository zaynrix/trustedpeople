import 'package:trustedtallentsvalley/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:trustedtallentsvalley/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:trustedtallentsvalley/features/auth/domain/entities/user.dart';
import 'package:trustedtallentsvalley/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of the AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<User?> getCurrentUser() async {
    try {
      // First try to get the user from remote source
      final remoteUser = await _remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        // Cache the user data
        await _localDataSource.saveUser(remoteUser);
        return remoteUser;
      }

      // If remote fails, try to get from local cache
      return await _localDataSource.getUser();
    } catch (e) {
      // If both fail, return null (unauthenticated)
      return null;
    }
  }

  @override
  Future<User> signIn(String email, String password) async {
    final user = await _remoteDataSource.signIn(email, password);
    // Cache the user data
    await _localDataSource.saveUser(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
    await _localDataSource.clearUser();
  }

  @override
  Future<bool> isUserAdmin(String uid) async {
    return await _remoteDataSource.isUserAdmin(uid);
  }

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;
}
