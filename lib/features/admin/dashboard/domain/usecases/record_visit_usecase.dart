// lib/features/admin/dashboard/domain/usecases/record_visit_usecase.dart
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/repositories/dashboard_repository.dart';

class RecordVisitUseCase {
  final DashboardRepository repository;

  RecordVisitUseCase(this.repository);

  Future<void> execute() async {
    return repository.recordVisit();
  }
}
