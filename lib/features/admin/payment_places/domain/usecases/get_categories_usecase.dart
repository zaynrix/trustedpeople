import '../repositories/admin_payment_places_repository.dart';

class GetCategoriesUseCase {
  final AdminPaymentPlacesRepository repository;

  GetCategoriesUseCase(this.repository);

  Stream<List<String>> call() {
    return repository.getCategories();
  }
}