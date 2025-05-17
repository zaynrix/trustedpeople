// lib/features/user/payment_places/domain/usecases/get_payment_places_usecase.dart
import 'package:trustedtallentsvalley/features/user/payment_places/domain/entities/payment_place.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/domain/repositories/payment_places_repository.dart';

class GetAllPaymentPlacesUseCase {
  final PaymentPlacesRepository repository;

  GetAllPaymentPlacesUseCase(this.repository);

  Stream<List<PaymentPlace>> execute() {
    return repository.getAllPaymentPlaces();
  }
}
