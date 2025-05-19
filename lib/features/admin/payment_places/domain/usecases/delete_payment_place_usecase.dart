import '../repositories/admin_payment_places_repository.dart';

class DeletePaymentPlaceUseCase {
  final AdminPaymentPlacesRepository repository;

  DeletePaymentPlaceUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deletePaymentPlace(id);
  }
}
