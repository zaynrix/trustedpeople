import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/features/user/data/datasources/user_remote_datasource.dart';
import 'package:trustedtallentsvalley/features/user/data/repositories/user_repository_impl.dart';
import 'package:trustedtallentsvalley/features/user/domain/entities/user.dart';
import 'package:trustedtallentsvalley/features/user/domain/repositories/user_repository.dart';
import 'package:trustedtallentsvalley/features/user/domain/usecases/get_users_usecases.dart';
import 'package:trustedtallentsvalley/features/user/domain/usecases/manage_users_usecases.dart';

/// Provider for FirebaseFirestore instance
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for UserRemoteDataSource
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return UserRemoteDataSource(firestore);
});

/// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource);
});

/// Provider for GetTrustedUsersUseCase
final getTrustedUsersUseCaseProvider = Provider<GetTrustedUsersUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetTrustedUsersUseCase(repository);
});

/// Provider for GetUntrustedUsersUseCase
final getUntrustedUsersUseCaseProvider =
    Provider<GetUntrustedUsersUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUntrustedUsersUseCase(repository);
});

/// Provider for GetAllUsersUseCase
final getAllUsersUseCaseProvider = Provider<GetAllUsersUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetAllUsersUseCase(repository);
});

/// Provider for GetUserByIdUseCase
final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserByIdUseCase(repository);
});

/// Provider for AddUserUseCase
final addUserUseCaseProvider = Provider<AddUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return AddUserUseCase(repository);
});

/// Provider for UpdateUserUseCase
final updateUserUseCaseProvider = Provider<UpdateUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateUserUseCase(repository);
});

/// Provider for DeleteUserUseCase
final deleteUserUseCaseProvider = Provider<DeleteUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return DeleteUserUseCase(repository);
});

/// Provider for GetLocationsUseCase
final getLocationsUseCaseProvider = Provider<GetLocationsUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetLocationsUseCase(repository);
});

/// Stream provider for trusted users
final trustedUsersStreamProvider = StreamProvider<List<User>>((ref) {
  final useCase = ref.watch(getTrustedUsersUseCaseProvider);
  return useCase();
});

/// Stream provider for untrusted users
final untrustedUsersStreamProvider = StreamProvider<List<User>>((ref) {
  final useCase = ref.watch(getUntrustedUsersUseCaseProvider);
  return useCase();
});

/// Stream provider for all users
final allUsersStreamProvider = StreamProvider<List<User>>((ref) {
  final useCase = ref.watch(getAllUsersUseCaseProvider);
  return useCase();
});

/// Stream provider for all locations
final locationsStreamProvider = StreamProvider<List<String>>((ref) {
  final useCase = ref.watch(getLocationsUseCaseProvider);
  return useCase();
});
