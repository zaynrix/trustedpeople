// lib/features/user/payment_places/domain/repositories/payment_places_repository.dart
import 'package:trustedtallentsvalley/features/user/payment_places/domain/entities/payment_place.dart';

abstract class PaymentPlacesRepository {
  Stream<List<PaymentPlace>> getAllPaymentPlaces();
  Stream<List<String>> getUniqueCategories();
  Stream<List<String>> getUniqueLocations();
  Future<PaymentPlace?> getPaymentPlaceById(String id);
  Future<bool> addPaymentPlace(PaymentPlace place);
  Future<bool> updatePaymentPlace(PaymentPlace place);
  Future<bool> deletePaymentPlace(String id);
}
