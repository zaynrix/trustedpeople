import '../../domain/entities/admin_payment_place.dart';
import '../../domain/repositories/admin_payment_places_repository.dart';
import '../datasources/admin_payment_places_remote_datasource.dart';
import '../models/admin_payment_place_model.dart';

class AdminPaymentPlacesRepositoryImpl implements AdminPaymentPlacesRepository {
  final AdminPaymentPlacesRemoteDataSource _dataSource;

  AdminPaymentPlacesRepositoryImpl(this._dataSource);

  @override
  Stream<List<AdminPaymentPlace>> getPaymentPlaces() {
    return _dataSource.getPaymentPlaces();
  }

  @override
  Future<AdminPaymentPlace?> getPaymentPlaceById(String id) {
    return _dataSource.getPaymentPlaceById(id);
  }

  @override
  Stream<List<String>> getCategories() {
    return _dataSource.getCategories();
  }

  @override
  Stream<List<String>> getLocations() {
    return _dataSource.getLocations();
  }

  @override
  Future<String> addPaymentPlace(AdminPaymentPlace place) {
    final model = AdminPaymentPlaceModel.fromEntity(place);
    return _dataSource.addPaymentPlace(model);
  }

  @override
  Future<void> updatePaymentPlace(AdminPaymentPlace place) {
    final model = AdminPaymentPlaceModel.fromEntity(place);
    return _dataSource.updatePaymentPlace(model);
  }

  @override
  Future<void> deletePaymentPlace(String id) {
    return _dataSource.deletePaymentPlace(id);
  }

  @override
  Future<void> updateVerificationStatus(String id, bool isVerified) {
    return _dataSource.updateVerificationStatus(id, isVerified);
  }

  @override
  Future<String> exportPlacesToCSV() {
    return _dataSource.exportPlacesToCSV();
  }

  @override
  Future<String> exportPlacesToExcel() {
    return _dataSource.exportPlacesToExcel();
  }
}