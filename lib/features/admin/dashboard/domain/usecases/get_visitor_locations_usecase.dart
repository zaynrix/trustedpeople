// lib/features/admin/dashboard/domain/usecases/get_visitor_locations_usecase.dart
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/dashboard_stats.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/repositories/dashboard_repository.dart';

class GetVisitorLocationsUseCase {
  final DashboardRepository repository;

  GetVisitorLocationsUseCase(this.repository);

  Future<List<VisitorLocation>> execute() async {
    return repository.getVisitorLocations();
  }
}
