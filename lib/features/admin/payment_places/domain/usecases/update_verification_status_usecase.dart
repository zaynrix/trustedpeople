import '../repositories/admin_payment_places_repository.dart';

class UpdateVerificationStatusUseCase {
  final AdminPaymentPlacesRepository repository;

  UpdateVerificationStatusUseCase(this.repository);

  Future<void> call(String id, bool isVerified) {
    return repository.updateVerificationStatus(id, isVerified);
  }
}