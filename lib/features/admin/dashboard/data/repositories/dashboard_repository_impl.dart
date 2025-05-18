// lib/features/admin/dashboard/data/repositories/dashboard_repository_impl.dart
import 'package:trustedtallentsvalley/features/admin/dashboard/data/datasources/analytics_datasource.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/dashboard_stats.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final AnalyticsDatasource _analyticsDatasource;

  DashboardRepositoryImpl({required AnalyticsDatasource analyticsDatasource})
      : _analyticsDatasource = analyticsDatasource;

  @override
  Future<DashboardStats> getAnalyticsData() async {
    try {
      final statsMap = await _analyticsDatasource.getVisitorStats();
      return DashboardStats.fromMap(statsMap);
    } catch (e) {
      throw Exception('Failed to load analytics data: $e');
    }
  }

  @override
  Future<List<ChartDataPoint>> getChartData() async {
    try {
      final chartDataList = await _analyticsDatasource.getVisitorChartData();
      return chartDataList.map((data) => ChartDataPoint.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to load chart data: $e');
    }
  }

  @override
  Future<List<VisitorLocation>> getVisitorLocations() async {
    try {
      final locationDataList =
          await _analyticsDatasource.getVisitorLocationData();
      return locationDataList
          .map((data) => VisitorLocation.fromMap(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to load visitor locations: $e');
    }
  }

  @override
  Future<void> recordVisit() async {
    try {
      await _analyticsDatasource.recordUniqueVisit();
    } catch (e) {
      throw Exception('Failed to record visit: $e');
    }
  }
}
