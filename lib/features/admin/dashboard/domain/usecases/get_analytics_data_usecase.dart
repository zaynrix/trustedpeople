// lib/features/admin/dashboard/domain/usecases/get_analytics_data_usecase.dart
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/dashboard_stats.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/repositories/dashboard_repository.dart';

class GetAnalyticsDataUseCase {
  final DashboardRepository repository;

  GetAnalyticsDataUseCase(this.repository);

  Future<DashboardStats> execute() async {
    return repository.getAnalyticsData();
  }
}
