import 'package:trustedtallentsvalley/features/admin/payment_places/data/models/admin_payment_place_model.dart';
import '../repositories/admin_payment_places_repository.dart';

class AddPaymentPlaceUseCase {
  final AdminPaymentPlacesRepository repository;

  AddPaymentPlaceUseCase(this.repository);

  Future<String> call(AdminPaymentPlaceModel place) {
    return repository.addPaymentPlace(place);
  }
}