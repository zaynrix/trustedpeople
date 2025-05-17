// lib/features/user/payment_places/domain/usecases/get_categories_usecase.dart
import 'package:trustedtallentsvalley/features/user/payment_places/domain/repositories/payment_places_repository.dart';

class GetUniqueCategoriesUseCase {
  final PaymentPlacesRepository repository;

  GetUniqueCategoriesUseCase(this.repository);

  Stream<List<String>> execute() {
    return repository.getUniqueCategories();
  }
}
