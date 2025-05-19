import '../entities/admin_payment_place.dart';
import '../repositories/admin_payment_places_repository.dart';

class GetAdminPaymentPlacesUseCase {
  final AdminPaymentPlacesRepository repository;

  GetAdminPaymentPlacesUseCase(this.repository);

  Stream<List<AdminPaymentPlace>> call() {
    return repository.getPaymentPlaces();
  }
}