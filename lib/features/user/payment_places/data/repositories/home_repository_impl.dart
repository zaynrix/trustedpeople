// lib/features/user/payment_places/data/repositories/payment_places_repository_impl.dart
import 'package:trustedtallentsvalley/features/user/payment_places/data/datasources/payment_places_remote_datasource.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/domain/entities/payment_place.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/domain/repositories/payment_places_repository.dart';

class PaymentPlacesRepositoryImpl implements PaymentPlacesRepository {
  final PaymentPlacesRemoteDatasource _remoteDatasource;

  PaymentPlacesRepositoryImpl(
      {required PaymentPlacesRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Stream<List<PaymentPlace>> getAllPaymentPlaces() {
    return _remoteDatasource.getAllPaymentPlacesStream();
  }

  @override
  Stream<List<String>> getUniqueCategories() {
    return _remoteDatasource.getUniqueCategoriesStream();
  }

  @override
  Stream<List<String>> getUniqueLocations() {
    return _remoteDatasource.getUniqueLocationsStream();
  }

  @override
  Future<PaymentPlace?> getPaymentPlaceById(String id) async {
    return _remoteDatasource.getPaymentPlaceById(id);
  }

  @override
  Future<bool> addPaymentPlace(PaymentPlace place) async {
    return _remoteDatasource.addPaymentPlace(place);
  }

  @override
  Future<bool> updatePaymentPlace(PaymentPlace place) async {
    return _remoteDatasource.updatePaymentPlace(place);
  }

  @override
  Future<bool> deletePaymentPlace(String id) async {
    return _remoteDatasource.deletePaymentPlace(id);
  }
}
