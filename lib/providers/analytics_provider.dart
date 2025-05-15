// lib/providers/analytics_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/services/visitor_analytics_service.dart';

import '../services/analytics_service.dart';

final visitorAnalyticsProvider = Provider<VisitorAnalyticsService>((ref) {
  return VisitorAnalyticsService();
});

final visitorStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(visitorAnalyticsProvider);
  return service.getVisitorStats();
});

final visitorChartDataProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(visitorAnalyticsProvider);
  return service.getVisitorChartData();
});

// In your providers.dart file

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final analyticsDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getAnalyticsData();
});

final analyticsChartDataProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getChartData();
});
