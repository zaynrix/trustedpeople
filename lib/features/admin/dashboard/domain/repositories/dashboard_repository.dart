// lib/features/admin/dashboard/domain/repositories/dashboard_repository.dart
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getAnalyticsData();
  Future<List<ChartDataPoint>> getChartData();
  Future<List<VisitorLocation>> getVisitorLocations();
  Future<void> recordVisit();
}
