// lib/features/user/payment_places/domain/usecases/crud_payment_place_usecase.dart
import 'package:trustedtallentsvalley/features/user/payment_places/domain/entities/payment_place.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/domain/repositories/payment_places_repository.dart';

class AddPaymentPlaceUseCase {
  final PaymentPlacesRepository repository;

  AddPaymentPlaceUseCase(this.repository);

  Future<bool> execute(PaymentPlace place) {
    return repository.addPaymentPlace(place);
  }
}

class UpdatePaymentPlaceUseCase {
  final PaymentPlacesRepository repository;

  UpdatePaymentPlaceUseCase(this.repository);

  Future<bool> execute(PaymentPlace place) {
    return repository.updatePaymentPlace(place);
  }
}

class DeletePaymentPlaceUseCase {
  final PaymentPlacesRepository repository;

  DeletePaymentPlaceUseCase(this.repository);

  Future<bool> execute(String id) {
    return repository.deletePaymentPlace(id);
  }
}
