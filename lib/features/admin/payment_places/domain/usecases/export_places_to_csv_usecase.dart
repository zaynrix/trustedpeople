import '../repositories/admin_payment_places_repository.dart';

class ExportPlacesToCSVUseCase {
  final AdminPaymentPlacesRepository repository;

  ExportPlacesToCSVUseCase(this.repository);

  Future<String> call() {
    return repository.exportPlacesToCSV();
  }
}