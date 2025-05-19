import '../repositories/admin_payment_places_repository.dart';

class GetLocationsUseCase {
  final AdminPaymentPlacesRepository repository;

  GetLocationsUseCase(this.repository);

  Stream<List<String>> call() {
    return repository.getLocations();
  }
}