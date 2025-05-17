// lib/features/admin/dashboard/presentation/providers/dashboard_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/data/datasources/analytics_datasource.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/dashboard_stats.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/usecases/get_analytics_data_usecase.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/usecases/get_chart_data_usecase.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/usecases/get_visitor_locations_usecase.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/usecases/record_visit_usecase.dart';

// Firestore provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Datasource provider
final analyticsDatasourceProvider = Provider<AnalyticsDatasource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return AnalyticsDatasource(firestore: firestore);
});

// Repository provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final datasource = ref.watch(analyticsDatasourceProvider);
  return DashboardRepositoryImpl(analyticsDatasource: datasource);
});

// Use cases providers
final getAnalyticsDataUseCaseProvider =
    Provider<GetAnalyticsDataUseCase>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetAnalyticsDataUseCase(repository);
});

final getChartDataUseCaseProvider = Provider<GetChartDataUseCase>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetChartDataUseCase(repository);
});

final getVisitorLocationsUseCaseProvider =
    Provider<GetVisitorLocationsUseCase>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetVisitorLocationsUseCase(repository);
});

final recordVisitUseCaseProvider = Provider<RecordVisitUseCase>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return RecordVisitUseCase(repository);
});

// Data providers
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final useCase = ref.watch(getAnalyticsDataUseCaseProvider);
  return useCase.execute();
});

final chartDataProvider = FutureProvider<List<ChartDataPoint>>((ref) async {
  final useCase = ref.watch(getChartDataUseCaseProvider);
  return useCase.execute();
});

final visitorLocationsProvider =
    FutureProvider<List<VisitorLocation>>((ref) async {
  final useCase = ref.watch(getVisitorLocationsUseCaseProvider);
  return useCase.execute();
});

// Record visit function - call this at app startup
final recordVisitProvider = Provider<Future<void> Function()>((ref) {
  final useCase = ref.watch(recordVisitUseCaseProvider);
  return () => useCase.execute();
});

// Loading state provider
final isLoadingProvider = StateProvider<bool>((ref) => false);
