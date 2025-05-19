import 'package:trustedtallentsvalley/features/admin/payment_places/data/models/admin_payment_place_model.dart';

import '../entities/admin_payment_place.dart';
import '../repositories/admin_payment_places_repository.dart';

class UpdatePaymentPlaceUseCase {
  final AdminPaymentPlacesRepository repository;

  UpdatePaymentPlaceUseCase(this.repository);

  Future<void> call(AdminPaymentPlaceModel place) {
    return repository.updatePaymentPlace(place);
  }
}