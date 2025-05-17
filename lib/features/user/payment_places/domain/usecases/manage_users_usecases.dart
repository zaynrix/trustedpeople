import 'package:trustedtallentsvalley/features/user/payment_places/domain/repositories/user_repository.dart';

/// Use case for adding a new user
class AddUserUseCase {
  final UserRepository repository;

  AddUserUseCase(this.repository);

  Future<bool> call({
    required String aliasName,
    required String mobileNumber,
    required String location,
    required bool isTrusted,
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
  }) {
    return repository.addUser(
      aliasName: aliasName,
      mobileNumber: mobileNumber,
      location: location,
      isTrusted: isTrusted,
      servicesProvided: servicesProvided,
      telegramAccount: telegramAccount,
      otherAccounts: otherAccounts,
      reviews: reviews,
    );
  }
}

/// Use case for updating an existing user
class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  Future<bool> call({
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
    return repository.updateUser(
      id: id,
      aliasName: aliasName,
      mobileNumber: mobileNumber,
      location: location,
      isTrusted: isTrusted,
      servicesProvided: servicesProvided,
      telegramAccount: telegramAccount,
      otherAccounts: otherAccounts,
      reviews: reviews,
    );
  }
}

/// Use case for deleting a user
class DeleteUserUseCase {
  final UserRepository repository;

  DeleteUserUseCase(this.repository);

  Future<bool> call(String id) {
    return repository.deleteUser(id);
  }
}

/// Use case for getting all locations
class GetLocationsUseCase {
  final UserRepository repository;

  GetLocationsUseCase(this.repository);

  Stream<List<String>> call() {
    return repository.getAllLocations();
  }
}
