// lib/features/admin/dashboard/domain/usecases/get_chart_data_usecase.dart
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/dashboard_stats.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/repositories/dashboard_repository.dart';

class GetChartDataUseCase {
  final DashboardRepository repository;

  GetChartDataUseCase(this.repository);

  Future<List<ChartDataPoint>> execute() async {
    return repository.getChartData();
  }
}
