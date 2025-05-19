import '../repositories/admin_payment_places_repository.dart';

class ExportPlacesToExcelUseCase {
  final AdminPaymentPlacesRepository repository;

  ExportPlacesToExcelUseCase(this.repository);

  Future<String> call() {
    return repository.exportPlacesToExcel();
  }
}